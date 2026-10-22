# Changelog

## 1.3.0

Rated for safe mode: every book is safe, except those Project Gutenberg files under an "Erotic …" subject (Library
of Congress subject headings), which are rated erotica. Requires an app version that reads ratings.

## 1.2.0

Categories: Fiction, Poetry, Drama, Science fiction, Adventure, Romance, Mystery, Horror, Fairy tales, Children,
History, Philosophy. Each is a subject search of the OPDS feed (`s.<subject>`), combined with the reader's search
(`query={{search}} {{category}}`). Requires an app version that reads categories.

## 1.1.1

Declare the rights again: public domain in the United States, with the Project Gutenberg licence terms
(they were dropped in 1.1.0). No change to what the source reads.

## 1.1.0

Read gutenberg.org directly instead of a self-hosted Gutendex plus a mirror.

- Catalog: the site's official OPDS search feed (`/ebooks/search.opds/`), paginated by `start_index`.
- Title: `/ebooks/<id>.opds` (name, authors, LCSH subjects, Summary when present).
- Books: EPUB from `www.gutenberg.org` itself; covers from `/cache/epub/<id>/`.
- Settings removed: no more Gutendex instance or mirror to host; hosts reduced to `www.gutenberg.org`.
- Requires the engine features `xml` response type and `startIndex` pagination.

## 1.0.0

First release.

- Browse and search the Project Gutenberg catalog through a Gutendex instance (books still under copyright are excluded).
- Books are EPUB files downloaded from a Project Gutenberg mirror and read on the device.
- Settings: Gutendex instance, Project Gutenberg mirror, catalog languages (default: en,fr).
