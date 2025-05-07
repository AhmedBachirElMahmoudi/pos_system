import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:frontend/models/PendingDocument.dart';
import 'package:frontend/models/Produits.dart';
import 'package:frontend/services/preferences_helper.dart';
import 'package:http/http.dart' as http;

// Classe représentant la réponse d'authentification
class AuthResponse {
  final String token;
  final Map<String, dynamic> user;

  AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(token: json['token'], user: json['user']);
  }
}

// Classe représentant la réponse des catégories
class CategoriesResponse {
  final List<dynamic> categories;

  CategoriesResponse({required this.categories});

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesResponse(categories: json['categories']);
  }
}

class ProductsResponse {
  final List<dynamic> produits;

  ProductsResponse({required this.produits});

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(produits: json['produits']);
  }
}

class ApiService {
  // Use your Laravel local development URL
  static final String baseUrl = () {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api';
    } else {
      return 'http://127.0.0.1:8000/api';
    }
  }();


  // Login method
  static Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('tes $responseData');

        return AuthResponse.fromJson(
          responseData,
        ); // Retourne un objet AuthResponse
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to login');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  static Future<CategoriesResponse> fetchCategories(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Si la réponse est une liste de catégories directement
        if (responseData is List) {
          return CategoriesResponse(categories: responseData);
        } else {
          // Si la réponse est un objet avec une clé "categories"
          return CategoriesResponse.fromJson(responseData);
        }
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(
          responseData['message'] ?? 'Failed to fetch categories',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  static Future<ProductsResponse> fetchProductsByCategory(
    int categoryId,
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produits/categorie/$categoryId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Si la réponse est une liste directement
        if (responseData is List) {
          return ProductsResponse(
            produits: responseData,
          ); // Retourne une liste de produits
        } else {
          // Si la réponse est un objet avec une clé "produits"
          return ProductsResponse.fromJson(responseData);
        }
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to fetch products');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  static Future<void> updateUser(
    Map<String, dynamic> userData,
    String token,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/update'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        // L'utilisateur a été mis à jour avec succès
        print('Utilisateur mis à jour avec succès');
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(responseData['message'] ?? 'Failed to update user');
      }
    } catch (e) {
      throw Exception('Failed to connect to server: $e');
    }
  }

  static Future<List<PendingDocument>> getTicketEnAtt(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/document/pending'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<dynamic> data = responseData['data'];


        return data.map((item) => PendingDocument.fromMap(item)).toList();
      } else {
        throw Exception('Échec avec le statut ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Échec de la connexion au serveur : $e');
    }
  }

  static Future<void> createNewTicket(
    String token,
    Produit produit,
    int quantity,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/document'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Utilisez votre token ici
        },
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final ticketId = responseData['ticket_id'];

        // Enregistrer le nouvel ID du ticket dans SharedPreferences
        await saveTicketId(ticketId);

        // Ajouter la ligne de document au nouveau ticket
        await addDocumentLine(token, ticketId, produit, quantity);
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(
          responseData['message'] ?? 'Erreur lors de la création du ticket',
        );
      }
    } catch (e) {
      throw Exception('Échec de la connexion au serveur : $e');
    }
  }

  static Future<void> createEmptyTicket(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/document'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final ticketId = responseData['ticket_id'];
        await saveTicketId(ticketId);
      } else {
        final responseData = jsonDecode(response.body);
        throw Exception(
          responseData['message'] ?? 'Erreur lors de la création du ticket',
        );
      }
    } catch (e) {
      throw Exception('Échec de la connexion au serveur : $e');
    }
  }

  static Future<void> addDocumentLine(
    String token,
    int ticketId,
    Produit produit,
    int quantity,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/document/$ticketId/lines'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'produit_id': produit.idProduit,
          'quantity': quantity,
        }),
      );

      print(
        'Request Body: ${jsonEncode({'produit_id': produit.idProduit, 'quantity': quantity})}',
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ ${responseData['message']}');
      } else {
        print('❌ Erreur côté serveur : ${responseData['message']}');
        throw Exception(
          responseData['message'] ??
              'Erreur lors de l\'ajout de la ligne de document',
        );
      }
    } catch (e) {
      print('❌ Exception de connexion : $e');
      throw Exception('Échec de la connexion au serveur');
    }
  }

  static Future<http.Response> deleteDocumentLine(
    String token,
    int ticketId,
    int produitId,
  ) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/document/$ticketId/lines/$produitId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return response;
  }

  static Future<List<dynamic>> fetchTicket(String token, int ticketId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/document/$ticketId/lines'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['document']; // car tu as fait: 'document' => $document->lines
    } else {
      throw Exception('Erreur lors du chargement des lignes de document');
    }
  }
}
