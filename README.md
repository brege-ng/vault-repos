# 🔐 HashiCorp Vault — Gestion des secrets, policies et utilisateurs

## 📑 Table des matières

- [📌 Objectif](#-objectif)
- [📂 Structure des secrets](#-structure-des-secrets)
- [🎯 Étapes de mise en place](#-étapes-de-mise-en-place)
- [⚙️ Configuration détaillée](#️-configuration-détaillée)
- [✅ Vérification et tests](#-vérification-et-tests)
- [📚 Concepts clés](#-concepts-clés)

---

## 📌 Objectif

Cette configuration permet de mettre en place une gestion des secrets avec **HashiCorp Vault** pour une application appelée `ligue`.

### Éléments à configurer

- ✅ Un moteur de secrets **KV v2**
- ✅ Des secrets DEV et PROD séparés
- ✅ Une policy `ligue-dev` pour les développeurs
- ✅ Une policy `ligue-prod` pour la production
- ✅ Une authentification `userpass`
- ✅ Des utilisateurs Vault (`dev1`, `dev2`, etc.)
- ✅ Séparation claire entre DEV et PROD
- ✅ Principe du **Least Privilege**

---

## 📂 Structure des secrets

```
secret/
└── ligue/
    ├── dev/
    │   ├── app
    │   └── database
    │
    └── prod/
        ├── app
        └── database
```

---

## 🎯 Étapes de mise en place

### Phase 1 : Préparation
- [Étape 1](#1-vérifier-vault) : Vérifier Vault
- [Étape 2](#2-se-connecter-à-vault) : Se connecter à Vault
- [Étape 3](#3-activer-le-moteur-de-secrets-kv-v2) : Activer le moteur KV v2

### Phase 2 : Création des secrets
- [Étape 4](#4-créer-les-secrets-dev) : Créer les secrets DEV
- [Étape 5](#5-créer-les-secrets-prod) : Créer les secrets PROD
- [Étape 6](#6-vérifier-les-secrets) : Vérifier les secrets

### Phase 3 : Création des policies
- [Étape 8](#8-créer-la-policy-dev) : Créer la policy DEV
- [Étape 10](#10-créer-la-policy-prod) : Créer la policy PROD

### Phase 4 : Authentification et utilisateurs
- [Étape 11](#11-activer-lauthentification-userpass) : Activer userpass
- [Étape 12](#12-créer-lutilisateur-dev) : Créer utilisateurs

### Phase 5 : Tests et validation
- [Étape 16](#16-tester-laccès-dev) : Tester accès DEV
- [Étape 18](#18-vérifier-les-capabilities) : Vérifier les capabilities

---

## ⚙️ Configuration détaillée

### 1. Vérifier Vault

**Vérifier la version :**
```bash
vault version
```

**Vérifier l'état de Vault :**
```bash
vault status
```

---

### 2. Se connecter à Vault

Se connecter avec un compte disposant des droits d'administration :

```bash
vault login
```

> ⚠️ Le token utilisé doit avoir les permissions nécessaires pour créer les secrets, policies et utilisateurs.

---

### 3. Activer le moteur de secrets KV v2

Si le moteur `secret/` n'existe pas encore :

```bash
vault secrets enable -path=secret kv-v2
```

**Vérifier les moteurs de secrets :**
```bash
vault secrets list
```

Résultat attendu :
```
Path      Type
----      ----
secret/   kv
```

---

### 4. Créer les secrets DEV

#### Secret de l'application DEV

```bash
vault kv put secret/ligue/dev/app \
  APP_KEY="TON_APP_KEY_DEV"
```

#### Secret de la base de données DEV

```bash
vault kv put secret/ligue/dev/database \
  DB_USERNAME="ligue_user" \
  DB_PASSWORD="TON_MOT_DE_PASSE_DB_DEV"
```

> ⚠️ Ne jamais mettre de vrais secrets directement dans Git.

---

### 5. Créer les secrets PROD

#### Secret de l'application PROD

```bash
vault kv put secret/ligue/prod/app \
  APP_KEY="TON_APP_KEY_PROD"
```

#### Secret de la base de données PROD

```bash
vault kv put secret/ligue/prod/database \
  DB_USERNAME="ligue_user" \
  DB_PASSWORD="TON_MOT_DE_PASSE_DB_PROD"
```

> 💡 Utiliser des secrets différents entre DEV et PROD.

---

### 6. Vérifier les secrets

**Lister le contenu de `secret/ligue/` :**
```bash
vault kv list secret/ligue/
```

**Lister les secrets DEV :**
```bash
vault kv list secret/ligue/dev/
```

**Lister les secrets PROD :**
```bash
vault kv list secret/ligue/prod/
```

---

### 7. Lire les secrets

```bash
# DEV
vault kv get secret/ligue/dev/app
vault kv get secret/ligue/dev/database

# PROD
vault kv get secret/ligue/prod/app
vault kv get secret/ligue/prod/database
```

---

### 8. Créer la policy DEV

**Créer le fichier `ligue-dev.hcl` :**

```bash
nano ligue-dev.hcl
```

**Contenu du fichier :**

```hcl
path "secret/data/ligue/dev/*" {
  capabilities = ["read"]
}

path "secret/metadata/ligue/dev/*" {
  capabilities = ["list"]
}
```

**Sauvegarder :** `CTRL + O` → `ENTER` → `CTRL + X`

#### Explication de la policy DEV

| Chemin | Capability | Signification |
|--------|-----------|---------------|
| `secret/data/ligue/dev/*` | `read` | Lire les secrets DEV |
| `secret/metadata/ligue/dev/*` | `list` | Lister les chemins DEV |

**Accès refusé :**
```
secret/data/ligue/prod/* → REFUSÉ
```

---

### 9. Enregistrer la policy DEV dans Vault

```bash
vault policy write ligue-dev ligue-dev.hcl
```

**Vérifier la policy :**
```bash
vault policy read ligue-dev
```

**Lister toutes les policies :**
```bash
vault policy list
```

---

### 10. Créer la policy PROD

**Créer le fichier `ligue-prod.hcl` :**

```bash
nano ligue-prod.hcl
```

**Contenu :**

```hcl
path "secret/data/ligue/prod/app" {
  capabilities = ["read"]
}

path "secret/data/ligue/prod/database" {
  capabilities = ["read"]
}
```

**Enregistrer dans Vault :**

```bash
vault policy write ligue-prod ligue-prod.hcl
```

---

### 11. Activer l'authentification `userpass`

```bash
vault auth enable userpass
```

**Vérifier :**
```bash
vault auth list
```

---

### 12. Créer l'utilisateur DEV

**Créer `dev1` :**

```bash
vault write auth/userpass/users/dev1 \
  password="MotDePasseFort" \
  policies="ligue-dev"
```

**Vérifier :**
```bash
vault read auth/userpass/users/dev1
```

#### Flux d'authentification

```
dev1
 ├─ userpass
 ├─ policy ligue-dev
 └─ accès secret/ligue/dev/*
```

---

### 13. Créer un deuxième développeur

```bash
vault write auth/userpass/users/dev2 \
  password="MotDePasseFort" \
  policies="ligue-dev"
```

---

### 14. Se connecter en tant que `dev1`

```bash
vault login -method=userpass username=dev1
```

Entrer le mot de passe défini lors de la création.

**Vérifier le token :**
```bash
vault token lookup
```

Le token doit être associé à la policy `ligue-dev`.

---

### 15. Modifier le mot de passe d'un développeur

```bash
vault write auth/userpass/users/dev1 \
  password="NouveauMotDePasseFort" \
  policies="ligue-dev"
```

---

### 16. Supprimer un utilisateur

```bash
vault delete auth/userpass/users/dev1
```

---

### 17. Associer plusieurs policies

```bash
vault write auth/userpass/users/dev1 \
  password="MotDePasseFort" \
  policies="ligue-dev,autre-policy"
```

---

### 18. Supprimer un secret

```bash
vault kv delete secret/ligue/dev/app
vault kv delete secret/ligue/dev/database
```

> 💡 KV v2 utilise un système de versions. Une suppression ne signifie pas une destruction définitive.

---

## ✅ Vérification et tests

### 16. Tester l'accès DEV

**Lire le secret de l'application DEV :**
```bash
vault kv get secret/ligue/dev/app
```
✅ Cette commande doit fonctionner.

**Lire la base DEV :**
```bash
vault kv get secret/ligue/dev/database
```
✅ Cette commande doit fonctionner.

**Lister les secrets DEV :**
```bash
vault kv list secret/ligue/dev/
```
✅ Cette commande doit fonctionner.

---

### 17. Tester l'accès PROD

**Essayer de lire l'application PROD :**
```bash
vault kv get secret/ligue/prod/app
```
❌ Cette commande doit être **refusée**.

**Essayer de lire la base PROD :**
```bash
vault kv get secret/ligue/prod/database
```
❌ Cette commande doit être **refusée**.

Erreur attendue :
```
permission denied
```

---

### 18. Vérifier les capabilities

Les capabilities permettent de vérifier ce que le token actuel peut faire.

**Vérifier l'accès DEV :**
```bash
vault token capabilities secret/data/ligue/dev/app
```
Résultat : `read` ✅

**Vérifier l'accès PROD :**
```bash
vault token capabilities secret/data/ligue/prod/app
```
Résultat : `deny` ❌

---

## 📚 Concepts clés

### Chemins KV v2

Avec la CLI, on utilise :
```bash
vault kv get secret/ligue/dev/app
```

Mais dans une policy KV v2, le chemin de données est :
```
secret/data/ligue/dev/*
```

Pour le listing, on utilise :
```
secret/metadata/ligue/dev/*
```

#### Structure KV v2

```
secret/
├── data/          (données des secrets)
└── metadata/      (métadonnées et versions)
```

---

### Capabilities disponibles

| Capability | Utilisation |
|-----------|-------------|
| `read` | Lire un secret |
| `create` | Créer un secret |
| `update` | Modifier un secret |
| `delete` | Supprimer un secret |
| `list` | Lister les chemins |

**Exemple avec permissions étendues :**

```hcl
path "secret/data/ligue/dev/*" {
  capabilities = ["read", "create", "update"]
}

path "secret/metadata/ligue/dev/*" {
  capabilities = ["list"]
}
```

---

### Principe du Least Privilege

❌ **À éviter :**
```
secret/ligue/*
```
Cela permettrait d'accéder à DEV ET PROD.

✅ **À faire :**
```
secret/ligue/dev/*
```
Accès limité au strict nécessaire.

> **Donner uniquement les permissions nécessaires à l'utilisateur pour effectuer son travail.**

---

### Authentification vs Policy

#### Authentification
**Question :** "Qui es-tu ?"

```bash
vault login -method=userpass username=dev1
```

Vault vérifie les identifiants.

#### Policy
**Question :** "Qu'as-tu le droit de faire ?"

```
dev1 → policy ligue-dev → secret/ligue/dev/* → READ
```

#### Flux complet

```
┌─────────────────────────────────┐
│   AUTHENTIFICATION              │
│   (Qui es-tu ?)                 │
├─────────────────────────────────┤
│   dev1 avec userpass            │
├─────────────────────────────────┤
│   POLICY ligue-dev              │
│   (Qu'as-tu le droit de faire ?)│
├─────────────────────────────────┤
│   secret/ligue/dev/*            │
├─────────────────────────────────┤
│   READ (Lire les secrets)       │
└─────────────────────────────────┘
```

---

### Architecture finale

```
                    VAULT
                      │
        ┌─────────────┼─────────────┐
        │                           │
       DEV                         PROD
        │                           │
   secret/ligue/dev/          secret/ligue/prod/
        │                           │
    ┌───┴───┐                   ┌───┴───┐
    │       │                   │       │
   app  database               app  database
    │
    │
 Policy ligue-dev
    │
  ┌─┴─┐
  │   │
 dev1 dev2
  │
  ├─→ READ DEV
  │
  └─→ DENY PROD
```

---

## 📝 Résumé de ce que dev1 peut faire

**Utilisateur :**
```
dev1
```

**Policy :**
```
ligue-dev
```

**Accès autorisé :**

| Chemin | Action | Résultat |
|--------|--------|----------|
| `secret/ligue/dev/app` | READ | ✅ Autorisé |
| `secret/ligue/dev/database` | READ | ✅ Autorisé |
| `secret/ligue/prod/*` | Tout | ❌ Refusé |

---

## 🔗 Fichiers de configuration

### ligue-dev.hcl

```hcl
path "secret/data/ligue/dev/*" {
  capabilities = ["read"]
}

path "secret/metadata/ligue/dev/*" {
  capabilities = ["list"]
}
```

### ligue-prod.hcl

```hcl
path "secret/data/ligue/prod/app" {
  capabilities = ["read"]
}

path "secret/data/ligue/prod/database" {
  capabilities = ["read"]
}
```

---

## 💡 Conseils de sécurité

- ✅ Toujours utiliser des mots de passe forts et uniques
- ✅ Limiter les capabilities au strict nécessaire
- ✅ Séparer DEV et PROD
- ✅ Auditer régulièrement qui accède à quoi
- ❌ Ne jamais partager les credentials
- ❌ Ne jamais committer les vrais secrets
- ❌ Ne pas donner `delete` sans nécessité

---

**Dernière mise à jour :** 2026-09-13
