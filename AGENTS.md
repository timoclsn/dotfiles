## AGENTS.md

This repository contains personal dotfiles for various command-line tools.

### Commands

There are no formal build, lint, or test commands. The primary way to "test" changes is to source the relevant configuration file or run the script directly. For example, to test changes to `.zshrc`, you would run `source ~/.zshrc`.

### Code Style

- **Shell Scripts**: Follow the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html). Use `shellcheck` for linting if available.
- **Configuration Files**: Match the existing style of the file you are editing. Pay attention to indentation and commenting style.
- **Error Handling**: Check for errors when calling commands and handle them appropriately. For example, exit the script if a critical command fails.
- **Naming Conventions**: Use lowercase with underscores for variable and function names in shell scripts (e.g., `my_variable`).
- **Imports/Sourcing**: When sourcing files, use paths relative to the script's location or absolute paths when necessary.
- **New Files**: When adding new configurations, place them in a directory named after the tool (e.g., `newtool/`).
