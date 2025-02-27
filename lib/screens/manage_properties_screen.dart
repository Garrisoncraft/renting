import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/firebase_property_service.dart';
import 'property_form.dart';
import 'authentication.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

class ManagePropertiesScreen extends StatelessWidget {
  const ManagePropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Properties'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PropertyForm(),
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: Provider.of<FirebasePropertyService>(context, listen: false)
            .getPropertiesByLandlord(FirebaseAuth.instance.currentUser?.uid ?? ''),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final properties = snapshot.data ?? [];

          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];

              return ListTile(
                leading: property['imageUrl'] != null
                    ? (property['imageUrl'] is String && property['imageUrl'].startsWith('data:image'))
                        ? Image.memory(
                            base64Decode(property['imageUrl'].split(',').last), // Decode Base64 string
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            property['imageUrl'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/property2.jpg', // Fallback to default asset image
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                    : Image.asset(
                        'assets/images/property2.jpg', // Default asset image
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                title: Text(property['title']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('\$${property['price']}'),
                    Text('${property['rooms']} rooms'),
                    Text(property['location']),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PropertyForm(property: property),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirmDelete = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm Deletion'),
                            content: const Text('Are you sure you want to delete this property?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmDelete == true) {
                          await Provider.of<FirebasePropertyService>(context, listen: false)
                              .deleteProperty(property['id']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Property deleted successfully!')),
                          );
                        }
                      },
                    ),

                  ],
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PropertyForm(property: property),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
