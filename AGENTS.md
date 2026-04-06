# Information for AI Agents

This repository provides `arb_utils`, a CLI tool for working with `.arb` files in Flutter.

## Key Commands for Agents

### 1. `keys`: List and search existing keys
Use this command to discover if a translation key already exists or to find similar keys.
```sh
arb_utils keys <regexp>
```
Example: `arb_utils keys ^welcome`

### 2. `add`: Add multiple translations at once
Use this command to add a new key with translations for all locales in one go.

#### Simple syntax
```sh
arb_utils add <key> --description '<description>' [locale:value...]
```
Example:
```sh
arb_utils add welcome --description 'Welcome message' en:'Welcome!' es:'¡Bienvenido!'
```

#### Complex syntax (Plurals, Select, etc.)
For complex ARB values, use the `--json` flag with the `$VAL$` placeholder.
```sh
arb_utils add --json '{"messageCount": "{count, plural, =0{No messages} one{1 message} other{{count} messages}}", "@messageCount": {"description": "Plural message example", "placeholders": {"count": {"type": "int"}}}}' en:'{count, plural, =0{No messages} one{1 message} other{{count} messages}}' es:'{count, plural, =0{No hay mensajes} one{1 mensaje} other{{count} mensajes}}'
```

Another example with `select`:
```sh
arb_utils add --json '{"genderSelect": "{gender, select, male{He} female{She} other{They}}", "@genderSelect": {"description": "Select example", "placeholders": {"gender": {"type": "String"}}}}' en:'{gender, select, male{He} female{She} other{They}}' es:'{gender, select, male{Él} female{Ella} other{Ellos}}'
```

## Agent Skills

### Skill: Safe Translation Addition
Before adding a new translation, an agent should:
1. Search for existing similar keys using `arb_utils keys`.
2. If no suitable key exists, add the new one using `arb_utils add`.

Example Workflow:
1. Agent needs to add a "login" button label.
2. Run `arb_utils keys login`.
3. If "loginButton" exists, use it.
4. If not, run `arb_utils add loginButton --description 'Label for login button' en:'Login' es:'Iniciar sesión'`.

### Important Notes
1. **Auto-Discovery**: Commands recursively find all `.arb` files. Use `--files` to limit scope.
2. **Strict Locale Check**: `add` fails if any locale is missing from the command.
3. **Order**: `add` appends to the end by default. Use `--sort` to re-sort after adding.
