<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class TypeDocument extends Model
{
    use HasFactory;

    protected $table = 'type_document';
    protected $primaryKey = 'id_type';
    public $timestamps = true;

    protected $fillable = [
        'id_type',
        'libeller',
    ];

    


}
