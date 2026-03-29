# Agents

This document provides context for AI agents working with the Turbo Bucket repository.

## Overview

**Turbo Bucket** is a [Scoop](https://scoop.sh) bucket for Windows package management. It contains applications that the maintainer uses personally.

- **Repository**: https://github.com/Small-Ku/turbo-bucket
- **Installation**: `scoop bucket add turbo 'https://github.com/Small-Ku/turbo-bucket.git'`
- **Usage**: `scoop install turbo/<app_name>`

## Bucket Structure

```
├── bucket/                  # App manifests (JSON files)
├── scripts/                 # Helper scripts
│   └── Get-ArchivePath.ps1  # Extract ZIP directory without downloading
├── .github/workflows/       # CI/CD pipelines
│   ├── pull_request.yml     # PR validation
│   └── biome-filter.yml     # JSON formatting checks
├── Bucket.Tests.ps1         # Test runner
├── biome.json               # Code formatting config
└── README.md                # User-facing documentation
```

## Adding New Apps

### 1. Create a Manifest

Add a new JSON file in `bucket/<app-name>.json` following the Scoop manifest format.

#### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `version` | string | App version (e.g., `"1.0.0"`) |
| `description` | string | Brief app description |
| `homepage` | string | Project URL |
| `license` | string or object | License identifier or `{identifier, url}` |
| `url` | string | Download URL (typically from GitHub releases) |
| `hash` | string | SHA256 hash of the download |

#### Optional Fields

| Field | Type | Description |
|-------|------|-------------|
| `shortcuts` | array | Start menu shortcuts `[["exe", "Name"]]` |
| `bin` | array | CLI executables `[["path\\to\\exe", "command_name"]]` |
| `depends` | array | Dependencies (e.g., `["pnpm", "nodejs"]`) |
| `architecture` | object | Per-architecture URLs/hashes (`64bit`, `arm64`) |
| `extract_dir` | string | Directory to extract after download |
| `pre_install` | array | PowerShell scripts to run before installation |
| `post_install` | array | PowerShell scripts to run after installation |
| `pre_uninstall` | array | PowerShell scripts before uninstall |
| `persist` | array or string | Files/directories to persist across updates |
| `notes` | string | Additional user information |
| `checkver` | object or string | Update checker configuration |
| `autoupdate` | object | Auto-update instructions |
| `installer` | object | Custom installer script (used with package managers like pnpm) |
| `post_uninstall` | string or array | Scripts to run after uninstall |

### 2. Manifest Examples

#### Simple GUI App (GitHub Releases)
```json
{
  "version": "1.7.2",
  "description": "App description here",
  "homepage": "https://github.com/user/repo",
  "license": "MIT",
  "url": "https://github.com/user/repo/releases/download/v1.7.2/App-x86_64-Portable.zip",
  "hash": "sha256-hash-here",
  "shortcuts": [["App.exe", "App Name"]],
  "checkver": "github",
  "autoupdate": {
    "url": "https://github.com/user/repo/releases/download/v$version/App-x86_64-Portable.zip"
  }
}
```

#### Multi-Architecture App
Scoop automatically detects the system architecture and uses the appropriate URL:
```json
{
	"version": "0.2.12",
	"description": "A JPEG XL (*.jxl) thumbnail handler for Windows File Explorer.",
	"homepage": "https://github.com/saschanaz/jxl-winthumb",
	"license": "ISC",
	"architecture": {
		"arm64": {
			"url": "https://github.com/saschanaz/jxl-winthumb/releases/download/v0.2.12/jxl_winthumb_aarch64.dll",
			"hash": "cc30724fb82d2aea0bc00313d5dc6c48885868a3a8ed1251ceddab6418c709e3"
		},
		"64bit": {
			"url": "https://github.com/saschanaz/jxl-winthumb/releases/download/v0.2.12/jxl_winthumb_x86_64.dll",
			"hash": "7416c3134277e7f108eaa73db3652ea8b083c6a5b4623c19962aa0b455ffeb5e"
		},
		"32bit": {
			"url": "https://github.com/saschanaz/jxl-winthumb/releases/download/v0.2.12/jxl_winthumb_i686.dll",
			"hash": "736014058987eed28a6fa622ffd4ab532e243fc73afd74267f44836bf5dd5bb0"
		}
	},
  "checkver": { "script": "...", "regex": "..." },
  "autoupdate": { "architecture": { "64bit": { ... }, "arm64": { ... } } }
}
```

#### CLI App with Dependencies
```json
{
  "version": "1.0.634",
  "description": "The world's strongest free coding agent",
  "homepage": "https://codebuff.com/",
  "license": "Apache-2.0",
  "url": "http://www.gstatic.com/generate_204#/dummy",
  "hash": "sha256-hash",
  "bin": [["node_modules\\.bin\\codebuff.ps1", "codebuff"]],
  "installer": { "script": "pushd $original_dir; pnpm add codebuff@$version; popd;" },
  "post_uninstall": "pnpm store prune",
  "depends": ["pnpm", "nodejs"],
  "checkver": { "url": "https://registry.npmjs.org/codebuff/latest", "jsonpath": "$.version" },
  "autoupdate": { "installer": { "script": "..." } }
}
```

#### App with Persistence
```json
{
  "version": "18.1.4.0",
  "description": "Driver removal utility",
  "homepage": "https://github.com/Wagnard/display-drivers-uninstaller",
  "license": { "identifier": "Freeware", "url": "..." },
  "url": "https://www.wagnardsoft.com/DDU/download/DDU%20v18.1.4.0.exe#/dl.zip",
  "hash": "sha256-hash",
  "extract_dir": "DDU v18.1.4.0",
  "pre_install": ["Copy-Item \"$persist_dir\\settings\\Settings.xml\" \"$dir\\settings\" -ErrorAction SilentlyContinue"],
  "shortcuts": [["Display Driver Uninstaller.exe", "DDU"]],
  "pre_uninstall": ["ensure \"$persist_dir\\settings\" | Out-Null", "Copy-Item \"$dir\\settings\\Settings.xml\" \"$persist_dir\\settings\" -ErrorAction SilentlyContinue"],
  "persist": ["settings"],
  "checkver": { "url": "...", "regex": "..." },
  "autoupdate": { "url": "...", "extract_dir": "DDU v$version" }
}
```

### 3. Getting the Hash

#### Using GitHub API (Recommended for GitHub Releases)
The GitHub API provides both download URLs and SHA256 digests in the release data:

```bash
curl -sL "https://api.github.com/repos/<owner>/<repo>/releases/latest"
```

Each asset in the response includes:
- `browser_download_url`: Direct download link
- `digest`: SHA256 hash in format `sha256:<hash>`

**Example from MaaEnd release:**
```json
{
  "name": "MaaEnd-win-x86_64-v2.3.0.zip",
  "browser_download_url": "https://github.com/MaaEnd/MaaEnd/releases/download/v2.3.0/MaaEnd-win-x86_64-v2.3.0.zip",
  "digest": "sha256:405dca7e297d001eb7666fe2033b005674d817f7e71ec6633743e702274ad87c"
}
```

#### Using PowerShell
```powershell
# Using Scoop's built-in command (recommended)
scoop hash <file>

# Using PowerShell directly
Get-FileHash -Path "file.zip" -Algorithm SHA256

# For a URL (download first)
Invoke-WebRequest -Uri "url" -OutFile "file.zip"
Get-FileHash -Path "file.zip" -Algorithm SHA256
```

### 4. Getting extract_dir

Use `scripts/Get-ArchivePath.ps1` to analyze a ZIP file **without downloading the entire file**. It parses the ZIP local file headers to list all files and determine if `extract_dir` is needed.

```powershell
# Run the script with a download URL
.\scripts\Get-ArchivePath.ps1 -Url "https://github.com/user/repo/releases/download/v1.0.0/App-win-x86_64-v1.0.0.zip"
```

**Output includes:**
- List of files at root level
- List of directories
- Recommendation: `extract_dir: "dirname"` or `NOT NEEDED`
- Whether autoupdate is needed for extract_dir

**Logic:**
- Files at root → no `extract_dir` needed
- Single top-level directory → `extract_dir` is that directory
- Multiple directories → no `extract_dir` needed (Scoop uses version-named folder)

**autoupdate.extract_dir:** Only needed if the path contains variables like `$version`. If the path is static (e.g., `"agent"`), it stays in the base manifest and doesn't need to be in autoupdate.

### 5. Checkver Configuration

#### GitHub Releases (Simplest)
```json
"checkver": "github"
```

#### Custom Regex from URL
```json
"checkver": {
  "url": "https://example.com/versions",
  "regex": "version ([\\d.]+)"
}
```

#### NPM Registry
```json
"checkver": { "url": "https://registry.npmjs.org/app-name/latest", "jsonpath": "$.version" }
```

#### PowerShell Script (Complex)
```json
"checkver": {
  "script": [
    "$rel_info = Invoke-RestMethod -Uri 'https://api.github.com/repos/user/repo/releases'",
    "$latest = $rel_info | Sort-Object {$_.published_at} | Select-Object -last 1",
    "Write-Output $latest.tag_name"
  ],
  "regex": "(?<version>[\\d.]+)"
}
```

### 6. Autoupdate Configuration

Match captured groups from checkver using `$matchGroupName`:
```json
"autoupdate": {
  "url": "https://github.com/user/repo/releases/download/v$version/App-$version.zip",
  "hash": "$matchX64hash"
}
```

## Validation Workflow

### Automatic Checks (GitHub Actions)

When a Pull Request is opened, two checks run automatically:

1. **Pull Request Validator** (`ScoopInstaller/GithubActions`)
   - Validates manifest JSON structure
   - Checks required fields
   - Verifies URLs are accessible

2. **Biome Format**
   - Ensures consistent JSON formatting
   - Uses tab indentation, CRLF line endings

### Local Testing

Run bucket tests locally:
```powershell
# Requires Scoop installed
scoop bucket test .
```

Or run the test script directly:
```powershell
# Set SCOOP_HOME if not already set
$env:SCOOP_HOME = (scoop prefix scoop)
. "$env:SCOOP_HOME\test\Import-Bucket-Tests.ps1"
```

## Committing Changes

### Single Manifest Commit Format

When committing a single manifest change (add or update), use this format:

```bash
# For new apps
git add bucket/<app-name>.json
git commit -m "add(<app-name>): <version>"

# For updates
git add bucket/<app-name>.json
git commit -m "update(<app-name>): <version>"
```

**Examples:**
- `add(maaend): 2.3.0` - Adding new app maaend version 2.3.0
- `update(letta-code): 0.21.1` - Updating letta-code to version 0.21.1
- `add(imageglass-beta): 10.0.0.314-beta-1` - Adding new app with beta version

### Workflow

1. Create/modify manifest in `bucket/`
2. Run validation: `scoop bucket test .`
3. Format with Biome: `npx biome format bucket/`
4. Commit with proper format
5. Push and create PR

## Conventions

### Formatting (Biome)

The bucket uses [Biome](https://biomejs.dev/) for JSON formatting:
- **Indent Style**: Tab
- **Indent Width**: 2
- **Line Ending**: CRLF
- **Trailing Newline**: true

Run Biome to format:
```powershell
npx biome format bucket/
```

### Naming Conventions

- Manifest filename: lowercase with hyphens (e.g., `ddu.json`, `gemini-cli.json`)
- App name in manifest: match the filename
- Version: follow semver for scoop version checking

### License Identifiers

Use [SPDX](https://spdx.org/licenses/) identifiers when possible:
- `MIT`, `Apache-2.0`, `GPL-3.0-or-later`, etc.
- For non-standard licenses: `{ "identifier": "Freeware", "url": "..." }`

### Best Practices

1. Use portable versions when available (no installer required)
2. Include `checkver` and `autoupdate` for automatic updates
3. Test locally before submitting PR
4. Verify hash matches the exact download
5. Use `shortcuts` for GUI apps so they appear in Start Menu
6. Use `bin` for CLI apps to create command shims
7. Consider `persist` for user data that should survive updates
8. Add `notes` if user setup is required (e.g., first-run wizard)