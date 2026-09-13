# Tests d'accès

Ces tests permettent de vérifier la séparation entre DEV et PROD.

# 1. Tester l'accès DEV

## Lire le secret de l'application DEV

```bash
vault kv get secret/ligue/dev/app
```

Résultat attendu :

```text
SUCCÈS
```

## Lire la base DEV

```bash
vault kv get secret/ligue/dev/database
```

Résultat attendu :

```text
SUCCÈS
```

## Lister les secrets DEV

```bash
vault kv list secret/ligue/dev/
```

Résultat attendu :

```text
SUCCÈS
```

---

# 2. Tester l'accès PROD

## Lire l'application PROD

```bash
vault kv get secret/ligue/prod/app
```

Résultat attendu :

```text
permission denied
```

## Lire la base PROD

```bash
vault kv get secret/ligue/prod/database
```

Résultat attendu :

```text
permission denied
```

L'accès PROD doit être refusé pour un utilisateur possédant uniquement `ligue-dev`.

---

# 3. Vérifier les capabilities

## DEV

```bash
vault token capabilities secret/data/ligue/dev/app
```

Résultat attendu :

```text
read
```

## PROD

```bash
vault token capabilities secret/data/ligue/prod/app
```

Résultat attendu :

```text
deny
```

---

# 4. Résultat final

```text
             dev1
               |
               v
        policy ligue-dev
          /           \
         v             v
       DEV            PROD
      ALLOW           DENY
```

La configuration est correcte si :

```text
DEV  → ALLOW
PROD → DENY
```
