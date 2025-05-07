<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Tiers extends Model
{
    use HasFactory;

    protected $table = 'tiers';
    protected $primaryKey = 'id_tiers';
    public $timestamps = true;

    protected $fillable = [
        'id_tiers',
        'type_tiers',
        'nom',
        'ICE',
        'adresse',
        'id_ville',
        'email',
        'tele',
        'carte_fidelite',
    ];


    public function document(){
        return $this->hasMany(Document::class , 'id_tiers' , 'id_tiers');
    }

    
}
