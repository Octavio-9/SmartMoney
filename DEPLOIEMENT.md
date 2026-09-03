# Déploiement de l'API Smart Money sur Railway

Cible : **Railway**, PHP 8.3 via Nixpacks, **PostgreSQL managé**.
Seul `smart_api/` est déployé. `smart_mobile/` est une application Flutter : elle
se compile en APK et n'a rien à faire sur le serveur.

> **Coût réel.** Railway n'a plus d'offre gratuite. Vous recevez **5 $ de crédit
> à l'inscription**, valables 30 jours et sans carte bancaire. Ensuite les
> services sont mis en pause, sauf passage au plan **Hobby à 5 $/mois**.
> Prévoyez-le : ce n'est pas un hébergement gratuit.

---

## 1. Ce qui a dû être corrigé avant de déployer

Trois problèmes bloquants ont été trouvés et réglés pendant la préparation.
Ils sont documentés ici parce qu'ils expliquent la forme du paquet livré.

**`storage/framework/` n'existait pas.** Laravel y compile les vues Blade. Sans
ce dossier, toute génération de PDF échouait avec « Please provide a valid cache
path ». Contrairement à ce que je pensais, Laravel **ne le recrée pas** seul.

**L'autoloader maison ignorait les classmaps.** `gen_autoload.php` écrivait un
`autoload_classmap.php` vide en dur. Or dompdf déclare `"classmap": ["lib/"]`,
et c'est là que vit `Dompdf\Cpdf`. Résultat : tout transfert renvoyait une 500.
Le générateur construit désormais la carte — **1 557 classes** indexées.

**La racine `/` renvoyait la vue `welcome`**, qui appelle `@vite(...)`. Sans
assets compilés, elle produit une 500 — et Railway teste la santé du service sur
cette URL. Elle renvoie maintenant un petit JSON d'état, ce qui supprime au
passage toute dépendance à npm et à Vite.

---

## 2. Le paquet à déployer

`smartmoney-deploy.zip` — **93 fichiers, 120 Ko**. Contenu écarté :

| Élément | Raison |
|---|---|
| `vendor/` | Composer le régénérera proprement en PHP 8.3 sur Railway |
| `.env` | Railway injecte les variables d'environnement directement |
| `database/database.sqlite` | remplacé par PostgreSQL |
| `smart_api.zip` (45,8 Mo), `composer.phar` (3,5 Mo) | inutiles |
| `package.json`, `vite.config.js`, `resources/css`, `resources/js`, `welcome.blade.php` | plus aucun asset front à construire |
| `gen_autoload.php`, `test_artisan.php` | spécifiques au poste de développement |

Le paquet contient un **`.env.railway.example`** : ce n'est pas un fichier lu par
Railway, mais l'aide-mémoire des variables à reporter dans l'interface.

---

## 3. Créer le compte et l'outil

