<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DocumentStatuts extends Model
{
    use HasFactory;

    protected $table = 'document_statuts';
    protected $primaryKey = 'id_statut';
    public $timestamps = true;


    protected $fillable = [
        'nom',
        'description'
    ];

    public function documents()
    {
        return $this->hasMany(Document::class, 'statut', 'id_statut');
    }
}
