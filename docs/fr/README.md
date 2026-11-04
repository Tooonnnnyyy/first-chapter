# First Chapter

[English](../../README.md) · [Français](README.md) · [简体中文](../zh-CN/README.md)

Un guide libre qui aide les étudiants de première année à découvrir les services de la Bibliothèque de l’Université d’Ottawa : aide à la recherche, salles d’étude, emprunt de matériel et plan personnel.

**P0 : rendre les informations essentielles faciles à trouver et assurer le fonctionnement des fonctions annoncées.** Projet indépendant, commencé au concours Library AI Buildathon 2026, sous [licence MIT](../../LICENSE).

[Application Web](https://first-chapter-nine.vercel.app) · [Signaler un problème](https://github.com/Tooonnnnyyy/first-chapter/issues) · [Wiki](https://github.com/Tooonnnnyyy/first-chapter/wiki)

## État actuel

- iOS : accueil, recherche, liens vers le matériel, assistant facultatif et plan enregistré sur l’appareil.
- Web : recherche, découverte, liens et plan stocké dans le navigateur. Sur Vercel, un relais serveur DeepSeek peut prendre en charge l’assistant.
- API expérimentale Node/SQLite : catalogue, sessions anonymes, plans, classement explicable et premières quêtes/récompenses. **Les applications actuelles ne sont pas connectées à cette API.**

Les comptes OAuth, le nouveau fil vertical et les fonctions communautaires sont prévus. Le catalogue français existe, mais le choix de langue dans l’application reste à intégrer. La documentation traduite ne signifie pas que l’interface est traduite. L’importation de fichiers est une fonction annoncée pour plus tard. Les économies de clics sont des estimations, pas des résultats d’étude.

## Utilisation

### iOS

Sur macOS avec Xcode 26+ et un simulateur iOS 26+, ouvrir `FirstChapter.xcodeproj`, choisir le schéma FirstChapter et un simulateur iPhone, puis lancer Run. Aucune clé API n’est nécessaire : la recherche locale est le dernier recours de l’assistant et sa source est indiquée.

```sh
xcodebuild -project FirstChapter.xcodeproj -scheme FirstChapter \
  -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Avec un simulateur iPhone déjà démarré, `./scripts/run.sh` compile, installe et lance l’application sans demander de clé. L’ancienne intégration native avec une clé directe est réservée au développement privé. Ne jamais distribuer une application contenant une clé fournisseur. La validation complète de l’accessibilité et de DeepSeek reste à faire.

### Web et page de présentation

Depuis la racine du dépôt, avec Python 3 :

```sh
npm run serve:web
```

Ouvrir <http://127.0.0.1:8080>. Ce serveur ne fournit que des fichiers statiques : `/api/ask` n’y fonctionne pas et l’assistant utilise le recours local indiqué. Pour le relais facultatif, déployer `web/` sur Vercel et définir `DEEPSEEK_API_KEY` dans l’environnement serveur, jamais dans le navigateur. GitHub Actions ne déploie pas automatiquement sur Vercel.

Ouvrir `landing/index.html` pour la page autonome du produit. Les captures sont intégrées au HTML et montrent le prototype de novembre 2026 ; elles peuvent différer des versions suivantes.

### API expérimentale et vérifications

Node 24 est requis (`.node-version`). La racine et le serveur n’ont aucune dépendance npm à installer.

```sh
npm run start:server
# Dans un autre terminal :
curl http://127.0.0.1:8787/health
npm run check
npm test
```

La base SQLite se trouve dans `server/data/`, exclu de Git. Variables : `HOST`, `PORT`, `FC_DATA_DIR`. L’adresse par défaut est locale. L’API ne possède pas encore de cycle de vie complet des comptes, de limitation des requêtes ni de validation exhaustive ; conserver un usage local. Les tests ne prouvent pas le fonctionnement de toute l’interface.

L’ancien prototype React est dans `archive/geeguide-web/`. Pour l’exécuter : `npm ci`, `npm test`, `npm run build`, puis `npm start` dans ce dossier (port 4173).

## Organisation

| Chemin | Contenu |
| --- | --- |
| `FirstChapter/`, `FirstChapter.xcodeproj/` | Code SwiftUI et configuration Xcode |
| `web/` | Application Web maintenue et relais Vercel facultatif |
| `server/` | API expérimentale, tests et conteneur |
| `landing/` | Page autonome avec captures intégrées |
| `docs/en/`, `docs/fr/`, `docs/zh-CN/` | Documentation par langue |
| `docs/architecture/`, `docs/reference/` | Architecture, décisions et sources officielles |
| `docs/planning/`, `docs/reviews/`, `docs/history/` | Planification, revues et archives datées |
| `scripts/`, `.github/` | Compilation, vérification et automatisation GitHub |
| `archive/geeguide-web/` | Ancien prototype, distinct du déploiement actuel |

[Contribution et automatisation](maintenance.md) · [Architecture de référence (anglais)](../architecture/overview.md) · [Feuille de route (anglais)](../planning/v2-roadmap.md) · [Sources (anglais)](../reference/library-services.md)

Les systèmes officiels déterminent les horaires, les conditions d’emprunt, les réservations et les disponibilités. Projet non affilié à l’Université d’Ottawa et non approuvé par elle. Les marques et contenus externes conservent leurs droits.
