<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Produit extends Model
{
    use HasFactory;

    protected $table = 'produit';
    protected $primaryKey = 'id_produit';
    public $timestamps = true;

    protected $fillable = [
        'nom',
        'description',
        'prix',
        'image',
        'id_categorie',
        'id_typeproduit'
    ];

    public function categorie()
    {
        return $this->belongsTo(Categorie::class, 'id_categorie');
    }

    public function typeproduit()
    {
        return $this->belongsTo(Typeproduit::class, 'id_typeproduit');
    }

    public function stocks()
    {
        return $this->hasMany(Stock::class, 'id_produit');
    }

    public function lines()
    {
        return $this->hasMany(DocumentLines::class, 'id_doc', 'id_document');
    }
}