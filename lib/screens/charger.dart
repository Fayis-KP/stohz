import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Charger extends StatefulWidget {
  const Charger({super.key});

  @override
  State<Charger> createState() => _ChargerState();
}

class _ChargerState extends State<Charger> {
  final User? user = FirebaseAuth.instance.currentUser; // Get the current user
  List<bool> favoriteStatus = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chargers'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('product')
            .where('category', isEqualTo: 'charger')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
                child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No chargers available'));
          }

          final chargers = snapshot.data!.docs;

          // Initialize favoriteStatus list with false values
          if (favoriteStatus.length != chargers.length) {
            favoriteStatus = List<bool>.filled(chargers.length, false);
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 5, // Aspect ratio for grid items
            ),
            itemCount: chargers.length,
            itemBuilder: (context, index) {
              final chargerDoc = chargers[index];
              final charger = chargerDoc.data() as Map<String, dynamic>;
              final imageUrl = charger['img'] ?? ''; // Ensure this matches your Firestore field name
              final name = charger['name'] ?? 'Unknown'; // Ensure this matches your Firestore field name
              final price = charger['price']?.toString() ?? 'Unknown'; // Ensure this matches your Firestore field name

              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Display a placeholder image or message in case of error
                                return Center(child: Text('No Image'));
                              },
                            )
                                : Center(child: Text('No Image')),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '\$$price',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        favoriteStatus[index]
                            ? Icons.favorite
                            : Icons.favorite_border,
                      ),
                      color: favoriteStatus[index] ? Colors.orange : Colors.grey[600],
                      onPressed: () async {
                        setState(() {
                          favoriteStatus[index] = !favoriteStatus[index];
                        });

                        if (favoriteStatus[index]) {
                          // Add to favorites collection in Firestore with user ID
                          await FirebaseFirestore.instance
                              .collection('favorites')
                              .doc(chargerDoc.id)
                              .set({
                            'uid': user!.uid,
                            ...charger, // Add all charger details
                          });
                        } else {
                          // Remove from favorites collection in Firestore
                          await FirebaseFirestore.instance
                              .collection('favorites')
                              .doc(chargerDoc.id)
                              .delete();
                        }
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(Icons.shopping_cart),
                      color: Colors.grey[600],
                      onPressed: () async {
                        // Add item to cart collection with user ID
                        if (user != null) {
                          await FirebaseFirestore.instance.collection('cart').add({
                            'uid': user!.uid,
                            'img': imageUrl,
                            'name': name,
                            'price': price,
                            'category': 'charger',
                            'quantity': 1, // You can handle quantity as per your requirements
                          });

                          // Optional: Show a snackbar notification
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('$name added to cart')),
                          );
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
