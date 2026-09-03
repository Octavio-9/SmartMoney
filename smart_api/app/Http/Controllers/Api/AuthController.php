<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Country;
use App\Models\User;
use App\Models\Wallet;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate([
            'first_name' => ['required', 'string', 'max:100'],
            'last_name' => ['required', 'string', 'max:100'],
            'phone' => ['required', 'string', 'max:30', 'unique:users,phone'],
            'password' => ['required', 'string', 'min:6'],
            'country_code' => ['required', 'string', 'exists:countries,code'],
        ]);

        $country = Country::query()->where('code', $data['country_code'])->firstOrFail();

        $user = User::create([
            'first_name' => $data['first_name'],
            'last_name' => $data['last_name'],
            'phone' => $data['phone'],
            'password' => $data['password'],
            'country_code' => $country->code,
            'currency' => $country->currency,
        ]);

        Wallet::create([
            'user_id' => $user->id,
            'balance' => 1000000,
            'currency' => $country->currency,
        ]);

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $this->userPayload($user->load(['wallet', 'country'])),
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $data = $request->validate([
            'phone' => ['required', 'string'],
            'password' => ['required', 'string'],
        ]);

        $user = User::query()->where('phone', $data['phone'])->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            throw ValidationException::withMessages([
                'phone' => ['Identifiants incorrects.'],
            ]);
        }

        $token = $user->createToken('mobile')->plainTextToken;

        return response()->json([
            'token' => $token,
            'user' => $this->userPayload($user->load(['wallet', 'country'])),
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Déconnecté']);
    }

    public function me(Request $request): JsonResponse
    {
        return response()->json([
            'user' => $this->userPayload($request->user()->load(['wallet', 'country'])),
        ]);
    }

    public static function userPayload(User $user): array
    {
        return [
            'id' => $user->id,
            'first_name' => $user->first_name,
            'last_name' => $user->last_name,
            'full_name' => $user->full_name,
            'phone' => $user->phone,
            'country_code' => $user->country_code,
            'currency' => $user->currency,
            'country' => $user->country ? [
                'code' => $user->country->code,
                'name_fr' => $user->country->name_fr,
                'currency' => $user->country->currency,
                'currency_name' => $user->country->currency_name,
                'flag_code' => $user->country->flag_code,
                'dial_code' => $user->country->dial_code,
            ] : null,
            'wallet' => $user->wallet ? [
                'balance' => (float) $user->wallet->balance,
                'currency' => $user->wallet->currency,
            ] : null,
        ];
    }
}
