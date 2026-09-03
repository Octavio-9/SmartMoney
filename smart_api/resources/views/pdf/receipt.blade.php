<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="utf-8">
    <title>Reçu Smart Money</title>
    <style>
        body { font-family: DejaVu Sans, sans-serif; color: #111; font-size: 12px; }
        .header { text-align: center; margin-bottom: 24px; }
        .logo { width: 72px; height: 72px; }
        .brand { color: #0062AD; font-size: 22px; font-weight: bold; margin-top: 8px; }
        .box { border: 1px solid #e5e5e5; border-radius: 8px; padding: 16px; margin-top: 12px; }
        .row { display: table; width: 100%; margin-bottom: 8px; }
        .label { display: table-cell; color: #757575; width: 45%; }
        .value { display: table-cell; font-weight: bold; text-align: right; }
        .success { color: #277A1F; font-size: 16px; font-weight: bold; text-align: center; margin: 16px 0; }
        .footer { margin-top: 28px; text-align: center; color: #757575; font-size: 10px; }
    </style>
</head>
<body>
    <div class="header">
        @if(file_exists($logo))
            <img class="logo" src="{{ $logo }}" alt="Smart Money">
        @endif
        <div class="brand">Smart Money</div>
        <div>Reçu de paiement</div>
    </div>

    <div class="success">Paiement confirmé</div>

    <div class="box">
        <div class="row"><span class="label">Référence</span><span class="value">{{ $transfer->reference }}</span></div>
        <div class="row"><span class="label">Date</span><span class="value">{{ $transfer->created_at->format('d/m/Y H:i') }}</span></div>
        <div class="row"><span class="label">Expéditeur</span><span class="value">{{ $transfer->sender->full_name }}</span></div>
        <div class="row"><span class="label">Destinataire</span><span class="value">{{ $transfer->recipient->full_name }}</span></div>
        <div class="row"><span class="label">Téléphone destinataire</span><span class="value">{{ $transfer->recipient->phone }}</span></div>
        <div class="row"><span class="label">Pays destination</span><span class="value">{{ $transfer->destination_country }}</span></div>
        <div class="row"><span class="label">Opérateur expéditeur</span><span class="value">{{ $transfer->sender_operator }}</span></div>
        <div class="row"><span class="label">Opérateur destinataire</span><span class="value">{{ $transfer->recipient_operator }}</span></div>
        <div class="row"><span class="label">Montant envoyé</span><span class="value">{{ number_format($transfer->amount_sent, 2, ',', ' ') }} {{ $transfer->sender_currency }}</span></div>
        <div class="row"><span class="label">Montant reçu</span><span class="value">{{ number_format($transfer->amount_received, 2, ',', ' ') }} {{ $transfer->recipient_currency }}</span></div>
        <div class="row"><span class="label">Frais</span><span class="value">{{ number_format($transfer->fee, 2, ',', ' ') }} {{ $transfer->sender_currency }}</span></div>
        <div class="row"><span class="label">Taux</span><span class="value">1 {{ $transfer->sender_currency }} = {{ rtrim(rtrim(number_format($transfer->rate, 6, '.', ''), '0'), '.') }} {{ $transfer->recipient_currency }}</span></div>
        <div class="row"><span class="label">Statut</span><span class="value">{{ strtoupper($transfer->status) }}</span></div>
    </div>

    <div class="footer">Merci d'utiliser Smart Money — Transferts sécurisés Afrique</div>
</body>
</html>
