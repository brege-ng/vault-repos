# Policies Vault

## 1. Policy DEV

La policy DEV est stockée dans :

```text
policies/ligue-dev.hcl
```

Son objectif est de permettre au développeur de lire les secrets DEV.

### Accès aux données DEV

```hcl
path "secret/data/ligue/dev/*" {
  capabilities = ["read"]
}
```

### Accès aux métadonnées DEV

```hcl
path "secret/metadata/ligue/dev/*" {
  capabilities = ["list"]
}
```

Le développeur peut donc :

```text
DEV  → autorisé
PROD → refusé
```

---

## 2. Policy PROD

La policy PROD est stockée dans :

```text
policies/ligue-prod.hcl
```

Elle permet la lecture des secrets PROD :

```hcl
path "secret/data/ligue/prod/app" {
  capabilities = ["read"]
}

path "secret/data/ligue/prod/database" {
  capabilities = ["read"]
}
```

---

# 3. Enregistrer les policies dans Vault

## Policy DEV

```bash
vault policy write ligue-dev policies/ligue-dev.hcl
```

Vérifier :

```bash
vault policy read ligue-dev
```

## Policy PROD

```bash
vault policy write ligue-prod policies/ligue-prod.hcl
```

Vérifier :

```bash
vault policy read ligue-prod
```

## Lister les policies

```bash
vault policy list
```

---

# 4. Modifier les permissions DEV

Actuellement, le développeur possède uniquement :

```text
read
```

S'il doit pouvoir créer et modifier les secrets DEV :

```hcl
path "secret/data/ligue/dev/*" {
  capabilities = ["read", "create", "update"]
}

path "secret/metadata/ligue/dev/*" {
  capabilities = ["list"]
}
```

Les principales capabilities sont :

| Capability | Utilisation |
|---|---|
| `read` | Lire un secret |
| `create` | Créer un secret |
| `update` | Modifier un secret |
| `delete` | Supprimer un secret |
| `list` | Lister les chemins |

On évite de donner :

```text
delete
```

si le développeur n'en a pas besoin.

---

# 5. Principe du moindre privilège

Il ne faut pas donner au développeur :

```text
secret/ligue/*
```

car cela pourrait lui permettre d'accéder à :

```text
secret/ligue/dev/*
secret/ligue/prod/*
```

Il faut limiter son accès à :

```text
secret/ligue/dev/*
```

> Least Privilege — Principe du moindre privilège.

Donner uniquement les permissions nécessaires à l'utilisateur pour effectuer son travail.
