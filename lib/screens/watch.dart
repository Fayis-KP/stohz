import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Watch extends StatefulWidget {
  const Watch({super.key});

  @override
  State<Watch> createState() => _WatchState();
}

class _WatchState extends State<Watch> {
  final User? user = FirebaseAuth.instance.currentUser; // Get the current user
  List<bool> favoriteStatus = [];

  @override
  void initState() {
    super.initState();
    _initializeFavoriteStatus();
  }

  // Initialize favoriteStatus from Firestore
  Future<void> _initializeFavoriteStatus() async {
    if (user != null) {
      final favoritesSnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('uid', isEqualTo: user!.uid)
          .where('category', isEqualTo: 'watch')
          .get();

      final favorites = favoritesSnapshot.docs.map((doc) => doc.id).toList();
      setState(() {
        // Ensure the favoriteStatus list reflects the Firestore data
        favoriteStatus = List<bool>.filled(100, false); // Adjust size if needed
        for (int i = 0; i < favoriteStatus.length; i++) {
          favoriteStatus[i] = favorites.contains('some_unique_id_for_item'); // Use actual item ID
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Watches'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('product')
            .where('category', isEqualTo: 'watch')
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
            return Center(child: Text('No watches available'));
          }

          final watches = snapshot.data!.docs;

          // Initialize favoriteStatus list with false values if not already done
          if (favoriteStatus.length != watches.length) {
            favoriteStatus = List<bool>.filled(watches.length, false);
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 4, // Aspect ratio for grid items
            ),
            itemCount: watches.length,
            itemBuilder: (context, index) {
              final watch = watches[index].data() as Map<String, dynamic>;
              final imageUrl = watch['img'] ?? ''; // Ensure this matches your Firestore field name
              final name = watch['name'] ?? 'Unknown';
              final price = watch['price']?.toString() ?? 'N/A';

              return Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[200],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 120,
                            errorBuilder: (context, error, stackTrace) {
                              // Display a placeholder image or message in case of error
                              return Center(child: Text('No Image'));
                            },
                          )
                              : Center(child: Text('No Image')),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('\$${price.toString()}'),
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
                      color: favoriteStatus[index]
                          ? Colors.orange
                          : Colors.grey[600],
                      onPressed: () async {
                        setState(() {
                          favoriteStatus[index] = !favoriteStatus[index];
                        });

                        if (favoriteStatus[index]) {
                          // Add to favorites collection in Firestore with user ID
                          await FirebaseFirestore.instance
                              .collection('favorites')
                              .doc(watches[index].id)
                              .set({
                            'uid': user!.uid,
                            ...watch, // Add all watch details
                            'category': 'watch',
                          });
                        } else {
                          // Remove from favorites collection in Firestore
                          await FirebaseFirestore.instance
                              .collection('favorites')
                              .doc(watches[index].id)
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
                            'category': 'watch',
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
