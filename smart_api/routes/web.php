<?php

use Illuminate\Support\Facades\Route;

// Smart Money n'expose qu'une API JSON. La racine sert de point de santé : les
// hébergeurs y envoient leurs vérifications automatiques, et la vue « welcome »
// de Laravel échouerait faute d'assets Vite compilés.
Route::get('/', function () {
    return response()->json([
        'name' => config('app.name'),
        'status' => 'ok',
        'api' => url('/api'),
    ]);
});
