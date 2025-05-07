import 'package:flutter/material.dart';
import 'package:frontend/components/categories.dart';
import 'package:frontend/components/panier.dart';
import 'package:frontend/components/produits.dart';
import 'package:frontend/models/PendingDocument.dart';
import 'package:frontend/components/searchbar.dart';
import 'package:frontend/models/Produits.dart';
import 'package:frontend/screens/editUser_screen.dart';
import 'package:frontend/services/api_service.dart';
import 'login_screen.dart';
import '../services/preferences_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = '';
  Map<Produit, int> cart = {};
  Map<String, dynamic> user = {};

  String? token;
  List<Produit> _products = [];
  List<Produit> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadUserData().then((_) {
      _loadCart(); // Charge le panier au démarrage
    });
  }

  Future<void> _loadUserData() async {
    try {
      String? fetchedToken = await getTokenFromPreferences();
      print(
        "Fetched Token: $fetchedToken",
      ); // Ajoutez cette ligne pour vérifier
      if (fetchedToken == null) throw Exception('No token found');

      Map<String, dynamic>? userData = await getUserFromPreferences();
      print(
        "Fetched User Data: $userData",
      ); // Ajoutez cette ligne pour vérifier
      if (userData == null) throw Exception('No user data found');

      setState(() {
        token = fetchedToken;
        user = userData;
      });
    } catch (e) {
      print(
        "Error loading user data: $e",
      ); // Log d'erreur pour vérifier où ça échoue
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  Future<void> _loadCart() async {
    try {
      final currentTicketId = await getTicketId();
      if (currentTicketId != null) {
        final cartItems = await ApiService.fetchTicket(token!, currentTicketId);

        setState(() {
          cart = Map.fromEntries(
            cartItems.map((item) {
              final produit = Produit.fromJson(item['produit']);
              final quantity =
                  int.tryParse(
                    double.parse(item['qte'].toString()).toStringAsFixed(0),
                  ) ??
                  0;
              return MapEntry(produit, quantity);
            }),
          );
        });
        await saveCart(cart);
        return;
      }
    } catch (e) {
      print("Erreur API, chargement depuis le cache: $e");
    }

    final cachedCart = await loadCart();
    setState(() => cart = cachedCart);
  }

  Future<void> _logout() async {
    bool confirmLogout = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Déconnexion'),
            content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Déconnexion', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );

    if (confirmLogout == true) {
      await clearUserData();
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Succès'),
              content: Text('Vous avez été déconnecté avec succès.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  Future<void> _loadProductsForCategory(int categoryId) async {
    try {
      final response = await ApiService.fetchProductsByCategory(
        categoryId,
        token!,
      );

      if (response.produits.isNotEmpty) {
        setState(() {
          _products =
              response.produits.map((item) => Produit.fromJson(item)).toList();
          _filteredProducts = _products;
        });
      } else {
        setState(() {
          _products = [];
          _filteredProducts = [];
        });
      }
    } catch (e) {
      setState(() {});
    }
  }

  void onCategorySelected(String category, int categoryId) {
    setState(() {
      selectedCategory = category;
    });

    _loadProductsForCategory(categoryId);
  }

  void _searchProducts(String query) {
    setState(() {
      _filteredProducts =
          _products.where((produit) {
            final lowerQuery = query.toLowerCase();
            return produit.nom.toLowerCase().contains(lowerQuery) ||
                produit.description.toLowerCase().contains(lowerQuery);
          }).toList();
    });
  }

  Future<void> _updateCart(Produit produit, int quantity) async {
    // Validation de la quantité
    if (quantity <= 0) {
      setState(() => cart.remove(produit));
      return;
    }

    // Mise à jour locale immédiate pour un meilleur UX
    setState(() {
      if (quantity > 0) {
        // Vérifie si le produit existe déjà dans le panier
        if (cart.containsKey(produit)) {
          // Si le produit existe, on met à jour sa quantité
          cart[produit] =
              cart[produit]! + quantity; // Ajoute la nouvelle quantité
        } else {
          // Si le produit n'existe pas, on l'ajoute au panier
          cart[produit] = quantity;
        }
      } else {
        // Si la quantité est 0 ou négative, on retire le produit du panier
        cart.remove(produit);
      }
    });

    try {
      // Gestion côté serveur
      final currentTicketId = await getTicketId();

      if (currentTicketId == null) {
        await ApiService.createNewTicket(token!, produit, quantity);
      } else {
        await ApiService.addDocumentLine(
          token!,
          currentTicketId,
          produit,
          quantity,
        );
      }
    } catch (e) {
      // En cas d'erreur, on revert les changements locaux
      setState(() {
        final previousQuantity = (cart[produit] ?? 0) - quantity;
        if (previousQuantity <= 0) {
          cart.remove(produit);
        } else {
          cart[produit] = previousQuantity;
        }
      });

      // Afficher une erreur à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la mise à jour du panier: ${e.toString()}',
          ),
        ),
      );
    }
  }

  Future<void> _removeFromCart(Produit produit) async {
    final currentTicketId = await getTicketId();

    final response = await ApiService.deleteDocumentLine(
      token!,
      currentTicketId!,
      produit.idProduit,
    );

    if (response.statusCode == 200) {
      // Suppression réussie dans la base de données
      setState(() {
        cart.remove(produit);
      });
    } else {
      // Échec de la suppression, afficher un message d’erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Échec de la suppression du produit, veuillez réessayer',
          ),
        ),
      );
    }
  }

  Future<void> _createTicket() async {
    try {
      await ApiService.createEmptyTicket(token!);

      setState(() {
        cart.clear();
      });
      await saveCart(cart); 

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ticket créé avec succès')));
    } catch (e) {
      print("Erreur lors de la création du ticket: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la création du ticket')),
      );
    }
  }

  Future<List<Map<String, dynamic>>> _getPendingTickets() async {
    try {
      final pendingDocs = await ApiService.getTicketEnAtt(token!);
      // Convertir chaque PendingDocument en un Map<String, dynamic>
      return pendingDocs.map((document) => document.toMap()).toList();
    } catch (e) {
      print('Erreur: $e');
      return []; // Retourner une liste vide en cas d'erreur
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: <Widget>[
          // Main Content
          Expanded(
            child: Container(
              color: Colors.grey[200],
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  SearchBarr(
                    user: user,
                    onSearch: _searchProducts,
                    logoutCallback: _logout,
                    createTicketCallback: _createTicket,
                    pendingTicketCallback: _getPendingTickets,
                    loadCartCallback: _loadCart,
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          child: MyPanier(
                            cart: cart,
                            onDeleteProduct: _removeFromCart,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              children: [
                                CategoriesGrid(
                                  selectedCategory: selectedCategory,
                                  onCategorySelected: onCategorySelected,
                                ),
                                SizedBox(height: 5),
                                ProduitSection(
                                  categoryTitle: selectedCategory,
                                  onUpdateCart: _updateCart,
                                  products: _filteredProducts,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
