<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class EventEntry extends Model
{
    use HasFactory;

    protected $fillable = [
        'event_id',
        'user_id',
        'entry_time',
        'entry_method',
        'notes',
    ];

    protected $casts = [
        'entry_time' => 'datetime',
    ];

    public function event()
    {
        return $this->belongsTo(Event::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
