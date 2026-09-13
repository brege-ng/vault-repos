# HashiCorp Vault — Gestion des secrets, policies et utilisateurs

## 📌 Objectif

Cette configuration permet de mettre en place une gestion des secrets avec **HashiCorp Vault** pour une application appelée `ligue`.

L'organisation des secrets sera la suivante :

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

Nous allons mettre en place :

* un moteur de secrets **KV v2**
* des secrets DEV et PROD
* une policy `ligue-dev`
* une policy `ligue-prod`
* une authentification `userpass`
* un utilisateur Vault `dev1`
* un utilisateur Vault `dev2`
* des tests d'accès DEV / PROD
* une vérification des capabilities
* une séparation claire entre DEV et PROD
* le principe du **Least Privilege**

---

# 1. Vérifier Vault

## Vérifier la version

```bash
vault version
```

## Vérifier l'état de Vault

```bash
vault status
```

---

# 2. Se connecter à Vault

Se connecter avec un compte disposant des droits d'administration nécessaires :

```bash
vault login
```

Vault demandera :

```text
Token:
```

Entrer le token Vault.

> Le token utilisé ici doit avoir les permissions nécessaires pour créer les secrets, policies et utilisateurs.

---

# 3. Activer le moteur de secrets KV v2

Si le moteur `secret/` n'existe pas encore :

```bash
vault secrets enable -path=secret kv-v2
```

Vérifier les moteurs de secrets :

```bash
vault secrets list
```

On doit retrouver quelque chose comme :

```text
Path      Type
----      ----
secret/   kv
```

> Si `secret/` existe déjà en KV v2, ne pas recréer le moteur.

---

# 4. Créer les secrets DEV

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

# 5. Créer les secrets PROD

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

# 6. Vérifier les secrets

## Lister le contenu de `secret/ligue/`

```bash
vault kv list secret/ligue/
```

## Lister les secrets DEV

```bash
vault kv list secret/ligue/dev/
```

## Lister les secrets PROD

```bash
vault kv list secret/ligue/prod/
```

---

# 7. Lire les secrets

## Lire le secret de l'application DEV

```bash
vault kv get secret/ligue/dev/app
```

## Lire le secret de la base DEV

```bash
vault kv get secret/ligue/dev/database
```

## Lire le secret de l'application PROD

```bash
vault kv get secret/ligue/prod/app
```

## Lire le secret de la base PROD

```bash
vault kv get secret/ligue/prod/database
```

---

# 8. Créer la policy DEV

Créer le fichier :

```bash
nano ligue-dev.hcl
```

Mettre exactement ceci dans le fichier :

```hcl
path "secret/data/ligue/dev/*" {
  capabilities = ["read"]
}

path "secret/metadata/ligue/dev/*" {
  capabilities = ["list"]
}
```

Enregistrer le fichier avec :

```text
CTRL + O
ENTER
CTRL + X
```

---

## Explication de la policy DEV

### Accès aux données DEV

```hcl
path "secret/data/ligue/dev/*" {
  capabilities = ["read"]
}
```

Ce chemin permet de lire les secrets situés sous :

```text
secret/ligue/dev/
```

La capability :

```text
read
```

permet de lire la valeur d'un secret.

---

### Accès aux métadonnées DEV

```hcl
path "secret/metadata/ligue/dev/*" {
  capabilities = ["list"]
}
```

La capability :

```text
list
```

permet de lister les chemins disponibles.

Le développeur peut donc voir quels secrets existent dans DEV sans avoir besoin d'un accès à PROD.

---

## Ce que la policy DEV n'autorise pas

La policy ne donne aucun accès à :

```text
secret/data/ligue/prod/*
```

Donc :

```text
DEV  → autorisé
PROD → refusé
```

---

# 9. Enregistrer la policy DEV dans Vault

Après avoir créé :

```text
ligue-dev.hcl
```

Enregistrer la policy dans Vault :

```bash
vault policy write ligue-dev ligue-dev.hcl
```

Vérifier la policy :

```bash
vault policy read ligue-dev
```

Lister toutes les policies :

```bash
vault policy list
```

On doit retrouver :

```text
ligue-dev
```

---

# 10. Créer la policy PROD

Créer le fichier :

```bash
nano ligue-prod.hcl
```

Mettre :

