<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
  /**
   * @OA\Get(
   *     path="/api/users",
   *     summary="Get a list of users",
   *     tags={"Users"},
   *     @OA\Response(
   *         response=200,
   *         description="A list of users",
   *         @OA\JsonContent(
   *             type="array",
   *             @OA\Items(ref="#/components/schemas/User")
   *         )
   *     )
   * )
   */
  public function index(Request $request)
  {
    $perPage = (int) $request->query('per_page', 15);
    $perPage = $perPage > 0 ? $perPage : 15;

    $users = User::query()->paginate($perPage);

    return response()->json($users, 200);
  }

  /**
   * @OA\Post(
   *     path="/api/users",
   *     summary="Create a new user",
   *     tags={"Users"},
   *     @OA\RequestBody(
   *         required=true,
   *         @OA\JsonContent(
   *             required={"name", "email", "password"},
   *             @OA\Property(property="name", type="string", example="John Doe"),
   *             @OA\Property(property="email", type="string", format="email", example="john.doe@example.com"),
   *             @OA\Property(property="password", type="string", format="password", example="password")
   *         )
   *     ),
   *     @OA\Response(
   *         response=201,
   *         description="User created successfully",
   *         @OA\JsonContent(ref="#/components/schemas/User")
   *     ),
   *     @OA\Response(
   *         response=422,
   *         description="Validation error"
   *     )
   * )
   */
  public function store(Request $request)
  {
    $validated = $request->validate([
      'name'     => ['required', 'string', 'max:255'],
      'email'    => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
      'password' => ['required', 'string', 'min:8'],
    ]);

    $user = User::create([
      'name'     => $validated['name'],
      'email'    => $validated['email'],
      'password' => Hash::make($validated['password']),
    ]);

    return response()->json($user, 201);
  }

  /**
   * @OA\Get(
   *     path="/api/users/{id}",
   *     summary="Get a specific user",
   *     tags={"Users"},
   *     @OA\Parameter(
   *         name="id",
   *         in="path",
   *         required=true,
   *         description="ID of the user",
   *         @OA\Schema(type="integer")
   *     ),
   *     @OA\Response(
   *         response=200,
   *         description="User details",
   *         @OA\JsonContent(ref="#/components/schemas/User")
   *     ),
   *     @OA\Response(
   *         response=404,
   *         description="User not found"
   *     )
   * )
   */
  public function show(User $user) // Route Model Binding
  {
    return response()->json($user, 200);
  }

  /**
   * @OA\Put(
   *     path="/api/users/{id}",
   *     summary="Update a user",
   *     tags={"Users"},
   *     @OA\Parameter(
   *         name="id",
   *         in="path",
   *         required=true,
   *         description="ID of the user",
   *         @OA\Schema(type="integer")
   *     ),
   *     @OA\RequestBody(
   *         required=true,
   *         @OA\JsonContent(
   *             @OA\Property(property="name", type="string", example="John Doe"),
   *             @OA\Property(property="email", type="string", format="email", example="john.doe@example.com"),
   *             @OA\Property(property="password", type="string", format="password", example="new_password")
   *         )
   *     ),
   *     @OA\Response(
   *         response=200,
   *         description="User updated successfully",
   *         @OA\JsonContent(ref="#/components/schemas/User")
   *     ),
   *     @OA\Response(
   *         response=404,
   *         description="User not found"
   *     ),
   *     @OA\Response(
   *         response=422,
   *         description="Validation error"
   *     )
   * )
   */
  public function update(Request $request, User $user)
  {
    $validated = $request->validate([
      'name'     => ['sometimes', 'string', 'max:255'],
      'email'    => ['sometimes', 'string', 'email', 'max:255', 'unique:users,email,' . $user->id],
      'password' => ['sometimes', 'nullable', 'string', 'min:8'],
    ]);

    if (array_key_exists('name', $validated)) {
      $user->name = $validated['name'];
    }
    if (array_key_exists('email', $validated)) {
      $user->email = $validated['email'];
    }
    if (array_key_exists('password', $validated) && $validated['password']) {
      $user->password = Hash::make($validated['password']);
    }

    $user->save();

    return response()->json($user, 200);
  }

  /**
   * @OA\Delete(
   *     path="/api/users/{id}",
   *     summary="Delete a user",
   *     tags={"Users"},
   *     @OA\Parameter(
   *         name="id",
   *         in="path",
   *         required=true,
   *         description="ID of the user",
   *         @OA\Schema(type="integer")
   *     ),
   *     @OA\Response(
   *         response=204,
   *         description="User deleted successfully"
   *     ),
   *     @OA\Response(
   *         response=404,
   *         description="User not found"
   *     )
   * )
   */
  public function destroy(User $user)
  {
    $user->delete();

    return response()->json(null, 204);
  }

  public function checkIn(User $user)
  {
    $user->entry_time = now();
    $user->save();

    return response()->json($user, 200);
  }
}
