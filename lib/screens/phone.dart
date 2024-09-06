import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({super.key});

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final User? user = FirebaseAuth.instance.currentUser; // Get the current user
  List<bool> favoriteStatus = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phones'),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('product')
            .where('category', isEqualTo: 'phone')
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
            return Center(child: Text('No phones available'));
          }

          final phones = snapshot.data!.docs;

          // Initialize favoriteStatus list with false values
          if (favoriteStatus.length != phones.length) {
            favoriteStatus = List<bool>.filled(phones.length, false);
          }

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 5, // Aspect ratio for grid items
            ),
            itemCount: phones.length,
            itemBuilder: (context, index) {
              final phoneDoc = phones[index];
              final phone = phoneDoc.data() as Map<String, dynamic>;
              final imageUrl = phone['img'] ?? ''; // Ensure this matches your Firestore field name
              final name = phone['name'] ?? 'Unknown'; // Ensure this matches your Firestore field name
              final price = phone['price']?.toString() ?? 'Unknown'; // Ensure this matches your Firestore field name

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
                              .doc(phoneDoc.id)
                              .set({
                            'uid': user!.uid,
                            ...phone, // Add all phone details
                          });
                        } else {
                          // Remove from favorites collection in Firestore
                          await FirebaseFirestore.instance
                              .collection('favorites')
                              .doc(phoneDoc.id)
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
                            'category': 'phone',
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
