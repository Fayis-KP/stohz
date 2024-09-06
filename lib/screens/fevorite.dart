import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Heart extends StatefulWidget {
  const Heart({super.key});

  @override
  State<Heart> createState() => _HeartState();
}

class _HeartState extends State<Heart> {
  final User? user = FirebaseAuth.instance.currentUser; // Get the current user

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Favorites"),
        backgroundColor: Colors.deepOrange,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('favorites')
            .where('uid', isEqualTo: user!.uid) // Filter by user ID
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error fetching favorites"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No favorite items"));
          }

          var favoriteItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: favoriteItems.length,
            itemBuilder: (context, index) {
              var item = favoriteItems[index];

              return ListTile(
                leading: Image.network(item['img']),
                title: Text(item['name']),
                subtitle: Text('\$${item['price']}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.deepOrange),
                  onPressed: () async {
                    // Delete the item from the 'favorites' collection
                    await FirebaseFirestore.instance
                        .collection('favorites')
                        .doc(item.id)
                        .delete();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
