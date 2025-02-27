import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/firebase_property_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

class PropertyForm extends StatefulWidget {
  final Map? property;

  const PropertyForm({Key? key, this.property}) : super(key: key);

  @override
  _PropertyFormState createState() => _PropertyFormState();
}

class _PropertyFormState extends State<PropertyForm> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  double _price = 0.0;
  String _description = '';
  String _location = '';
  int _rooms = 0;
  String _contact = '';
  Uint8List? _imageFile; // Stores the image in memory as Uint8List

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
   
   if (pickedFile != null) {
      // Convert the image to Uint8List
      final bytes = await pickedFile.readAsBytes(); // Use readAsBytes for web compatibility
      setState(() {
        _imageFile = bytes;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final propertyData = {
          'title': _title,
          'price': _price,
          'description': _description,
          'location': _location,
          'rooms': _rooms,
          'contact': _contact,
          'isAvailable': true,
        };

        String? imageUrl;
        if (_imageFile != null) {
          imageUrl = 'data:image/jpg;base64,${base64Encode(_imageFile!)}'; // Encode the image as Base64
        }

        await Provider.of<FirebasePropertyService>(context, listen: false)
            .addProperty(propertyData, FirebaseAuth.instance.currentUser?.uid ?? '', imageUrl ?? '');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.property == null ? 'Property added successfully!' : 'Property updated successfully!')),
        );

        Navigator.of(context).pop(); // Close the form screen
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save property: $error')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.property != null) {
      _title = widget.property!['title'] ?? '';
      _price = widget.property!['price']?.toDouble() ?? 0.0;
      _description = widget.property!['description'] ?? '';
      _location = widget.property!['location'] ?? '';
      _rooms = widget.property!['rooms'] ?? 0;
       _contact = widget.property!['contact'] ?? '';


      if (widget.property!['imageUrl'] is String && widget.property!['imageUrl']!.startsWith('data:image')) {
        // Decode Base64 string if stored as Base64
        final base64String = widget.property!['imageUrl']!.split(',').last;
        _imageFile = base64Decode(base64String);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.property == null ? 'Add Property' : 'Edit Property'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                onChanged: (value) => _title = value,
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                initialValue: _price.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price'),
                onChanged: (value) {
                  _price = double.tryParse(value) ?? 0.0;
                },
                validator: (value) => value!.isEmpty ? 'Please enter a price' : null,
              ),
              TextFormField(
                initialValue: _description,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
                onChanged: (value) => _description = value,
                validator: (value) => value!.isEmpty ? 'Please enter a description' : null,
              ),
              TextFormField(
                initialValue: _location,
                decoration: const InputDecoration(labelText: 'Location'),
                onChanged: (value) => _location = value,
                validator: (value) => value!.isEmpty ? 'Please enter a location' : null,
              ),
              TextFormField(
                initialValue: _rooms.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Rooms'),
                onChanged: (value) {
                  _rooms = int.tryParse(value) ?? 0;
                },
                validator: (value) => value!.isEmpty ? 'Please enter the number of rooms' : null,
              ),
                 TextFormField(
                initialValue: _contact,
                decoration: const InputDecoration(labelText: 'Contact'),
                onChanged: (value) => _contact = value,
                validator: (value) => value!.isEmpty ? 'Please enter a contact' : null,
              ),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Select Image from Gallery'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: _buildImageWidget(), // Display the selected image
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(widget.property == null ? 'Add Property' : 'Update Property'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (_imageFile == null) {
      return const Placeholder(fallbackHeight: 150); // Show placeholder if no image
    }
    return Image.memory(
      _imageFile!,
      height: 150,
      fit: BoxFit.cover,
    );
  }
}