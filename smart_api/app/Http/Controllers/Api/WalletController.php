<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WalletController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $wallet = $request->user()->wallet;

        return response()->json([
            'wallet' => [
                'balance' => (float) $wallet->balance,
                'currency' => $wallet->currency,
            ],
        ]);
    }
}
