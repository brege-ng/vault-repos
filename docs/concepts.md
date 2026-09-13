# Concepts fondamentaux d'HashiCorp Vault

Ce document explique les concepts clés utilisés dans cette configuration de HashiCorp Vault.

---

## 🔑 1. Secrets Engine (Moteur de secrets)

Dans Vault, les secrets ne sont pas simplement stockés dans une base de données classique ; ils sont gérés par un **Moteur de secrets** (*Secret Engine*).

### Le moteur KV (Key-Value) v2

Nous utilisons le moteur **KV v2** sur le chemin `secret/`.

- **Stockage clé-valeur** : Permet de stocker des paires comme `DB_USERNAME="ligue_user"`.
- **Versioning (Gestion des versions)** : Chaque modification d'un secret crée une nouvelle version.
- **Chemins internes KV v2** :
  - `secret/data/ligue/dev/app` : Contient les valeurs réelles des secrets.
  - `secret/metadata/ligue/dev/app` : Contient les métadonnées (versions, date de création, auteur).

---

## 🛂 2. Authentification (*Auth Methods*) & `userpass`

Vault sépare strictement **l'authentification** (vérifier l'identité) de **l'autorisation** (vérifier les permissions).

```text
  [ Utilisateur / App ]
           │
           │ 1. S'authentifie (ex: userpass)
           ▼
     [ Vault Auth ]
           │
           │ 2. Émet un Token d'accès
           ▼
    [ Token Vault ]
```

### Le moteur `userpass`

Le moteur d'authentification `userpass` permet à des utilisateurs humains (ex: `dev1`, `dev2`) de s'authentifier avec un **nom d'utilisateur** et un **mot de passe** stockés dans Vault.

> En production ou pour les applications, on utilise souvent d'autres méthodes automatisées (AppRole, Kubernetes, TLS Certificates, OIDC/GitLab).

---

## 🎟️ 3. Tokens Vault

Le **Token** est l'élément central dans Vault. Tout appel à l'API Vault nécessite un token valide.

- Quand `dev1` se connecte avec `userpass`, Vault valide le mot de passe et génère un **Token**.
- Ce token porte sur lui la liste des **Policies** associées (ex: `ligue-dev`).
- Le token a généralement une durée de vie limitée (*TTL - Time To Live*).

---

## 📜 4. Policies (Politiques d'accès & HCL)

Une **Policy** définit exactement **qui a le droit de faire quoi** dans Vault.

- Les policies sont rédigées en **HCL** (*HashiCorp Configuration Language*).
- **Default Deny** : Par défaut, TOUT accès est refusé sauf ce qui est explicitement autorisé.

### Les Capabilities (Permissions)

| Capability | Rôle |
|---|---|
| `read` | Lire la valeur d'un secret |
| `create` | Créer un nouveau secret |
| `update` | Mettre à jour une version existante |
| `delete` | Supprimer une version d'un secret |
| `list` | Lister les clés/chemins d'un dossier (`metadata`) |
| `deny` | Bloquer explicitement l'accès à un chemin |

Exemple :
```hcl
path "secret/data/ligue/dev/*" {
  capabilities = ["read"]
}
```

---

## 🛡️ 5. Principe du moindre privilège (*Least Privilege*)

Le principe du moindre privilège stipule qu'une identité (utilisateur ou application) doit posséder **strictement les accès nécessaires** à l'accomplissement de sa tâche, et rien de plus.

```text
    Développeur DEV
           │
           ▼
    Policy ligue-dev
     ├── DEV  (secret/data/ligue/dev/*)  ──► ALLOW
     └── PROD (secret/data/ligue/prod/*) ──► DENY
```

- Un développeur travaillant sur DEV n'a pas accès aux secrets de PROD.
- Une application en production n'a accès qu'à son propre chemin de secrets.
