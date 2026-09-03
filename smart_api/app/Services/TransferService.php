<?php

namespace App\Services;

use App\Models\ExchangeRate;
use App\Models\Transaction;
use App\Models\Transfer;
use App\Models\User;
use App\Models\Wallet;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use RuntimeException;

class TransferService
{
    public function getRate(string $from, string $to): float
    {
        if ($from === $to) {
            return 1.0;
        }

        $rate = ExchangeRate::query()
            ->where('from_currency', $from)
            ->where('to_currency', $to)
            ->value('rate');

        if ($rate === null) {
            throw new RuntimeException("Taux de change introuvable pour {$from} → {$to}");
        }

        return (float) $rate;
    }

    public function create(User $sender, array $data): Transfer
    {
        $recipient = User::query()->where('phone', $data['recipient_phone'])->first();

        if (! $recipient) {
            throw new RuntimeException('Destinataire introuvable. Vérifiez le numéro.');
        }

        if ($recipient->id === $sender->id) {
            throw new RuntimeException('Vous ne pouvez pas vous envoyer de l\'argent à vous-même.');
        }

        $amount = (float) $data['amount'];
        if ($amount <= 0) {
            throw new RuntimeException('Le montant doit être supérieur à 0.');
        }

        $rate = $this->getRate($sender->currency, $recipient->currency);
        $amountReceived = round($amount * $rate, 2);
        $reference = 'SM'.strtoupper(Str::random(10));

        return DB::transaction(function () use ($sender, $recipient, $data, $amount, $amountReceived, $rate, $reference) {
            /** @var Wallet $senderWallet */
            $senderWallet = Wallet::query()->where('user_id', $sender->id)->lockForUpdate()->firstOrFail();
            /** @var Wallet $recipientWallet */
            $recipientWallet = Wallet::query()->where('user_id', $recipient->id)->lockForUpdate()->firstOrFail();

            if ((float) $senderWallet->balance < $amount) {
                throw new RuntimeException('Solde insuffisant.');
            }

            $senderWallet->balance = (float) $senderWallet->balance - $amount;
            $senderWallet->save();

            $recipientWallet->balance = (float) $recipientWallet->balance + $amountReceived;
            $recipientWallet->save();

            $transfer = Transfer::create([
                'reference' => $reference,
                'sender_id' => $sender->id,
                'recipient_id' => $recipient->id,
                'amount_sent' => $amount,
                'amount_received' => $amountReceived,
                'fee' => 0,
                'rate' => $rate,
                'sender_currency' => $sender->currency,
                'recipient_currency' => $recipient->currency,
                'sender_operator' => $data['sender_operator'],
                'recipient_operator' => $data['recipient_operator'],
                'destination_country' => $data['destination_country'],
                'status' => 'completed',
            ]);

            Transaction::create([
                'user_id' => $sender->id,
                'type' => 'debit',
                'amount' => $amount,
                'balance_after' => $senderWallet->balance,
                'related_type' => Transfer::class,
                'related_id' => $transfer->id,
                'description' => "Envoi vers {$recipient->full_name}",
            ]);

            Transaction::create([
                'user_id' => $recipient->id,
                'type' => 'credit',
                'amount' => $amountReceived,
                'balance_after' => $recipientWallet->balance,
                'related_type' => Transfer::class,
                'related_id' => $transfer->id,
                'description' => "Réception de {$sender->full_name}",
            ]);

            $receiptPath = $this->generateReceipt($transfer->fresh(['sender', 'recipient']));
            $transfer->update(['receipt_path' => $receiptPath]);

            return $transfer->fresh(['sender', 'recipient']);
        });
    }

    public function generateReceipt(Transfer $transfer): string
    {
        $dir = storage_path('app/public/receipts');
        if (! is_dir($dir)) {
            mkdir($dir, 0755, true);
        }

        $filename = "receipt_{$transfer->reference}.pdf";
        $relative = "receipts/{$filename}";

        $pdf = Pdf::loadView('pdf.receipt', [
            'transfer' => $transfer,
            'logo' => public_path('images/logo.png'),
        ]);

        $pdf->save(storage_path("app/public/{$relative}"));

        return $relative;
    }
}
