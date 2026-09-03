<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ExchangeRate;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ExchangeController extends Controller
{
    /**
     * Taux disponibles depuis la devise de l'utilisateur.
     *
     * Le calcul de conversion est fait côté client à partir de ces taux, avec la
     * même formule que TransferService : montant × taux, arrondi à 2 décimales.
     */
    public function rates(Request $request): JsonResponse
    {
        $base = $request->user()->currency;

        $rates = ExchangeRate::query()
            ->where('from_currency', $base)
            ->where('to_currency', '!=', $base)
            ->orderBy('to_currency')
            ->get()
            ->map(fn (ExchangeRate $r) => [
                'currency' => $r->to_currency,
                'rate' => (float) $r->rate,
            ]);

        return response()->json([
            'base' => $base,
            'data' => $rates,
        ]);
    }
}
