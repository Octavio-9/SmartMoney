<?php

namespace Database\Seeders;

use App\Models\ExchangeRate;
use Illuminate\Database\Seeder;

class ExchangeRateSeeder extends Seeder
{
    public function run(): void
    {
        $rates = [
            ['from_currency' => 'XOF', 'to_currency' => 'XOF', 'rate' => 1],
            ['from_currency' => 'XAF', 'to_currency' => 'XAF', 'rate' => 1],
            ['from_currency' => 'USD', 'to_currency' => 'USD', 'rate' => 1],
            ['from_currency' => 'GNF', 'to_currency' => 'GNF', 'rate' => 1],
            ['from_currency' => 'XOF', 'to_currency' => 'XAF', 'rate' => 1],
            ['from_currency' => 'XAF', 'to_currency' => 'XOF', 'rate' => 1],
            ['from_currency' => 'XOF', 'to_currency' => 'USD', 'rate' => 0.00165],
            ['from_currency' => 'USD', 'to_currency' => 'XOF', 'rate' => 605],
            ['from_currency' => 'XAF', 'to_currency' => 'USD', 'rate' => 0.00165],
            ['from_currency' => 'USD', 'to_currency' => 'XAF', 'rate' => 605],
            ['from_currency' => 'XOF', 'to_currency' => 'GNF', 'rate' => 14.2],
            ['from_currency' => 'GNF', 'to_currency' => 'XOF', 'rate' => 0.0704],
            ['from_currency' => 'XAF', 'to_currency' => 'GNF', 'rate' => 14.2],
            ['from_currency' => 'GNF', 'to_currency' => 'XAF', 'rate' => 0.0704],
            ['from_currency' => 'USD', 'to_currency' => 'GNF', 'rate' => 8600],
            ['from_currency' => 'GNF', 'to_currency' => 'USD', 'rate' => 0.000116],
        ];

        foreach ($rates as $rate) {
            ExchangeRate::updateOrCreate(
                [
                    'from_currency' => $rate['from_currency'],
                    'to_currency' => $rate['to_currency'],
                ],
                ['rate' => $rate['rate']]
            );
        }
    }
}
