<?php

namespace App\Services;

use App\Models\Transaction;
use App\Models\User;
use App\Models\Wallet;
use App\Models\Withdrawal;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use RuntimeException;

class WithdrawalService
{
    public function create(User $user, array $data): Withdrawal
    {
        $amount = (float) $data['amount'];
        if ($amount <= 0) {
            throw new RuntimeException('Le montant doit être supérieur à 0.');
        }

        $reference = 'SW'.strtoupper(Str::random(10));

        return DB::transaction(function () use ($user, $data, $amount, $reference) {
            /** @var Wallet $wallet */
            $wallet = Wallet::query()->where('user_id', $user->id)->lockForUpdate()->firstOrFail();

            if ((float) $wallet->balance < $amount) {
                throw new RuntimeException('Solde insuffisant.');
            }

            $wallet->balance = (float) $wallet->balance - $amount;
            $wallet->save();

            $withdrawal = Withdrawal::create([
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
                'type' => 'debit',
                'amount' => $amount,
                'balance_after' => $wallet->balance,
                'related_type' => Withdrawal::class,
                'related_id' => $withdrawal->id,
                'description' => 'Retrait vers '.$data['operator_code'],
            ]);

            return $withdrawal;
        });
    }
}
