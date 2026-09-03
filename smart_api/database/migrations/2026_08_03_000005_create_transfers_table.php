<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('transfers', function (Blueprint $table) {
            $table->id();
            $table->string('reference')->unique();
            $table->foreignId('sender_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('recipient_id')->constrained('users')->cascadeOnDelete();
            $table->decimal('amount_sent', 18, 2);
            $table->decimal('amount_received', 18, 2);
            $table->decimal('fee', 18, 2)->default(0);
            $table->decimal('rate', 18, 6);
            $table->string('sender_currency', 5);
            $table->string('recipient_currency', 5);
            $table->string('sender_operator');
            $table->string('recipient_operator');
            $table->string('destination_country', 5);
            $table->string('status')->default('completed');
            $table->string('receipt_path')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('transfers');
    }
};
