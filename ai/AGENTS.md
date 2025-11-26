## General

- Use spaces for indentation.
- Default to 2 spaces.
- Focus on the most performant solutions.
- Allways make your soultions accessible.
- Don't add comments all over the place. Only comment where it adds value.
- Dont use git commit or git push if not otherwise instructed by the user.

## Typescript

- Always prefer arrow functions.
- Infer as much types as possible only add explicit types when needed.
- Don't add return types to functions when not needed. Let them be infered.
- Prefere functional coding style.
- Don't put types in their own files if not necessary. Put them in the files where they are used.
- Don't use default exports use named exports if possible.
- Prefer interfaces over types
- Avoid enums
- Only create an abstraction if it’s actually needed
- Prefer clear function/variable names over inline comments
- Don’t unnecessarily add `try`/`catch`
- Don’t cast to `any`Avoid helper functions when a simple inline expression would suffice Use early returns, avoid nested "if" and avoid "else" if possible.

## React

- Dont't use React as a default import, import all react functions and types explicitly (useEffect, etc.)
- Prefere function components don't use class components if not necessary.
- Type components with a "Props" interface and destructure its props: { prop }: Props.
- Name Components in PascalCase (in code and the files).
- If the project has a design system or ui components use these whenever possible.
- Avoid massive JSX blocks and compose smaller components
- Colocate code that changes together
- Avoid `useEffect` unless absolutely neededTry to find solutions with css if possible only use React / JavaScript if necessary.

## Tailwind

- Mostly use built-in values, occasionally allow dynamic values, rarely globals
- Always use v4 + global CSS file format

## Tmux

- Only start long running task like watchers or dev servers via tmux.
- When no pane to work in is provided use pane 2 in window 3 in the current session to (the one you are running in).
- Use `tmux capture-pane -p` to capture current pane content before sending keys to preserve context

## MCP Servers

### Figma Dev Mode MCP Rules

- The Figma Dev Mode MCP Server provides an assets endpoint which can serve image and SVG assets
- IMPORTANT: If the Figma Dev Mode MCP Server returns a localhost source for an image or an SVG, use that image or SVG source directly
- IMPORTANT: DO NOT import/add new icon packages, all the assets should be in the Figma payload
- IMPORTANT: do NOT use or create placeholders if a localhost source is provided

## GitHub

- When asked about PRs or GitHub in general use the GitHub CLI (gh).
- When using the GitHub CLI ensure you are using the "timoclsn" account `gh auth switch --user timoclsn`. Stop if you are not.
