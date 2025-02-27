import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/firebase_property_service.dart';
import 'property_details.dart';
import 'property_search_delegate.dart';
import 'property_search.dart';
import 'authentication.dart';
import 'package:fluttertoast/fluttertoast.dart';

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({super.key});

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  String _roomFilter = 'All';
  String _locationFilter = 'All';
  double _minPrice = 0;
  double _maxPrice = 5000;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Dashboard'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () async {
              final properties = await Provider.of<FirebasePropertyService>(context, listen: false).getProperties();
              showSearch(
                context: context,
                delegate: PropertySearchDelegate(properties: properties),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const AuthenticationScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: Provider.of<FirebasePropertyService>(context, listen: false).getProperties(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final properties = snapshot.data ?? [];
            if (properties.isEmpty) {
              Fluttertoast.showToast(
                msg: "No properties available.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _roomFilter,
                              items: ['All', '1', '2', '3', '4+'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text('$value rooms'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _roomFilter = value!;
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Filter by Rooms',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _locationFilter,
                              items: ['All', 'Nyarutarama', 'Kabeza', 'Kicukiro', 'Gikondo', 'Kibagabaga']
                                  .map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _locationFilter = value!;
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Filter by Location',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      RangeSlider(
                        values: RangeValues(_minPrice, _maxPrice),
                        min: 0,
                        max: 5000,
                        divisions: 10,
                        labels: RangeLabels(
                          '\$${_minPrice.round()}',
                          '\$${_maxPrice.round()}',
                        ),
                        onChanged: (values) {
                          setState(() {
                            _minPrice = values.start;
                            _maxPrice = values.end;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    final property = properties[index];

                    // Apply filters
                    if (_roomFilter != 'All' &&
                        !(_roomFilter == '4+' ? property['rooms'] >= 4 : property['rooms'].toString() == _roomFilter)) {
                      return Container();
                    }
                    if (_locationFilter != 'All' && property['location'] != _locationFilter) {
                      return Container();
                    }
                    if (property['price'] < _minPrice || property['price'] > _maxPrice) {
                      return Container();
                    }
                    if (!property['isAvailable']) {
                      Fluttertoast.showToast(
                        msg: "This property is not available.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Leading image widget
                          property['imageUrl'] != null && property['imageUrl'] is String && property['imageUrl'].isNotEmpty
                              ? Container(
                                  width: 60, // Adjusted size of the leading widget
                                  height: 60,
                                  margin: const EdgeInsets.all(8.0),
                                  child: Image.network(
                                    property['imageUrl'],
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Placeholder(fallbackWidth: 50, fallbackHeight: 50);
                                    },
                                  ),
                                )
                              : const Placeholder(
                                  fallbackWidth: 50,
                                  fallbackHeight: 50,
                                  color: Colors.grey,
                                ),

                          const SizedBox(width: 10),

                          // Property details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property['title'] ?? 'No Title',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text('\$${property['price']}', style: const TextStyle(color: Colors.green)),
                                Text(property['location'] ?? 'Unknown Location'),
                                if (!property['isAvailable'])
                                  const Text(
                                    'Booked',
                                    style: TextStyle(color: Colors.red),
                                  ),
                              ],
                            ),
                          ),

                          // Trailing actions
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${property['rooms']} rooms'),
                              if (property['isAvailable'])
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      await Provider.of<FirebasePropertyService>(context, listen: false)
                                          .bookProperty(property['id']);
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Property booked successfully!')),
                                      );
                                    } catch (error) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Failed to book property: $error')),
                                      );
                                    }
                                  },
                                  child: const Text('Book'),
                                ),
                            ],
                          ),

                        ],
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
