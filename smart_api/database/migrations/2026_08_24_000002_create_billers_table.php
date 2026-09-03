<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('billers', function (Blueprint $table) {
            $table->id();
            $table->string('code')->unique();
            $table->string('name');
            // electricite | eau | internet | tv | telephone
            $table->string('category');
            // null = facturier disponible dans tous les pays
            $table->string('country_code', 5)->nullable();
            // Libellé de la référence attendue : « Numéro de compteur », etc.
            $table->string('reference_label')->default('Référence client');
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->index(['country_code', 'category']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('billers');
    }
};
