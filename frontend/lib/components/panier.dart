import 'package:flutter/material.dart';
import 'package:frontend/models/Produits.dart';

class MyPanier extends StatelessWidget {
  final Map<Produit, int> cart;
  final Future<void> Function(Produit) onDeleteProduct;

  const MyPanier({super.key, required this.cart, required this.onDeleteProduct});

  @override
  Widget build(BuildContext context) {
    double subTotal = 0.0;
    cart.forEach((produit, quantity) {
      subTotal += produit.prix * quantity;
    });

    double tax = 5.2;
    double totalPayment = subTotal + tax;

    return Container(
      width: MediaQuery.of(context).size.width < 600
          ? double.infinity
          : MediaQuery.of(context).size.width * 0.3,
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Liste des produits ou message si panier vide
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Text(
                      'Aucun produit dans le panier',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      Produit produit = cart.keys.elementAt(index);
                      return Column(
                        children: [
                          Dismissible(
                            key: ValueKey(produit), // Utiliser une clé unique pour chaque produit
                            direction: DismissDirection.endToStart, // Glisser de droite à gauche pour supprimer
                            onDismissed: (direction) async {
                              // Action de suppression lors du glissement
                              await onDeleteProduct(produit);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "${produit.nom} supprimé du panier",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              height: 100,
                              child: Icon(Icons.delete, color: Colors.white),
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          produit.nom,
                                          style: TextStyle(
                                            fontSize: 18, fontWeight: FontWeight.bold),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "x ${cart[produit]}",
                                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                      ),
                                      SizedBox(width: 30),
                                      Text(
                                        "${produit.prix}",
                                        style: TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 8),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20), // Espace entre les éléments du panier
                        ],
                      );
                    },
                  ),
          ),
          // Section de résumé de paiement
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Payment Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _buildPaymentRow('Sub Total', '${subTotal.toStringAsFixed(2)} MAD'),
                _buildPaymentRow('Tax', '${tax.toStringAsFixed(2)} MAD'),
                _buildPaymentRow('Total Payment', '${totalPayment.toStringAsFixed(2)} MAD', isBold: true),
                const SizedBox(height: 0),
              ],
            ),
          ),
          // Prix total avec bouton de validation
          Padding(
            padding: const EdgeInsets.only(top: 14.0, left: 14.0, right: 14.0, bottom: 0.0),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Commande validée")),
                  );
                },
                child: const Text(
                  'Place An Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
