# CLAUDE.md

Ce fichier fournit des instructions à Claude Code (claude.ai/code) pour travailler sur ce dépôt.

## Structure du dépôt

Tout le code source se trouve dans `smartmoney-main/` (le dossier parent `SmartMoney/` ne contient que ce répertoire et une archive zip). Ce n'est pas un dépôt git.

- `smartmoney-main/smart_api` — API JSON Laravel 13 (cible PHP 8.3, Sanctum, SQLite)
- `smartmoney-main/smart_mobile` — client Flutter (package `smart_money`), seul consommateur de l'API

Smart Money est une **démo / simulation** d'une application de transfert d'argent mobile pour l'Afrique de l'Ouest et centrale. Il n'y a aucune intégration de paiement réelle : les transferts déplacent un solde entre deux utilisateurs déjà inscrits sur ce même système, et chaque transfert ou retrait est créé avec `status = 'completed'` et `fee = 0`. Toutes les chaînes visibles par l'utilisateur et les messages d'erreur de l'API sont en **français** — garder le français pour les nouveaux messages, car l'interface Flutter affiche le `message` de l'API tel quel.

## Chaîne d'outils sur cette machine (important)

`php` et `composer` ne sont **pas dans le PATH**. PHP se trouve dans `C:\xampp\php\php.exe` et est en version **8.2.0**, alors que `composer.json` exige `^8.3`.

Le projet contourne le problème : `vendor/autoload.php` n'est **pas** celui de Composer — il a été généré par `smart_api/gen_autoload.php`, un autoloader écrit à la main (`ComposerAutoloaderInitSmartMoney`) construit à partir de `composer.lock` + `vendor/composer/installed.php`. Cela court-circuite le contrôle de plateforme de Composer, ce qui explique que Laravel 13.23 démarre ici sur PHP 8.2.

Conséquences :

- Ne **pas** lancer `composer install`, `composer update` ni `composer dump-autoload` — ils échouent sur le contrôle de plateforme `^8.3` et écraseraient l'autoloader personnalisé.
- Si l'autoloading casse après l'ajout de classes, le régénérer avec `php gen_autoload.php` depuis `smart_api/`.
- `test_artisan.php` est un test de démarrage ponctuel écrit précisément pour cette configuration.
- Les scripts `composer setup` et `composer dev` de `composer.json` sont ceux de Laravel par défaut et ne sont pas utilisables ici.

Flutter 3.44 et Node 22 sont accessibles normalement depuis le PATH.

## Commandes

À lancer depuis `smartmoney-main/smart_api`, en préfixant chaque `php` par le chemin complet de XAMPP (par ex. `& C:\xampp\php\php.exe artisan serve`) :

```
php artisan serve --host=0.0.0.0 --port=8000          # API sur le port 8000
php artisan migrate --seed                            # reconstruit SQLite + données de démo
php artisan db:seed --class=CountrySeeder             # un seeder en particulier
php artisan storage:link                              # public/storage -> storage/app/public
php artisan test                                      # PHPUnit, sqlite en mémoire (phpunit.xml)
php artisan test --filter=test_demo_login_and_transfer  # un seul test
vendor/bin/pint                                       # formatage PHP
```

La base de données est `database/database.sqlite`, déjà migrée et remplie.

Depuis `smartmoney-main/smart_mobile` :

```
flutter run                                           # par défaut http://10.0.2.2:8000/api (émulateur Android)
flutter run --dart-define=API_BASE_URL=http://192.168.x.x:8000/api   # appareil physique
flutter analyze
flutter test
```

`AppConfig.apiBaseUrl` dans [config.dart](smartmoney-main/smart_mobile/lib/core/config.dart) est une constante **de compilation** (`String.fromEnvironment`) — changer l'URL du backend impose une recompilation complète avec `--dart-define`, un hot reload ne suffit pas.

## Architecture backend

Les routes sont à plat dans [api.php](smartmoney-main/smart_api/routes/api.php) : `register` / `login` / `countries` / `operators` sont publiques, tout le reste est derrière `auth:sanctum`.

**Tout mouvement d'argent est confiné à deux services** — [TransferService](smartmoney-main/smart_api/app/Services/TransferService.php) et [WithdrawalService](smartmoney-main/smart_api/app/Services/WithdrawalService.php). Les contrôleurs se contentent de valider, déléguer et mettre en forme le JSON. Les deux services suivent le même schéma d'invariants, que toute nouvelle opération monétaire doit reprendre :

1. Encapsuler dans `DB::transaction`.
2. Poser un `lockForUpdate()` sur la ou les lignes de portefeuille avant de lire le solde.
3. Lever une `RuntimeException` avec un message en français pour toute erreur métier (solde insuffisant, destinataire inconnu, taux manquant) — les contrôleurs interceptent `RuntimeException` et la convertissent en HTTP **422**.
4. Écrire une ligne de journal `Transaction` pour **chaque** variation de solde, avec `balance_after` et un `related_type`/`related_id` polymorphe pointant vers le `Transfer` ou le `Withdrawal`.

