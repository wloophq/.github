# Contributing

Thanks for taking the time to help. This guide applies to every repository in the wloophq organization unless the repository has its own `CONTRIBUTING.md`.

## Before you start

- **Bugs:** open an issue with the bug report form. Include the version (`<command> version`), your OS, and the smallest steps that reproduce it.
- **Features:** open an issue with the feature request form before writing code, so we can agree on the shape first. Small fixes (typos, docs, an obvious bug) can go straight to a pull request.
- **Security problems:** do not open a public issue. Report them privately through the repository's **Security** tab, **Report a vulnerability**.

## Pull requests

- Fork the repository and branch from `main`.
- Keep a pull request to one change. Every pull request is squash-merged, so its title becomes the commit on `main`: write it as a short sentence saying what the change does.
- Add or update tests for changed behavior, and update the documentation the change affects.
- Run the repository's checks locally before pushing. For Go repositories that is usually `make lint` and `make test`; the README and the `Makefile` name the exact targets.
- CI must pass before a pull request can merge. A maintainer reviews it and may ask for changes.

## Style

- Code, comments, commit messages and documentation are in English.
- Follow the conventions already in the code you touch. Comments explain why something is done when the code cannot say it; they do not narrate the change.

## License

By contributing, you agree that your contributions are licensed under the repository's license.
