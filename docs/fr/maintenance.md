# Contribuer et maintenir First Chapter

[Utilisation](README.md) · [English](../en/maintenance.md) · [简体中文](../zh-CN/maintenance.md)

## Contribution

Créer ou choisir une issue avec un besoin étudiant et des critères observables. P0 concerne une fonction essentielle défaillante ou un problème de confidentialité bloquant ; P1 désigne l’amélioration suivante ; P2 le travail ultérieur. Consulter aussi les priorités du plan v2 et la répartition des tâches. Créer une branche depuis `main` à jour, sans écrire directement sur `main`.

Faire une modification ciblée, conserver les sources officielles, actualiser les traductions et exécuter les vérifications du README. Une modification Swift exige une compilation pour simulateur ; une modification d’interface exige une vérification interactive et d’accessibilité. Ouvrir une PR liée à l’issue, expliquer le résultat et les tests, résoudre les discussions et attendre les contrôles requis. Ne pas prétendre avoir reçu une revue indépendante si ce n’est pas le cas.

Les contributions en anglais, français et chinois sont bienvenues. Les identifiants du code restent stables. Signaler ce qui n’est pas traduit ; la documentation multilingue ne garantit pas une interface multilingue. Respecter le [code de conduite](../../CODE_OF_CONDUCT.md).

## Automatisation GitHub

| Outil | Déclenchement | Effet |
| --- | --- | --- |
| CI | PR, push sur main ou manuel | Liens et sources, tests API/archive, compilation iOS sans signature, test de santé du conteneur |
| Security | PR, main et chaque semaine | Analyse des dépendances de la PR et analyse CodeQL JavaScript/TypeScript |
| Source release | Tag `v*` publié | Valide la version et son appartenance à main, teste et crée une **version brouillon** avec archive et somme SHA-256 |
| Publish experimental API container | Manuel, main seulement | Publie une image GHCR liée au commit ; ne déploie pas de serveur |
| Wiki navigation | Documentation modifiée sur main ou manuel | Produit un artefact multilingue ; synchronisation seulement avec le secret `WIKI_TOKEN` |
| Dependabot | Actions chaque semaine, npm archivé chaque mois | Propose des PR de mise à jour, sans fusion automatique |

Dans **Actions**, ouvrir une exécution puis un job pour lire ses journaux. Le vert confirme uniquement ces contrôles, pas toute l’interface ni la sécurité d’un déploiement. En cas d’échec, corriger la première étape défaillante sur la même branche et pousser la correction. Aucun compte cloud payant n’est configuré.

## Versions et paquets

Un tag Git nomme un commit ; une Release GitHub lui ajoute des notes et des fichiers. Après validation d’un commit sur main et mise à jour du CHANGELOG, créer un tag annoté, par exemple `v0.1.0-alpha.1`, puis pousser ce tag précis. Le workflow crée un brouillon à relire avant publication. Utiliser des préversions tant que la validation complète n’est pas terminée. Ce n’est ni une application iOS signée ni un déploiement. Ne pas remplacer un tag publié ; utiliser une nouvelle version ou une PR de retour arrière.

Le paquet racine est privé et contient les commandes de développement ; le serveur n’a aucune dépendance npm. Aucun des deux n’est publié sur npm. L’ancien prototype React possède son propre lockfile (`npm ci`).

Le Dockerfile du serveur utilise un compte non privilégié. Avec Docker installé :

```sh
docker build -t first-chapter-api:local server
docker run --rm -p 127.0.0.1:8787:8787 -v first-chapter-data:/data first-chapter-api:local
```

Le volume conserve la base après l’arrêt ; sa suppression efface les données. La publication manuelle utilise `ghcr.io/tooonnnnyyy/first-chapter/api:sha-<commit-complet>`, sans tag `latest`. Vérifier la visibilité du paquet : elle est distincte de celle du dépôt. L’API reste expérimentale, même publiée. L’application native et le site statique n’ont pas besoin de ce paquet.

## Wiki, données et organisation

La documentation versionnée reste la référence. GitHub exige une première page Wiki créée dans l’interface avant l’existence du dépôt `.wiki.git`. Le workflow produit toujours un artefact ; la synchronisation nécessite un jeton dédié, limité aux droits nécessaires sur le Wiki, enregistré comme secret Actions `WIKI_TOKEN`. Ne jamais le mettre dans le code. Sans ce secret, copier les pages générées manuellement dans le Wiki initialisé.

Les plans actuels restent sur l’appareil/dans le navigateur. Un assistant facultatif peut transmettre la question à un fournisseur : éviter les données sensibles. Ne pas joindre de données étudiantes, jetons ou bases aux issues. Consulter [SECURITY](../../SECURITY.md) et les [limites de l’API](../architecture/overview.md) avant tout hébergement.

Les dossiers applicatifs restent stables pour les branches en cours. L’[architecture](../architecture/overview.md), la [feuille de route](../planning/v2-roadmap.md), les sources et les archives ont une référence anglaise ; ce guide et le README en donnent une synthèse traduite.
