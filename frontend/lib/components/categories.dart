import 'package:flutter/material.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/services/preferences_helper.dart';
import 'package:frontend/models/Categorie.dart';

class CategoriesGrid extends StatefulWidget {
  final String selectedCategory;
  final Function(String, int) onCategorySelected;

  const CategoriesGrid({
    required this.selectedCategory,
    required this.onCategorySelected,
    Key? key,
  }) : super(key: key);

  @override
  _CategoriesGridState createState() => _CategoriesGridState();
}

class _CategoriesGridState extends State<CategoriesGrid> {
  List<Categorie> categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? token;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadTokenAndCategories();
  }

  Future<void> _loadTokenAndCategories() async {
    token = await getTokenFromPreferences();

    if (token == null) {
      setState(() {
        _errorMessage = 'No authentication token available';
        _isLoading = false;
      });
    } else if (categories.isEmpty && _errorMessage == null) {
      _loadCategories();
    }
  }

  Future<void> _loadCategories() async {
    print('Loading categories with token: $token');
    try {
      final response = await ApiService.fetchCategories(token!);
      print(response);
      if (mounted) {
        setState(() {
          categories = (response.categories as List)
              .map((json) => Categorie.fromMap(json))
              .toList();
          _isLoading = false;

          if (categories.isNotEmpty && widget.selectedCategory.isEmpty) {
            widget.onCategorySelected(
              categories[0].nom,
              categories[0].idCategorie,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load categories: ${e.toString()}';
          _isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading categories: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  final Map<String, IconData> categoryIcons = {
    "Clothes": Icons.shopping_bag_outlined,
    "Electronics": Icons.electrical_services_outlined,
    "Furniture": Icons.chair_outlined,
    "Shoes": Icons.shopping_cart_outlined,
    "Miscellaneous": Icons.category_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.all(0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
                  ? Center(child: Text(_errorMessage!))
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.all(5),
                      child: Row(
                        children: categories
                            .map((cat) => categoryCard(
                                  cat,
                                  isSelected: cat.nom == widget.selectedCategory,
                                ))
                            .toList(),
                      ),
                    ),
        );
      },
    );
  }

  Widget categoryCard(Categorie categorie, {required bool isSelected}) {
    final IconData icon =
        categoryIcons[categorie.nom] ?? Icons.category_outlined;

    Color cardColor = isSelected ? Colors.blue : Colors.white;
    Color iconBackground = isSelected
        ? Colors.white
        : const Color.fromARGB(255, 227, 221, 221);
    Color iconColor =
        isSelected ? Colors.blue : Colors.grey[800]!;

    return GestureDetector(
      onTap: () {
        widget.onCategorySelected(categorie.nom, categorie.idCategorie);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(7),
        width: 250,
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(icon, color: iconColor, size: 30),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    categorie.nom,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    "Stock: available",
                    style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey[700],
                      fontSize: 14,
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
