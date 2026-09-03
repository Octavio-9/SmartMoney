<?php

namespace Database\Seeders;

use App\Models\Operator;
use Illuminate\Database\Seeder;

class OperatorSeeder extends Seeder
{
    public function run(): void
    {
        $map = [
            'BJ' => [['Orange Money', 'orange_money'], ['MTN MoMo', 'mtn'], ['Moov Money', 'moov']],
            'BF' => [['Orange Money', 'orange_money'], ['Moov Money', 'moov']],
            'CI' => [['Orange Money', 'orange_money'], ['MTN MoMo', 'mtn'], ['Wave', 'wave'], ['Moov Money', 'moov']],
            'SN' => [['Orange Money', 'orange_money'], ['Wave', 'wave'], ['Free Money', 'free_money']],
            'CM' => [['Orange Money', 'orange_money'], ['MTN MoMo', 'mtn']],
            'GA' => [['Airtel Money', 'airtel'], ['Moov Money', 'moov']],
            'CG' => [['Airtel Money', 'airtel'], ['MTN MoMo', 'mtn']],
            'CD' => [['Orange Money', 'orange_money'], ['Airtel Money', 'airtel'], ['M-Pesa', 'mpesa']],
            'GN' => [['Orange Money', 'orange_money'], ['MTN MoMo', 'mtn']],
            'ML' => [['Orange Money', 'orange_money'], ['Moov Money', 'moov']],
            'TG' => [['TMoney', 'tmoney'], ['Moov Money', 'moov']],
            'NE' => [['Airtel Money', 'airtel'], ['Moov Money', 'moov']],
        ];

        foreach ($map as $countryCode => $operators) {
            foreach ($operators as [$name, $code]) {
                Operator::updateOrCreate(
                    ['country_code' => $countryCode, 'code' => $code],
                    ['name' => $name, 'logo' => null, 'is_active' => true]
                );
            }
        }
    }
}
