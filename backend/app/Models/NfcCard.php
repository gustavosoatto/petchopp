<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

/**
 * @OA\Schema(
 *     schema="NfcCard",
 *     type="object",
 *     title="NfcCard",
 *     required={"nfc_tag"},
 *     properties={
 *         @OA\Property(property="id", type="integer", format="int64", readOnly=true),
 *         @OA\Property(property="nfc_tag", type="string"),
 *         @OA\Property(property="details", type="string"),
 *         @OA\Property(property="created_at", type="string", format="date-time", readOnly=true),
 *         @OA\Property(property="updated_at", type="string", format="date-time", readOnly=true)
 *     }
 * )
 */
class NfcCard extends Model
{
  /**
   * The attributes that are mass assignable.
   *
   * @var list<string>
   */
  protected $fillable = [
    'user',
    'empresa',
    'hashcode',
    'validate',
  ];
}
