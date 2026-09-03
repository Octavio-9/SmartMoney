<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Biller;
use App\Models\BillPayment;
use App\Services\BillPaymentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use RuntimeException;

class BillPaymentController extends Controller
{
    public function __construct(private BillPaymentService $billPaymentService) {}

    /**
     * Facturiers disponibles : ceux du pays de l'utilisateur, plus les
     * facturiers internationaux dont le country_code est nul.
     */
    public function billers(Request $request): JsonResponse
    {
        $country = $request->user()->country_code;

        $billers = Biller::query()
            ->where('is_active', true)
            ->where(fn ($q) => $q->whereNull('country_code')->orWhere('country_code', $country))
            ->orderBy('category')
            ->orderBy('name')
            ->get()
            ->map(fn (Biller $b) => [
                'code' => $b->code,
                'name' => $b->name,
                'category' => $b->category,
                'country_code' => $b->country_code,
                'reference_label' => $b->reference_label,
            ]);

        return response()->json(['data' => $billers]);
    }

    public function index(Request $request): JsonResponse
    {
        $items = BillPayment::query()
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get()
            ->map(fn (BillPayment $p) => $this->payload($p));

        return response()->json(['data' => $items]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'biller_code' => ['required', 'string', 'exists:billers,code'],
            'customer_reference' => ['required', 'string', 'max:60'],
            'amount' => ['required', 'numeric', 'gt:0'],
        ]);

        try {
            $payment = $this->billPaymentService->create($request->user(), $data);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Paiement effectué avec succès',
            'payment' => $this->payload($payment),
            'wallet' => [
                'balance' => (float) $request->user()->fresh()->wallet->balance,
                'currency' => $request->user()->currency,
            ],
        ], 201);
    }

    private function payload(BillPayment $p): array
    {
        return [
            'id' => $p->id,
            'reference' => $p->reference,
            'biller_code' => $p->biller_code,
            'biller_name' => $p->biller_name,
            'customer_reference' => $p->customer_reference,
            'amount' => (float) $p->amount,
            'currency' => $p->currency,
            'status' => $p->status,
            'created_at' => $p->created_at?->toIso8601String(),
        ];
    }
}
