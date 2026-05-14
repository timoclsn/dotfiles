## General

- Apply all of the rules in this file to new code you write. Don't change already present code that you don't have to touch. (Keep diffs minimal)
- Focus on the most performant solutions.
- Always make your solutions accessible.
- Try to separate presentational and business logic when possible.
- After making changes, check if related tests need to be updated as well.

## Typescript

- Always prefer arrow functions.
- Infer as much types as possible only add explicit types when needed.
- Don't add return types to functions when not needed. Let them be infered.
- Prefer functional coding style.
- Don't put types in their own files if not necessary. Put them in the files where they are used.
- Don't use default exports use named exports if possible.
- Prefer interfaces over types
- Avoid enums
- Only create an abstraction if it’s actually needed
- Prefer clear function/variable names over inline comments
- Don’t unnecessarily add `try`/`catch`
- Don’t cast to `any`
- Don’t fix type errors by premature type casting, fix the underlying issue instead
- Avoid helper functions when a simple inline expression would suffice
- Use early returns, avoid nested "if" and avoid "else" if possible.
- Don't test what the type system already guarantees.

## React

- Don't use React as a default import (if not needed), import all react functions and types explicitly (useEffect, etc.)
- Prefer function components don't use class components if not necessary.
- Type components with a "Props" interface and destructure its props: { prop }: Props.
- Name Components in PascalCase (in code and the files).
- If the project has a design system or ui components use these whenever possible.
- Avoid massive JSX blocks and compose smaller components
- Colocate code that changes together
- Avoid `useEffect` unless absolutely needed
- Try to find solutions with css if possible only use React / JavaScript if necessary.

## Tailwind

- Mostly use built-in values, occasionally allow dynamic values, rarely globals
- Always use v4 + global CSS file format

## Tmux

- Use `tmux capture-pane -p` to capture current pane content before sending keys to preserve context
- A pattern like `dotfiles:4.4` refers to a tmux pane (format: `session:window.pane`)

## GitHub

- When asked about PRs or GitHub in general use the GitHub CLI (gh).
- When using the GitHub CLI ensure you are using the "timoclsn" account `gh auth switch --user timoclsn`. Stop if you are not.
- Write PR titles and descriptions concise and to the point. Don't add test steps.
- When creating PRs, if not otherwise instructed, make them drafts and assign them to myself.

## Vercel

- When debugging Vercel builds or deployments use the Vercel CLI (`vercel`). It is installed locally.

## Notifications

- When I ask you to "ping me", "notify me", "let me know", or similar, send BOTH a local notification and a push to my phone.
- Local: use `terminal-notifier -title "<title>" -message "<message>"`.
- Phone: use Pushover via curl to the REST API. Credentials live in `$PUSHOVER_TOKEN` and `$PUSHOVER_USER`:
  ```sh
  curl -s \
    --form-string "token=$PUSHOVER_TOKEN" \
    --form-string "user=$PUSHOVER_USER" \
    --form-string "title=<title>" \
    --form-string "message=<message>" \
    https://api.pushover.net/1/messages.json
  ```
- Always send both unless I explicitly say "local only" or "phone only".