Les taux de change proviennent de la table `exchange_rates`, indexée sur `(from_currency, to_currency)` ; une même devise court-circuite à 1.0 et une paire absente lève une exception. La `currency` d'un utilisateur est copiée depuis son `Country` à l'inscription et ne change jamais. Ajouter un pays impose donc de seeder le pays, ses opérateurs **et** les lignes de taux dans les deux sens — sinon les transferts vers ce pays échouent avec « Taux de change introuvable ».

Les reçus PDF sont générés par dompdf depuis `resources/views/pdf/receipt.blade.php` *à l'intérieur* de la transaction de transfert, enregistrés dans `storage/app/public/receipts/`, et servis uniquement via `GET /api/transfers/{id}/receipt`, qui revérifie que l'appelant est bien l'expéditeur ou le destinataire. Le lien symbolique public de storage n'est pas le canal de livraison.

### Conventions backend

- Les modèles déclarent l'assignation de masse via les **attributs** Laravel 13 — `#[Fillable([...])]`, `#[Hidden([...])]` au-dessus de la classe — et non via les propriétés `$fillable`/`$hidden`. Reprendre cette forme pour tout nouveau modèle.
- Aucune API Resource. Chaque contrôleur possède une méthode privée `payload()` qui construit le tableau à la main. Les champs monétaires utilisent des casts Eloquent `decimal`, donc ils reviennent sous forme de chaînes et doivent être convertis avec `(float)` avant d'être renvoyés.
- Les collections sont renvoyées sous la forme `{"data": [...]}` ; les objets uniques sous une clé nommée (`user`, `wallet`, `transfer`, `withdrawal`, `recipient`). Le `ApiService` Flutter déballe exactement ces clés.
- `AuthController::userPayload()` est `public static` et constitue l'unique définition de la forme JSON d'un utilisateur.
- `bootstrap/app.php` force le rendu JSON des erreurs pour `api/*`.

## Architecture mobile

`provider` pour l'état, `go_router` pour la navigation, câblés dans [main.dart](smartmoney-main/smart_mobile/lib/main.dart) : `ApiClient` → `ApiService` → `AuthProvider`, plus un `TransferDraft`.

- [ApiClient](smartmoney-main/smart_mobile/lib/core/api/api_client.dart) encapsule Dio, injecte le jeton Sanctum depuis `flutter_secure_storage` (clé `auth_token`) via un intercepteur, et expose `extractError()` — le seul endroit qui transforme les `message`/`errors` de Laravel en chaîne affichable. Les blocs `catch` de l'UI doivent toujours l'utiliser.
- `AuthProvider.bootstrap()` restaure la session ; un `/me` en échec supprime le jeton. L'indicateur d'onboarding vit dans `SharedPreferences` (`onboarding_done`), séparément du jeton.
- Le `redirect` de [app_router.dart](smartmoney-main/smart_mobile/lib/core/router/app_router.dart) est l'unique garde d'authentification (splash → onboarding → login → home). Les quatre onglets du bas forment un `StatefulShellRoute.indexedStack` (`/home`, `/history`, `/support`, `/profile`) ; tout le reste est empilé par-dessus.
- L'assistant de transfert est une chaîne de `push` fixe partageant un unique `TransferDraft` (ChangeNotifier) : `/transfer/destination` → `/corridor` → `/operators` (expéditeur) → `/operators?for=recipient` → `/details` → `/confirm` → `go('/transfer/success?id=..')`. `ConfirmScreen` est le seul écran qui appelle l'API ; il rafraîchit l'utilisateur, appelle `draft.reset()`, puis utilise `go` (et non `push`) pour que l'assistant quitte la pile. `TransferDraft.toPayload()` déréférence ses opérateurs et sa destination avec `!`, donc ces écrans ne doivent pas être ouverts hors séquence.
- Les champs de montant sont parsés avec `replaceAll(',', '.')` — les décimales à virgule font partie des saisies attendues.
- `lib/features/<feature>/` contient les écrans et leurs providers, `lib/shared/widgets/` les composants réutilisables, `lib/core/` l'api, le routeur, le thème et les modèles. Tous les modèles sont de simples classes `fromJson` dans un seul fichier, [models.dart](smartmoney-main/smart_mobile/lib/core/models/models.dart) — aucune génération de code.
- Le thème est centralisé dans `AppTheme.light()` + `AppColors` ; mode clair uniquement, police Poppins via `google_fonts`.

## Données de démo

`DatabaseSeeder` enchaîne Country → Operator → ExchangeRate → DemoUser. 12 pays (XOF/XAF/USD/GNF) avec leurs opérateurs de mobile money.

Comptes seedés, mot de passe `password` : `0700000001` (CI/XOF), `0700000002` (SN/XOF), `0700000003` (CM/XAF).

L'inscription comme le seeding créditent un nouveau portefeuille de **1 000 000** dans la devise de l'utilisateur (codé en dur dans `AuthController::register` et `DemoUserSeeder`).
