<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Typeproduit extends Model
{
    use HasFactory;

    protected $table = 'typeproduit';
    protected $primaryKey = 'id_typeproduit';
    public $timestamps = true;

    protected $fillable = ['nom'];

    public function produits()
    {
        return $this->hasMany(Produit::class, 'id_typeproduit');
    }
}