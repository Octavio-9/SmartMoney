<?php

namespace App\Services;

use App\Models\Biller;
use App\Models\BillPayment;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use RuntimeException;

class BillPaymentService
{
    public function create(User $user, array $data): BillPayment
    {
        $amount = (float) $data['amount'];
        if ($amount <= 0) {
            throw new RuntimeException('Le montant doit être supérieur à 0.');
        }

        /** @var Biller|null $biller */
        $biller = Biller::query()
            ->where('code', $data['biller_code'])
            ->where('is_active', true)
            ->first();

        if (! $biller) {
            throw new RuntimeException('Facturier introuvable ou indisponible.');
        }

        // Un facturier national ne doit pas être payable depuis un autre pays.
        if ($biller->country_code !== null && $biller->country_code !== $user->country_code) {
            throw new RuntimeException("{$biller->name} n'est pas disponible dans votre pays.");
        }

        $reference = 'SP'.strtoupper(Str::random(10));

        return DB::transaction(function () use ($user, $data, $amount, $reference, $biller) {
            /** @var Wallet $wallet */
            $wallet = Wallet::query()->where('user_id', $user->id)->lockForUpdate()->firstOrFail();

            if ((float) $wallet->balance < $amount) {
                throw new RuntimeException('Solde insuffisant.');
            }

            $wallet->balance = (float) $wallet->balance - $amount;
            $wallet->save();

            $payment = BillPayment::create([
                'reference' => $reference,
                'user_id' => $user->id,
                'biller_code' => $biller->code,
                'biller_name' => $biller->name,
                'customer_reference' => $data['customer_reference'],
                'amount' => $amount,
                'currency' => $user->currency,
                'status' => 'completed',
            ]);

            Transaction::create([
                'user_id' => $user->id,
                'type' => 'debit',
                'amount' => $amount,
                'balance_after' => $wallet->balance,
                'related_type' => BillPayment::class,
                'related_id' => $payment->id,
                'description' => 'Paiement '.$biller->name,
            ]);

            return $payment;
        });
    }
}
