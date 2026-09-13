#!/bin/bash

set -e

echo "================================="
echo " Création des policies Vault"
echo "================================="

echo ""
echo "Création de la policy DEV..."

vault policy write ligue-dev policies/ligue-dev.hcl

echo ""
echo "Création de la policy PROD..."

vault policy write ligue-prod policies/ligue-prod.hcl

echo ""
echo "Policies créées avec succès."

echo ""
echo "Policies disponibles :"

vault policy list
