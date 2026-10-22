# Writing vovoscan source plugins

A brief for whoever (human or agent) writes new sources for this repository. Read it fully, then `README.md`
(repository format, packages, versioning). It describes **what the engine does today**, exactly; when a source needs
something it doesn't do, don't work around it — write a feature request (last section).

## 1. Ground rules

- **Only legitimate content.** Public domain works, openly licensed catalogs, official APIs, or sites whose terms
  allow automated reading. Never a scanlation or piracy site, never a source that needs to get past a CAPTCHA, an
  anti-bot check, a paywall or a login it isn't entitled to. If a site's terms or `robots.txt` forbid it, don't write
  the source. When in doubt, ask instead of writing it.
- **Be gentle with the site.** Keep `rateLimit.requestsPerMinute` low (default 30), never add hosts you don't need.
- **`rights` is optional.** When present, `basis` is `public-domain` or `licensed`; `notes` states the real terms
  (licence, attribution, territories, commercial limits). For an official source an admin checks it before activation.
- **No code.** A plugin is a JSON manifest: requests, extractions and a fixed list of transforms. Nothing in it runs.

## 2. How a plugin runs

The phone interprets the manifest and makes every request itself (vovoscan's servers never see the content):

```
catalog  (list of titles, paginated, searchable)
  → title (details + its units: chapters, or a single unit for a one-file book)
    → content.comic (the page images of one unit)   or   content.book (the EPUB file of one unit)
```

A source reaches users two ways: **official** (an admin installs it on the server, everyone gets it) or
**third-party** (a user adds this repository, a manifest link or a `.vovo` file in the app; private to them).

## 3. Workflow

1. `sources/<key>/source.json` — the manifest (`key` = folder name, `^[a-z0-9][a-z0-9-]{1,62}$`, not `vovoscan`).
2. `sources/<key>/README.md` — what the source is, its rights and terms, each setting and how to fill it.
3. `sources/<key>/CHANGELOG.md` — first heading `## 1.0.0` (must equal the manifest `version`), a few lines.
4. Optional `sources/<key>/icon.png` (PNG, ≤ 256 KB).
5. `python3 scripts/build-index.py` (regenerates `repo.json`), then `scripts/check.sh` (needs the backend next to
   this repo, `../backend`, or `VOVOSCAN_BE=<path>`): versions, index, schema, `vovoscan check-source`.
6. Optional: `python3 scripts/pack.py <key>` → `dist/<key>-<version>.vovo` (not committed; for releases).
7. Commit messages in English, no footer, no `Co-Authored-By`; `v1` is the main branch.

Changing an existing source: bump `version` (semver, no prerelease), add a `## <version>` section at the top of its
CHANGELOG, rebuild `repo.json`, run `check.sh`. Adding a host makes every user confirm the update: avoid it.

## 4. Manifest reference

Schema: `schema/source.schema.json` (contract v1, `additionalProperties: false` everywhere — unknown keys are
refused). Examples: `sources/gutenberg/source.json` (JSON API) and the HTML example in §8.

| Field | Notes |
|---|---|
| `contractVersion` | `1` |
| `key`, `name` (≤ 120), `version` (`x.y.z`), `description` (≤ 1000) | |
| `kinds` | `comic` and/or `book` (served). `audiobook`, `video` are in the contract but not enabled: the app refuses them. Every declared kind needs its `content` rules. |
| `langs` | ISO 639-1 codes of the content (`["en", "fr"]`). Informational today. |
| `rights` (optional) | `{ "basis": "public-domain" \| "licensed", "notes": "≥ 10 chars" }` |
| `settings` | `{ "<name>": { "label", "type": "url" \| "string" \| "integer", "required"?, "default"?, "help"? } }`. Users (or admins for official sources) fill them in the app. `url` values must be https; their host is allowed automatically. Use them for instance or mirror addresses. |
| `hosts` | Fixed hostnames the phone may contact (lowercase, no scheme). |
| `rateLimit.requestsPerMinute` | 1–600, default 30, per source on the device. |
| `catalog`, `title`, `content` | See §6. |

### Requests

```json
{ "url": "https://api.example.org/books", "type": "json", "query": { "page": "{{page}}", "search": "{{search}}" } }
```

- **GET only.** No custom headers, no cookies, no body, no authentication. Fixed User-Agent
  `vovoscan/0.1 (+https://vovoscan.yieldgrowth.org)`.
- `type`: `json` (parsed as JSON), `html` (parsed by Ksoup, a jsoup port; no JavaScript is run, so pages built in
  the browser show nothing), or `xml` (parsed by Ksoup in XML mode — Atom/RSS/OPDS feeds; CSS selectors address
  elements by local name, e.g. `entry`, `link[rel=next]`).
- `query` values are templates; **an empty value is not sent** (so `{{search}}` disappears while browsing).
- `pagination` (optional, catalog only), for sites that don't take a page number:
  - `{"type": "startIndex", "param": "start_index", "pageSize": 25, "base": 1}` — the engine sends
    `start_index = base + (page - 1) * pageSize` (never for page 1 when it equals `base`);
  - `{"type": "cursor", "param": "cursor", "from": {"path": "$.nextCursor"}}` — page 1 is the plain request;
    each next page repeats it with `param=<value extracted from the previous response by `from`>`; an empty
    extraction means no next page.
- Every host, including after redirects, must be in `hosts` or come from a `url` setting; **at most 3 redirects**,
  each checked again; the query string is dropped after a redirect.
- Timeouts: 10 s to connect, 30 s per request. Size: **5 MB** for catalog/title/content responses, 30 MB for
  downloads (EPUB). http:// works but prefer https.

### Template variables

| Variable | Where | Value |
|---|---|---|
| `{{settings.<name>}}` | everywhere | the setting's value (declare it in `settings`, `check-source` refuses undeclared ones) |
| `{{page}}` | catalog | 1, 2, 3… |
| `{{search}}` | catalog | the user's search, empty while browsing |
| `{{id}}` | title, content, units.single | the title id from the catalog item |
| `{{unitId}}` | content | the unit (chapter) id |
| `{{cursor}}` | catalog | next-page cursor, set by the engine when `pagination` is `cursor` (empty on page 1) |
| `{{lang}}` | — | **always empty today** (not wired to the user's language): don't rely on it |

Templates are plain substitution (`{{name}}`, `{{settings.name}}`), no logic or defaults.

## 5. Selectors, values, transforms

**Selector** (the `list` of a section): a JSONPath string (`"$.results[*]"`) or `{"css": "div.card"}`.

**JSONPath subset**: `$`, `.key`, `['key with spaces']`, `["key"]`, `[n]` (negative counts from the end), `[*]`
(array items or object values). No filters, no `..`, no slices, no expressions.

**CSS**: jsoup selector syntax (`div.card > a[href]`, `:nth-child`, `:contains(...)`, attribute selectors…).
`":self"` or `""` means the current node.

**Value**: a JSONPath string, or an object with exactly one source and optional steps:

```json
{ "path": "$.x" }            JSONPath on the current JSON node
{ "css": "h1", "attr": "…" } CSS on the current HTML node; attr: "text" (default), "html", or an attribute name
{ "const": "completed" }     a constant
{ "template": "{{settings.base}}/x/{{id}}" }
  + "all": true              all matches as a list (default: the first match)
  + "then": [ … ]            transforms, in order
  + "default": …             used when the result is null, "" or an empty list
```

Inside a `list`, each item's values are evaluated **on that item node**; section-level values (`hasNext`, `total`)
on the whole response.

**Transforms** (applied to each element when the value is a list, except `first`, `join`, `notNull`):

| Transform | Effect |
|---|---|
| `"trim"`, `"collapseSpaces"`, `"lower"` | string clean-up |
| `"string"` | to text (`2.0` → `"2"`) |
| `"number"` / `"integer"` | parse a number (`,` accepted as decimal point) / then truncate |
| `"absUrl"` | resolve a relative URL against the response's final URL |
| `"first"` | first element of a list |
| `"notNull"` | `true` if the value is non-null and non-empty, else `false` (use it for `hasNext`) |
| `{"regex": "…", "group": n}` | first match; group 1 by default when the pattern has groups, else the whole match; no match → null |
| `{"replace": ["old", "new"]}` | literal replacement |
| `{"join": ", "}` | list → text |
| `{"map": {"a": "b"}, "default": "c"}` | lookup table (unmapped: `default`, else the value unchanged) |
| `{"pluck": "$.name"}` | JSONPath inside each JSON object (e.g. authors objects → names) |
| `{"format": "{{settings.files}}/{value}.jpg"}` | `{value}` replaced by the current value; variables substituted |

## 6. Sections and what the app does with them

### `catalog` (required)

`request`, `list`, `item` { `id`, `name` (required), `cover`, `kind`, `format`, `status` }, optional `hasNext`, `total`.

- An item without `id` or `name` is skipped. `id` is turned into text and becomes `{{id}}` later.
- `kind` defaults to the first of `kinds`; `format` defaults to `manga` for comics, `text` for books;
  `status` defaults to `ongoing`.
- `format` values the app knows: `manga` (right-to-left pages), `webtoon` (vertical strip), `text` (book). Anything
  else is read as `manga`. `status`: use `ongoing` or `completed`.
- `hasNext` must evaluate to **boolean `true`** for the app to ask the next page (`notNull` on a "next" link or a
  JSON `next` field). `total` is a number (optional).
- Search uses the same request with `{{search}}` filled.

### `title` (required)

`request`, `fields` { `name` (required), `description`, `cover`, `authors`, `genres`, `status`, `format` }, `units`.

- The title's kind is the **first** of `kinds` (one kind per source in practice).
- `authors`, `genres`: a list (`"all": true`, or a JSON array, or `pluck` over objects).
- `units` is either a list — `list` + `item` { `id` (required), `number`, `name` } — or `{"single": {"id":
  "{{id}}", "name": "Full text"}}` for a book in one file.
- Units: `number` falls back to the position (1, 2, …); **two units with the same number keep only the first**; the
  app sorts by number ascending (reading order). Make `number` a real number (`"then": [{"regex": …}, "number"]`).

### `content.comic`

`request` (with `{{id}}`, `{{unitId}}`), `list` (one node per page image), `item` { `url` (required), `width`,
`height` (integers, optional) }.

- Images are loaded by the app's image loader with a plain GET: **no Referer, no cookies**. A site that blocks
  hotlinked images will show broken pages — that's a feature request, not something to work around.
- Use `absUrl` for relative URLs; prefer the full-size attribute (`data-src`, `srcset` parsing via `regex`).

### `content.book`

`document` { `url` (value), `mediaType`: `"application/epub+zip"` } and an optional `request` (when the file URL
must be read from a page). Without `request`, `url` is usually a `template` built from `{{id}}` / `{{unitId}}` /
settings. EPUB only; the phone downloads it once (≤ 30 MB) and reads it offline with scripts and links stripped.

## 7. Checking your work

- `scripts/check.sh` validates the schema and consistency: declared kinds have content rules, templates only use
  declared settings, the key isn't reserved, versions and `repo.json` are up to date. **It doesn't run the manifest
  against the site.**
- There is **no dry-run tool yet**. Check the extraction by hand: fetch the real responses (`curl` the catalog,
  title and content URLs with the same query) and walk your JSONPath / CSS rules over them. Note in the source's
  README what you checked and when.
- Then try it in the app: Sources → + Add → link to the manifest (or a `.vovo`), browse, open a title, read a unit.

## 8. Example (HTML site)

From the backend tests (`tests/fixtures/sources/inkwell.json`, a fictional licensed site):

```json
{
  "contractVersion": 1, "key": "inkwell", "name": "Inkwell (test comic site)", "version": "1.0.0",
  "kinds": ["comic"], "langs": ["en"],
  "rights": {"basis": "licensed", "notes": "Test fixture: an HTML comic site under licence."},
  "hosts": ["comics.inkwell.example"],
  "catalog": {
    "request": {"url": "https://comics.inkwell.example/browse", "type": "html", "query": {"p": "{{page}}", "q": "{{search}}"}},
    "list": {"css": "div.card"},
    "item": {
      "id": {"css": "a", "attr": "href", "then": [{"regex": "/series/([a-z0-9-]+)"}]},
      "name": {"css": "h3", "then": ["trim"]},
      "cover": {"css": "img", "attr": "src", "then": ["absUrl"]},
      "format": {"css": ".tag", "then": ["trim", "lower", {"map": {"vertical": "webtoon"}, "default": "manga"}]}
    },
    "hasNext": {"css": "a.next", "attr": "href", "then": ["notNull"]}
  },
  "title": {
    "request": {"url": "https://comics.inkwell.example/series/{{id}}", "type": "html"},
    "fields": {
      "name": {"css": "h1", "then": ["trim"]},
      "description": {"css": ".synopsis", "then": ["collapseSpaces"]},
      "authors": {"css": ".author", "all": true, "then": ["trim"]}
    },
    "units": {
      "list": {"css": "ul.chapters li a"},
      "item": {
        "id": {"css": ":self", "attr": "href", "then": [{"regex": "/read/([0-9]+)"}]},
        "number": {"css": ":self", "then": [{"regex": "Chapter ([0-9.]+)"}, "number"]},
        "name": {"css": ":self", "then": [{"regex": "Chapter [0-9.]+: (.+)"}]}
      }
    }
  },
  "content": {
    "comic": {
      "request": {"url": "https://comics.inkwell.example/read/{{unitId}}", "type": "html"},
      "list": {"css": "div.reader img"},
      "item": {
        "url": {"css": ":self", "attr": "data-src", "then": ["absUrl"]},
        "width": {"css": ":self", "attr": "width", "then": ["integer"]},
        "height": {"css": ":self", "attr": "height", "then": ["integer"]}
      }
    }
  }
}
```

For a JSON API with settings, a single-unit book and a templated file URL, read `sources/gutenberg/source.json`.

## 9. Current limits and feature requests

Not supported today (don't fake them):

- request headers (Referer, Accept-Language, API keys), cookies, login, POST / GraphQL;
- JavaScript-rendered pages; token pagination that is not a plain `cursor` extraction (OAuth flows, signed URLs);
- `{{lang}}` (always empty), per-user language choice;
- unit dates, volumes, per-unit languages; covers per unit;
- `audiobook` and `video` kinds; book formats other than EPUB;
- image requests with headers (hotlink-protected images).

When a legitimate source needs one of these, stop and report a **feature request** instead of a workaround:

```
### Feature request: <short name>
Source: <key> (<site>, rights: <basis>)
Needed because: <what fails today, with the URL pattern>
Proposed contract change: <schema snippet, e.g. "request.headers": {"Referer": "{{settings.base}}"}>
Engine impact: <what the app must do: mobile core/sources>
```

The contract changes in the backend first (`src/vovoscan/features/catalog/domain/contract/`), then the engine in the
mobile app (`core/sources`), then the schema copy here; a new contract feature may need `contractVersion` 2.

## 10. Deliverable checklist

- [ ] `sources/<key>/source.json`, `README.md` (rights, terms, settings, what you checked), `CHANGELOG.md`.
- [ ] Rights are real and the site allows this use; no protection bypassed; low rate limit; minimal hosts.
- [ ] `python3 scripts/build-index.py` run, `repo.json` updated; `scripts/check.sh` passes.
- [ ] Rules checked by hand against real responses (catalog page 1 and 2, a search, a title, one unit's content).
- [ ] Feature requests, if any, written as above.
