<?php

namespace App\Http\Controllers;

use App\Models\Document;
use App\Models\DocumentLines;
use App\Models\Produit;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;

class DocumentController extends Controller
{
    //
    const PENDING_STATUS = 1;

    public function __construct()
    {
        $this->middleware('auth:sanctum');
    }


    public function getAllPendingDocuments()
    {
        try {
            // Join with statuts table instead of using Eloquent relationship
            $documents = Document::select('document.*', 'document_statuts.nom as statut_nom')
                ->leftJoin('document_statuts', 'document.statut', '=', 'document_statuts.id_statut')
                ->where('document.statut', self::PENDING_STATUS)
                ->get();
                
            $formattedDocuments = $documents->map(function ($document) {
                return [
                    'id_document' => $document->id_document,
                    'id_domaine' => $document->id_domaine,
                    'id_type' => $document->id_type,
                    'id_tiers' => $document->id_tiers,
                    'N_doc' => $document->N_doc,
                    'date_doc' => $document->date_doc,
                    'id_depot' => $document->id_depot,
                    'id_depot_cible' => $document->id_depot_cible,
                    'totalht' => (float)$document->totalht,
                    'remise' => (float)$document->remise,
                    'totalnet' => (float)$document->totalnet,
                    'totalttc' => (float)$document->totalttc,
                    'Ndevis' => $document->Ndevis,
                    'Nbl' => $document->Nbl,
                    'Nfactur' => $document->Nfacture,
                    'statut_nom' => $document->statut_nom ?? 'Unknown',
                    'created' => $document->created_at,
                    'updated' => $document->updated_at,
                ];
            });
            
            return response()->json([
                'data' => $formattedDocuments,
                'message' => 'Pending documents retrieved successfully',
                'meta' => [
                    'count' => $formattedDocuments->count()
                ]
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Erreur lors de la récupération des documents.',
                'message' => $e->getMessage(),
            ], 500);
        }
    }






    private function generateNumeroDocument()
    {
        $lastDocument = Document::orderBy('id_document', 'desc')->first();
        $nextNumber = $lastDocument ? $lastDocument->id_document + 1 : 1;

        return 'DOC-' . str_pad($nextNumber, 6, '0', STR_PAD_LEFT);
    }

    public function createNewTicket(){

        try{
            $dateDoc = Carbon::now()->format('Y-m-d');

            $numeroDoc = $this->generateNumeroDocument();
            
            $document = Document::create([
                'id_domaine' => 1, // adapte cette valeur selon ton système
                'id_type' => 1,
                'id_tiers' => 1,
                'id_depot' => 1,
                'date_doc' => $dateDoc,
                'N_doc' => $numeroDoc,
                'statut' => 1, // statut par défaut
                'totalht' => 0,
                'remise' => 0,
                'totalnet' => 0,
                'totalttc' => 0,
            ]);

            return response()->json([
                'success' => true,
                'ticket_id' => $document->id_document,
                'message' => 'Ticket créé avec succès.',
            ], 201);
        } catch(\Exception $e){
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la création du ticket.',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function addProductLine(Request $request, $ticket)
    {
        try {
            $validated = $request->validate([
                'produit_id' => 'required|exists:produit,id_produit',
                'quantity' => 'required|integer|min:1',
            ]);

            // Vérification du document
            $document = Document::findOrFail($ticket);

            // Récupération du produit
            $produit = Produit::find($validated['produit_id']);
            
            if (!$produit) {
                return response()->json([
                    'success' => false,
                    'message' => 'Produit non trouvé.',
                ], 404);
            }

            // Calcul des montants
            $prixUnitaire = $produit->prix;
            $qte = $validated['quantity'];
            $remise = 0;
            $tva = 20; // TVA fixe
            $mntnet = $prixUnitaire * $qte;
            $PUnetTTC = $prixUnitaire * (1 + $tva / 100);
            $netttc = $PUnetTTC * $qte;

            // Vérifier si la ligne existe déjà
            $existingLine = DocumentLines::where('id_doc', $document->id_document)
                                        ->where('id_produit', $produit->id_produit)
                                        ->first();

            if ($existingLine) {
                // Mise à jour de la ligne existante
                DB::table('document_ligne')
                ->where('id_doc', $document->id_document)
                ->where('id_produit', $produit->id_produit)
                ->update([
                    'qte' => DB::raw("qte + $qte"),
                    'mntnet' => DB::raw("mntnet + $mntnet"),
                    'PUnetTTC' => $PUnetTTC,
                    'netttc' => DB::raw("netttc + $netttc"),
                ]);
            } else {
                // Création d'une nouvelle ligne
                DocumentLines::create([
                    'id_doc' => $document->id_document,
                    'id_produit' => $produit->id_produit,
                    'qte' => $qte,
                    'prixunitaire' => $prixUnitaire,
                    'remise' => $remise,
                    'mntnet' => $mntnet,
                    'tautxtva' => $tva,
                    'PUnetTTC' => $PUnetTTC,
                    'netttc' => $netttc,
                ]);
            }

            // Mise à jour des totaux dans le document
            Document::where('id_document', $document->id_document)->update([
                'totalht' => DB::raw("totalht + $mntnet"),
                'totalttc' => DB::raw("totalttc + $netttc"),
            ]);

            return response()->json([
                'success' => true,
                'message' => $existingLine 
                            ? 'Ligne de document mise à jour avec succès.' 
                            : 'Ligne de document ajoutée avec succès.',
            ], $existingLine ? 200 : 201);

        } catch (\Illuminate\Validation\ValidationException $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation.',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de l\'ajout de la ligne de document.',
                'error' => $e->getMessage()
            ], 500);
        }
    }


    public function destroyLines($ticket, $produit)
    {
        try {
            $document = Document::findOrFail($ticket);
            $produit = Produit::findOrFail($produit);

            $existingLine = DocumentLines::where('id_doc', $document->id_document)
                                        ->where('id_produit', $produit->id_produit)
                                        ->first();

            if ($existingLine) {
                DocumentLines::where('id_doc', $document->id_document)
                            ->where('id_produit', $produit->id_produit)
                            ->delete();

                return response()->json(['message' => 'Ligne de document supprimée avec succès'], 200);
            }

            return response()->json(['message' => 'Ligne de document non trouvée'], 404);

        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Une erreur s\'est produite',
                'error' => $e->getMessage()
            ], 500);
        }
    }





    public function getDocumentLines($ticket)
    {
        try {
            // On récupère le document avec ses lignes et les produits associés
            $document = Document::with(['lines.produit'])
                                ->where('id_document', $ticket)
                                ->firstOrFail();

            return response()->json([
                'document' => $document->lines
            ], 200);
            
        } catch (\Exception $e) {
            return response()->json([
                'message' => 'Erreur lors de la récupération des lignes du document',
                'error' => $e->getMessage()
            ], 500);
        }
    }



}
