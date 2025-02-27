import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_property_service.dart';
import 'property_details.dart';

class PropertySearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> properties;

  // Define filters
  String _roomFilter = 'All';
  double _minPrice = 0;
  double _maxPrice = 5000;

  PropertySearchDelegate({required this.properties});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear the search query
          showSuggestions(context); // Refresh suggestions
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, ''); // Close the search screen
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    // Filter properties based on the search query and filters
    final results = properties.where((property) {
      final matchesTitle = property['title']?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final matchesLocation = property['location']?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final matchesRoomFilter = _roomFilter == 'All' || property['rooms'].toString() == _roomFilter;
      final matchesPriceRange = property['price'] >= _minPrice && property['price'] <= _maxPrice;
      return (matchesTitle || matchesLocation) && matchesRoomFilter && matchesPriceRange;
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final property = results[index];
        return ListTile(
          leading: property['imageUrl'] != null
              ? Image.network(
                  property['imageUrl'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Placeholder(fallbackWidth: 60, fallbackHeight: 60);
                  },
                )
              : null,
          title: Text(property['title'] ?? 'No Title'),
          subtitle: Text('\$${property['price']} - ${property['location']}'),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => PropertyDetailsScreen(property: property),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Show suggestions while typing
    final suggestions = query.isEmpty
        ? properties
        : properties.where((property) {
            final matchesTitle = property['title']?.toLowerCase().contains(query.toLowerCase()) ?? false;
            final matchesLocation = property['location']?.toLowerCase().contains(query.toLowerCase()) ?? false;
            final matchesRoomFilter = _roomFilter == 'All' || property['rooms'].toString() == _roomFilter;
            final matchesPriceRange = property['price'] >= _minPrice && property['price'] <= _maxPrice;
            return (matchesTitle || matchesLocation) && matchesRoomFilter && matchesPriceRange;
          }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final property = suggestions[index];
        return ListTile(
          leading: property['imageUrl'] != null
              ? Image.network(
                  property['imageUrl'],
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Placeholder(fallbackWidth: 60, fallbackHeight: 60);
                  },
                )
              : null,
          title: Text(property['title'] ?? 'No Title'),
          subtitle: Text('\$${property['price']} - ${property['location']}'),
          onTap: () {
            query = property['title']; // Set the query to the selected property's title
            showResults(context); // Navigate to the results screen
          },
        );
      },
    );
  }
}