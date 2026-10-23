# Pince pour macOS

Pince garde tout ce que vous copiez (texte, liens, images, fichiers, couleurs, tableaux, code), le retrouve vite et le
recolle dans l'app où vous travaillez. L'app vit dans la barre des menus (icône de trombone) ; ⇧⌘V ouvre le panneau.
Les secrets (clés, jetons, cartes) sont détectés et effacés du disque au bout de 2 minutes, les e-mails et numéros
sont floutés dans le panneau. Tout reste sur le Mac : aucun compte, aucune télémétrie.

Ce dépôt ne contient que les versions à installer. Le code source n'est pas public.

## Ce qu'il faut

- un Mac à puce Apple (M1 ou plus récent) ;
- macOS 15 ou plus (verre natif sous macOS 26) ;
- si Paste ou un autre gestionnaire de presse-papiers est ouvert : n'en garder qu'un seul actif.

Aucun compte GitHub, aucun outil à installer, aucun mot de passe administrateur.

## Installer

**Une commande dans Terminal (la plus sûre).** Dans Terminal (Cmd + Espace, « Terminal »), une seule commande, qui installe aussi les mises à jour :

```
curl -fsSL https://raw.githubusercontent.com/LucasHRCHatReply/pince-releases/main/installer.sh | zsh
```

Le script télécharge la dernière version, vérifie l'empreinte SHA-256 du zip, l'identifiant de l'app et sa signature
(équipe Apple `JT9FY7PP7K`, `codesign --verify --deep --strict`), copie `Pince.app` dans `~/Applications`, pose la
commande `pince` dans `~/.local/bin`, puis ouvre l'app. Il garde l'historique et les réglages. Au premier lancement,
un didacticiel de cinq écrans fait essayer Pince ; il se rouvre depuis Aide › Didacticiel.

**Ou le fichier d'installation.** Télécharger [Pince.dmg](https://github.com/LucasHRCHatReply/pince-releases/releases/latest/download/Pince.dmg), l'ouvrir, puis glisser Pince dans Applications. Au premier lancement macOS refuse d'ouvrir l'app (voir l'avertissement plus bas) : clic droit sur Pince › Ouvrir, ou Réglages Système › Confidentialité et sécurité › « Ouvrir quand même ».

Une autorisation facultative : pour que Retour colle tout seul, Réglages Système › Confidentialité et sécurité ›
Accessibilité › Pince. Sans elle, Pince copie l'élément et vous collez avec ⌘V.

## Avertissement : app non validée par Apple

Pince est signée mais pas « notarisée » : cela demande un compte développeur payant. macOS la juge donc non vérifiée au
premier lancement. Le script retire pour cela le blocage du premier lancement (l'attribut de quarantaine posé par le
téléchargement), seulement sur `Pince.app`. À ne lancer que si vous faites confiance à l'auteur ; le script se lit en
entier : [installer.sh](installer.sh). Le contrôle d'équipe et d'empreinte protège contre un zip altéré en route, pas
contre quelqu'un qui détiendrait aussi ce dépôt.

## Mettre à jour

Dans l'app : icône du menu › « Mettre à jour… ». Pince interroge alors GitHub (et seulement alors : elle ne se connecte
jamais d'elle-même), propose la nouvelle version, contrôle sa signature et remplace l'app. Ou relancer la commande
ci-dessus. Journal de la mise à jour : `~/Library/Logs/Pince-mise-a-jour.log`.

## Désinstaller

Télécharger le zip de la dernière version dans les [Releases](../../releases/latest), le décompresser, puis lancer
`./uninstall.sh` dans le dossier `Pince-X.Y.Z` : l'app et la commande sont supprimées, et le script demande avant
d'effacer l'historique.
