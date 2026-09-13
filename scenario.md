# Scénario : DevOps + 2 développeurs avec Vault

## 👥 Les acteurs

L'équipe est composée de **3 personnes** :

* **1 DevOps** → administre Vault et gère la sécurité.
* **Dev 1** → travaille sur l'environnement DEV.
* **Dev 2** → travaille également sur l'environnement DEV.

---

## 🔐 Rôle du DevOps

Le **DevOps** est responsable de la configuration de Vault.

Il :

* met en place le moteur de secrets **KV v2** ;
* crée les secrets **DEV** et **PROD** ;
* crée les policies ;
* configure l'authentification ;
* crée les comptes des développeurs ;
* attribue les bonnes policies aux développeurs ;
* contrôle les accès ;
* protège les secrets de production.

Le DevOps possède les droits nécessaires pour administrer Vault.

---

## 👨‍💻 Rôle de Dev 1 et Dev 2

Les deux développeurs disposent chacun de leur **propre compte Vault**.

```text
Dev 1 ──┐
        ├──> Policy ligue-dev ──> Accès DEV
Dev 2 ──┘
```

Ils peuvent accéder aux secrets nécessaires à leur travail sur **DEV**.

Par exemple :

```text
secret/ligue/dev/
├── app
└── database
```

Ils peuvent lire ces secrets selon les permissions définies par la policy.

---

## 🚫 Accès à PROD

Les développeurs **n'ont pas accès aux secrets PROD**.

```text
Dev 1 ──> DEV  ✅
Dev 2 ──> DEV  ✅

Dev 1 ──> PROD ❌
Dev 2 ──> PROD ❌
```

Les secrets PROD sont protégés par une policy différente et sont destinés à une identité ayant réellement besoin de ces secrets.

---

## 🔄 Fonctionnement global

```text
                    DEVOPS
                      │
          ┌───────────┼───────────┐
          │           │           │
          ▼           ▼           ▼
       Secrets      Policies    Authentification
          │           │           │
          └───────────┼───────────┘
                      │
                     VAULT
                      │
              Policy ligue-dev
                 │          │
                 ▼          ▼
               Dev 1      Dev 2
                 │          │
                 └────┬─────┘
                      │
                      ▼
                     DEV
                      │
             ┌────────┴────────┐
             │                 │
            app             database


                     PROD
                      │
               Accès séparé
                      │
              Devs = ❌ accès
```

---

## 🎯 Pourquoi cette organisation ?

Le principe est de **séparer les responsabilités et les environnements**.

### DevOps

> Gère Vault et les accès.

### Dev 1 / Dev 2

> Développent l'application et utilisent uniquement les secrets dont ils ont besoin en DEV.

### PROD

> Les secrets de production ne sont pas accessibles aux développeurs par défaut.

---

## 🔑 Principe à retenir

```text
DevOps
   ↓
Configure Vault
   ↓
Définit les permissions
   ↓
Attribue les policies
   ↓
Dev 1 / Dev 2
   ↓
Accès uniquement aux secrets nécessaires
   ↓
DEV ✅
PROD ❌
```

C'est l'application du principe **Least Privilege** :

> **Chaque personne reçoit uniquement les permissions nécessaires à son rôle.**
