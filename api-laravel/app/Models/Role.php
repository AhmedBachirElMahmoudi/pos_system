<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Role extends Model
{
    use HasFactory;

    protected $table = 'role';
    protected $primaryKey = 'id_role';
    public $timestamps = true;

    protected $fillable = ['nom'];

    public function utilisateurs()
    {
        return $this->hasMany(Utilisateur::class, 'id_role');
    }
}