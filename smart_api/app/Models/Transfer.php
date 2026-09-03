<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Attributes\Fillable;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

#[Fillable([
    'reference',
    'sender_id',
    'recipient_id',
    'amount_sent',
    'amount_received',
    'fee',
    'rate',
    'sender_currency',
    'recipient_currency',
    'sender_operator',
    'recipient_operator',
    'destination_country',
    'status',
    'receipt_path',
])]
class Transfer extends Model
{
    protected function casts(): array
    {
        return [
            'amount_sent' => 'decimal:2',
            'amount_received' => 'decimal:2',
            'fee' => 'decimal:2',
            'rate' => 'decimal:6',
        ];
    }

    public function sender(): BelongsTo
    {
        return $this->belongsTo(User::class, 'sender_id');
    }

    public function recipient(): BelongsTo
    {
        return $this->belongsTo(User::class, 'recipient_id');
    }
}
