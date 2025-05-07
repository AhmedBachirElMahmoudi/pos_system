import 'package:flutter/material.dart';
import 'package:frontend/models/Produits.dart';

class ProduitSection extends StatefulWidget {
  final String categoryTitle;
  final Function(Produit, int) onUpdateCart;
  final List<Produit> products;

  ProduitSection({
    required this.categoryTitle,
    required this.onUpdateCart,
    required this.products,
  });

  @override
  _ProduitSectionState createState() => _ProduitSectionState();
}

class _ProduitSectionState extends State<ProduitSection> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categoryTitle,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            LayoutBuilder(
              builder: (context, constraints) {
                double maxWidth = constraints.maxWidth;
                int crossAxisCount = 3;
                double aspectRatio = 1.5;

                if (maxWidth < 600) {
                  crossAxisCount = 2;
                  aspectRatio = 2;
                } else if (maxWidth < 900) {
                  crossAxisCount = 3;
                  aspectRatio = 1.35;
                }else if (maxWidth < 1200) {
                  crossAxisCount = 3;
                  aspectRatio = 1.7;
                } else {
                  crossAxisCount = 4;
                  aspectRatio = 1.6;
                }

                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: aspectRatio,
                  ),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(12),
                  itemCount: widget.products.length,
                  itemBuilder: (context, index) {
                    return ProduitCard(
                      key: ValueKey(
                        widget.products[index].id,
                      ), // Clé unique pour chaque carte
                      produit: widget.products[index],
                      onUpdateCart: widget.onUpdateCart,
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ProduitCard extends StatefulWidget {
  final Produit produit;
  final Function(Produit, int) onUpdateCart;

  // Ajout du paramètre key
  ProduitCard({Key? key, required this.produit, required this.onUpdateCart})
    : super(key: key); // Transfert de la clé à la classe parente

  @override
  _ProduitCardState createState() => _ProduitCardState();
}

class _ProduitCardState extends State<ProduitCard> {
  int quantity = 1;

  void _changeQuantity(int change) {
    setState(() {
      quantity += change;
      if (quantity < 1) quantity = 1;
    });
  }

  void _addToCart() {
    if (quantity > 0) {
      widget.onUpdateCart(widget.produit, quantity);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${widget.produit.nom} ajouté au panier (x$quantity)"),
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        quantity = 1; // Réinitialisation après ajout, si tu veux
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Veuillez sélectionner une quantité avant d'ajouter."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _addToCart,
      child: Container(
        padding: EdgeInsets.all(10),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Infos
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.produit.imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          width: 100,
                          height: 100,
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.produit.nom,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        widget.produit.description,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),

            // Prix & Contrôle
            Container(
              padding: EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Prix
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${widget.produit.prix}",
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: EdgeInsets.only(bottom: 4), // ajuste au besoin
                        child: Text(
                          "MAD",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 157, 158, 157),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Quantité
                  Container(
                    width: 105,
                    padding: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () => _changeQuantity(-1),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Icon(
                            Icons.remove_circle,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        Text(
                          "$quantity",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        InkWell(
                          onTap: () => _changeQuantity(1),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Icon(
                            Icons.add_circle,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
