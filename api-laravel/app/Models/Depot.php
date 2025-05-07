<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Depot extends Model
{
    use HasFactory;

    protected $table = 'depot'; // Nom de la table dans la base de données
    protected $primaryKey = 'id_depot'; // Clé primaire
    public $timestamps = true; // Si created_at et updated_at sont utilisés

    protected $fillable = [
        'nom',
        'adresse',
    ];

    public function document(){
        return $this->hasMany(Document::class , 'id_depot' , 'id_depot');
    }
}
