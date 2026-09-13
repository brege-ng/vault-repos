#!/bin/bash

echo "================================="
echo " Tests d'accès Vault"
echo "================================="

echo ""
echo "===== TEST DEV ====="

echo ""
echo "--- Lecture APP DEV ---"

vault kv get secret/ligue/dev/app

echo ""
echo "--- Lecture DATABASE DEV ---"

vault kv get secret/ligue/dev/database

echo ""
echo "--- Liste DEV ---"

vault kv list secret/ligue/dev/

echo ""
echo "===== TEST PROD ====="

echo ""
echo "--- Lecture APP PROD ---"

vault kv get secret/ligue/prod/app

echo ""
echo "--- Lecture DATABASE PROD ---"

vault kv get secret/ligue/prod/database

echo ""
echo "===== CAPABILITIES ====="

echo ""
echo "--- DEV ---"

vault token capabilities secret/data/ligue/dev/app

echo ""
echo "--- PROD ---"

vault token capabilities secret/data/ligue/prod/app

echo ""
echo "================================="
echo " Tests terminés"
echo "================================="
