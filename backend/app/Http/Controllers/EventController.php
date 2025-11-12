<?php

namespace App\Http\Controllers;

use App\Models\Event;
use Illuminate\Http\Request;

class EventController extends Controller
{
    public function index()
    {
        $events = Event::with('entries.user')->orderBy('start_date', 'desc')->get();
        return response()->json($events, 200);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'start_date' => ['required', 'date'],
            'end_date' => ['nullable', 'date', 'after:start_date'],
            'location' => ['nullable', 'string', 'max:255'],
            'is_active' => ['boolean'],
        ]);

        $event = Event::create($validated);

        return response()->json($event, 201);
    }

    public function show(Event $event)
    {
        $event->load('entries.user');
        return response()->json($event, 200);
    }

    public function update(Request $request, Event $event)
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'description' => ['nullable', 'string'],
            'start_date' => ['sometimes', 'date'],
            'end_date' => ['nullable', 'date', 'after:start_date'],
            'location' => ['nullable', 'string', 'max:255'],
            'is_active' => ['boolean'],
        ]);

        $event->update($validated);

        return response()->json($event, 200);
    }

    public function destroy(Event $event)
    {
        $event->delete();
        return response()->json(null, 204);
    }

    public function getActiveEvent()
    {
        $event = Event::where('is_active', true)
            ->orderBy('start_date', 'desc')
            ->first();

        if (!$event) {
            return response()->json(['message' => 'No active event found'], 404);
        }

        $event->load('entries.user');
        return response()->json($event, 200);
    }

    public function getEventEntries(Event $event)
    {
        $entries = $event->entries()
            ->with('user')
            ->orderBy('entry_time', 'desc')
            ->get();

        return response()->json($entries, 200);
    }
}
