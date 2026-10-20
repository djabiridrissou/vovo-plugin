# Project Gutenberg

Classic books from the Project Gutenberg catalog, public domain in the United States. Kind: `book` (EPUB).

## Rights

- The texts are public domain in the **United States** only. Elsewhere (Togo, Ghana, France…), the copyright term
  depends on the country (author's life + 50 or 70 years): check before opening the source in a country.
- The few works still under copyright (distributed with their author's permission) are excluded: `copyright=false`.
- Free distribution: the files stay as they are, with the Project Gutenberg licence notice.
- Paid access: a 20% royalty on profits to the Project Gutenberg Literary Archive Foundation, unless every mention
  of Project Gutenberg is removed from the files.
- Each reader's app queries the catalog and downloads the book they open (like a browser); never bulk harvesting.
  Project Gutenberg forbids automated access to gutenberg.org: the catalog comes from a Gutendex instance
  (preferably our own; the public instance asks you to host one for sustained use), the files from a mirror.

## Settings (on activation)

| Setting | Required | Purpose |
|---|---|---|
| `catalogBaseUrl` | yes | Gutendex instance hosted by us, built from the Project Gutenberg offline catalog (github.com/garethbjohnson/gutendex). |
| `filesBaseUrl` | yes | Mirror (private or official) serving `/cache/epub/<id>/`, from which the app downloads the opened book. |
| `languages` | no (`en,fr`) | Catalog languages, comma-separated ISO 639-1 codes. |

## Activation

```http
POST /api/v1/admin/sources            { "manifest": <source.json> }
PATCH /api/v1/admin/sources/gutenberg { "settings": { "catalogBaseUrl": "https://…", "filesBaseUrl": "https://…" },
                                        "rightsBasis": "public-domain", "status": "active" }
```
