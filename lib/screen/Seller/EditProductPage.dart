import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

class EditProductPage extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> existingData;

  const EditProductPage({
    required this.productId,
    required this.existingData,
    Key? key,
  }) : super(key: key);

  @override
  State<EditProductPage> createState() => _EditProductPageState();
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

  String _selectedUnit = 'Kg';
  bool _isLoading = false;
  Map<String, double> uploadProgress = {};

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.existingData['name'] ?? '';
    _priceController.text = widget.existingData['price'].toString();
    _descriptionController.text = widget.existingData['description'] ?? '';
    _quantityController.text = widget.existingData['quantity'].toString();
    _selectedUnit = widget.existingData['unit'] ?? 'Kg';

    if (widget.existingData['imageUrls'] != null) {
      existingImageUrls = List<String>.from(widget.existingData['imageUrls']);
    }
  }

  Future<void> _pickGalleryImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() => newGalleryImages.addAll(images));
    }
  }

  void _addNetworkImageUrl() {
    final url = _networkImageUrlController.text.trim();
    if (url.isNotEmpty) {
      setState(() {
        newNetworkImageUrls.add(url);
        _networkImageUrlController.clear();
      });
    }
  }

  Future<String> _uploadToSupabase(XFile image) async {
    final bytes = await image.readAsBytes();
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.name)}';
    final storagePath = 'grains/$fileName';

    final fileOptions = FileOptions(cacheControl: '3600', upsert: false);
    final fileMime = lookupMimeType(image.name);

    final upload = supabase.storage
        .from('user-images')
        .uploadBinary(
          storagePath,
          bytes,
          fileOptions: fileOptions,
        );

    await upload;

    return supabase.storage.from('user-images').getPublicUrl(storagePath);
  }

  Future<void> _deleteSupabaseImage(String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final segments = uri.pathSegments;

      final index = segments.indexOf('user-images');
      if (index != -1 && segments.length > index + 1) {
        final filePath = segments.sublist(index + 1).join('/');
        await supabase.storage.from('user-images').remove([filePath]);
        print("Deleted from Supabase: $filePath");
      } else {
        print("Could not parse file path from URL: $imageUrl");
      }
    } catch (e) {
      print("Error deleting image from Supabase: $e");
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
      setState(() => _isLoading = true);

      // Upload new gallery images
      List<String> uploadedImageUrls = [];
      for (var image in newGalleryImages) {
        final publicUrl = await _uploadToSupabase(image);
        uploadedImageUrls.add(publicUrl);
      }

      final finalImageUrls = [
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
            'unit': _selectedUnit,
            'imageUrls': finalImageUrls,
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Product updated successfully")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to update: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Grain"),
        backgroundColor: Color.fromARGB(255, 47, 138, 47),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Grain Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        border: OutlineInputBorder(),
                        suffixIcon: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedUnit,
                            items:
                                ['Gram', 'Kg', 'Quintal', 'Pieces'].map((unit) {
                                  return DropdownMenuItem(
                                    value: unit,
                                    child: Text(unit),
                                  );
                                }).toList(),
                            onChanged:
                                (val) => setState(() => _selectedUnit = val!),
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 20),

                    Text("Existing Images"),
                    Wrap(
                      spacing: 10,
                      children:
                          existingImageUrls.map((url) {
                            return Stack(
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
                                    onTap: () async {
                                      await _deleteSupabaseImage(url);
                                      setState(
                                        () => existingImageUrls.remove(url),
                                      );
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
                            );
                          }).toList(),
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: _pickGalleryImages,
                      child: Text("Pick Images from Gallery"),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _networkImageUrlController,
                      decoration: InputDecoration(
                        labelText: 'Add Network Image URL',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add),
                          onPressed: _addNetworkImageUrl,
                        ),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          ...newGalleryImages.map(
                            (img) => Stack(
                              children: [
                                kIsWeb
                                    ? Image.network(
                                      img.path,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    )
                                    : Image.file(
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
                                        newGalleryImages.remove(img);
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ...newNetworkImageUrls.map(
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
                                        newNetworkImageUrls.remove(url);
                                      });
                                    },
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                    ),
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
                      onTap: _isLoading ? null : _saveChanges,
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 47, 138, 47),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
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
    );
  }
}
