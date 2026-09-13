# Architecture Vault

## Architecture logique complète

```text
                                  VAULT
                                    |
                    +---------------+---------------+
                    |                               |
              AUTHENTICATION                  SECRET ENGINE
                    |                               |
                 userpass                          KV v2
                    |                               |
             +------+-------+               +-------+-------+
             |              |               |               |
            dev1           dev2            DEV             PROD
             |              |               |               |
             +------+-------+         secret/ligue/   secret/ligue/
                    |                       dev/          prod/
                    v                         |               |
              Policy ligue-dev          +----+----+      +----+----+
                    |                    |         |      |         |
                    |                   app    database   app   database
                    |
              +-----+-----+
              |           |
             READ        LIST
              |
              v
             DEV

             PROD
               |
               v
              DENY
```

---

# Flux d'authentification

Lorsqu'un développeur se connecte :

```text
USER
 |
 | username + password
 v
USERPASS
 |
 | authentification
 v
VAULT TOKEN
 |
 v
POLICY ligue-dev
 |
 v
secret/data/ligue/dev/*
 |
 v
READ
```

Le développeur n'a donc pas besoin de connaître un token administrateur.

---

# Flux d'autorisation

Lorsqu'un utilisateur tente d'accéder à un secret :

```text
dev1
 |
 v
Token Vault
 |
 v
Policy ligue-dev
 |
 +------> DEV  → ALLOW
 |
 +------> PROD → DENY
```

Exemple DEV :

```text
secret/data/ligue/dev/app
        |
        +--> read
```

Exemple PROD :

```text
secret/data/ligue/prod/app
        |
        +--> deny
```

---

# Différence entre DEV et PROD

| Élément | DEV | PROD |
|---|---|---|
| Secrets | Oui | Oui |
| Policy | `ligue-dev` | `ligue-prod` |
| Développeur `dev1` | Oui | Non |
| Lecture DEV | Oui | Selon policy |
| Lecture PROD | Non | Oui avec policy dédiée |
| Accès administrateur | Non | Non |
| Token admin | Non | Non |

---

# Fonctionnement général

```text
AUTHENTIFICATION
       |
       v
     dev1
       |
       v
     TOKEN
       |
       v
     POLICY
       |
       v
secret/ligue/dev/*
       |
       v
      READ
```

La logique fondamentale est :

```text
AUTHENTIFICATION
       ↓
      QUI ?
       ↓
     dev1
       ↓
  AUTH USERPASS
       ↓
     TOKEN
       ↓
  AUTORISATION
       ↓
     POLICY
       ↓
QUE PEUT-IL FAIRE ?
       ↓
    READ DEV
       ↓
   DENY PROD
```