```hcl
path "secret/data/ligue/prod/app" {
  capabilities = ["read"]
}

path "secret/data/ligue/prod/database" {
  capabilities = ["read"]
}
```

Enregistrer :

```text
CTRL + O
ENTER
CTRL + X
```

Créer la policy dans Vault :

```bash
vault policy write ligue-prod ligue-prod.hcl
```

Vérifier :

```bash
vault policy read ligue-prod
```

---

# 11. Activer l'authentification `userpass`

Activer le moteur d'authentification :

```bash
vault auth enable userpass
```

Vérifier les méthodes d'authentification :

```bash
vault auth list
```

On doit retrouver :

```text
userpass/
```

---

# 12. Créer l'utilisateur DEV

Créer l'utilisateur `dev1` :

```bash
vault write auth/userpass/users/dev1 \
  password="MotDePasseFort" \
  policies="ligue-dev"
```

### Explication

`dev1` :

```text
Nom de l'utilisateur Vault
```

`password` :

```text
Mot de passe permettant à dev1 de s'authentifier
```

`policies="ligue-dev"` :

```text
Associe l'utilisateur à la policy ligue-dev
```

Le fonctionnement est donc :

```text
dev1
 |
 +--> userpass
 |
 +--> policy ligue-dev
 |
 +--> accès DEV
```

---

# 13. Vérifier l'utilisateur

Vérifier l'utilisateur :

```bash
vault read auth/userpass/users/dev1
```

Vérifier également la policy :

```bash
vault policy read ligue-dev
```

---

# 14. Se connecter en tant que `dev1`

Utiliser :

```bash
vault login -method=userpass username=dev1
```

Vault demande :

```text
Password:
```

Entrer le mot de passe défini lors de la création de `dev1`.

---

# 15. Vérifier le token du développeur

Après connexion :

```bash
vault token lookup
```

Le token doit être associé à la policy :

```text
ligue-dev
```

Le fonctionnement est donc :

```text
dev1
 |
 +--> Authentification userpass
 |
 +--> Token Vault
 |
 +--> Policy ligue-dev
 |
 +--> secret/ligue/dev/*
 |
 +--> READ
```

---

# 16. Tester l'accès DEV

## Lire le secret de l'application DEV

```bash
vault kv get secret/ligue/dev/app
```

Cette commande doit fonctionner.

---

## Lire la base DEV

```bash
vault kv get secret/ligue/dev/database
```

Cette commande doit fonctionner.

---

## Lister les secrets DEV

```bash
vault kv list secret/ligue/dev/
```

Cette commande doit fonctionner.

---

# 17. Tester l'accès PROD

Essayer de lire l'application PROD :

```bash
vault kv get secret/ligue/prod/app
```

Cette commande doit être refusée.

Essayer de lire la base PROD :

```bash
vault kv get secret/ligue/prod/database
```

Cette commande doit également être refusée.

L'utilisateur doit obtenir une erreur similaire à :

```text
permission denied
```

C'est le comportement attendu.

---

# 18. Vérifier les capabilities

Les capabilities permettent de vérifier directement ce que le token actuel peut faire sur un chemin.

## Vérifier DEV

```bash
vault token capabilities secret/data/ligue/dev/app
```

Résultat attendu :

```text
read
```

---

## Vérifier PROD

```bash
vault token capabilities secret/data/ligue/prod/app
```

Résultat attendu :

```text
deny
```

Cela permet de confirmer que le token possède bien les permissions DEV mais pas PROD.

---

# 19. Créer un deuxième développeur

Créer `dev2` :

```bash
vault write auth/userpass/users/dev2 \
  password="MotDePasseFort" \
  policies="ligue-dev"
```

`dev2` possède donc les mêmes permissions que `dev1`.

Se connecter :

```bash
vault login -method=userpass username=dev2
```

Puis vérifier :

```bash
vault token lookup
```

---

# 20. Modifier le mot de passe d'un développeur

Pour modifier le mot de passe de `dev1` :

```bash
vault write auth/userpass/users/dev1 \
  password="NouveauMotDePasseFort" \
  policies="ligue-dev"
```

> `vault write` permet ici de créer ou de mettre à jour la configuration de l'utilisateur.

---

# 21. Supprimer un utilisateur

Pour supprimer `dev1` :

```bash
vault delete auth/userpass/users/dev1
```

