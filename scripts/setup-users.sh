#!/bin/bash

set -e

echo "================================="
echo " Création des utilisateurs Vault"
echo "================================="

echo ""
echo "Activation de userpass..."

vault auth enable userpass 2>/dev/null || true

echo ""
echo "Création de dev1..."

vault write auth/userpass/users/dev1 \
  password="MotDePasseFort" \
  policies="ligue-dev"

echo ""
echo "Création de dev2..."

vault write auth/userpass/users/dev2 \
  password="MotDePasseFort" \
  policies="ligue-dev"

echo ""
echo "Utilisateurs créés avec succès."
