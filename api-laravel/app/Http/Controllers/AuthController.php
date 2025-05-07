<?php

namespace App\Http\Controllers;

use App\Models\Utilisateur;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Fonction de connexion pour les utilisateurs
     */

    public function login(Request $request)
    {
        // Validation des données d'entrée
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        // Recherche de l'utilisateur dans la base de données avec la relation "role"
        $user = Utilisateur::with('role')->where('email', $request->email)->first();

        // Vérification si l'utilisateur existe et si le mot de passe est correct
        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Les informations d\'identification ne correspondent pas à nos archives.'],
            ]);
        }

        // Création du token d'accès
        $token = $user->createToken('api-laravel')->plainTextToken;

        // Préparer les données utilisateur avec le rôle
        $userData = [
            'id_utilisateur' => $user->id_utilisateur,
            'nom' => $user->nom,
            'email' => $user->email,
            'image' => $user->image,
            'id_role' => $user->id_role,
            'id_magasin' => $user->id_magasin,
            'role' => $user->role?->nom, // <- Inclure uniquement le nom du rôle
            'created_at' => $user->created_at,
            'updated_at' => $user->updated_at,
        ];

        return response()->json([
            'token' => $token,
            'user' => $userData
        ]);
    }


    /**
     * Fonction de déconnexion pour les utilisateurs
     */
    public function logout(Request $request)
    {
        // Requête pour récupérer l'utilisateur authentifié
        $user = $request->user();

        // Révocation du token d'authentification actuel
        $user->tokens->each(function ($token) {
            $token->delete();
        });

        // Retourne un message de confirmation de déconnexion
        return response()->json(['message' => 'Déconnexion réussie.']);
    }

    public function updateUser(Request $request)
    {
        // Récupérer l'utilisateur authentifié
        $user = $request->user();

        // Validation des données
        $request->validate([
            'nom' => 'required|string|max:255',
            'email' => 'required|email|max:255|unique:utilisateur,email,' . $user->id_utilisateur, // Exclure l'email de l'utilisateur actuel
            'password' => 'nullable|string|min:8', // Si un mot de passe est fourni
            'image' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048', // Validation de l'image
        ]);

        // Mise à jour du nom et de l'email
        $user->nom = $request->input('nom');
        $user->email = $request->input('email');

        // Mise à jour du mot de passe (si fourni)
        if ($request->filled('password')) {
            $user->password = Hash::make($request->input('password')); // Hacher le mot de passe
        }

        // Gestion de l'image (si une nouvelle image est téléchargée)
        if ($request->hasFile('image')) {
            // Supprimer l'ancienne image si elle existe
            if ($user->image && Storage::exists($user->image)) {
                Storage::delete($user->image);
            }

            // Enregistrer la nouvelle image et obtenir le chemin
            $imagePath = $request->file('image')->store('user_images', 'public');
            $user->image = $imagePath; // Mettre à jour le champ image
        }

        // Sauvegarder les modifications dans la base de données
        $user->save();

        // Retourner une réponse JSON avec les nouvelles informations de l'utilisateur
        return response()->json([
            'message' => 'Utilisateur mis à jour avec succès.',
            'user' => $user
        ]);
    }

}
