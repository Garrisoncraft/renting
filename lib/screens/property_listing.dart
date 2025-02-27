import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../services/mock_property_service.dart';

class PropertyListingScreen extends StatefulWidget {
  const PropertyListingScreen({super.key});

  @override
  State<PropertyListingScreen> createState() => _PropertyListingScreenState();
}

class _PropertyListingScreenState extends State<PropertyListingScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    const PropertyListTab(),
    const AddPropertyTab(),
  ];


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Listing'),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Properties',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Property',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class PropertyListTab extends StatelessWidget {
  const PropertyListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Provider.of<MockPropertyService>(context, listen: false).getProperties(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final properties = snapshot.data ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: properties.length,
          itemBuilder: (context, index) {
            final property = properties[index];
            return Card(
              child: ListTile(
                title: Text(property['title']),
                subtitle: Text('\$${property['price']} - ${property['location']}'),
                trailing: Text('${property['rooms']} rooms'),
              ),
            );
          },
        );
      },
    );
  }
}

class AddPropertyTab extends StatefulWidget {
  const AddPropertyTab({super.key});

  @override
  _AddPropertyTabState createState() => _AddPropertyTabState();
}

class _AddPropertyTabState extends State<AddPropertyTab> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  File? _image;
  final _property = {
    'title': '',
    'description': '',
    'price': 0,
    'location': '',
    'rooms': 1,
    'contact': '',
  };

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    _formKey.currentState?.save();

    try {
      final propertyService = Provider.of<MockPropertyService>(context, listen: false);
      await propertyService.addProperty({
        'title': _property['title'],
        'description': _property['description'],
        'price': _property['price'],
        'location': _property['location'],
        'rooms': _property['rooms'],
        'contact': _property['contact'],
        'imageUrl': _image != null ? _image!.path : null,
      }, 'landlord1'); // TODO: Replace with actual landlord ID

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property listed successfully!')),
      );

      _formKey.currentState?.reset();
      setState(() {
        _image = null;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error listing property: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (_image != null)
              Image.file(
                _image!,
                height: 200,
                fit: BoxFit.cover,
              ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Add Property Image'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              onSaved: (value) {
                _property['title'] = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              onSaved: (value) {
                _property['description'] = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                return null;
              },
              onSaved: (value) {
                _property['price'] = int.parse(value!);
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Location'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a location';
                }
                return null;
              },
              onSaved: (value) {
                _property['location'] = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Number of Rooms'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of rooms';
                }
                return null;
              },
              onSaved: (value) {
                _property['rooms'] = int.parse(value!);
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Contact Info'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter contact information';
                }
                return null;
              },
              onSaved: (value) {
                _property['contact'] = value!;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('List Property'),
            ),
          ],
        ),
      ),
    );
  }
}
