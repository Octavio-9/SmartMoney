<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('operators', function (Blueprint $table) {
            $table->id();
            $table->string('country_code', 5)->index();
            $table->string('name');
            $table->string('code');
            $table->string('logo')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamps();

            $table->unique(['country_code', 'code']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('operators');
    }
};
