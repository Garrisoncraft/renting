import 'package:flutter/material.dart';
import 'property_details.dart';
import 'package:provider/provider.dart';
import '../services/firebase_property_service.dart';
import 'property_search_delegate.dart';

class PropertySearchScreen extends StatelessWidget {
  const PropertySearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Properties'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                // Handle search input (optional: you can trigger a real-time search here)
              },
              decoration: InputDecoration(
                labelText: 'Search properties',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () async {
                    // Fetch properties from the provider or service
                    final properties = await Provider.of<FirebasePropertyService>(context, listen: false).getProperties();
                    showSearch(
                      context: context,
                      delegate: PropertySearchDelegate(properties: properties),
                    );
                  },
                ),
              ),
            ),
          ),
          const Center(
            child: Text('Search: '),
          ),
        ],
      ),
    );
  }
}