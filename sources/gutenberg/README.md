# Project Gutenberg

Classic books from the Project Gutenberg catalog, public domain in the United States. Kind: `book` (EPUB).

The source reads **gutenberg.org directly**: catalog and title metadata from its official OPDS feeds
(Atom/XML), EPUB files and covers from the site's own `/cache/epub/` paths. No third-party instance,
no mirror, no setting to fill.

Note: gutenberg.org's `robots.txt` has `Disallow: /ebooks/search`. As a path prefix, that rule also
covers `/ebooks/search.opds/`, the OPDS search feed this source's catalog uses (title pages use
`/ebooks/<id>.opds`, which it doesn't cover). The requests come from each reader's device when the reader
browses or searches, not from a crawler, at the manifest rate limit (30 a minute); whether that is
acceptable to Project Gutenberg is an open question for the owner of this repository.

## Settings

None.

## Categories

Fiction, Poetry, Drama, Science fiction, Adventure, Romance, Mystery, Horror, Fairy tales, Children, History,
Philosophy: each id is a subject search (`s.Fiction`, `s.Love stories`…) sent with the reader's search in the same
`query` (`{{search}} {{category}}`; a query of only spaces behaves as no query on the site). A subject search also
returns a "Subjects" navigation entry first; its id is not `/ebooks/<n>.opds`, so the item rule drops it.

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

## Checked by hand (2026-10-22: categories; 2026-10-21: the rest)

`curl` with the app User-Agent: search feed with and without query (25 entries, `rel="next"`),
title feed (name, author, LCSH subjects, Summary paragraph, EPUB acquisition link), cover URLs
(HTTP 200 on ids 5, 10, 84, 103), EPUB path `/cache/epub/103/pg103-images.epub` (reached through
`/ebooks/103.epub.images`, one same-host redirect).
