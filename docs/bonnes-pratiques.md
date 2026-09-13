# Bonnes pratiques de sécurité

## 1. Ne jamais mettre les secrets dans Git

Éviter de mettre de vrais secrets dans :

```text
.env
config.php
application.yml
docker-compose.yml
```

avec de vrais mots de passe ou clés API.

Les secrets doivent être stockés dans Vault.

---

# 2. Utiliser des secrets différents entre DEV et PROD

Éviter :

```text
DEV DB_PASSWORD = PROD DB_PASSWORD
```

Préférer :

```text
DEV  → secret différent
PROD → secret différent
```

---

# 3. Utiliser le principe du moindre privilège

Un développeur qui travaille uniquement sur DEV ne devrait pas recevoir :

```text
secret/ligue/*
```

mais uniquement :

```text
secret/ligue/dev/*
```

---

# 4. Ne pas utiliser un compte administrateur pour l'application

Un compte administrateur Vault ne doit pas être utilisé par une application.

Préférer :

```text
Application
    |
    v
Identité dédiée
    |
    v
Policy dédiée
    |
    v
Secrets nécessaires uniquement
```

---

# 5. Séparer DEV et PROD

Un développeur DEV ne doit pas avoir automatiquement accès aux secrets PROD.

```text
DEV
 |
 +--> ligue-dev
       |
       +--> READ DEV

PROD
 |
 +--> ligue-prod
       |
       +--> READ PROD
```

---

# 6. Identité dédiée pour les applications

Pour une application de production, il est préférable d'utiliser une identité Vault dédiée avec une policy limitée aux secrets dont elle a réellement besoin.
