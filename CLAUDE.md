# vovo-plugin

vovoscan content sources, described by **JSON rule manifests**: no code, only requests to the declared hosts and
extractions (JSONPath, CSS selectors) followed by known transformations.
The vovoscan server installs them, activates them (required rights and settings) and distributes their manifest;
**the mobile app interprets them and makes the requests itself** (`vovoscan-mob`, `core/sources`): their content
never goes through our servers. The backend validates the contract (`vovoscan check-source`).

## Contents

```
schema/source.schema.json      v1 contract (copy from vovoscan-be: src/vovoscan/features/catalog/domain/contract/)
sources/<key>/source.json      one manifest per source
sources/<key>/README.md        rights, settings, activation
scripts/check.sh               validates every manifest against the backend contract
```

## Check

```bash
scripts/check.sh          # sibling backend (../backend or ../vovoscan-be), or VOVOSCAN_BE=<path>
```

## Writing a source

- `kinds`: `comic`, `book` (served today), `audiobook`, `video` (planned by the contract). Each declared kind has
  its rules in `content` (`comic`: a list of pages; `book`: an EPUB file).
- Sections: `catalog` (paginated list, search via `{{search}}`), `title` (details + units: a list, or `single` for
  a book in a single file), `content`.
- Values: a JSONPath (`"$.title"`), or `{ "path" | "css" | "const" | "template", "attr", "all", "then": [...],
  "default" }`. Transformations: `trim`, `collapseSpaces`, `string`, `number`, `integer`, `lower`, `absUrl`,
  `first`, `notNull`, `regex`, `replace`, `join`, `map`, `pluck`, `format`.
- Templates: `{{settings.<setting>}}`, `{{page}}`, `{{search}}`, `{{lang}}`, `{{id}}` (title), `{{unitId}}` (unit).
- Hosts: the app only contacts those in `hosts` and in `url`-type settings, with a separate HTTP client that never
  sends the vovoscan session.
- **Rights**: `rights.basis` is `public-domain` or `licensed`, and `rights.notes` states the source's terms.
  The backend refuses to activate a source without a rights basis confirmed by an admin (proof required for
  `licensed`). No source that bypasses a protection (CAPTCHA, anti-bot) or violates a site's terms.
- The schema changes in the backend first, then is copied here (`scripts/check.sh` checks that they are equal).
  The Gutenberg manifest has a copy in the backend tests (`tests/fixtures/sources/gutenberg.json`).

## Branches and commits

`v1` is the main branch (pull requests target `v1`). Commit messages in English, with no footer and no
`Co-Authored-By` line.
