<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\UserController;
use App\Http\Controllers\EventController;
use App\Http\Controllers\EventEntryController;
use App\Http\Controllers\NfcController;

Route::get('/test', function () {
  return 'Hello from the backend!';
});

// Users routes
Route::apiResource('users', UserController::class);
Route::post('/users/{user}/check-in', [UserController::class, 'checkIn']);

// Events routes
Route::apiResource('events', EventController::class);
Route::get('/events-active', [EventController::class, 'getActiveEvent']);
Route::get('/events/{event}/entries', [EventController::class, 'getEventEntries']);

// Event Entries routes
Route::apiResource('entries', EventEntryController::class)->only(['index', 'store']);
Route::post('/check-in', [EventEntryController::class, 'checkInByCode']);

// NFC routes
Route::post('/verify-nfc', [NfcController::class, 'verify']);

Route::get('/user', function (Request $request) {
  return $request->user();
})->middleware('auth:sanctum');
