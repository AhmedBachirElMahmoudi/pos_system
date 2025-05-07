class Produit {
  final int idProduit;
  final String nom;
  final String description;
  final double prix;
  final String imageUrl;
  final int idCategorie;
  final int idTypeProduit;

  Produit({
    required this.idProduit,
    required this.nom,
    required this.description,
    required this.prix,
    required this.imageUrl,
    required this.idCategorie,
    required this.idTypeProduit,
  });

  // Méthode pour convertir un Produit en Map (sérialisation)
  Map<String, dynamic> toJson() => {
    'id_produit': idProduit,
    'nom': nom,
    'description': description,
    'prix': prix,
    'image': imageUrl,
    'id_categorie': idCategorie,
    'id_typeproduit': idTypeProduit,
  };

  // Méthode pour créer un Produit à partir d'un Map (désérialisation)
  factory Produit.fromJson(Map<String, dynamic> json) {
    return Produit(
      idProduit: json['id_produit'],
      nom: json['nom'],
      description: json['description'],
      prix: json['prix'] != null 
          ? double.tryParse(json['prix'].toString()) ?? 0.0
          : 0.0,
      imageUrl: json['image'],
      idCategorie: json['id_categorie'],
      idTypeProduit: json['id_typeproduit'],
    );
  }

  get id => null;

}
