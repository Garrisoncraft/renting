import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../services/mock_property_service.dart';

class PropertyDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> property;

  const PropertyDetailsScreen({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(property['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Updated line to use Image.network
            Image.network(property['imageUrl']),
            const SizedBox(height: 16),
            Text(
              property['description'],
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text('Price: \$${property['price']}'),
            Text('Location: ${property['location']}'),
            Text('Rooms: ${property['rooms']}'),
            Text('Contact: ${property['contact']}'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final url = 'https://wa.me/${property['contact']}';
                    if (await canLaunch(url)) {
                      await launch(url);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not open WhatsApp')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat),
                      SizedBox(width: 8),
                      Text('Contact via WhatsApp'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await Provider.of<MockPropertyService>(context, listen: false)
                          .bookProperty(property['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Property booked successfully!')),
                      );
                      Navigator.of(context).pop();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booking failed. Please try again.')),
                      );
                    }
                  },
                  child: const Text('Book Property'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
