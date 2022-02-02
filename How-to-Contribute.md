# Contributing to Sanmill

There are many ways to contribute to the Sanmill project: logging bugs, submitting pull requests, reporting issues, and creating suggestions.

After cloning and building the repo, check out the [issues list](https://github.com/Calcitem/Sanmill/issues?utf8=%E2%9C%93&q=is%3Aopen+is%3Aissue). Issues labeled [`help wanted`](https://github.com/Calcitem/Sanmill/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22) are good issues to submit a PR for. Issues labeled [`good first issue`](https://github.com/Calcitem/Sanmill/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) are great candidates to pick up if you are in the code for the first time. If you are contributing significant changes, or if the issue is already assigned to a specific month milestone, please discuss with the assignee of the issue first before starting to work on the issue.

## Prerequisites

In order to download necessary tools, clone the repository, you need network access.

You'll need the following tools:

- [Git](https://git-scm.com)
- A C/C++ compiler tool chain for your platform:
  - **Windows 10/11**
        - Install the Visual C++ Build Environment by installing the [Visual Studio Community Edition](https://visualstudio.microsoft.com/vs/community/). The minimum workload to install is 'Desktop Development with C++'.
  - **macOS**
    - [Xcode](https://developer.apple.com/xcode/downloads/) and the Command Line Tools, which will install `gcc` and the related toolchain containing `make`
      - Run `xcode-select --install` to install the Command Line Tools
  - **Linux**
    - On Debian-based Linux: `sudo apt-get install build-essential g++`

### Troubleshooting

## Enable Commit Signing

If you're a community member, feel free to jump over this step.

Otherwise, if you're a member of the Sanmill team, follow the [Commit Signing](https://github.com/Calcitem/Sanmill/wiki/Commit-Signing) guide.

## Build and Run

If you want to understand how Sanmill works or want to debug an issue, you'll want to get the source, build it, and run the tool locally.

### Getting the sources

First, fork the Sanmill repository so that you can make a pull request. Then, clone your fork locally:

```shell
git clone https://github.com/<<<your-github-account>>>/Sanmill.git
```

Occasionally you will want to merge changes in the upstream repository (the official code repo) with your fork.

```shell
cd Sanmill
git checkout dev
git pull https://github.com/Calcitem/Sanmill.git dev
```

Manage any merge conflicts, commit them, and then push them to your fork.

**Note**: The `calcitem/Sanmill` repository contains a collection of GitHub Actions that help us with triaging issues. As you probably don't want these running on your fork, you can disable Actions for your fork via `https://github.com/<<Your Username>>/Sanmill/settings/actions`.

### Build


**Troubleshooting:**

#### Errors and Warnings

Errors and warnings will show in the console while developing Sanmill. If you use Sanmill to develop Sanmill, errors and warnings are shown in the editor.

### Run

To test the changes, you launch a development version of Sanmill on the workspace `Sanmill`, which you are currently editing.

**macOS and Linux**

```bash

```

**Windows**

```bat

```

### Debugging

#### Using Sanmill

### Monkey Testing

### Unit Testing

### Linting

### Extensions

## Work Branches

Even if you have push rights on the Calcitem/Sanmill repository, you should create a personal fork and create feature branches there when you need them. This keeps the main repository clean and your personal workflow cruft out of sight.

## Pull Requests

To enable us to quickly review and accept your pull requests, always create one pull request per issue and [link the issue in the pull request](https://github.com/blog/957-introducing-issue-mentions). Never merge multiple requests in one unless they have the same root cause. Be sure to follow our [[Coding Guidelines|Coding-Guidelines]] and keep code changes as small as possible. Avoid pure formatting changes to code that has not been modified otherwise. Pull requests should contain tests whenever possible.

### Where to Contribute

Check out the [full issues list](https://github.com/Calcitem/Sanmill/issues?utf8=%E2%9C%93&q=is%3Aopen+is%3Aissue) for a list of all potential areas for contributions. Note that just because an issue exists in the repository does not mean we will accept a contribution to the core editor for it. There are several reasons we may not accept a pull request like:

- Performance - One of Sanmill's core values is to deliver a *lightweight* app, that means it should perform well in both real and perceived performance.
- User experience - Since we want to deliver a *lightweight* app, the UX should feel lightweight as well and not be cluttered. Most changes to the UI should go through the issue owner.
- Architectural - The team and/or feature owner needs to agree with any architectural impact a change may make. Things like new extension APIs *must* be discussed with and agreed upon by the feature owner.

To improve the chances to get a pull request merged you should select an issue that is labelled with the [`help-wanted`](https://github.com/Calcitem/Sanmill/issues?q=is%3Aopen+is%3Aissue+label%3A%22help+wanted%22) label. If the issue you want to work on is not labelled with `help-wanted`, you can start a conversation with the issue owner asking whether an external contribution will be considered.

To avoid multiple pull requests resolving the same issue, let others know you are working on it by saying so in a comment.

### Spell check errors

Pull requests that fix spell check errors in **translatable strings** are welcomed, otherwise it will be difficult to review. Pull requests only fixing spell check errors in source code are **not** recommended.

## Packaging

Sanmill can be packaged for the following platforms: `win32-ia32 | win32-x64 | darwin-x64 | darwin-arm64 | linux-ia32 | linux-x64 | linux-arm`

## Suggestions

We're also interested in your feedback for the future of Sanmill. You can submit a suggestion or feature request through the issue tracker. To make this process more effective, we're asking that these include more information to help define them more clearly.

## Translations

## Discussion Etiquette

In order to keep the conversation clear and transparent, please limit discussion to English/Chinese and keep things on topic with the issue. Be considerate to others and try to be courteous and professional at all times.
