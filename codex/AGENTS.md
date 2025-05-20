## General

- Use spaces for indentation.
- Default to 2 spaces.
- Focus on the most performant solutions.
- Allways make your soultions accessible.
- Don't add comments all over the place. Only comment where it adds value.

## Typescript

- Always prefer arrow functions.
- Infer as much types as possible only add explicit types when needed.
- Don't add return types to functions when not needed. Let them be infered.
- Prefere functional coding style.
- Don't put types in their own files if not necessary. Put them in the files where they are used.
- Don't use default exports use named exports if possible.
- Prefer interfaces over types
- Avoid enums

## React

- Dont't use React as a default import, import all react functions and types explicitly (useEffect, etc.)
- Prefere function components don't use class components if not necessary.
- Type components with a "Props" interface and destructure its props: { prop }: Props.
- Name Components in PascalCase (in code and the files).
- If the project has a design system or ui components use these whenever possible.
- Try to find solutions with css if possible only use React / JavaScript if necessary.
