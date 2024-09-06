import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Headphone extends StatefulWidget {
  const Headphone({super.key});

  @override
  State<Headphone> createState() => _HeadphoneState();
}

class _HeadphoneState extends State<Headphone> {
  final User? user = FirebaseAuth.instance.currentUser; // Get the current user
  List<bool> favoriteStatus = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Headsets'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('product')
            .where('category', isEqualTo: 'headset')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No headsets available'));
          }

          final headsets = snapshot.data!.docs;

          // Initialize favoriteStatus list with false values
          if (favoriteStatus.length != headsets.length) {
            favoriteStatus = List<bool>.filled(headsets.length, false);
          }

          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 3,
            ),
            itemCount: headsets.length,
            itemBuilder: (context, index) {
              final headsetDoc = headsets[index];
              final headset = headsetDoc.data() as Map<String, dynamic>;
              final imageUrl = headset['img'] ?? '';
              final name = headset['name'] ?? 'Unknown';
              final price = headset['price']?.toString() ?? 'N/A';

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
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(child: Text('No Image'));
                              },
                            )
                                : Center(child: Text('No Image')),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            name,
                            style: const TextStyle(
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
                      color: favoriteStatus[index] ? Colors.orange : Colors.grey[600],
                      onPressed: () async {
                        setState(() {
                          favoriteStatus[index] = !favoriteStatus[index];
                        });

                        if (favoriteStatus[index]) {
                          // Add to favorites collection in Firestore with user ID
                          if (user != null) {
                            await FirebaseFirestore.instance
                                .collection('favorites')
                                .doc(headsetDoc.id)
                                .set({
                              'uid': user!.uid,
                              ...headset, // Add all headset details
                            });
                          }
                        } else {
                          // Remove from favorites collection in Firestore
                          await FirebaseFirestore.instance
                              .collection('favorites')
                              .doc(headsetDoc.id)
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
                            'category': 'headset',
                            'quantity': 1,
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
