import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'manage_properties_screen.dart';
import 'property_form.dart';
import 'authentication.dart';

import '../services/firebase_property_service.dart';


class LandlordDashboardScreen extends StatefulWidget {
  const LandlordDashboardScreen({super.key});

  @override
  State<LandlordDashboardScreen> createState() => _LandlordDashboardScreenState();
}

class _LandlordDashboardScreenState extends State<LandlordDashboardScreen> {
  int? _propertyCount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPropertyCount();
      Fluttertoast.showToast(
        msg: "Welcome to the Landlord Dashboard!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
  }

  Future<void> _loadPropertyCount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Fluttertoast.showToast(
        msg: "You must be logged in to view your properties.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      return;
    }

    try {
      final properties = await Provider.of<FirebasePropertyService>(context, listen: false)
          .getPropertiesByLandlord(user.uid);
      setState(() {
        _propertyCount = properties.length;
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to load properties: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Landlord Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const AuthenticationScreen(),
                  ),
                );
              } catch (e) {
                Fluttertoast.showToast(
                  msg: "Failed to log out: $e",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_propertyCount == null) ...[
              const Center(child: CircularProgressIndicator()), // Show loading indicator
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        'Your Properties',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_propertyCount properties listed',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ManagePropertiesScreen(),
                  ),
                );
              },
              child: const Text('Manage Properties'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PropertyForm(property: null),

                  ),
                );
              },
              child: const Text('Add New Property'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: null, // Disable the button
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.grey, // Change text color to grey
                backgroundColor: Colors.grey[300], // Change background color to light grey
              ),
              child: const Text('Feature Coming Soon'),
            ),
          ],
        ),
      ),
    );
  }
}
