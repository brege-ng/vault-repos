# Installation et vérification de Vault

## 1. Vérifier Vault

### Vérifier la version

```bash
vault version
```

### Vérifier l'état de Vault

```bash
vault status
```

---

## 2. Se connecter à Vault

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

## 3. Activer le moteur de secrets KV v2

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
