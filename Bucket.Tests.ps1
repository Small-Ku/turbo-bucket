if (-not ($env:SCOOP_HOME)) { $env:SCOOP_HOME = shovel prefix scoop | Resolve-Path }

BeforeDiscovery {
	$script:root = $PSScriptRoot
	$script:trackedFiles = @(git -C $PSScriptRoot ls-files -z --cached --exclude-standard | Out-String).Split([char]0, [StringSplitOptions]::RemoveEmptyEntries) |
		ForEach-Object { Join-Path $PSScriptRoot $_ } |
		Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } |
		Where-Object { $_ -inotmatch '\.(exe|zip|dll|png|jpe?g|gif|ico|7z|pack)$' }
	$script:manifestFiles = @($script:trackedFiles | Where-Object { $_ -imatch '[\\/]bucket[\\/][^\\/]+\.json$' })
}

Describe 'Manifest validates against the schema' {
	BeforeAll {
		Add-Type -Path "$env:SCOOP_HOME\supporting\validator\bin\Scoop.Validator.dll"
		$validator = New-Object Scoop.Validator("$PSScriptRoot/schema.json", $true)
	}
	It '<_>' -TestCases $manifestFiles {
		$file = $_
		$validator.Validate($file)
		if ($validator.Errors.Count -gt 0) {
			Write-Host "  [-] $file has $($validator.Errors.Count) Error$(if ($validator.Errors.Count -gt 1) { 's' })!" -ForegroundColor Red
			Write-Host $validator.ErrorsAsString -ForegroundColor Yellow
		}
		$validator.Errors.Count | Should -Be 0
	}
}

Describe 'Style constraints for git-tracked text files' {
	BeforeAll {
		$files = @($trackedFiles)
	}

	It 'files do not contain leading UTF-8 BOM' {
		$badFiles = @(foreach ($file in $files) {
				$head = [byte[]](Get-Content -LiteralPath $file -AsByteStream -TotalCount 3)
				if ($head.Count -eq 3 -and $head[0] -eq 0xEF -and $head[1] -eq 0xBB -and $head[2] -eq 0xBF) { $file }
			})
		if ($badFiles.Count -gt 0) { throw "The following files have utf-8 BOM: `r`n`r`n$($badFiles -join "`r`n")" }
	}

	It 'files end with a newline' {
		$badFiles = @(foreach ($file in $files) {
				$string = [System.IO.File]::ReadAllText($file)
				if ($string.Length -gt 0 -and $string[-1] -ne "`n") { $file }
			})
		if ($badFiles.Count -gt 0) { throw "The following files do not end with a newline: `r`n`r`n$($badFiles -join "`r`n")" }
	}

	It 'file newlines are CRLF' {
		$badFiles = @(foreach ($file in $files) {
				if ($file -imatch '\.ya?ml$') { continue }
				$content = [System.IO.File]::ReadAllText($file)
				if ($content -match '(?<!\r)\n|\r(?!\n)') { $file }
			})
		if ($badFiles.Count -gt 0) { throw "The following files have non-CRLF line endings: `r`n`r`n$($badFiles -join "`r`n")" }
	}

	It 'files have no lines containing trailing whitespace' {
		$badLines = @(foreach ($file in $files) {
				$lines = [System.IO.File]::ReadAllLines($file)
				for ($i = 0; $i -lt $lines.Count; $i++) {
					if ($lines[$i] -match '\s+$') { 'File: {0}, Line: {1}' -f $file, ($i + 1) }
				}
			})
		if ($badLines.Count -gt 0) { throw "The following $($badLines.Count) lines contain trailing whitespace: `r`n`r`n$($badLines -join "`r`n")" }
	}
	It 'indentation uses tabs instead of spaces (excepting markdown, yaml and makefiles)' {
		$badLines = @(foreach ($file in $files) {
				if ($file -imatch '\.(md|ya?ml)$' -or $file -imatch '(^|[\\/.])makefile$') { continue }
				$lines = [System.IO.File]::ReadAllLines($file)
				for ($i = 0; $i -lt $lines.Count; $i++) {
					if ($lines[$i] -match '^\t* +\S') { 'File: {0}, Line: {1}' -f $file, ($i + 1) }
				}
			})
		if ($badLines.Count -gt 0) { throw "The following $($badLines.Count) lines are indented with spaces: `r`n`r`n$($badLines -join "`r`n")" }
	}
}

Describe 'PowerShell syntax' {
	It 'PowerShell code files do not contain syntax errors' {
		$badFiles = @(foreach ($file in ($trackedFiles | Where-Object { $_ -imatch '\.(ps1|psm1)$' })) {
				$errors = $null
				$null = [System.Management.Automation.Language.Parser]::ParseFile($file, [ref]$null, [ref]$errors)
				if ($errors.Count -gt 0) { $file }
			})
		if ($badFiles.Count -gt 0) { throw "The following files have syntax errors: `r`n`r`n$($badFiles -join "`r`n")" }
	}
}
