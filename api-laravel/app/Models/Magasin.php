<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Magasin extends Model
{
    use HasFactory;

    protected $table = 'magasin';
    protected $primaryKey = 'id_magasin';
    public $timestamps = true;

    protected $fillable = [
        'nom',
        'adresse',
        'telephone',
        'email',
        'type_magasin'
    ];

    public function utilisateurs()
    {
        return $this->hasMany(Utilisateur::class, 'id_magasin');
    }

    public function stocks()
    {
        return $this->hasMany(Stock::class, 'id_magasin');
    }
}