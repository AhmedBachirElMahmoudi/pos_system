<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Categorie extends Model
{
    use HasFactory;

    protected $table = 'categorie';
    protected $primaryKey = 'id_categorie';
    public $timestamps = true;

    protected $fillable = [
        'nom', 
        'description',
        'image'
    ];

    public function produits()
    {
        return $this->hasMany(Produit::class, 'id_categorie');
    }
}