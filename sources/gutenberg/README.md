# Project Gutenberg

Classic books from the Project Gutenberg catalog, public domain in the United States. Kind: `book` (EPUB).

The source reads **gutenberg.org directly**: catalog and title metadata from its official OPDS feeds
(Atom/XML), EPUB files and covers from the site's own `/cache/epub/` paths. No third-party instance,
no mirror, no setting to fill.

Note: gutenberg.org's `robots.txt` disallows `/ebooks/search` (its HTML pages also carry an explicit
no-scraping warning); this source never touches them. It uses the OPDS catalog the site publishes
for machine access (`/ebooks/search.opds/`, `/ebooks/<id>.opds`), at the manifest rate limit.

## Settings

None.

## Engine features used

- `type: "xml"` (OPDS/Atom feeds, CSS selectors on element names) — requires an app version that
  supports contract features `xml` + `pagination`.
- `pagination: {"type": "startIndex", "param": "start_index", "pageSize": 25, "base": 1}` — the OPDS
  catalog paginates by start position (1, 26, 51…), not by page number.

## Activation

```http
POST /api/v1/admin/sources            { "manifest": <source.json> }
PATCH /api/v1/admin/sources/gutenberg { "status": "active" }
```

## Checked by hand (2026-10-21)

`curl` with the app User-Agent: search feed with and without query (25 entries, `rel="next"`),
title feed (name, author, LCSH subjects, Summary paragraph, EPUB acquisition link), cover URLs
(HTTP 200 on ids 5, 10, 84, 103), EPUB path `/cache/epub/103/pg103-images.epub` (reached through
`/ebooks/103.epub.images`, one same-host redirect).
