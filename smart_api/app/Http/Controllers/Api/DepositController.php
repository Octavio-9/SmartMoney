<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Deposit;
use App\Services\DepositService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use RuntimeException;

class DepositController extends Controller
{
    public function __construct(private DepositService $depositService) {}

    public function index(Request $request): JsonResponse
    {
        $items = Deposit::query()
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get()
            ->map(fn (Deposit $d) => $this->payload($d));

        return response()->json(['data' => $items]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'amount' => ['required', 'numeric', 'gt:0'],
            'operator_code' => ['required', 'string'],
            'phone' => ['required', 'string'],
        ]);

        try {
            $deposit = $this->depositService->create($request->user(), $data);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Rechargement effectué avec succès',
            'deposit' => $this->payload($deposit),
            'wallet' => [
                'balance' => (float) $request->user()->fresh()->wallet->balance,
                'currency' => $request->user()->currency,
            ],
        ], 201);
    }

    private function payload(Deposit $d): array
    {
        return [
            'id' => $d->id,
            'reference' => $d->reference,
            'amount' => (float) $d->amount,
            'currency' => $d->currency,
            'operator_code' => $d->operator_code,
            'phone' => $d->phone,
            'status' => $d->status,
            'created_at' => $d->created_at?->toIso8601String(),
        ];
    }
}
