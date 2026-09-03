<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Withdrawal;
use App\Services\WithdrawalService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use RuntimeException;

class WithdrawalController extends Controller
{
    public function __construct(private WithdrawalService $withdrawalService) {}

    public function index(Request $request): JsonResponse
    {
        $items = Withdrawal::query()
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get()
            ->map(fn (Withdrawal $w) => $this->payload($w));

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
            $withdrawal = $this->withdrawalService->create($request->user(), $data);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Retrait effectué avec succès',
            'withdrawal' => $this->payload($withdrawal),
            'wallet' => [
                'balance' => (float) $request->user()->fresh()->wallet->balance,
                'currency' => $request->user()->currency,
            ],
        ], 201);
    }

    private function payload(Withdrawal $w): array
    {
        return [
            'id' => $w->id,
            'reference' => $w->reference,
            'amount' => (float) $w->amount,
            'currency' => $w->currency,
            'operator_code' => $w->operator_code,
            'phone' => $w->phone,
            'status' => $w->status,
            'created_at' => $w->created_at?->toIso8601String(),
        ];
    }
}