Après suppression, `dev1` ne pourra plus s'authentifier avec `userpass`.

---

# 22. Associer plusieurs policies

Un utilisateur peut posséder plusieurs policies.

Exemple :

```bash
vault write auth/userpass/users/dev1 \
  password="MotDePasseFort" \
  policies="ligue-dev,autre-policy"
```

L'utilisateur possède alors :

```text
ligue-dev
autre-policy
```

> Attention à ne pas donner une policy plus puissante que nécessaire.

---

# 23. Supprimer un secret

Supprimer le secret DEV de l'application :

```bash
vault kv delete secret/ligue/dev/app
```

Supprimer le secret DEV de la base :

```bash
vault kv delete secret/ligue/dev/database
```

> KV v2 utilise un système de versions. Une suppression avec `vault kv delete` ne signifie pas nécessairement une destruction définitive de toutes les versions.

---

# 24. Comprendre les chemins KV v2

Avec la CLI, on utilise :

```bash
vault kv get secret/ligue/dev/app
```

Mais dans une policy KV v2, le chemin de données est :

```text
secret/data/ligue/dev/*
```

Pour le listing, on utilise :

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

## Exemple

Commande CLI :

```bash
vault kv get secret/ligue/dev/app
```

Policy correspondante :

```hcl
path "secret/data/ligue/dev/*" {
  capabilities = ["read"]
}
```

Pour le listing :

```hcl
path "secret/metadata/ligue/dev/*" {
  capabilities = ["list"]
}
```

---

# 25. Si le développeur doit modifier les secrets DEV

Dans la configuration actuelle, le développeur possède uniquement :

```text
read
```

S'il doit pouvoir créer et modifier les secrets DEV, la policy peut être modifiée ainsi :

```hcl
path "secret/data/ligue/dev/*" {
  capabilities = ["read", "create", "update"]
}

path "secret/metadata/ligue/dev/*" {
  capabilities = ["list"]
}
```

Les principales capabilities sont :

| Capability | Utilisation         |
| ---------- | ------------------- |
| `read`     | Lire un secret      |
| `create`   | Créer un secret     |
| `update`   | Modifier un secret  |
| `delete`   | Supprimer un secret |
| `list`     | Lister les chemins  |

On évite de donner :

```text
delete
```

si le développeur n'en a pas besoin.

---

# 26. Principe du moindre privilège

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

C'est le principe :

> **Least Privilege — Principe du moindre privilège**

Autrement dit :

> Donner uniquement les permissions nécessaires à l'utilisateur pour effectuer son travail.

---

# 27. Authentification vs Policy

Il est important de comprendre la différence entre **authentification** et **autorisation**.

## Authentification

Question :

> **Qui es-tu ?**

Exemple :

```bash
vault login -method=userpass username=dev1
```

Vault vérifie les identifiants de `dev1`.

---

## Policy

Question :

> **Qu'as-tu le droit de faire ?**

Exemple :

```text
ligue-dev
```

La policy indique :

```text
dev1
 |
 +--> peut lire DEV
 |
 +--> ne peut pas lire PROD
```

---

## Fonctionnement général

```text
AUTHENTIFICATION
        |
        v
      dev1
        |
        v
POLICY ligue-dev
        |
        v
secret/ligue/dev/*
        |
        v
       READ
```

---

# 28. Architecture finale

```text
                         VAULT
                           |
             +-------------+-------------+
             |                           |
            DEV                         PROD
             |                           |
       secret/ligue/dev/          secret/ligue/prod/
             |                           |
        +----+----+                 +----+----+
        |         |                 |         |
       app     database            app     database
        |
        |
   Policy ligue-dev
        |
   +----+----+
   |         |
  dev1      dev2
   |
   +--> READ DEV
   |
   +--> DENY PROD
```

---

# 29. Ce que le développeur peut faire

L'utilisateur :

```text
dev1
```

possède :

```text
policy = ligue-dev
```

Cette policy donne accès à :

```text
secret/ligue/dev/*
```

avec :

```text
READ
```

Le développeur peut donc :

```text
secret/ligue/dev/app
        |
        +--> READ

secret/ligue/dev/database
        |
        +--> READ
```

Mais :

```text
secret/ligue/prod/*
```

est refusé.

Donc :

```text
DEV  = OUI
PROD = NON
```

---

# 30. Policy DEV complète

