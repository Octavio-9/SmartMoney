# Smart Money — Comptes démo

## API

```bash
cd smart_api
php artisan serve --host=0.0.0.0 --port=8000
```

## Flutter

```bash
cd smart_mobile
flutter run
```

Base URL Android émulateur : `http://10.0.2.2:8000/api`  
(appareil physique : IP locale de la machine, ex. `--dart-define=API_BASE_URL=http://192.168.x.x:8000/api`)

## Comptes seedés (mot de passe : `password`)

| Téléphone   | Nom            | Pays | Devise |
|-------------|----------------|------|--------|
| 0700000001  | Amélie Kouassi | CI   | XOF    |
| 0700000002  | Moussa Diallo  | SN   | XOF    |
| 0700000003  | Paul Mbarga    | CM   | XAF    |

Solde initial : **1 000 000** par portefeuille.
