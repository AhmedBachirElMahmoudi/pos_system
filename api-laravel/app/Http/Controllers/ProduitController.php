<?php

namespace App\Http\Controllers;

use App\Models\Categorie;
use App\Models\Produit;
use Illuminate\Http\Request;

class ProduitController extends Controller
{
    //

    public function __construct()
    {
        $this->middleware('auth:sanctum');
    }

    public function getProductsByCategory(Categorie $categorie) {
        $produits = Produit::where('id_categorie', $categorie->id_categorie)->get();
    
        // Vérifie si des produits existent pour cette catégorie
        if ($produits->isEmpty()) {
            return response()->json(['message' => 'Aucun produit trouvé pour cette catégorie'], 404);
        }
    
        return response()->json($produits);
    }
    
}
