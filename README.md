# Generic Shovel bucket

In this repository you will find everything you need to know about creating custom bucket with appveyor support.

- [Files and helpers](#files-and-helpers)
    - [`bucket` Folder](#bucket-folder)
    - [`bin` Folder](#bin-folder)
    - [`Bucket.Tests.ps1` File](#buckettestsps1-file)
    - [`.vscode` Folder](#vscode-folder)
    - [`.github` Folder](#github-folder)
    - [`config files`](#config-files)
- [How to use and adopt this bucket](#how-to-use-and-adopt-this-bucket)

## Files and helpers

### `bucket` Folder

- All manifests belong here
- `.gitkeep` file could be removed when you push your first manifest

### `bin` Folder

If you need custom scripts you should create `bin` folder.

### `Bucket.Tests.ps1` File

- Test which are executed inside Appveyor pipeline
- Could be configured as `pre_commit` hook

### `.vscode` Folder

Contains all syntax highlighting, code formating, manifest creating tools you could use.

- Extensions
    - All extensions which will save your time while writing manifests are in recommended sections
    - You will be notified about installing them when you open project
- Settings
    - All settings are set to be compatible with Appveyor pipeline and upstream (official) repositories
        - No need to worry about formating restrictions between repositories.
- Code snippets
    - > Code snippets are templates that make it easier to enter repeating code patterns, such as loops or conditional-statements.
    - You could use workspace wide code snippets for speed up manifest creating
    - While editing json file write partitial name of snippet and press `tab`
    - Available Json snippets:
        - `app`
            - Create default manifest structure
        - `appArch`
            - Create default manifest structure with full acrchitecture
        - `arch`
            - Create only architecture property with 64bit and 32bit
        - `upAr`
            - Create autoupdate property with architecture

### `.github` Folder

GitHub repository configuration.

- `workflows` folder
    - [GitHub Actions](https://github.com/features/actions) configuration for automatic issue/PR/updates handling
    - Refer to [GithubActions repository](https://github.com/shovel-org/GithubActions) for more information
- `CODEOWNERS`
    - Pull requests will automatically request review for users defined in this file
- `PULL REQUEST TEMPLATE`
    - Prefilled pull request types with proper titles
- `ISSUE TEMPLATE`
    - The most used issue templates for users to select and prefilled with required information and labels

### `config files`

- `.appveyor.yml`
    - Definition of Appveyor CI pipeline
- `.editorconfig`
    - Universal configuration file, compatible with all types of editors
    - Defines how files should look
- `.gitattributes`
    - Simplifying line endings for git
    - No need to configure `auto.clrf` setting on each clone or new workspaces
- `Bucket.Tests.ps1`
    - Test which are executed inside Appveyor pipeline
    - Could be configured as `pre_commit` hook

## How to use and adopt this bucket

1. Click on `Use this template` to create new repository in your account with same files
1. Open project settings and **give your bucket new name**
1. Add proper description of repository
    - Information about what type of manifests could be found here
1. Add `shovel-bucket` tag for repository
    - If approved, your bucket could be part of <https://shovel.ash258.com> (Currently still Work-in-progress)
1. Enable appveyor CI/CD
    1. Register / Login to [Appveyor](https://ci.appveyor.com/login)
    1. Click `New Project`
    1. From Left Panel, choose your source control variant (Github)
    1. From Right Panel, choose repository with bucket and click `+ Add`
    1. 🎉 Project created and ready to build 🎉
    1. Get Badge URL
        1. Open Appveyor Project settings
        1. Navigate to Badges
        1. Copy `Branch Sample markdown code` snippet for further usage
            - Only master branch is better, since you can freely test in other branches and do not mystificate users
            - [You could use alternative styles](https://shields.io/category/build#styles)
1. Clone project into some folder
    - `git clone git@github.com:USER/REPO.git MyAwesomeBucket`
    - or
    - `git clone https://github.com/USER/REPO.git MyAwesomeBucket`
1. Open vscode with this clone
    - `code MyAwesomeBucket`
1. _[optional]_ Configure remote repository
    1. `git remote add 'upstream' 'https://github.com/Ash258/GenericBucket.git'`
    - This step will allow you to synchronize changes with this template repository
1. Create proper README.md
    1. [Open this README in the browser for reference](https://github.com/shovel-org/GenericBucket/tree/main/README.md)
    1. Open `README.template.md`
    1. Replace all `%%templatestring%%` with real and according values
        1. Replace appveyor status badge with yours
            - See: <https://appveyor.com/docs/status-badges/>
    1. Override this README with completed `README.template.md`
    1. Remove template `README.template.md`
1. Repository tweaks
    1. Open `.github\CODEOWNERS` and change `@Ash258` to desired GitHub username
    1. Actions
        1. Open each file in `.github\workflows` and change `youremail@email.com` with your email
        1. Visit <https://github.com/shovel-org/GithubActions> for more information
1. 🎉🎉 Everything set. High quality and automated bucket is ready for new users 🎉🎉
