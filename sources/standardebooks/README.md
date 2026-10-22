# Standard Ebooks

Public-domain literature in professional-grade ebook editions, from [standardebooks.org](https://standardebooks.org).
Kind: `book` (EPUB download).

The source reads **standardebooks.org directly**: catalog and metadata from the site's HTML pages, the
EPUB from the site's own `/downloads/` paths. No OPDS (the feeds answer 401 to this engine's requests),
no mirror, no setting to fill.

Rights: Standard Ebooks editions are released into the public domain (their own typographic work is
CC0; the texts are public domain). Requests come from each reader's device at the manifest rate limit
(30 a minute); the EPUB files are served directly by standardebooks.org.

## Settings

None.

## Structure relied on (checked 2026-10-22, with the engine's User-Agent)

- Catalog: `/ebooks` — 12 books per page as `ol.ebooks-list li` (schema.org Book markup); the id is the
  `about` path (`author-slug/book-slug`), the cover from the card image. `?query=` searches server-side.
  Pagination: `?page=N` via a `startIndex` rule with `pageSize: 1` (page N sends `page=N`); a full 12th
  row means another page exists.
- Title: `/ebooks/<author>/<book>` — `h1[property=schema:name]`, author from the schema.org markup,
  description in `section#description > div > p` (the donation banner lives in a sibling `aside` and is
  not matched), cover from `/images/covers/`.
- Book: the title page is fetched once more and the "Compatible epub" link (`a.epub`, `application/epub+zip`)
  is taken as the document; the file itself is served directly (no redirect), so it passes the engine's
  allowed-host check.

## Engine features used

- `content.book.request` so the document URL is extracted with CSS from the title page instead of a template.
- `absUrl` for root-relative cover and EPUB paths.

## Limits

- English only (the catalog is English literature).
- One unit per book, as usual for `book` sources: the EPUB is the whole edition.
