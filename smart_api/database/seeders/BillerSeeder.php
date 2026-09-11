<?php

namespace Database\Seeders;

use App\Models\Biller;
use Illuminate\Database\Seeder;

class BillerSeeder extends Seeder
{
    /**
     * Facturiers réels de la zone couverte.
     *
     * Un country_code nul rend le facturier disponible partout : c'est le cas
     * des bouquets TV, présents dans toute la sous-région.
     */
    public function run(): void
    {
        $compteur = 'Numéro de compteur';
        $abonne = "Numéro d'abonné";
        $contrat = 'Numéro de contrat';
        $decodeur = 'Numéro de décodeur';
        $telephone = 'Numéro de téléphone';

        $billers = [
            // [code, nom, catégorie, pays, libellé de référence]
            ['sbee', 'SBEE', 'electricite', 'BJ', $compteur],
            ['soneb', 'SONEB', 'eau', 'BJ', $abonne],

            ['sonabel', 'SONABEL', 'electricite', 'BF', $compteur],
            ['onea', 'ONEA', 'eau', 'BF', $abonne],

            ['cie', 'CIE', 'electricite', 'CI', $compteur],
            ['sodeci', 'SODECI', 'eau', 'CI', $abonne],

            ['senelec', 'Senelec', 'electricite', 'SN', $compteur],
            ['seneau', "SEN'EAU", 'eau', 'SN', $abonne],

            ['eneo', 'ENEO', 'electricite', 'CM', $compteur],
            ['camwater', 'Camwater', 'eau', 'CM', $abonne],
            ['camtel', 'Camtel', 'internet', 'CM', $contrat],

            ['seeg', 'SEEG', 'electricite', 'GA', $compteur],

            ['e2c', 'E2C', 'electricite', 'CG', $compteur],
            ['lcde', 'LCDE', 'eau', 'CG', $abonne],

            ['snel', 'SNEL', 'electricite', 'CD', $compteur],
            ['regideso', 'REGIDESO', 'eau', 'CD', $abonne],

            ['edg', 'EDG', 'electricite', 'GN', $compteur],
            ['seg', 'SEG', 'eau', 'GN', $abonne],
            ['orange_gn', 'Orange Guinée', 'telephone', 'GN', $telephone],
            ['mtn_gn', 'MTN Guinée', 'telephone', 'GN', $telephone],
            ['cellcom_gn', 'Cellcom Guinée', 'telephone', 'GN', $telephone],

            ['edm', 'EDM-SA', 'electricite', 'ML', $compteur],

            ['ceet', 'CEET', 'electricite', 'TG', $compteur],
            ['tde', 'TdE', 'eau', 'TG', $abonne],

            ['nigelec', 'NIGELEC', 'electricite', 'NE', $compteur],
            ['seen', 'SEEN', 'eau', 'NE', $abonne],

            // Disponibles dans tous les pays couverts
            ['canal_plus', 'Canal+', 'tv', null, $decodeur],
            ['startimes', 'StarTimes', 'tv', null, $decodeur],
        ];

        foreach ($billers as [$code, $name, $category, $country, $label]) {
            Biller::updateOrCreate(
                ['code' => $code],
                [
                    'name' => $name,
                    'category' => $category,
                    'country_code' => $country,
                    'reference_label' => $label,
                    'is_active' => true,
                ]
            );
        }
    }
}
