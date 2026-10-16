#!/bin/zsh
# Pince — installation ou mise à jour, sans compte GitHub et sans outil à installer :
#   curl -fsSL https://raw.githubusercontent.com/LucasHRCHatReply/pince-releases/main/installer.sh | zsh
# Le script télécharge la dernière version publiée, vérifie l'empreinte SHA-256, l'identifiant et l'équipe de signature
# (codesign --verify --deep --strict), puis lance install.sh du zip : Pince.app va dans ~/Applications, la quarantaine est
# levée sur Pince.app seulement, la commande `pince` est posée dans ~/.local/bin, l'app est lancée. Une instance de Pince
# qui tourne est quittée d'abord. Historique et réglages (~/Library/Application Support/Pince) ne sont jamais touchés.
# Aucun mot de passe administrateur. Le script se lit en entier avant de le lancer.
set -uo pipefail
ZIP_URL="${PINCE_ZIP_URL:-https://github.com/LucasHRCHatReply/pince-releases/releases/latest/download/Pince.zip}"
TEAM="JT9FY7PP7K"
BUNDLE_ID="fr.lucas.pince"
fail() { echo "\nÉCHEC : $*" >&2; exit 1; }
step() { echo "\n[$1/3] $2"; }

step 1 "Ce Mac convient-il ?"
macos=$(sw_vers -productVersion)
(( ${macos%%.*} >= 15 )) || fail "Pince demande macOS 15 ou plus (ce Mac : $macos)."
[[ "$(sysctl -n hw.optional.arm64 2>/dev/null)" == "1" ]] || fail "Pince ne tourne que sur les Mac à puce Apple (M1 ou plus récent)."
echo "  macOS $macos : ok"

step 2 "Téléchargement et contrôle"
WORK=$(mktemp -d "${TMPDIR:-/tmp}/pince-install.XXXXXX") || fail "dossier temporaire impossible"
trap 'rm -rf "$WORK"' EXIT
curl -fL --silent --show-error -o "$WORK/Pince.zip" "$ZIP_URL" || fail "téléchargement impossible (réseau coupé, ou aucune version publiée) : $ZIP_URL"
if curl -fL --silent -o "$WORK/Pince.zip.sha256" "$ZIP_URL.sha256" 2>/dev/null && [[ -s "$WORK/Pince.zip.sha256" ]]; then
  want=$(awk '{print $1; exit}' "$WORK/Pince.zip.sha256"); have=$(shasum -a 256 "$WORK/Pince.zip" | awk '{print $1}')
  [[ "$want" == "$have" ]] || fail "l'empreinte SHA-256 du zip ne correspond pas à celle publiée : installation refusée."
  echo "  empreinte SHA-256 : conforme"
else
  fail "l'empreinte SHA-256 publiée est introuvable : installation refusée."
fi
ditto -x -k "$WORK/Pince.zip" "$WORK/contenu" || fail "le zip est illisible"
DIR=$(ls -d "$WORK"/contenu/Pince-* 2>/dev/null | head -1)
[[ -n "$DIR" && -d "$DIR/Pince.app" && -f "$DIR/install.sh" ]] || fail "le zip n'a pas le contenu attendu (Pince-X.Y.Z/Pince.app et install.sh)."
[[ "$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$DIR/Pince.app/Contents/Info.plist" 2>/dev/null)" == "$BUNDLE_ID" ]] || fail "identifiant de l'app inattendu : installation refusée."
got=$(codesign -dv "$DIR/Pince.app" 2>&1 | sed -n 's/^TeamIdentifier=//p')
[[ "$got" == "$TEAM" ]] || fail "l'app n'est pas signée par l'équipe attendue ($TEAM) mais par « ${got:-aucune} » : installation refusée."
codesign --verify --deep --strict "$DIR/Pince.app" 2>/dev/null || fail "la signature de Pince.app est invalide : installation refusée."
NEW=$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$DIR/Pince.app/Contents/Info.plist")
echo "  Pince $NEW, signature valide, équipe $TEAM : ok  ($(du -h "$WORK/Pince.zip" | cut -f1))"

step 3 "Installation"
zsh "$DIR/install.sh" "$DIR/Pince.app" || fail "l'installation a échoué (voir le message ci-dessus)."
echo "\nTerminé."
