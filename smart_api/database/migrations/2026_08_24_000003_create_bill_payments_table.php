<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('bill_payments', function (Blueprint $table) {
            $table->id();
            $table->string('reference')->unique();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('biller_code');
            $table->string('biller_name');
            // Numéro de compteur, d'abonné, de contrat selon le facturier.
            $table->string('customer_reference');
            $table->decimal('amount', 18, 2);
            $table->string('currency', 5);
            $table->string('status')->default('completed');
            $table->timestamps();

            $table->index('biller_code');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('bill_payments');
    }
};
