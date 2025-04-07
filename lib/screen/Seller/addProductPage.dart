import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  final String? productId;
  final Map<String, dynamic>? existingData;

  const AddProductPage({this.productId, this.existingData, Key? key})
    : super(key: key);

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
    final TextEditingController _quantityController = TextEditingController();
  
  String _selectedUnit = 'Kg'; // Default unit

  final List<XFile> _pickedImages = [];
  final List<String> _networkImageUrls = [];

  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // Upload picked images to Firebase Storage
  Future<String?> _uploadImageToStorage(XFile image) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(
        'product_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}',
      );
      await ref.putFile(File(image.path));
      return await ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
                _quantityController.text.isEmpty || // ✅ Add validation for quantity
        (_pickedImages.isEmpty && _networkImageUrls.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("All fields and at least one image are required"),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        List<String> uploadedUrls = [];

        // Upload picked gallery images
        for (var image in _pickedImages) {
          final url = await _uploadImageToStorage(image);
          if (url != null) uploadedUrls.add(url);
        }

        // Combine both sets of URLs
        final allImageUrls = [...uploadedUrls, ..._networkImageUrls];

        await FirebaseFirestore.instance.collection('products').add({
          'name': _nameController.text.trim(),
          'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
          'description': _descriptionController.text.trim(),
          'quantity': _quantityController.text.trim(), // quantity value
          'unit': _selectedUnit, // unit value
          'imageUrls': allImageUrls,
          'sellerId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Product added successfully")));

        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add product: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addNetworkImageUrl() {
    if (_imageUrlController.text.isNotEmpty) {
      setState(() {
        _networkImageUrls.add(_imageUrlController.text.trim());
        _imageUrlController.clear();
      });
    }
  }

  Future<void> _pickMultipleImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _pickedImages.addAll(images);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Grains"),
        backgroundColor: Color.fromARGB(255, 47, 138, 47),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: "Grain Name",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _priceController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: "Grain Price",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: "Grain Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),

            // ✅ Add quantity field
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(),
                suffixIcon: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedUnit,
                    items:
                        ['Gram', 'Kg', 'Quintal','Pieces']
                            .map(
                              (unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUnit = value!;
                      });
                    },
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 20),

            // Button to select multiple images
            ElevatedButton(
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.all(
                  Colors.white,
                ), // Text color
                backgroundColor: WidgetStateProperty.resolveWith<Color>((
                  Set<WidgetState> states,
                ) {
                  if (states.contains(WidgetState.pressed)) {
                    return Color.fromARGB(
                      255,
                      47,
                      138,
                      47,
                    ); // Color when pressed
                  }
                  return Color.fromARGB(255, 47, 138, 47); // Default color
                }),
                shadowColor: WidgetStateProperty.all(Colors.black),
                elevation: WidgetStateProperty.all(8), // Elevation
                padding: WidgetStateProperty.all(
                  EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              onPressed: _pickMultipleImages,
              child: Text("Pick Images from Gallery"),
            ),
            SizedBox(height: 10,),

            // Field to add network image URL
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _imageUrlController,
                    decoration: InputDecoration(
                      labelText: "Add Network Image URL",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  onPressed: _addNetworkImageUrl,
                  icon: Icon(Icons.add_circle, color: Color.fromARGB(255, 47, 138, 47),
                  ),
                ),
              ],
            ),

            // Show preview of selected gallery images and network URLs
            SizedBox(height: 20),
            Text("Selected Images:",style: TextStyle(fontSize: 15),),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ..._pickedImages.map(
                    (img) => Stack(
                      children: [
                        Image.file(
                          File(img.path),
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _pickedImages.remove(img);
                              });
                            },
                            child: Icon(Icons.close, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._networkImageUrls.map(
                    (url) => Stack(
                      children: [
                        Image.network(
                          url,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _networkImageUrls.remove(url);
                              });
                            },
                            child: Icon(Icons.close, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30),
            GestureDetector(
              onTap: _isLoading ? null : _addProduct,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 47, 138, 47),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child:
                      _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text(
                            "Add Grain",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
