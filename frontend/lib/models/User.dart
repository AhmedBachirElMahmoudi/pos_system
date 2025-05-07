import 'dart:convert';

class User {
  final int id;
  final String nom;
  final String email;
  final String? image;
  final int idRole;
  final String idMagasin;
  final String? role; // <- Ajout du champ pour le rôle
  final String createdAt;
  final String updatedAt;
  
  

  User({
    required this.id,
    required this.nom,
    required this.email,
    required this.image,
    required this.idRole,
    required this.idMagasin,
    required this.role, // <- Rôle optionnel
    required this.createdAt,
    required this.updatedAt,
  });

  // Convertir un objet JSON en un objet User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_utilisateur'],
      nom: json['nom'],
      email: json['email'],
      image: json['image'],
      idRole: json['id_role'],
      idMagasin: json['id_magasin'],
      role: json['role'], // <- Ajout de la récupération du rôle
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Convertir un objet User en JSON
  Map<String, dynamic> toJson() {
    return {
      'id_utilisateur': id,
      'nom': nom,
      'email': email,
      'image': image,
      'id_role': idRole,
      'id_magasin': idMagasin,
      'role': role, // <- Ajout du rôle dans la conversion JSON
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Convertir un User en une chaîne JSON
  String toRawJson() => jsonEncode(toJson());

  // Créer un User à partir d'une chaîne JSON
  static User fromRawJson(String str) => User.fromJson(jsonDecode(str));
}
