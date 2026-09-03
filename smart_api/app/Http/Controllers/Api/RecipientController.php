<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RecipientController extends Controller
{
    public function lookup(Request $request): JsonResponse
    {
        $data = $request->validate([
            'phone' => ['required', 'string'],
        ]);

        $user = User::query()->where('phone', $data['phone'])->first();

        if (! $user) {
            return response()->json([
                'found' => false,
                'message' => 'Aucun compte trouvé pour ce numéro.',
            ], 404);
        }

        if ($request->user() && $user->id === $request->user()->id) {
            return response()->json([
                'found' => false,
                'message' => 'Ce numéro correspond à votre compte.',
            ], 422);
        }

        return response()->json([
            'found' => true,
            'recipient' => [
                'id' => $user->id,
                'first_name' => $user->first_name,
                'last_name' => $user->last_name,
                'full_name' => $user->full_name,
                'phone' => $user->phone,
                'country_code' => $user->country_code,
                'currency' => $user->currency,
            ],
        ]);
    }
}
