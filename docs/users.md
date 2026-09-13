# Gestion des utilisateurs Vault

## 1. Activer userpass

Activer le moteur d'authentification :

```bash
vault auth enable userpass
```

Vérifier :

```bash
vault auth list
```

On doit retrouver :

```text
userpass/
```

---

# 2. Créer l'utilisateur dev1

```bash
vault write auth/userpass/users/dev1 \
  password="MotDePasseFort" \
  policies="ligue-dev"
```

`dev1` est maintenant associé à :

```text
ligue-dev
```

Le fonctionnement est :

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

# 3. Se connecter avec dev1

```bash
vault login -method=userpass username=dev1
```

Vault demande :

```text
Password:
```

Entrer le mot de passe défini lors de la création de `dev1`.

---

# 4. Vérifier le token

Après connexion :

```bash
vault token lookup
```

Le token doit être associé à la policy :

```text
ligue-dev
```

---

# 5. Créer dev2

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

# 6. Modifier le mot de passe

Pour modifier le mot de passe de `dev1` :

```bash
vault write auth/userpass/users/dev1 \
  password="NouveauMotDePasseFort" \
  policies="ligue-dev"
```

> `vault write` permet ici de créer ou de mettre à jour la configuration de l'utilisateur.

---

# 7. Supprimer un utilisateur

Pour supprimer `dev1` :

```bash
vault delete auth/userpass/users/dev1
```

Après suppression, `dev1` ne pourra plus s'authentifier avec `userpass`.

---

# 8. Associer plusieurs policies

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

# 9. Authentification vs autorisation

## Authentification

Question :

> Qui es-tu ?

Exemple :

```bash
vault login -method=userpass username=dev1
```

Vault vérifie les identifiants de `dev1`.

## Policy / autorisation

Question :

> Que peux-tu faire ?

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
