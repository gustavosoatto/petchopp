<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Event extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'description',
        'start_date',
        'end_date',
        'location',
        'is_active',
    ];

    protected $casts = [
        'start_date' => 'datetime',
        'end_date' => 'datetime',
        'is_active' => 'boolean',
    ];

    public function entries()
    {
        return $this->hasMany(EventEntry::class);
    }

    public function users()
    {
        return $this->belongsToMany(User::class, 'event_entries')
            ->withPivot('entry_time', 'entry_method', 'notes')
            ->withTimestamps();
    }
}
