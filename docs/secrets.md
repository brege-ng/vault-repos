# Gestion des secrets

## Organisation

Les secrets sont organisés comme ceci :

```text
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

# 1. Créer les secrets DEV

## Secret de l'application DEV

```bash
vault kv put secret/ligue/dev/app \
  APP_KEY="TON_APP_KEY_DEV"
```

## Secret de la base de données DEV

```bash
vault kv put secret/ligue/dev/database \
  DB_USERNAME="ligue_user" \
  DB_PASSWORD="TON_MOT_DE_PASSE_DB_DEV"
```

Les valeurs utilisées ici sont des exemples.

> Ne jamais mettre de vrais secrets directement dans Git.

---

# 2. Créer les secrets PROD

## Secret de l'application PROD

```bash
vault kv put secret/ligue/prod/app \
  APP_KEY="TON_APP_KEY_PROD"
```

## Secret de la base de données PROD

```bash
vault kv put secret/ligue/prod/database \
  DB_USERNAME="ligue_user" \
  DB_PASSWORD="TON_MOT_DE_PASSE_DB_PROD"
```

Il est recommandé d'utiliser des secrets différents entre DEV et PROD.

---

# 3. Vérifier les secrets

## Lister `secret/ligue/`

```bash
vault kv list secret/ligue/
```

## Lister DEV

```bash
vault kv list secret/ligue/dev/
```

## Lister PROD

```bash
vault kv list secret/ligue/prod/
```

---

# 4. Lire les secrets

## Application DEV

```bash
vault kv get secret/ligue/dev/app
```

## Base DEV

```bash
vault kv get secret/ligue/dev/database
```

## Application PROD

```bash
vault kv get secret/ligue/prod/app
```

## Base PROD

```bash
vault kv get secret/ligue/prod/database
```

---

# 5. Comprendre les chemins KV v2

Avec la CLI, on utilise :

```bash
vault kv get secret/ligue/dev/app
```

Mais dans une policy KV v2, le chemin de données est :

```text
secret/data/ligue/dev/*
```

Pour le listing :

```text
secret/metadata/ligue/dev/*
```

C'est normal.

KV v2 sépare notamment :

```text
secret/
   |
   +-- data/
   |
   +-- metadata/
```

---

# 6. Supprimer un secret

Supprimer le secret DEV de l'application :

```bash
vault kv delete secret/ligue/dev/app
```

Supprimer le secret DEV de la base :

```bash
vault kv delete secret/ligue/dev/database
```

> KV v2 utilise un système de versions. Une suppression avec `vault kv delete` ne signifie pas nécessairement une destruction définitive de toutes les versions.
