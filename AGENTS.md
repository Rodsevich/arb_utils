# Information for AI Agents

This repository provides `arb_utils`, a CLI tool for working with `.arb` files in Flutter.

## Key Command: `add`

The `add` command is particularly useful for AI agents to programmatically add new translations or entries to `.arb` files.

### Usage

```sh
arb_utils add '<json-string>' [file-paths...]
```

- `<json-string>`: A valid JSON string containing the keys and values to add.
- `[file-paths...]`: (Optional) One or more paths to `.arb` files. If omitted, the command will recursively find and update all `.arb` files in the current directory and its subdirectories.

### Examples

Add a single key to all `.arb` files:
```sh
arb_utils add '{"myNewKey": "My New Value"}'
```

Add multiple keys and metadata to specific files:
```sh
arb_utils add '{"welcome": "Welcome!", "@welcome": {"description": "Welcome message"}}' lib/l10n/app_en.arb
```

## Other Commands

- `sort`: Sorts keys in an `.arb` file alphabetically, keeping metadata next to its key.
  ```sh
  arb_utils sort <file-path>
  ```
- `generate-meta`: Adds missing metadata placeholders for all keys in an `.arb` file.
  ```sh
  arb_utils generate-meta <file-path>
  ```
- `merge`: Merges multiple `.arb` files.
  ```sh
  arb_utils merge <file1> <file2> -o <output-file>
  ```

## Best Practices for Agents

1. **Auto-Discovery**: If you don't know the exact paths to `.arb` files, just use `arb_utils add '{"key": "value"}'` and it will find them for you.
2. **Batching**: You can add multiple translations in a single command by providing a larger JSON object.
3. **Consistency**: The `add` command uses pretty-printing (2-space indentation) to maintain a clean file structure.
