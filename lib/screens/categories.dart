import 'package:flutter/material.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  final List<String> categories = []; // List of categories

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of items per row
              crossAxisSpacing: 10.0, // Horizontal spacing between items
              mainAxisSpacing: 10.0, // Vertical spacing between items
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Handle the container tap if needed
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[100], // Background color of the container
                    borderRadius: BorderRadius.circular(10), // Rounded corners
                    border: Border.all(color: Colors.grey), // Border color
                  ),
                  child: Center(
                    child: Text(
                      categories[index],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}