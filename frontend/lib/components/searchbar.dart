import 'package:flutter/material.dart';
import 'package:frontend/screens/editUser_screen.dart';
import 'package:frontend/services/preferences_helper.dart';

// SearchBar Widget
class SearchBarr extends StatefulWidget {
  final Map<String, dynamic> user;
  final ValueChanged<String> onSearch;
  final Future<void> Function() logoutCallback;
  final Future<void> Function() createTicketCallback;
  final Future<List<Map<String, dynamic>>> Function() pendingTicketCallback;
  final Future<void> Function() loadCartCallback;

  const SearchBarr({
    super.key,
    required this.user,
    required this.onSearch,
    required this.logoutCallback,
    required this.createTicketCallback,
    required this.pendingTicketCallback,
    required this.loadCartCallback,
  });

  @override
  State<SearchBarr> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBarr> {
  List<Map<String, dynamic>> pendingTickets = [];
  bool isLoading = false;

  // Chargement des tickets en attente
  Future<void> _loadPendingTickets() async {
    setState(() {
      isLoading = true;
    });

    try {
      pendingTickets = await widget.pendingTicketCallback();
    } catch (e) {
      print('Erreur lors du chargement des tickets: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String fullName = widget.user['nom'] ?? 'Utilisateur';
    List<String> nameParts = fullName.split(' ');
    String initials =
        nameParts.length >= 2
            ? (nameParts[0][0] + nameParts[1][0]).toUpperCase()
            : fullName.substring(0, min(fullName.length, 2)).toUpperCase();

    String? imagePath = widget.user['image'];
    String roleUser = widget.user['role'];

    // Fonction pour obtenir l'image de l'utilisateur
    ImageProvider? getUserImage(String? path) {
      if (path == null || path.isEmpty) return null;
      if (path.startsWith('http')) {
        return NetworkImage(path);
      } else {
        return AssetImage(path);
      }
    }

    return Container(
      height: 90,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Champ de recherche
          Container(
            width: 550,
            child: TextField(
              onChanged: widget.onSearch,
              decoration: InputDecoration(
                hintText: 'Search a Products ...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Color.fromARGB(255, 248, 248, 248),
              ),
            ),
          ),
          Spacer(),
          // Bouton: Créer un ticket vide
          GestureDetector(
            onTap: widget.createTicketCallback,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.add, color: Colors.white, size: 30),
                ),
                SizedBox(height: 5),
                Text(
                  'Créer Ticket vide',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ],
            ),
          ),
          SizedBox(width: 20),
          // Bouton: Tickets en attente avec Popup
          GestureDetector(
            onTap: () async {
              // Afficher un indicateur de chargement pendant que les tickets sont récupérés
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return Center(child: CircularProgressIndicator());
                },
              );

              // Appeler la fonction _loadPendingTickets pour récupérer les tickets
              await _loadPendingTickets();

              // Fermer l'indicateur de chargement
              Navigator.pop(context);

              // Afficher la liste des tickets
              // Remplace uniquement cette partie dans onTap de "Tickets en attente"
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  TextEditingController _searchController =
                      TextEditingController();
                  List<Map<String, dynamic>> filteredTickets = List.from(
                    pendingTickets,
                  );

                  return StatefulBuilder(
                    builder: (context, setState) {
                      void _filterTickets(String query) {
                        setState(() {
                          filteredTickets =
                              pendingTickets
                                  .where(
                                    (ticket) =>
                                        ticket['N_doc'].toString().contains(
                                          query,
                                        ) ||
                                        ticket['date_doc'].toString().contains(
                                          query,
                                        ),
                                  )
                                  .toList();
                        });
                      }

                      return Dialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: EdgeInsets.all(20),
                          constraints: BoxConstraints(
                            maxHeight: 600,
                            maxWidth: 500,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  Icon(
                                    Icons.receipt_long_rounded,
                                    color: Colors.blue,
                                    size: 26,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Tickets en attente',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Spacer(),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: Icon(
                                      Icons.close_rounded,
                                      color: Colors.grey[500],
                                      size: 24,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),

                              // Barre de recherche
                              TextField(
                                controller: _searchController,
                                onChanged: _filterTickets,
                                decoration: InputDecoration(
                                  hintText: 'Rechercher un ticket...',
                                  prefixIcon: Icon(Icons.search),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16),

                              // Liste des tickets
                              Expanded(
                                child: filteredTickets.isEmpty
                                        ? Center(
                                          child: Text(
                                            'Aucun ticket trouvé.',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 16,
                                            ),
                                          ),
                                        )
                                        : ListView.builder(
                                          itemCount: filteredTickets.length,
                                          itemBuilder: (context, index) {
                                            final ticket =
                                                filteredTickets[index];
                                            final number =
                                                ticket['N_doc'] ?? '---';
                                            final date =
                                                ticket['date_doc'] ?? '';
                                            final montant =
                                                (ticket['totalttc'] ?? 0)
                                                    .toDouble();

                                            return Card(
                                              elevation: 2,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              margin: EdgeInsets.only(
                                                bottom: 10,
                                              ),
                                              child: ListTile(
                                                onTap: () async {
                                                  await saveTicketId(ticket['id_document']);
                                                  Navigator.of(context).pop();
                                                  await widget.loadCartCallback();
                                                },
                                                leading: Icon(
                                                  Icons.receipt,
                                                  color: Colors.blue,
                                                ),
                                                title: Text(
                                                  'Ticket #$number',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                subtitle: Text(
                                                  'Date: $date',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                  ),
                                                ),
                                                trailing: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 4,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.orange,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              20,
                                                            ),
                                                      ),
                                                      child: Text(
                                                        'En attente',
                                                        style: TextStyle(
                                                          fontSize: 11,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      '${montant.toStringAsFixed(2)} €',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.green,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                  ),
                              ),
                              // Bouton Fermer
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.close),
                                  label: Text('Fermer'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            child: Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.pending_actions,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Tickets en attente',
                    style: TextStyle(fontSize: 12, color: Colors.orange),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Spacer(),
          // Avatar + User Info Popup
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                // Handle logout
                widget.logoutCallback();
              } else if (value == 'edit_info') {
                // Affichage de l'effet de chargement
                await navigateToEditUserScreen();
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem<String>(
                    value: 'edit_info',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.blue),
                        SizedBox(width: 10),
                        Text('Changer les informations'),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Se déconnecter'),
                      ],
                    ),
                  ),
                ],
            color: const Color.fromARGB(255, 255, 255, 255),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blueGrey[100],
                  backgroundImage: getUserImage(imagePath),
                  child:
                      getUserImage(imagePath) == null
                          ? Text(
                            initials,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : null,
                ),
                SizedBox(width: 10),
                // User Info
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      roleUser,
                      style: TextStyle(fontSize: 17, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fonction d'aide pour éviter RangeError sur String.substring
  int min(int a, int b) {
    return a < b ? a : b;
  }

  // Nouvelle fonction pour la navigation avec effet de chargement
  Future<void> navigateToEditUserScreen() async {
    // Afficher un dialogue ou une animation de chargement
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    // Simuler un délai
    await Future.delayed(Duration(seconds: 2));

    Navigator.pop(context); // Fermer le dialogue
    // Naviguer vers l'écran d'édition utilisateur
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserInfoScreen(user: widget.user),
      ),
    );
  }
}
