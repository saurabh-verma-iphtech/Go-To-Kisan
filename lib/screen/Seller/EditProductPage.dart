import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProductPage extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> existingData;

  const EditProductPage({
    required this.productId,
    required this.existingData,
    Key? key,
  }) : super(key: key);

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _networkImageUrlController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  List<String> existingImageUrls = [];
  List<XFile> newGalleryImages = [];
  List<String> newNetworkImageUrls = [];
  bool _isLoading = false;
  String _selectedUnit = 'Kg'; // default unit

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.existingData['name'] ?? '';
    _priceController.text = widget.existingData['price'].toString();
    _descriptionController.text = widget.existingData['description'] ?? '';
    _quantityController.text = widget.existingData['quantity']?.toString() ?? '0.0';
    _selectedUnit = widget.existingData['unit'] ?? 'Kg'; // pre-fill unit if available

    if (widget.existingData['imageUrls'] != null) {
      existingImageUrls = List<String>.from(widget.existingData['imageUrls']);
    }
  }

  // To pick image from gallery ->bs
  Future<void> _pickGalleryImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        newGalleryImages.addAll(images);
      });
    }
  }

  void _addNetworkImageUrl() {
    if (_networkImageUrlController.text.trim().isNotEmpty) {
      setState(() {
        newNetworkImageUrls.add(_networkImageUrlController.text.trim());
        _networkImageUrlController.clear();
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("All fields must be filled")));
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      List<String> uploadedImageUrls = [];

      // Upload new gallery images
      for (var image in newGalleryImages) {
        String fileName = DateTime.now().millisecondsSinceEpoch.toString();
        Reference ref = FirebaseStorage.instance.ref().child(
          'product_images/$fileName',
        );
        await ref.putFile(File(image.path));
        String downloadUrl = await ref.getDownloadURL();
        uploadedImageUrls.add(downloadUrl);
      }

      List<String> finalImageUrls = [
        ...existingImageUrls,
        ...uploadedImageUrls,
        ...newNetworkImageUrls,
      ];

      await FirebaseFirestore.instance
          .collection('products')
          .doc(widget.productId)
          .update({
            'name': _nameController.text.trim(),
            'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
            'description': _descriptionController.text.trim(),
            'quantity': int.tryParse(_quantityController.text.trim()) ?? 0,

            'imageUrls': finalImageUrls,
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Grain updated successfully")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Grain Details"),
        backgroundColor: Color.fromARGB(
                                    255,
                                    47,
                                    138,
                                    47,
                                  ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Grain Name",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: "Grain Price",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: "Grain Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 15),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: "Grain Quantity",
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

              SizedBox(height: 20),
              Text("Existing Images:"),
              SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children:
                    existingImageUrls
                        .map(
                          (url) => Stack(
                            children: [
                              Image.network(
                                url,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      existingImageUrls.remove(url);
                                    });
                                  },
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
              ),
              SizedBox(height: 15),
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
                onPressed: _pickGalleryImages,
                child: Text("Pick Images from Gallery"),
              ),
              SizedBox(height: 15),
              TextField(
                controller: _networkImageUrlController,
                decoration: InputDecoration(
                  labelText: "Add Network Image URL",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addNetworkImageUrl,
                  ),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              // Text("Network Images to Add:"),
              Wrap(
                spacing: 10,
                children:
                    newNetworkImageUrls
                        .map(
                          (url) => Stack(
                            children: [
                              Image.network(
                                url,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      newNetworkImageUrls.remove(url);
                                    });
                                  },
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.red,
                                    child: Icon(
                                      Icons.close,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
              ),
              SizedBox(height: 10),
              // Text("New Gallery Images:"),
              Wrap(
                spacing: 10,
                children:
                    newGalleryImages
                        .map(
                          (file) => Image.file(
                            File(file.path),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        )
                        .toList(),
              ),
              SizedBox(height: 30),
              GestureDetector(
                onTap: _isLoading ? null : _saveChanges,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(
                                    255,
                                    47,
                                    138,
                                    47,
                                  ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child:
                        _isLoading
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              "Save Changes",
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
      ),
    );
  }
}
