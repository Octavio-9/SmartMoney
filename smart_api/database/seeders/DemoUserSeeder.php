<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Wallet;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DemoUserSeeder extends Seeder
{
    public function run(): void
    {
        $users = [
            [
                'first_name' => 'Amélie',
                'last_name' => 'Kouassi',
                'phone' => '0700000001',
                'country_code' => 'CI',
                'currency' => 'XOF',
            ],
            [
                'first_name' => 'Moussa',
                'last_name' => 'Diallo',
                'phone' => '0700000002',
                'country_code' => 'SN',
                'currency' => 'XOF',
            ],
            [
                'first_name' => 'Paul',
                'last_name' => 'Mbarga',
                'phone' => '0700000003',
                'country_code' => 'CM',
                'currency' => 'XAF',
            ],
            [
                'first_name' => 'Fatoumata',
                'last_name' => 'Camara',
                'phone' => '0700000004',
                'country_code' => 'GN',
                'currency' => 'GNF',
            ],
        ];

        foreach ($users as $data) {
            $user = User::updateOrCreate(
                ['phone' => $data['phone']],
                [
                    'first_name' => $data['first_name'],
                    'last_name' => $data['last_name'],
                    'country_code' => $data['country_code'],
                    'currency' => $data['currency'],
                    'password' => Hash::make('password'),
                ]
            );

            Wallet::updateOrCreate(
                ['user_id' => $user->id],
                [
                    'balance' => 1000000,
                    'currency' => $data['currency'],
                ]
            );
        }
    }
}
