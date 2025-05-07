import 'dart:convert';
import 'package:frontend/models/Produits.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Méthode pour enregistrer l'objet utilisateur
Future<void> saveUserToPreferences(Map<String, dynamic> user) async {
  final prefs = await SharedPreferences.getInstance();
  String userJson = jsonEncode(user); // Sérialiser l'objet utilisateur en JSON
  await prefs.setString('user', userJson); // Sauvegarder la chaîne JSON
}

// Méthode pour récupérer l'objet utilisateur à partir de SharedPreferences
Future<Map<String, dynamic>?> getUserFromPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  String? userJson = prefs.getString('user'); // Lire la chaîne JSON

  if (userJson != null) {
    print(userJson);
    return jsonDecode(userJson); // Désérialiser la chaîne JSON en Map
  }
  return null; // Si aucun utilisateur n'est trouvé
}

// Méthode pour sauvegarder le token
Future<void> saveTokenToPreferences(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('token', token); // Sauvegarder le token
}

// Méthode pour récupérer le token
Future<String?> getTokenFromPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token'); // Lire le token
}

Future<void> saveTicketId(int ticketId) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('current_ticket_id', ticketId);
}

Future<int?> getTicketId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('current_ticket_id');
}

Future<void> saveCart(Map<Produit, int> cart) async {
  final prefs = await SharedPreferences.getInstance();
  final cartJson = jsonEncode(cart.entries.map((entry) => {
    'product': entry.key.toJson(),  // <- Utilisez toJson() au lieu de fromJson()
    'quantity': entry.value,
  }).toList());
  await prefs.setString('cart', cartJson);
}

Future<Map<Produit, int>> loadCart() async {
  final prefs = await SharedPreferences.getInstance();
  final cartJson = prefs.getString('cart');
  if (cartJson == null) return {};

  final decoded = jsonDecode(cartJson) as List<dynamic>;
  return Map.fromEntries(decoded.map((item) => MapEntry(
    Produit.fromJson(item['product']),
    item['quantity'],
  )));
}

// Méthode pour supprimer le token et l'utilisateur de SharedPreferences
Future<void> clearUserData() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('token');
  await prefs.remove('user');
  await prefs.remove('current_ticket_id');
  await prefs.remove('cart');
}
