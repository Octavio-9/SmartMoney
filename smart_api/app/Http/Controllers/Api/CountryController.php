<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Country;
use App\Models\Operator;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CountryController extends Controller
{
    public function index(): JsonResponse
    {
        $countries = Country::query()->orderBy('name_fr')->get()->map(fn (Country $c) => [
            'code' => $c->code,
            'name_fr' => $c->name_fr,
            'currency' => $c->currency,
            'currency_name' => $c->currency_name,
            'flag_code' => $c->flag_code,
            'dial_code' => $c->dial_code,
        ]);

        return response()->json(['data' => $countries]);
    }

    public function operators(Request $request): JsonResponse
    {
        $request->validate([
            'country' => ['required', 'string', 'exists:countries,code'],
        ]);

        $operators = Operator::query()
            ->where('country_code', $request->string('country'))
            ->where('is_active', true)
            ->orderBy('name')
            ->get()
            ->map(fn (Operator $o) => [
                'id' => $o->id,
                'country_code' => $o->country_code,
                'name' => $o->name,
                'code' => $o->code,
                'logo' => $o->logo,
            ]);

        return response()->json(['data' => $operators]);
    }
}
