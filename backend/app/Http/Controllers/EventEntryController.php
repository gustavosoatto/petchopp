<?php

namespace App\Http\Controllers;

use App\Models\Event;
use App\Models\EventEntry;
use App\Models\User;
use Illuminate\Http\Request;

class EventEntryController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'event_id' => ['required', 'exists:events,id'],
            'user_identifier' => ['required', 'string'], // Can be user_id, email, or entry_code
            'entry_method' => ['required', 'in:qrcode,nfc,manual'],
            'notes' => ['nullable', 'string'],
        ]);

        // Find user by ID, email, or entry_code
        $user = User::where('id', $validated['user_identifier'])
            ->orWhere('email', $validated['user_identifier'])
            ->orWhere('entry_code', $validated['user_identifier'])
            ->first();

        if (!$user) {
            return response()->json(['message' => 'User not found'], 404);
        }

        // Check if user already checked in to this event
        $existingEntry = EventEntry::where('event_id', $validated['event_id'])
            ->where('user_id', $user->id)
            ->whereDate('entry_time', now()->toDateString())
            ->first();

        if ($existingEntry) {
            return response()->json([
                'message' => 'User already checked in to this event today',
                'entry' => $existingEntry->load('user', 'event')
            ], 409);
        }

        $entry = EventEntry::create([
            'event_id' => $validated['event_id'],
            'user_id' => $user->id,
            'entry_time' => now(),
            'entry_method' => $validated['entry_method'],
            'notes' => $validated['notes'] ?? null,
        ]);

        $entry->load('user', 'event');

        return response()->json($entry, 201);
    }

    public function checkInByCode(Request $request)
    {
        $validated = $request->validate([
            'code' => ['required', 'string'],
            'entry_method' => ['required', 'in:qrcode,nfc,manual'],
        ]);

        $user = User::where('entry_code', strtoupper($validated['code']))->first();

        if (!$user) {
            return response()->json(['message' => 'Invalid entry code'], 404);
        }

        // Get active event
        $event = Event::where('is_active', true)->first();

        if (!$event) {
            return response()->json(['message' => 'No active event'], 404);
        }

        // Check if user already checked in
        $existingEntry = EventEntry::where('event_id', $event->id)
            ->where('user_id', $user->id)
            ->whereDate('entry_time', now()->toDateString())
            ->first();

        if ($existingEntry) {
            return response()->json([
                'message' => 'User already checked in to this event today',
                'entry' => $existingEntry->load('user', 'event')
            ], 409);
        }

        $entry = EventEntry::create([
            'event_id' => $event->id,
            'user_id' => $user->id,
            'entry_time' => now(),
            'entry_method' => $validated['entry_method'],
        ]);

        $entry->load('user', 'event');

        return response()->json($entry, 201);
    }

    public function index()
    {
        $entries = EventEntry::with('user', 'event')
            ->orderBy('entry_time', 'desc')
            ->get();

        return response()->json($entries, 200);
    }
}
