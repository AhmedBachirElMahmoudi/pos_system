<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\DocumentController;
use App\Http\Controllers\Magasin;
use App\Http\Controllers\ProduitController;
use Dom\Document;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use League\CommonMark\Renderer\Block\DocumentRenderer;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::post('login', [AuthController::class, 'login']);

// Routes protégées : seulement accessibles si l'utilisateur est authentifié
Route::middleware('auth:sanctum')->group(function () {
    // Exemple d'une route protégée
    Route::get('/user', function (Request $request) {
        return $request->user(); // Accès aux informations de l'utilisateur connecté
    });

    // Ajoute d'autres routes protégées ici
    // Par exemple, une route pour récupérer tous les magasins :

    Route::get('/categories' , [Magasin::class , 'getCategoriesForUserStore']);

    Route::get('produits/categorie/{categorie}' , [ProduitController::class , 'getProductsByCategory']);

    Route::put('/user/update', [AuthController::class, 'updateUser']);

    Route::get('/document/pending' , [DocumentController::class , 'getAllPendingDocuments']);

    Route::post('/document' , [DocumentController::class , 'createNewTicket']);

    Route::post('/document/{id}/lines' , [DocumentController::class , 'addProductLine']);

    Route::delete('/document/{ticket}/lines/{produit}' , [DocumentController::class , 'destroyLines']);

    Route::get('/document/{ticket}/lines', [DocumentController::class, 'getDocumentLines']);

});