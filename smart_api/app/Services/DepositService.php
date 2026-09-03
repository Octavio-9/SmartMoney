<?php

namespace App\Services;

use App\Models\Deposit;
use App\Models\Transaction;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use RuntimeException;

class DepositService
{
    /**
     * Plafond par opération.
     *
     * Le rechargement est simulé : aucun opérateur mobile money n'est réellement
     * débité, le solde est crédité sans contrepartie. Ce garde-fou évite qu'une
     * saisie erronée — ou volontaire — crédite un montant absurde.
     */
    private const MAX_AMOUNT = 1000000;

    public function create(User $user, array $data): Deposit
    {
        $amount = (float) $data['amount'];

        if ($amount <= 0) {
            throw new RuntimeException('Le montant doit être supérieur à 0.');
        }

        if ($amount > self::MAX_AMOUNT) {
            throw new RuntimeException(
                'Le montant ne peut pas dépasser '.number_format(self::MAX_AMOUNT, 0, ',', ' ').' par rechargement.'
            );
        }

        $reference = 'SD'.strtoupper(Str::random(10));

        return DB::transaction(function () use ($user, $data, $amount, $reference) {
            /** @var Wallet $wallet */
            $wallet = Wallet::query()->where('user_id', $user->id)->lockForUpdate()->firstOrFail();

            $wallet->balance = (float) $wallet->balance + $amount;
            $wallet->save();

            $deposit = Deposit::create([
                'reference' => $reference,
                'user_id' => $user->id,
                'amount' => $amount,
                'currency' => $user->currency,
                'operator_code' => $data['operator_code'],
                'phone' => $data['phone'],
                'status' => 'completed',
            ]);

            Transaction::create([
                'user_id' => $user->id,
                'type' => 'credit',
                'amount' => $amount,
                'balance_after' => $wallet->balance,
                'related_type' => Deposit::class,
                'related_id' => $deposit->id,
                'description' => 'Rechargement depuis '.$data['operator_code'],
            ]);

            return $deposit;
        });
    }
}
