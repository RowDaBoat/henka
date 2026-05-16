# Vexel
## Project
`henka` generates Nim FFI bindings.
- Bindings for C/C++ headers are generated using `libclang`'s AST.
- Bindings for Javascript/Typescript code are generated using the typescript compiler's API.

- Authors: RowDaBoat/heysokam
- Issues are tracked as HIPs (Henka Issue Prompts) in the `issues/` directory.
- `HIP 0` outlines how to write HIPs.

Changes must be localized to the task we're focusing on, any extra change outside of our current focus will only generate friction.
Answers must be technical and honest.


## Tech stack
- target: nim
- sources: C, C++, JS/TS
- clang
- heysokam's `astTF` and `slate`


## Architecture
- `henka` uses `libclang` to traverse C/C++ header files, building an intermediate representation in `astTF`.
- On Javascript/Typescript, it uses the Typescript compiler's API instead to build the `astTF` intermediate representation.
- Then the IR is translated into `nim` using `slate`.


## Code style
- Semantic naming over comments.
- Never-nester principle: max 1-2 nesting levels; extract methods instead.
- No `continue` in loops; extract the loop's body to it's own `proc` and use early returns.
- `camelCase` for procs/variables, `PascalCase` for types.
- Two blank lines between proc/type declarations.
- Use named variables to avoid too much inlining.
- Full words for variable names (no abbreviations).
- Functions should do one thing.
- Commit messages: brief, intention-focused.


## Markdown style
- Two blank lines before titles.
- Text on immediate next line after a title.
