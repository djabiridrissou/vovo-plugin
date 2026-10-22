# xkcd

xkcd, the webcomic of romance, sarcasm, math and language by Randall Munroe. Kind: `comic` (single image per comic).

The source reads **xkcd.com directly**: the full archive list from `/archive/`, each comic's page from
`/<number>/`, and the comic image from `imgs.xkcd.com`. No mirror, no API key, no setting to fill.

Rights: [CC BY-NC 2.5](https://xkcd.com/license.html) — free to reuse for non-commercial purposes with
attribution. This source only fetches pages as the reader browses, at the manifest rate limit (30 a minute).

## Settings

None.

## Structure relied on (checked 2026-10-22, with the engine's User-Agent)

- Catalog: `/archive/` — all ~3,300 comics as plain links `/<n>/` inside `#middleContainer`; the id is
  the number, the name is the link text. One page, no pagination, no search server-side (search filters
  the catalog in the app).
- Title: `/<n>/` — `#ctitle` is the comic's title; the description is the image's `title` attribute
  (the hover text, e.g. "Day six: 'The hell? Who mails a bobcat?'"). One unit per comic.
- Comic: same page — the single image inside `#comic`, src made absolute (`//imgs.xkcd.com/…`).

## Engine features used

- `absUrl` for the protocol-relative image src.
- Single-unit titles (`units.single`), as every comic is one image.

## Limits

- No covers: xkcd pages have no per-comic cover art.
- Comics absent from the archive listing (e.g. xkcd 404, which is intentionally not listed) can't be reached.
- The interactive/JSON comics (e.g. the periodic table of things that hurt) appear as their static image.
