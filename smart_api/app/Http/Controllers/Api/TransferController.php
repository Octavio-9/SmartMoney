<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transfer;
use App\Services\TransferService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use RuntimeException;
use Symfony\Component\HttpFoundation\StreamedResponse;

class TransferController extends Controller
{
    public function __construct(private TransferService $transferService) {}

    public function index(Request $request): JsonResponse
    {
        $userId = $request->user()->id;

        $transfers = Transfer::query()
            ->with(['sender:id,first_name,last_name,phone', 'recipient:id,first_name,last_name,phone'])
            ->where(fn ($q) => $q->where('sender_id', $userId)->orWhere('recipient_id', $userId))
            ->latest()
            ->get()
            ->map(fn (Transfer $t) => $this->payload($t, $request));

        return response()->json(['data' => $transfers]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'recipient_phone' => ['required', 'string'],
            'amount' => ['required', 'numeric', 'gt:0'],
            'sender_operator' => ['required', 'string'],
            'recipient_operator' => ['required', 'string'],
            'destination_country' => ['required', 'string', 'exists:countries,code'],
        ]);

        try {
            $transfer = $this->transferService->create($request->user(), $data);
        } catch (RuntimeException $e) {
            return response()->json(['message' => $e->getMessage()], 422);
        }

        return response()->json([
            'message' => 'Transfert effectué avec succès',
            'transfer' => $this->payload($transfer, $request),
        ], 201);
    }

    public function show(Request $request, Transfer $transfer): JsonResponse
    {
        $this->authorizeTransfer($request, $transfer);

        return response()->json([
            'transfer' => $this->payload($transfer->load(['sender', 'recipient']), $request),
        ]);
    }

    public function receipt(Request $request, Transfer $transfer): StreamedResponse|JsonResponse
    {
        $this->authorizeTransfer($request, $transfer);

        // Sur un hébergement qui redéploie dans un conteneur neuf, le disque est
        // éphémère : le chemin reste enregistré en base alors que le PDF a
        // disparu. Toutes les données du reçu étant en base, on le régénère.
        if (! $transfer->receipt_path || ! Storage::disk('public')->exists($transfer->receipt_path)) {
            try {
                $path = $this->transferService->generateReceipt(
                    $transfer->fresh(['sender', 'recipient'])
                );
            } catch (\Throwable) {
                return response()->json(['message' => 'Reçu introuvable'], 404);
            }

            $transfer->update(['receipt_path' => $path]);
            $transfer->refresh();
        }

        return Storage::disk('public')->download(
            $transfer->receipt_path,
            "recu_{$transfer->reference}.pdf"
        );
    }

    private function authorizeTransfer(Request $request, Transfer $transfer): void
    {
        $userId = $request->user()->id;
        abort_unless(
            $transfer->sender_id === $userId || $transfer->recipient_id === $userId,
            403,
            'Accès refusé'
        );
    }

    private function payload(Transfer $transfer, Request $request): array
    {
        return [
            'id' => $transfer->id,
            'reference' => $transfer->reference,
            'amount_sent' => (float) $transfer->amount_sent,
            'amount_received' => (float) $transfer->amount_received,
            'fee' => (float) $transfer->fee,
            'rate' => (float) $transfer->rate,
            'sender_currency' => $transfer->sender_currency,
            'recipient_currency' => $transfer->recipient_currency,
            'sender_operator' => $transfer->sender_operator,
            'recipient_operator' => $transfer->recipient_operator,
            'destination_country' => $transfer->destination_country,
            'status' => $transfer->status,
            'receipt_url' => $transfer->receipt_path
                ? url('/api/transfers/'.$transfer->id.'/receipt')
                : null,
            'created_at' => $transfer->created_at?->toIso8601String(),
            'sender' => $transfer->sender ? [
                'id' => $transfer->sender->id,
                'full_name' => $transfer->sender->full_name,
                'phone' => $transfer->sender->phone,
            ] : null,
            'recipient' => $transfer->recipient ? [
                'id' => $transfer->recipient->id,
                'full_name' => $transfer->recipient->full_name,
                'phone' => $transfer->recipient->phone,
            ] : null,
            'direction' => $transfer->sender_id === $request->user()->id ? 'sent' : 'received',
        ];
    }
}
