<?php

namespace Database\Seeders;

use App\Models\Country;
use Illuminate\Database\Seeder;

class CountrySeeder extends Seeder
{
    public function run(): void
    {
        $countries = [
            ['code' => 'BJ', 'name_fr' => 'Bénin', 'currency' => 'XOF', 'currency_name' => 'CFA Franc BCEAO', 'flag_code' => 'bj', 'dial_code' => '+229'],
            ['code' => 'BF', 'name_fr' => 'Burkina Faso', 'currency' => 'XOF', 'currency_name' => 'CFA Franc BCEAO', 'flag_code' => 'bf', 'dial_code' => '+226'],
            ['code' => 'CI', 'name_fr' => "Côte d'Ivoire", 'currency' => 'XOF', 'currency_name' => 'CFA Franc BCEAO', 'flag_code' => 'ci', 'dial_code' => '+225'],
            ['code' => 'SN', 'name_fr' => 'Sénégal', 'currency' => 'XOF', 'currency_name' => 'CFA Franc BCEAO', 'flag_code' => 'sn', 'dial_code' => '+221'],
            ['code' => 'CM', 'name_fr' => 'Cameroun', 'currency' => 'XAF', 'currency_name' => 'Central African CFA Franc', 'flag_code' => 'cm', 'dial_code' => '+237'],
            ['code' => 'GA', 'name_fr' => 'Gabon', 'currency' => 'XAF', 'currency_name' => 'Central African CFA Franc', 'flag_code' => 'ga', 'dial_code' => '+241'],
            ['code' => 'CG', 'name_fr' => 'République du Congo', 'currency' => 'XAF', 'currency_name' => 'Central African CFA Franc', 'flag_code' => 'cg', 'dial_code' => '+242'],
            ['code' => 'CD', 'name_fr' => 'République démocratique du Congo', 'currency' => 'USD', 'currency_name' => 'US Dollar', 'flag_code' => 'cd', 'dial_code' => '+243'],
            ['code' => 'GN', 'name_fr' => 'Guinée', 'currency' => 'GNF', 'currency_name' => 'Guinean Franc', 'flag_code' => 'gn', 'dial_code' => '+224'],
            ['code' => 'ML', 'name_fr' => 'Mali', 'currency' => 'XOF', 'currency_name' => 'CFA Franc BCEAO', 'flag_code' => 'ml', 'dial_code' => '+223'],
            ['code' => 'TG', 'name_fr' => 'Togo', 'currency' => 'XOF', 'currency_name' => 'CFA Franc BCEAO', 'flag_code' => 'tg', 'dial_code' => '+228'],
            ['code' => 'NE', 'name_fr' => 'Niger', 'currency' => 'XOF', 'currency_name' => 'CFA Franc BCEAO', 'flag_code' => 'ne', 'dial_code' => '+227'],
        ];

        foreach ($countries as $country) {
            Country::updateOrCreate(['code' => $country['code']], $country);
        }
    }
}
