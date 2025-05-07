<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Stock extends Model
{
    use HasFactory;

    protected $table = 'stock';
    protected $primaryKey = 'id_stock';
    public $timestamps = true;

    protected $fillable = [
        'id_magasin',
        'id_produit',
        'quantite',
        'stock_min',
        'stck_max'
    ];

    public function magasin()
    {
        return $this->belongsTo(Magasin::class, 'id_magasin');
    }

    public function produit()
    {
        return $this->belongsTo(Produit::class, 'id_produit');
    }
}