Fichier :

```bash
nano ligue-dev.hcl
```

Contenu :

```hcl
path "secret/data/ligue/dev/*" {
  capabilities = ["read"]
}

path "secret/metadata/ligue/dev/*" {
  capabilities = ["list"]
}
```

Enregistrer :

```text
CTRL + O
ENTER
CTRL + X
```

Puis :

```bash
vault policy write ligue-dev ligue-dev.hcl
```

Vérifier :

```bash
vault policy read ligue-dev
```

---

# 31. Policy PROD complète

Fichier :

```bash
nano ligue-prod.hcl
```

Contenu :

```hcl
path "secret/data/ligue/prod/app" {
  capabilities = ["read"]
}

path "secret/data/ligue/prod/database" {
  capabilities = ["read"]
}
```

Enregistrer :

```text
CTRL + O
ENTER
CTRL + X
```

Puis :

```bash
vault policy write ligue-prod ligue-prod.hcl
```

Vérifier :

```bash
vault policy read ligue-prod
```

---

# 32. Résumé complet des commandes

## Vérification

```bash
vault version
vault status
```

---

## Connexion administrateur

```bash
vault login
```

---

## Activer KV v2

```bash
vault secrets enable -path=secret kv-v2
```

---

## Vérifier les moteurs

```bash
vault secrets list
```

---

## Créer les secrets DEV

```bash
vault kv put secret/ligue/dev/app \
  APP_KEY="TON_APP_KEY_DEV"
```

```bash
vault kv put secret/ligue/dev/database \
  DB_USERNAME="ligue_user" \
  DB_PASSWORD="TON_MOT_DE_PASSE_DB_DEV"
```

---

## Créer les secrets PROD

```bash
vault kv put secret/ligue/prod/app \
  APP_KEY="TON_APP_KEY_PROD"
```

```bash
vault kv put secret/ligue/prod/database \
  DB_USERNAME="ligue_user" \
  DB_PASSWORD="TON_MOT_DE_PASSE_DB_PROD"
```

---

## Vérifier les secrets

```bash
vault kv list secret/ligue/
```

```bash
vault kv list secret/ligue/dev/
```

```bash
vault kv list secret/ligue/prod/
```

---

## Lire les secrets

```bash
vault kv get secret/ligue/dev/app
```

```bash
vault kv get secret/ligue/dev/database
```

```bash
vault kv get secret/ligue/prod/app
```

```bash
vault kv get secret/ligue/prod/database
```

---

# 33. Création de la policy DEV

Créer le fichier :

```bash
nano ligue-dev.hcl
```

Mettre :

```hcl
path "secret/data/ligue/dev/*" {
  capabilities = ["read"]
}

path "secret/metadata/ligue/dev/*" {
  capabilities = ["list"]
}
```

Enregistrer :

```text
CTRL + O
ENTER
CTRL + X
```

Créer la policy :

```bash
vault policy write ligue-dev ligue-dev.hcl
```

Vérifier :

```bash
vault policy read ligue-dev
```

---

# 34. Création de la policy PROD

Créer le fichier :

```bash
nano ligue-prod.hcl
```

Mettre :

```hcl
path "secret/data/ligue/prod/app" {
  capabilities = ["read"]
}

path "secret/data/ligue/prod/database" {
  capabilities = ["read"]
}
```

Enregistrer :

```text
CTRL + O
ENTER
CTRL + X
```

Créer :

```bash
vault policy write ligue-prod ligue-prod.hcl
```

Vérifier :

```bash
vault policy read ligue-prod
```

---

# 35. Création de l'authentification `userpass`

Activer :

```bash
vault auth enable userpass
```

Vérifier :

```bash
vault auth list
```

---

# 36. Création du développeur

Créer `dev1` :

```bash
vault write auth/userpass/users/dev1 \
  password="MotDePasseFort" \
  policies="ligue-dev"
```

Connexion :

```bash
vault login -method=userpass username=dev1
```

Vérifier le token :

```bash
vault token lookup
```

---

# 37. Créer un deuxième développeur

```bash
vault write auth/userpass/users/dev2 \
  password="MotDePasseFort" \
  policies="ligue-dev"
```

Connexion :

```bash
vault login -method=userpass username=dev2
```

Vérifier :

```bash
vault token lookup
```

---

# 38. Tests DEV

