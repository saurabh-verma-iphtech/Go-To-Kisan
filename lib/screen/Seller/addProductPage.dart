// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class AddProductPage extends StatefulWidget {
//   final String? productId;
//   final Map<String, dynamic>? existingData;

//   const AddProductPage({this.productId, this.existingData, Key? key})
//     : super(key: key);

//   @override
//   _AddProductPageState createState() => _AddProductPageState();
// }

// class _AddProductPageState extends State<AddProductPage> {
//   // Controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _priceController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _imageUrlController = TextEditingController();
//   final TextEditingController _quantityController = TextEditingController();

//   final ImagePicker _picker = ImagePicker();

//   List<XFile> _pickedImages = [];
//   List<String> _networkImageUrls = [];

//   String _selectedUnit = 'Kg'; // Default unit
//   bool _isLoading = false;

//   // Upload a single image to Firebase Storage and return its download URL
//   Future<String?> _uploadImageToStorage(XFile image) async {
//     try {
//       File file = File(image.path);

//       // Check if file exists before uploading
//       if (!file.existsSync()) {
//         print("File does not exist at path: ${image.path}");
//         return null;
//       }

//       final ref = FirebaseStorage.instance.ref().child(
//         'product_images/${DateTime.now().millisecondsSinceEpoch}_${image.name}',
//       );
//       await ref.putFile(file); // Upload the actual file
//       return await ref.getDownloadURL();
//     } catch (e) {
//       print("❌ Error uploading image: $e");
//       return null;
//     }
//   }


//   // Validate input and upload images, then add product to Firestore
//   Future<void> _addProduct() async {
//     if (_nameController.text.isEmpty ||
//         _priceController.text.isEmpty ||
//         _descriptionController.text.isEmpty ||
//         _quantityController.text.isEmpty ||
//         (_pickedImages.isEmpty && _networkImageUrls.isEmpty)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("All fields and at least one image are required"),
//         ),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       if (user == null) throw "User not authenticated";

//       List<String> uploadedUrls = [];

//       // Upload each selected gallery image
//       for (XFile image in _pickedImages) {
//         final url = await _uploadImageToStorage(image);
//         if (url != null) {
//           uploadedUrls.add(url);
//         } else {
//           print("⚠️ Skipping image due to upload failure: ${image.name}");
//         }
//       }

//       final allImageUrls = [...uploadedUrls, ..._networkImageUrls];

//       // Prepare product data
//       final productData = {
//         'name': _nameController.text.trim(),
//         'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
//         'description': _descriptionController.text.trim(),
//         'quantity': _quantityController.text.trim(),
//         'unit': _selectedUnit,
//         'imageUrls': allImageUrls,
//         'sellerId': user.uid,
//         'createdAt': FieldValue.serverTimestamp(),
//       };

//       // ✅ Add new product
//       await FirebaseFirestore.instance.collection('products').add(productData);

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("✅ Product added successfully")));

//       Navigator.pop(context);
//     } catch (e) {
//       print("❌ Failed to add product: $e");
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Failed to add product: $e")));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   // Add a direct image URL from the internet
//   void _addNetworkImageUrl() {
//     if (_imageUrlController.text.isNotEmpty) {
//       setState(() {
//         _networkImageUrls.add(_imageUrlController.text.trim());
//         _imageUrlController.clear();
//       });
//     }
//   }

//   // Pick multiple gallery images
//   Future<void> _pickMultipleImages() async {
//     final List<XFile> images = await _picker.pickMultiImage();
//     if (images.isNotEmpty) {
//       setState(() {
//         _pickedImages.addAll(images);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Add Grains"),
//         backgroundColor: Color.fromARGB(255, 47, 138, 47),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Column(
//           children: [
//             // Grain Name
//             TextFormField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: "Grain Name",
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             SizedBox(height: 15),

//             // Price
//             TextFormField(
//               controller: _priceController,
//               decoration: InputDecoration(
//                 labelText: "Grain Price",
//                 border: OutlineInputBorder(),
//               ),
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//             ),
//             SizedBox(height: 15),

//             // Description
//             TextFormField(
//               controller: _descriptionController,
//               decoration: InputDecoration(
//                 labelText: "Grain Description",
//                 border: OutlineInputBorder(),
//               ),
//               maxLines: 3,
//             ),
//             SizedBox(height: 20),

//             // Quantity with unit dropdown
//             TextFormField(
//               controller: _quantityController,
//               decoration: InputDecoration(
//                 labelText: "Quantity",
//                 border: OutlineInputBorder(),
//                 suffixIcon: DropdownButtonHideUnderline(
//                   child: DropdownButton<String>(
//                     value: _selectedUnit,
//                     items:
//                         ['Gram', 'Kg', 'Quintal', 'Pieces']
//                             .map(
//                               (unit) => DropdownMenuItem(
//                                 value: unit,
//                                 child: Text(unit),
//                               ),
//                             )
//                             .toList(),
//                     onChanged: (value) {
//                       setState(() => _selectedUnit = value!);
//                     },
//                     icon: Icon(Icons.arrow_drop_down, color: Colors.grey),
//                   ),
//                 ),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 20),

//             // Gallery Image Picker
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color.fromARGB(255, 47, 138, 47),
//                 foregroundColor: Colors.white,
//                 elevation: 8,
//                 padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//               ),
//               onPressed: _pickMultipleImages,
//               child: Text("Pick Images from Gallery"),
//             ),
//             SizedBox(height: 10),

