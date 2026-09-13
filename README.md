# HashiCorp Vault — Gestion des secrets

Configuration de HashiCorp Vault pour une application appelée `ligue`.

## 🎯 Objectif

Cette configuration permet de mettre en place une gestion des secrets avec HashiCorp Vault.

L'organisation des secrets est la suivante :

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

## 🔐 Fonctionnalités

- Moteur de secrets KV v2
- Secrets DEV et PROD
- Policy `ligue-dev`
- Policy `ligue-prod`
- Authentification `userpass`
- Utilisateur Vault `dev1`
- Utilisateur Vault `dev2`
- Tests d'accès DEV / PROD
- Vérification des capabilities
- Séparation DEV / PROD
- Principe du moindre privilège

## 📁 Structure du projet

```text
vault-repos/
│
├── README.md
│
├── docs/
│   ├── architecture.md
│   ├── bonnes-pratiques.md
│   ├── concepts.md
│   ├── installation.md
│   ├── policies.md
│   ├── secrets.md
│   ├── tests.md
│   └── users.md
│
├── policies/
│   ├── ligue-dev.hcl
│   └── ligue-prod.hcl
│
└── scripts/
    ├── setup-policies.sh
    ├── setup-secrets.sh
    ├── setup-users.sh
    └── test-access.sh
```

## 📚 Documentation

### Concepts clés

[Concepts fondamentaux de Vault](docs/concepts.md)

### Installation

[Installation et vérification de Vault](docs/installation.md)

### Secrets

[Gestion des secrets](docs/secrets.md)

### Policies

[Gestion des policies](docs/policies.md)

### Utilisateurs

[Gestion des utilisateurs](docs/users.md)

### Tests

[Tests d'accès](docs/tests.md)

### Architecture

[Architecture de Vault](docs/architecture.md)

### Bonnes pratiques

[Bonnes pratiques de sécurité](docs/bonnes-pratiques.md)

## 🔐 Principe de sécurité

Un développeur travaillant sur DEV doit uniquement accéder aux secrets DEV.

```text
dev1
 |
 v
userpass
 |
 v
Token Vault
 |
 v
Policy ligue-dev
 |
 +----> DEV  → ALLOW
 |
 └----> PROD → DENY
```

## ⚠️ Sécurité

Ne jamais mettre de vrais secrets, mots de passe ou clés API dans Git.

Les valeurs présentes dans les exemples sont fictives.

## 🚀 Prochaine étape

Connecter une application à Vault afin qu'elle récupère ses secrets sans les stocker directement dans le code ou dans un fichier `.env`.
