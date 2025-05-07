<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Document extends Model
{
    use HasFactory;

    protected $table = 'document';
    protected $primaryKey = 'id_document';
    public $timestamps = true;

    protected $fillable = [
        'id_document',
        'id_domaine',
        'id_type',
        'id_tiers',
        'N_doc',
        'date_doc',
        'id_depot',
        'id_depot_cible',
        'statut',
        'totalht',
        'remise',
        'totalnet',
        'totalttc',
        'Ndevis',
        'Nbc',
        'Nbl',
        'Nfacture',
    ];

    public function domaine(){
        return $this->belongsTo(Domaine::class , 'id_domaine' , 'id_domaine');
    }

    public function typeDocuement(){
        return $this->belongsTo(TypeDocument::class , 'id_type' , 'id_type');
    }

    public function depot()
    {
        return $this->belongsTo(Depot::class, 'id_depot', 'id_depot');
    }

    public function tiers(){
        return $this->belongsTo(Tiers::class , 'id_tiers' , 'id_tiers');
    }

    public function lines()
    {
        return $this->hasMany(DocumentLines::class, 'id_doc', 'id_document');
    }

    public function statut()
    {
        return $this->belongsTo(DocumentStatuts::class, 'statut', 'id_statut');
    }
}
