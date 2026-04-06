# Information for AI Agents

This repository provides `arb_utils`, a CLI tool for working with `.arb` files in Flutter.

## Key Command: `add`

The `add` command is designed to easily add multiple translations for a single key at once.

### Usage

#### Human-friendly syntax
```sh
arb_utils add <key> --description '<description>' [locale:value...]
```
Example:
```sh
arb_utils add welcome --description 'Welcome message' en:'Welcome!' es:'¡Bienvenido!'
```

#### JSON template syntax (with placeholder)
```sh
arb_utils add --json '<template>' [locale:value...]
```
Example:
```sh
arb_utils add --json '{"welcome": "$VAL$", "@welcome": {"description": "Welcome message"}}' en:'Welcome!' es:'¡Bienvenido!'
```

### Important Notes
1. **Auto-Discovery**: By default, it recursively finds all `.arb` files in the current directory. To specify files, use the `--files` flag: `--files file1.arb --files file2.arb`.
2. **Strict Locale Check**: The command will fail if you don't provide a value for every locale found in the `.arb` files.
3. **Tail Addition**: New entries are added to the end of the files by default. Use the `--sort` (or `-s`) flag to sort the files after adding.
4. **Pretty-printing**: Output is formatted with 2-space indentation and a trailing newline.

## Other Commands
- `sort`: `arb_utils sort <file-path>`
- `generate-meta`: `arb_utils generate-meta <file-path>`
- `merge`: `arb_utils merge <file1> <file2> -o <output-file>`