Lire le secret de l'application :

```bash
vault kv get secret/ligue/dev/app
```

Lire le secret de la base :

```bash
vault kv get secret/ligue/dev/database
```

Lister les secrets :

```bash
vault kv list secret/ligue/dev/
```

Ces commandes doivent fonctionner.

---

# 39. Tests PROD

Lire l'application PROD :

```bash
vault kv get secret/ligue/prod/app
```

Lire la base PROD :

```bash
vault kv get secret/ligue/prod/database
```

Ces commandes doivent être refusées.

Résultat attendu :

```text
permission denied
```

---

# 40. Tests des capabilities

Tester DEV :

```bash
vault token capabilities secret/data/ligue/dev/app
```

Résultat attendu :

```text
read
```

Tester PROD :

```bash
vault token capabilities secret/data/ligue/prod/app
```

Résultat attendu :

```text
deny
```

---

# 41. Modifier un utilisateur

Modifier le mot de passe de `dev1` :

```bash
vault write auth/userpass/users/dev1 \
  password="NouveauMotDePasseFort" \
  policies="ligue-dev"
```

---

# 42. Supprimer un utilisateur

```bash
vault delete auth/userpass/users/dev1
```

---

# 43. Supprimer un secret

Supprimer le secret DEV de l'application :

```bash
vault kv delete secret/ligue/dev/app
```

Supprimer le secret DEV de la base :

```bash
vault kv delete secret/ligue/dev/database
```

> Attention : avec KV v2, la suppression d'une version n'est pas nécessairement une destruction définitive de toutes les versions.

---

# 44. Fichiers créés

La configuration locale contient notamment :

```text
.
├── ligue-dev.hcl
└── ligue-prod.hcl
```

## `ligue-dev.hcl`

```hcl
path "secret/data/ligue/dev/*" {
  capabilities = ["read"]
}

path "secret/metadata/ligue/dev/*" {
  capabilities = ["list"]
}
```

## `ligue-prod.hcl`

```hcl
path "secret/data/ligue/prod/app" {
  capabilities = ["read"]
}

path "secret/data/ligue/prod/database" {
  capabilities = ["read"]
}
```

---

# 45. Architecture logique complète

```text
                                  VAULT
                                    |
             +----------------------+----------------------+
             |                                             |
        AUTHENTICATION                                SECRET ENGINE
             |                                             |
         userpass                                          KV v2
             |                                             |
      +------+-------+                           +---------+---------+
      |              |                           |                   |
     dev1           dev2                        DEV                 PROD
      |              |                           |                   |
      +------+-------+                    secret/ligue/dev/   secret/ligue/prod/
             |                                   |                   |
             v                              +----+----+         +----+----+
       Policy ligue-dev                      |         |         |         |
             |                              app    database     app    database
             |
       +-----+------+
       |            |
      READ         LIST
       |
       v
      DEV

      PROD
       |
       +--> DENY
```

---

# 46. Flux d'authentification

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

# 47. Flux d'autorisation

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
 +------------------------------+
 |                              |
 v                              v
DEV                            PROD
 |                              |
 v                              v
ALLOW                          DENY
```

Exemple :

```text
secret/data/ligue/dev/app
        |
        +--> read
```

Mais :

```text
secret/data/ligue/prod/app
        |
        +--> deny
