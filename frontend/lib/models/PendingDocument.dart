import 'dart:convert';

PendingDocument pendingDocumentFromMap(String str) =>
    PendingDocument.fromMap(json.decode(str));

String pendingDocumentToMap(PendingDocument data) =>
    json.encode(data.toMap());

class PendingDocument {
  int idDocument;
  int idDomaine;
  int idType;
  int idTiers;
  String nDoc;
  DateTime dateDoc;
  int idDepot;
  String? idDepotCible;  // Peut être null
  double totalht;
  double remise;
  double totalnet;
  double totalttc;
  String? ndevis;  // Peut être null
  String? nbl;  // Peut être null
  String? nfactur;  // Peut être null
  String statutNom;
  DateTime created;
  DateTime updated;

  PendingDocument({
    required this.idDocument,
    required this.idDomaine,
    required this.idType,
    required this.idTiers,
    required this.nDoc,
    required this.dateDoc,
    required this.idDepot,
    required this.idDepotCible,
    required this.totalht,
    required this.remise,
    required this.totalnet,
    required this.totalttc,
    required this.ndevis,
    required this.nbl,
    required this.nfactur,
    required this.statutNom,
    required this.created,
    required this.updated,
  });

  factory PendingDocument.fromMap(Map<String, dynamic> json) => PendingDocument(
    idDocument: json["id_document"],
    idDomaine: json["id_domaine"],
    idType: json["id_type"],
    idTiers: json["id_tiers"],
    nDoc: json["N_doc"],
    dateDoc: DateTime.parse(json["date_doc"]),
    idDepot: json["id_depot"],
    idDepotCible: json["id_depot_cible"] as String?,  // Peut être null
    totalht: (json["totalht"] is double) ? json["totalht"] : 0.0,
    remise: (json["remise"] is double) ? json["remise"] : 0.0,
    totalnet: (json["totalnet"] is double) ? json["totalnet"] : 0.0,
    totalttc: (json["totalttc"] is double) ? json["totalttc"] : 0.0,
    ndevis: json["Ndevis"] as String?,  // Peut être null
    nbl: json["Nbl"] as String?,  // Peut être null
    nfactur: json["Nfactur"] as String?,  // Peut être null
    statutNom: json["statut_nom"],
    created: DateTime.parse(json["created"]),
    updated: DateTime.parse(json["updated"]),
  );

  Map<String, dynamic> toMap() => {
    "id_document": idDocument,
    "id_domaine": idDomaine,
    "id_type": idType,
    "id_tiers": idTiers,
    "N_doc": nDoc,
    "date_doc": "${dateDoc.year.toString().padLeft(4, '0')}-${dateDoc.month.toString().padLeft(2, '0')}-${dateDoc.day.toString().padLeft(2, '0')}",
    "id_depot": idDepot,
    "id_depot_cible": idDepotCible,  // Peut être null
    "totalht": totalht,
    "remise": remise,
    "totalnet": totalnet,
    "totalttc": totalttc,
    "Ndevis": ndevis,  // Peut être null
    "Nbl": nbl,  // Peut être null
    "Nfactur": nfactur,  // Peut être null
    "statut_nom": statutNom,
    "created": created.toIso8601String(),
    "updated": updated.toIso8601String(),
  };
}
