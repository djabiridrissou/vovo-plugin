# vovo-plugin

Sources de contenu de vovoscan, décrites par des **manifestes de règles JSON** : aucun code, seulement des
requêtes vers les hôtes déclarés et des extractions (JSONPath, sélecteurs CSS) suivies de transformations connues.
Le serveur vovoscan les installe, les active (droits et réglages exigés) et distribue leur manifeste ; **l'appli
mobile les interprète et fait elle-même les requêtes** (`vovoscan-mob`, `core/sources`) : leur contenu ne passe
jamais par nos serveurs. Le backend valide le contrat (`vovoscan check-source`).

## Contenu

```
schema/source.schema.json      contrat v1 (copie de vovoscan-be : src/vovoscan/features/catalog/domain/contract/)
sources/<clé>/source.json      un manifeste par source
sources/<clé>/README.md        droits, réglages, activation
scripts/check.sh               valide tous les manifestes avec le contrat du backend
```

## Vérifier

```bash
scripts/check.sh          # backend voisin (../backend ou ../vovoscan-be), ou VOVOSCAN_BE=<chemin>
```

## Écrire une source

- `kinds` : `comic`, `book` (servis aujourd'hui), `audiobook`, `video` (prévus par le contrat). Chaque type déclaré
  a ses règles dans `content` (`comic` : liste de pages ; `book` : fichier EPUB).
- Sections : `catalog` (liste paginée, recherche par `{{search}}`), `title` (fiche + unités : liste, ou `single`
  pour un livre d'un seul fichier), `content`.
- Valeurs : un JSONPath (`"$.title"`), ou `{ "path" | "css" | "const" | "template", "attr", "all", "then": [...],
  "default" }`. Transformations : `trim`, `collapseSpaces`, `string`, `number`, `integer`, `lower`, `absUrl`,
  `first`, `notNull`, `regex`, `replace`, `join`, `map`, `pluck`, `format`.
- Modèles : `{{settings.<réglage>}}`, `{{page}}`, `{{search}}`, `{{lang}}`, `{{id}}` (titre), `{{unitId}}` (unité).
- Hôtes : l'appli ne contacte que ceux de `hosts` et des réglages de type `url`, avec un client HTTP séparé qui
  n'envoie jamais la session vovoscan.
- **Droits** : `rights.basis` vaut `public-domain` ou `licensed`, et `rights.notes` dit les conditions de la source.
  Le backend refuse d'activer une source sans base de droits confirmée par un admin (preuve exigée pour `licensed`).
  Pas de source qui contourne une protection (CAPTCHA, anti-bot) ni qui viole les conditions d'un site.
- Le schéma change dans le backend d'abord, puis il est recopié ici (`scripts/check.sh` vérifie qu'ils sont égaux).
  Le manifeste Gutenberg a une copie dans les tests du backend (`tests/fixtures/sources/gutenberg.json`).

## Branches et commits

`v1` est la branche principale (pull request vers `v1`). Messages de commit en français, sans pied de page ni
ligne `Co-Authored-By`.
