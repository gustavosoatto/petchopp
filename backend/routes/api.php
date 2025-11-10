<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;

Route::get('/test', function () {
  return 'Hello from the backend!';
});

Route::apiResource('users', UserController::class);

use App\Http\Controllers\NfcController;

Route::get('/user', function (Request $request) {
  return $request->user();
})->middleware('auth:sanctum');

Route::post('/verify-nfc', [NfcController::class, 'verify']);