```

---

# 48. Différence entre DEV et PROD

| Élément              | DEV         | PROD                   |
| -------------------- | ----------- | ---------------------- |
| Secrets              | Oui         | Oui                    |
| Policy               | `ligue-dev` | `ligue-prod`           |
| Développeur `dev1`   | Oui         | Non                    |
| Lecture DEV          | Oui         | Selon policy           |
| Lecture PROD         | Non         | Oui avec policy dédiée |
| Accès administrateur | Non         | Non                    |
| Token admin          | Non         | Non                    |

---

# 49. Bonnes pratiques

## Ne jamais mettre les secrets dans Git

Éviter :

```text
.env
config.php
application.yml
docker-compose.yml
```

avec de vrais mots de passe ou clés API.

Les secrets doivent être stockés dans Vault.

---

## Utiliser des secrets différents entre DEV et PROD

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

## Utiliser le principe du moindre privilège

Un développeur qui travaille uniquement sur DEV ne devrait pas recevoir :

```text
secret/ligue/*
```

mais uniquement :

```text
secret/ligue/dev/*
```

---

## Ne pas utiliser un compte administrateur pour l'application

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

# 50. Résultat final

La configuration finale permet d'obtenir :

```text
                          VAULT
                            |
                            v
                       USERPASS
                            |
             +--------------+--------------+
             |                             |
            dev1                          dev2
             |                             |
             +--------------+--------------+
                            |
                            v
                     ligue-dev
                            |
                  +---------+---------+
                  |                   |
                 DEV                PROD
                  |                   |
                 ALLOW               DENY
                  |
          +-------+-------+
          |               |
         app           database
```

Le développeur :

* possède son propre compte Vault ;
* s'authentifie avec `userpass` ;
* reçoit un token Vault ;
* possède la policy `ligue-dev` ;
* peut lire les secrets DEV ;
* peut lister les chemins DEV ;
* ne peut pas lire les secrets PROD ;
* ne reçoit pas de token administrateur ;
* ne reçoit pas les identifiants PROD.

---

# 51. Principe général de Vault

Le fonctionnement peut être résumé simplement :

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
                  ligue-dev
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

---

# 52. Commandes essentielles à retenir

Si tu dois retenir uniquement les commandes principales :

### Vérifier Vault

```bash
vault status
```

### Se connecter

```bash
vault login
```

### Voir les moteurs de secrets

```bash
vault secrets list
```

### Créer un secret

```bash
vault kv put secret/ligue/dev/app APP_KEY="..."
```

### Lire un secret

```bash
vault kv get secret/ligue/dev/app
```

### Lister les secrets

```bash
vault kv list secret/ligue/dev/
```

### Créer une policy

```bash
vault policy write ligue-dev ligue-dev.hcl
```

### Lire une policy

```bash
vault policy read ligue-dev
```

### Activer userpass

```bash
vault auth enable userpass
```

### Créer un utilisateur

```bash
vault write auth/userpass/users/dev1 \
  password="MotDePasseFort" \
  policies="ligue-dev"
```

### Se connecter avec userpass

```bash
vault login -method=userpass username=dev1
```

### Vérifier le token

```bash
vault token lookup
```

### Vérifier les permissions

```bash
vault token capabilities secret/data/ligue/dev/app
```

---

# 53. Résumé conceptuel

```text
                    VAULT
                      |
        +-------------+-------------+
        |                           |
 AUTHENTICATION                 SECRETS
        |                           |
    userpass                       KV v2
        |                           |
      dev1                    secret/ligue/
        |                           |
        v                    +------+------+
   TOKEN VAULT               |             |
        |                    DEV          PROD
        v                    |             |
  POLICY ligue-dev           |             |
        |                    |             |
        v                  app/database  app/database
  READ + LIST
        |
        v
       DEV
```

### À retenir

```text
Authentication = Qui es-tu ?
Policy          = Que peux-tu faire ?
Secret Engine   = Où sont stockés les secrets ?
KV v2           = Moteur de stockage clé/valeur avec versions
Token           = Identité temporaire utilisée par Vault
Capability      = Action autorisée (read, list, create, update, delete)
Least Privilege = Donner uniquement les permissions nécessaires
```

---

# 54. Séparation DEV / PROD

L'objectif final est d'avoir une séparation claire :

```text
                  VAULT
                    |
        +-----------+-----------+
        |                       |
       DEV                     PROD
        |                       |
 ligue-dev                 ligue-prod
        |                       |
 développeurs              accès dédié
        |                       |
       READ                  READ
        |                       |
        +------X PROD X---------+
```

Un développeur travaillant sur DEV ne doit pas avoir automatiquement accès aux secrets PROD.

Pour une application de production, il est préférable d'utiliser une **identité Vault dédiée à l'application** avec une policy limitée aux secrets dont elle a réellement besoin.

---

# 55. Fin

Cette configuration constitue une base permettant de comprendre et de mettre en œuvre :

* HashiCorp Vault
* KV v2
* Secret Engines
* Policies
* Authentication Methods
* `userpass`
* Tokens
* Capabilities
* séparation DEV / PROD
* contrôle d'accès
* principe du moindre privilège

La prochaine étape naturelle consiste à connecter une application à Vault afin qu'elle récupère ses secrets **sans stocker les mots de passe directement dans le code ou dans un fichier `.env`**.
