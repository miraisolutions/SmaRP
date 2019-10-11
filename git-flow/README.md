# GitFlow and Release Model for SmaRP


## Branching System

We use a [**GitFlow**](https://nvie.com/posts/a-successful-git-branching-model/) branching model, where the repository holds two main **branches** with an infinite lifetime:

- [**`master`**](https://github.com/miraisolutions/SmaRP/tree/master) reflects the [**latest release**](https://github.com/miraisolutions/SmaRP/releases/latest) to production, i.e. the current version of the [live app](https://mirai-solutions.ch/gallery/smarp).
- [**`develop`**](https://github.com/miraisolutions/SmaRP/tree/develop) collects all completed developments for the [**next release**](#release).

The overall GitFlow branching system is described as follows

- No work is committed and pushed directly to `master`, which is updated only as part of a [**release**](#release).
- Small (maintenance) work can be done directly in `develop`, however meaningful pieces should be developed in a dedicated **_feature_ branch** created from `develop` and associated to a GitHub issue. By convention, the branch name is of the form `feature/<ID>-short-title`.
    - Once completed, the branch is merged back into `develop` via a pull request.
    - Each significant development must be mentioned as a bullet point in the top-section of [**`NEWS.md`**](../NEWS.md) before being pushed to or merged into `develop`, to serve as a change log for the next release.
- **Hot-fixes** that need to be brought in asap, independently of any other pending development, are carried out in a dedicated branch (of the form `hotfix/<ID>-short-title`) created from `master`. The branch is merged directly back to `master` as a new **patch release**, and must be also merged into `develop` (or possibly an open _release_ branch).


## Versioning and Releases {#release}

**SmaRP** uses a [**semantic versioning**](https://semver.org/) scheme bound to the version of the underlying R package. The basic versioning scheme `major.minor.patch` (e.g. `1.1.2`) is reserved for release tagging and the `master` branch (which reflects the most recent release). On the other hand, a fourth _development_ component `-9000` is added for the not-yet-released development happening in the `develop` and _feature_ branches. The package version is updated for the next release (see below) just before the merge into `master` (from `develop` or a _release_ branch). Afterwards, `-9000` is added again to the new version for the future development.

Here we assume that the most recent release is `1.0.0`, hence the version on `develop` is `1.0.0-9000`.
Releases should only happen from a **stable `develop`**, possibly creating a **_release_ branch** for the release preparation, with a name of the form `release/v<next-release-version>`, e.g. `release/v1.1.0` for a new _minor_ release.

1. **Release preparation**
    - Consolidate and re-organize the changes in `NEWS.md` (see e.g. Hadley's [recommendations](http://r-pkgs.had.co.nz/release.html#important-files) and [style guide](https://style.tidyverse.org/news.html#news-release)), using the level-3 header `###` for sections if any (nicer rendering in GitHub)
        - Changes should have been collected in `NEWS.md` already during development
    - Decide on the **next version** based on whether it is a _patch_, _minor_, _major_ release
        - For _patch_ changes: `1.0.0-9000` -> `1.0.1` (mainly for hot-fixes)
        - For _minor_ changes: `1.0.0-9000` -> `1.1.0` (e.g. any change that affects calculations and numbers in the output, minor app refinements or additions, general maintenance)
        - For _major_ changes: `1.0.0-9000` -> `2.0.0`
    - Change version number in `NEWS.md` and `DESCRIPTION` files.

(Note: for the remaining steps, a minor release with  `1.1.0` will be used as an example)

2. **Commit and push** all changes with the comment: `1.1.0 release preps` and `closes` lines for all issues mentioned in the `NEWS.md`, e.g.

    ```
    1.1.0 release preps
    * closes #26
    * closes #38
    ```
3. Go on GitHub and create a new **pull request** from `develop` (or the _release_ branch) to `master`
    - Write title in the form "1.1.0 release"
    - Paste as comment the list of changes in `NEWS.md`
    - Assign reviewer(s) and set project to SmaRP
4. As part of the review process, make sure the app can be built and run via Docker locally
    - Build image with test tag: `docker build -f Dockerfile -t mirai/smarp:test-1.1.0 .`
    - Run the app: `docker run --rm -p 80:80 mirai/smarp:test-1.1.0`
    - Visit `http://127.0.0.1:80` and test the app
    - Type `Ctrl+C` to stop the container, which is automatically removed (`--rm`)
    - Cleanup the image: `docker image rm mirai/smarp:test-1.1.0` 
5. Once the pull request is merged into `master`, create a **new release on GitHub** ([Code > releases > Draft new release](https://github.com/miraisolutions/SmaRP/releases/new))
    - Tag version: v1.1.0
    - Title: SmaRP 1.1.0
    - Body: Paste as comment the list of changes in `NEWS.md`
    - Click on "Publish release"
6. If the release was done from a _release_ branch, a pull request should be created to merge it back into `develop`
7. Prepare for **next version** on `develop`
    - Change the `Version` field in `DESCRIPTION` to the development version `1.1.0-9000`
    - Create a new heading in `NEWS.md` for `SmaRP 1.1.0-9000`
    - Commit and push


## References

* [GitFlow for GitHub](https://datasift.github.io/gitflow) by DataSift.
* [Git and GitHub](http://r-pkgs.had.co.nz/git.html) from Hadley Wickham's [R packages](http://r-pkgs.had.co.nz/).
* [Package versioning](http://r-pkgs.had.co.nz/description.html#version) from Hadley Wickham's [R packages](http://r-pkgs.had.co.nz/).
* [Releasing a package](http://r-pkgs.had.co.nz/release.html) from Hadley Wickham's [R packages](http://r-pkgs.had.co.nz/).