//             // Network URL Input
//             Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _imageUrlController,
//                     decoration: InputDecoration(
//                       labelText: "Add Network Image URL",
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 10),
//                 IconButton(
//                   onPressed: _addNetworkImageUrl,
//                   icon: Icon(
//                     Icons.add_circle,
//                     color: Color.fromARGB(255, 47, 138, 47),
//                   ),
//                 ),
//               ],
//             ),

//             // Show selected images
//             SizedBox(height: 20),
//             Align(
//               alignment: Alignment.centerLeft,
//               child: Text("Selected Images:", style: TextStyle(fontSize: 15)),
//             ),
//             SizedBox(
//               height: 120,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: [
//                   // Gallery images
//                   ..._pickedImages.map(
//                     (img) => Stack(
//                       children: [
//                         Image.file(
//                           File(img.path),
//                           width: 100,
//                           height: 100,
//                           fit: BoxFit.cover,
//                         ),
//                         Positioned(
//                           right: 0,
//                           top: 0,
//                           child: GestureDetector(
//                             onTap:
//                                 () => setState(() => _pickedImages.remove(img)),
//                             child: Icon(Icons.close, color: Colors.red),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   // Network images
//                   ..._networkImageUrls.map(
//                     (url) => Stack(
//                       children: [
//                         Image.network(
//                           url,
//                           width: 100,
//                           height: 100,
//                           fit: BoxFit.cover,
//                         ),
//                         Positioned(
//                           right: 0,
//                           top: 0,
//                           child: GestureDetector(
//                             onTap:
//                                 () => setState(
//                                   () => _networkImageUrls.remove(url),
//                                 ),
//                             child: Icon(Icons.close, color: Colors.red),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Submit Button
//             SizedBox(height: 30),
//             GestureDetector(
//               onTap: _isLoading ? null : _addProduct,
//               child: Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.all(15),
//                 decoration: BoxDecoration(
//                   color: Color.fromARGB(255, 47, 138, 47),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Center(
//                   child:
//                       _isLoading
//                           ? CircularProgressIndicator(color: Colors.white)
//                           : Text(
//                             "Add Grain",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 18,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }




import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  final ImagePicker _picker = ImagePicker();

  List<XFile> _pickedImages = [];
  List<String> _networkImageUrls = [];

  String _selectedUnit = 'Kg';
  bool _isLoading = false;

  Future<String?> _uploadImageToSupabase(XFile image) async {
    try {
      final fileExt = image.path.split('.').last;
      final fileName =
          'grains/${DateTime.now().millisecondsSinceEpoch}.${fileExt}';
          final bucketName = 'user-images';

      if (kIsWeb) {
        // For Flutter Web
        final bytes = await image.readAsBytes();
        await Supabase.instance.client.storage
            .from('your-bucket-name')
            .uploadBinary(
              fileName,
              bytes,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
      } else {
        // For mobile platforms
        final file = File(image.path);
        await Supabase.instance.client.storage
            .from(bucketName)
            .upload(
              fileName,
              file,
              fileOptions: const FileOptions(contentType: 'image/jpeg'),
            );
      }

      final imageUrl = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      return imageUrl;
    } catch (e) {
      print("❌ Supabase upload error: $e");
      return null;
    }
  }

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        (_pickedImages.isEmpty && _networkImageUrls.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("All fields and at least one image are required"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "User not authenticated";

      List<String> uploadedUrls = [];

      for (XFile image in _pickedImages) {
        final url = await _uploadImageToSupabase(image);
        if (url != null) {
          uploadedUrls.add(url);
        } else {
          print("⚠️ Skipping image due to upload failure: ${image.name}");
        }
      }

      final allImageUrls = [...uploadedUrls, ..._networkImageUrls];

      final productData = {
        'name': _nameController.text.trim(),
        'price': double.tryParse(_priceController.text.trim()) ?? 0.0,
        'description': _descriptionController.text.trim(),
        'quantity': _quantityController.text.trim(),
        'unit': _selectedUnit,
        'imageUrls': allImageUrls,
        'sellerId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'approved': true,
      };

      await FirebaseFirestore.instance.collection('products').add(productData);
await Future.delayed(const Duration(seconds: 1)); // Give time to sync

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("✅ Product added successfully")));

      Navigator.pop(context);
    } catch (e) {
      print("❌ Failed to add product: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to add product: $e")));
    } finally {
      setState(() => _isLoading = false);
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
        title: const Text("Add Grains"),
        backgroundColor: const Color.fromARGB(255, 47, 138, 47),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Grain Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: "Grain Price",
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: "Grain Description",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _quantityController,
              decoration: InputDecoration(
                labelText: "Quantity",
                border: const OutlineInputBorder(),
                suffixIcon: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedUnit,
                    items:
                        ['Gram', 'Kg', 'Quintal', 'Pieces']
                            .map(
                              (unit) => DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() => _selectedUnit = value!);
                    },
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                  ),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 47, 138, 47),
                foregroundColor: Colors.white,
                elevation: 8,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: _pickMultipleImages,
              child: const Text("Pick Images from Gallery"),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(
                      labelText: "Add Network Image URL",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _addNetworkImageUrl,
                  icon: const Icon(
                    Icons.add_circle,
                    color: Color.fromARGB(255, 47, 138, 47),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Selected Images:", style: TextStyle(fontSize: 15)),
            ),
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
                            onTap:
                                () => setState(() => _pickedImages.remove(img)),
                            child: const Icon(Icons.close, color: Colors.red),
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
                            onTap:
                                () => setState(
                                  () => _networkImageUrls.remove(url),
                                ),
                            child: const Icon(Icons.close, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _isLoading ? null : _addProduct,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 47, 138, 47),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
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
