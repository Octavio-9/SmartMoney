<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BillPaymentController;
use App\Http\Controllers\Api\CountryController;
use App\Http\Controllers\Api\DepositController;
use App\Http\Controllers\Api\ExchangeController;
use App\Http\Controllers\Api\RecipientController;
use App\Http\Controllers\Api\TransferController;
use App\Http\Controllers\Api\WalletController;
use App\Http\Controllers\Api\WithdrawalController;
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::get('/countries', [CountryController::class, 'index']);
Route::get('/operators', [CountryController::class, 'operators']);

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::get('/wallet', [WalletController::class, 'show']);

    Route::get('/recipients/lookup', [RecipientController::class, 'lookup']);

    Route::get('/transfers', [TransferController::class, 'index']);
    Route::post('/transfers', [TransferController::class, 'store']);
    Route::get('/transfers/{transfer}', [TransferController::class, 'show']);
    Route::get('/transfers/{transfer}/receipt', [TransferController::class, 'receipt']);

    Route::get('/withdrawals', [WithdrawalController::class, 'index']);
    Route::post('/withdrawals', [WithdrawalController::class, 'store']);

    Route::get('/deposits', [DepositController::class, 'index']);
    Route::post('/deposits', [DepositController::class, 'store']);

    Route::get('/exchange/rates', [ExchangeController::class, 'rates']);

    Route::get('/billers', [BillPaymentController::class, 'billers']);
    Route::get('/bill-payments', [BillPaymentController::class, 'index']);
    Route::post('/bill-payments', [BillPaymentController::class, 'store']);
});
