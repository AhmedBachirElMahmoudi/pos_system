<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DocumentLines extends Model
{
    use HasFactory;

    protected $table = 'document_ligne'; 

    protected $primaryKey = ['id_doc', 'id_produit'];
    
    public $incrementing = false; 
    public $timestamps = true;

    protected $fillable = [
        'id_doc',
        'id_produit',
        'qte',
        'prixunitaire',
        'remise',
        'mntnet',
        'tautxtva',
        'PUnetTTC',
        'netttc',
    ];

    public function document()
    {
        return $this->belongsTo(Document::class, 'id_doc', 'id_document');
    }

    public function produit()
    {
        return $this->belongsTo(Produit::class, 'id_produit', 'id_produit');
    }
}
