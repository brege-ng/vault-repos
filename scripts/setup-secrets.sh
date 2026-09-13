#!/bin/bash

set -e

echo "================================="
echo " Création des secrets Vault"
echo "================================="

echo ""
echo "Création des secrets DEV..."

vault kv put secret/ligue/dev/app \
  APP_KEY="TON_APP_KEY_DEV"

vault kv put secret/ligue/dev/database \
  DB_USERNAME="ligue_user" \
  DB_PASSWORD="TON_MOT_DE_PASSE_DB_DEV"

echo ""
echo "Création des secrets PROD..."

vault kv put secret/ligue/prod/app \
  APP_KEY="TON_APP_KEY_PROD"

vault kv put secret/ligue/prod/database \
  DB_USERNAME="ligue_user" \
  DB_PASSWORD="TON_MOT_DE_PASSE_DB_PROD"

echo ""
echo "Secrets créés avec succès."
