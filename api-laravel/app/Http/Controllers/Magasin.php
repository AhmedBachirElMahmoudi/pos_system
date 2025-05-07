<?php

namespace App\Http\Controllers;

use App\Models\Categorie;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class Magasin extends Controller
{
    //

    public function __construct()
    {
        $this->middleware('auth:sanctum');
    }

    public function getCategoriesForUserStore(Request $request)
    {
        $user = Auth::user();

        // Vérifier si l'utilisateur a un magasin associé
        if (!$user || !$user->magasin) {
            return response()->json(['error' => 'Utilisateur non connecté ou pas de magasin associé'], 403);
        }


        $categories = Categorie::all();

        return response()->json($categories);
        
    }
}
