<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Domaine extends Model
{
    use HasFactory;

    protected $table = 'domaine';
    protected $primaryKey = 'id_domaine';
    public $timestamps = true;

    protected $fillable = [
        'id_domaine',
        'libelle',
    ];


    public function document(){
        return $this->hasMany(Document::class , 'id_domaine' , 'id_domaine');
    }
}
