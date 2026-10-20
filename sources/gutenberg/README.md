# Project Gutenberg

Livres classiques du catalogue Project Gutenberg, du domaine public aux États-Unis. Type : `book` (EPUB).

## Droits

- Textes du domaine public aux **États-Unis** seulement. Ailleurs (Togo, Ghana, France…), la durée de protection
  dépend du pays (vie de l'auteur + 50 ou 70 ans) : à vérifier avant d'ouvrir la source dans un pays.
- Les quelques œuvres encore protégées (diffusées avec l'accord de leur auteur) sont exclues : `copyright=false`.
- Diffusion gratuite : les fichiers restent tels quels, avec la notice de licence de Project Gutenberg.
- Accès payant : 20 % de redevance sur les bénéfices à la Project Gutenberg Literary Archive Foundation, sauf si
  toute mention de Project Gutenberg est retirée des fichiers.
- L'appli de chaque lecteur interroge le catalogue et télécharge le livre qu'il ouvre (comme un navigateur) ;
  jamais de récolte en masse. Project Gutenberg interdit l'accès automatisé à gutenberg.org : le catalogue vient
  d'une instance Gutendex (la nôtre de préférence, l'instance publique demande d'en héberger une pour un usage
  durable), les fichiers d'un miroir.

## Réglages (à l'activation)

| Réglage | Obligatoire | Rôle |
|---|---|---|
| `catalogBaseUrl` | oui | Instance Gutendex hébergée par nous, construite sur le catalogue hors ligne de Project Gutenberg (github.com/garethbjohnson/gutendex). |
| `filesBaseUrl` | oui | Miroir (privé ou officiel) qui sert `/cache/epub/<id>/`, d'où l'appli télécharge le livre ouvert. |
| `languages` | non (`en,fr`) | Langues du catalogue, codes ISO 639-1 séparés par des virgules. |

## Activation

```http
POST /api/v1/admin/sources            { "manifest": <source.json> }
PATCH /api/v1/admin/sources/gutenberg { "settings": { "catalogBaseUrl": "https://…", "filesBaseUrl": "https://…" },
                                        "rightsBasis": "public-domain", "status": "active" }
```
