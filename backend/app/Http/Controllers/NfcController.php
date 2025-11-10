<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\NfcCard; // Import the NfcCard model

class NfcController extends Controller
{
    /**
     * @OA\Post(
     *     path="/api/verify-nfc",
     *     summary="Verify an NFC tag",
     *     tags={"NFC"},
     *     @OA\RequestBody(
     *         required=true,
     *         @OA\JsonContent(
     *             required={"nfc_tag"},
     *             @OA\Property(property="nfc_tag", type="string", example="TAG_EXEMPLO_123")
     *         )
     *     ),
     *     @OA\Response(
     *         response=200,
     *         description="NFC card found and verified",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="string", example="success"),
     *             @OA\Property(property="message", type="string", example="Cartão NFC encontrado e verificado."),
     *             @OA\Property(property="card_details", ref="#/components/schemas/NfcCard")
     *         )
     *     ),
     *     @OA\Response(
     *         response=404,
     *         description="NFC card not found",
     *         @OA\JsonContent(
     *             @OA\Property(property="status", type="string", example="error"),
     *             @OA\Property(property="message", type="string", example="Cartão NFC não encontrado ou não registrado.")
     *         )
     *     ),
     *      @OA\Response(
     *         response=422,
     *         description="Validation error",
     *         @OA\JsonContent(
     *             @OA\Property(property="message", type="string", example="The nfc tag field is required."),
     *             @OA\Property(property="errors", type="object",
     *                 @OA\Property(property="nfc_tag", type="array",
     *                     @OA\Items(type="string", example="The nfc tag field is required.")
     *                 )
     *             )
     *         )
     *     )
     * )
     */
    public function verify(Request $request)
    {
        // Validate the incoming request
        $request->validate([
            'nfc_tag' => 'required|string|max:255',
        ]);

        // Check if the NFC tag exists in the database
        $nfcCard = NfcCard::where('nfc_tag', $request->nfc_tag)->first();

        if ($nfcCard) {
            // If the card is found, return a success response
            return response()->json([
                'status' => 'success',
                'message' => 'Cartão NFC encontrado e verificado.',
                'card_details' => $nfcCard // Optionally return card details
            ], 200);
        } else {
            // If the card is not found, return a failure response
            return response()->json([
                'status' => 'error',
                'message' => 'Cartão NFC não encontrado ou não registrado.'
            ], 404);
        }
    }
}
