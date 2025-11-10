<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class CardController extends Controller
{
  /**
   * Display a listing of the resource.
   */
  public function index()
  {
    return User::all();
  }

  /**
   * Store a newly created resource in storage.
   */
  public function store(Request $request)
  {
    $validatedData = $request->validate([
      'user' => 'required|string|max:255',
      'empresa' => 'required|string|max:255',
      'hashcode' => 'required|string|min:8',
      'validate' => 'required|string|min:8',
    ]);

    $NfcCard = NfcCard::create([
      'user' => $validatedData['user'],
      'empresa' => $validatedData['empresa'],
      'hashcode' => Hash::make($validatedData['hashcode']),
      'validate' => $validatedData['validate'],
    ]);

    return response()->json($NfcCard, 201);
  }

  /**
   * Display the specified resource.
   */
  public function show(string $id)
  {
    return NfcCard::findOrFail($id);
  }

  /**
   * Update the specified resource in storage.
   */
  public function update(Request $request, string $id)
  {
    $NfcCard = NfcCard::findOrFail($id);

    $validatedData = $request->validate([
      'user' => 'string|max:255',
      'empresa' => 'string|max:255' . $NfcCard->id,
      'hashcode' => 'string|min:8',
      'validate' => 'string|min:8',
    ]);

    if ($request->has('user')) {
      $NfcCard->user = $validatedData['user'];
    }

    if ($request->has('empresa')) {
      $NfcCard->empresa = $validatedData['empresa'];
    }

    if ($request->has('hashcode')) {
      $user->hashcode = Hash::make($validatedData['hashcode']);
    }
    if ($request->has('validate')) {
      $user->validate = Hash::make($validatedData['validate']);
    }

    $NfcCard->save();

    return response()->json($NfcCard);
  }

  /**
   * Remove the specified resource from storage.
   */
  public function destroy(string $id)
  {
    $NfcCard = NfcCard::findOrFail($id);
    $NfcCard->delete();

    return response()->json(null, 204);
  }
}