Inscrivez-vous sur **[railway.com](https://railway.com/)** — la création de
compte via GitHub est la plus rapide.

Puis installez l'outil en ligne de commande (Node 22 est déjà présent) :

```bash
npm install -g @railway/cli
railway login
```

> **Pourquoi la ligne de commande plutôt que GitHub.** `railway up` téléverse le
> dossier courant directement. Vous évitez ainsi de créer un dépôt Git et de
> publier votre code sur GitHub. Si vous préférez le déploiement automatique à
> chaque `git push`, connectez un dépôt à la place — les deux fonctionnent.

---

## 4. Créer le projet et la base

```bash
mkdir smartmoney-deploy && cd smartmoney-deploy
# extrayez ici le contenu de smartmoney-deploy.zip
railway init          # nommez le projet, par ex. smartmoney
```

Puis, dans l'interface Railway : **New** → **Database** → **Add PostgreSQL**.

Railway crée le service et publie une variable `DATABASE_URL` réutilisable par
référence. Il n'y a **ni hôte ni mot de passe à recopier**.

---

## 5. Les variables

Service PHP → onglet **Variables** → **Raw Editor**, puis collez le contenu de
`.env.railway.example` en remplaçant ce qui doit l'être.

Deux lignes méritent attention :

```ini
DB_URL=${{Postgres.DATABASE_URL}}
LOG_CHANNEL=stderr
```

`DB_URL` — et non `DATABASE_URL` : le bloc `pgsql` de `config/database.php` lit
cette clé-là. La syntaxe `${{Postgres.DATABASE_URL}}` est une référence Railway,
résolue automatiquement.

`LOG_CHANNEL=stderr` — sur un conteneur, un fichier de log est invisible et perdu
au redéploiement. `stderr` remonte dans les journaux Railway.

Générez enfin la clé applicative en local et collez-la dans `APP_KEY` :

```bash
& C:\xampp\php\php.exe artisan key:generate --show
```

---

## 6. Déployer

```bash
railway up
```

Nixpacks détecte PHP via `composer.json` (qui exige `^8.3`), installe les
dépendances avec `composer install --no-dev`, et sert `public/` derrière
nginx + php-fpm.

Générez ensuite l'URL publique : service → **Settings** → **Networking** →
**Generate Domain**. Reportez-la dans `APP_URL`.

---

## 7. Initialiser la base

**Une seule fois**, après le premier déploiement réussi :

```bash
railway run php artisan migrate --force --seed
```

Le `--seed` remplit les 12 pays, leurs opérateurs, les taux de change, les 25
facturiers et les 3 comptes de démonstration. Sans lui, tout transfert échoue
avec « Taux de change introuvable ».

> ⚠️ **Ne rejouez pas `--seed` ensuite.** Tous les seeders utilisent
> `updateOrCreate`, donc ils sont idempotents — mais `DemoUserSeeder` remet le
> solde des trois comptes à **1 000 000** et effacerait vos essais.
> Pour les déploiements suivants : `railway run php artisan migrate --force`.

---

## 8. Vérifier

```bash
railway run php artisan config:cache
railway run php artisan route:cache
```

Puis, depuis n'importe où :

```
GET  https://VOTRE-SERVICE.up.railway.app/            -> {"status":"ok",...}
GET  https://VOTRE-SERVICE.up.railway.app/api/countries   -> 12 pays
POST https://VOTRE-SERVICE.up.railway.app/api/login       -> un jeton
```

Enchaînez avec un transfert complet : il valide en une fois la base, les taux de
change, le verrouillage et la génération du PDF.

---

## 9. Recompiler l'application Flutter

`AppConfig.apiBaseUrl` est une constante **de compilation** : un rechargement à
chaud ne suffit pas.

```bash
cd smart_mobile
flutter build apk --release \
  --dart-define=API_BASE_URL=https://VOTRE-SERVICE.up.railway.app/api
```

L'APK sort dans `build/app/outputs/flutter-apk/app-release.apk` (≈ 54 Mo).
C'est cette compilation qui rend la tablette autonome : PC éteint, hors du Wi-Fi
local, 4G comprise.

---

## 10. Le disque est éphémère — ce qui a été fait

Railway redéploie dans un conteneur neuf : **tout fichier écrit disparaît.**

Les reçus PDF étaient concernés. `TransferService` les écrit dans
`storage/app/public/receipts/` et enregistre le chemin en base ; après un
redéploiement, la ligne subsiste mais le fichier non.

`TransferController::receipt()` **régénère désormais le PDF** quand le fichier
est absent, à partir des données du transfert. Vérifié en local : disque vidé,
puis requête → HTTP 200, `application/pdf`, 911 Ko, signature `%PDF` valide,
fichier recréé.

Aucune action de votre part n'est requise. Si vous préférez un stockage durable,
Railway propose des volumes à 0,15 $/Go/mois sur les plans payants.

---

## 11. Points de vigilance avant d'ouvrir au public

Le déploiement rend l'API accessible à tous. Trois comportements, acceptables en
démonstration locale, deviennent alors discutables :

1. **L'inscription crédite automatiquement 1 000 000** dans la devise de
   l'utilisateur (codé en dur dans `AuthController::register`). N'importe qui
   peut créer un compte et obtenir un million.
2. **Les comptes de démonstration** `0700000001`, `0700000002`, `0700000003`
   ont tous le mot de passe `password`.
3. **Aucune limitation de débit** sur `/api/login` : rien n'empêche une attaque
   par force brute.

Si l'application doit rester une démonstration privée, ces points sont sans
conséquence. Si elle doit être publique, traitez-les d'abord.

---

## 12. Mettre à jour plus tard

```bash
cd smartmoney-deploy
# remplacez les fichiers modifiés
railway up
railway run php artisan migrate --force
railway run php artisan config:cache
```

`railway run php artisan config:clear` si un changement de variable semble
ignoré : la configuration mise en cache masque l'environnement.

---

## 13. Ce qui n'a pas été vérifié

- **Aucune étape Railway n'a été exécutée réellement.** Je n'ai pas de compte :
  les commandes et les noms de menus viennent de leur documentation. La logique
  est juste, les intitulés peuvent différer.
- **La détection PHP par Nixpacks n'est pas testée.** Elle repose sur
  `composer.json` + `public/index.php`, tous deux présents. Si le build échoue,
  un fichier `nixpacks.toml` peut forcer la configuration.
- **La suite de tests ne tourne pas sur le poste de développement** : PHPUnit
  exige PHP 8.3, XAMPP local est en 8.2. Toute la vérification a été faite par
  requêtes HTTP — 15 contrôles passés, y compris les garde-fous 422.
- **`lockForUpdate()` ne fait rien sous SQLite** (`SQLiteGrammar::compileLock()`
  retourne une chaîne vide). Le passage à PostgreSQL le rend effectif : c'est un
  gain de sûreté réel sur les mouvements d'argent, pas seulement un changement
  d'hébergement.
