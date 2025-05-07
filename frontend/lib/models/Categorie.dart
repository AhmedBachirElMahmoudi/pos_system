import 'dart:convert';

Categorie categorieFromMap(String str) => Categorie.fromMap(json.decode(str));

String categorieToMap(Categorie data) => json.encode(data.toMap());

class Categorie {
  int idCategorie;
  String nom;
  String description;
  String image;
  DateTime createdAt;
  DateTime updatedAt;

  Categorie({
    required this.idCategorie,
    required this.nom,
    required this.description,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Categorie.fromMap(Map<String, dynamic> json) => Categorie(
        idCategorie: json["id_categorie"],
        nom: json["nom"],
        description: json["description"],
        image: json["image"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toMap() => {
        "id_categorie": idCategorie,
        "nom": nom,
        "description": description,
        "image": image,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
      };
}
