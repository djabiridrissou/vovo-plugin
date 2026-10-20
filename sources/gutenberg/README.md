# Project Gutenberg

Livres classiques du catalogue Project Gutenberg, du domaine public aux États-Unis. Type : `book` (EPUB).

## Droits

- Textes du domaine public aux **États-Unis** seulement. Ailleurs (Togo, Ghana, France…), la durée de protection
  dépend du pays (vie de l'auteur + 50 ou 70 ans) : à vérifier avant d'ouvrir la source dans un pays.
- Les quelques œuvres encore protégées (diffusées avec l'accord de leur auteur) sont exclues : `copyright=false`.
- Diffusion gratuite : les fichiers restent tels quels, avec la notice de licence de Project Gutenberg.
- Accès payant : 20 % de redevance sur les bénéfices à la Project Gutenberg Literary Archive Foundation, sauf si
  toute mention de Project Gutenberg est retirée des fichiers.
- Aucun accès automatisé à gutenberg.org (interdit par Project Gutenberg) : le catalogue vient d'une instance
  Gutendex hébergée par nous, les fichiers d'un miroir.

## Réglages (à l'activation)

| Réglage | Obligatoire | Rôle |
|---|---|---|
| `catalogBaseUrl` | oui | Instance Gutendex hébergée par nous, construite sur le catalogue hors ligne de Project Gutenberg (github.com/garethbjohnson/gutendex). |
| `filesBaseUrl` | oui | Miroir (privé ou officiel) qui sert `/cache/epub/<id>/`. Chaque fichier est récupéré une seule fois, puis servi par vovoscan. |
| `languages` | non (`en,fr`) | Langues du catalogue, codes ISO 639-1 séparés par des virgules. |

## Activation

```http
POST /api/v1/admin/sources            { "manifest": <source.json> }
PATCH /api/v1/admin/sources/gutenberg { "settings": { "catalogBaseUrl": "https://…", "filesBaseUrl": "https://…" },
                                        "rightsBasis": "public-domain", "status": "active" }
```
