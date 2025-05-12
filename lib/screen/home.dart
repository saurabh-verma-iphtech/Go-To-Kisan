// import 'dart:async';
// import 'dart:math';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:signup_login_page/News/Screens/newsUI2.dart';
// import 'package:signup_login_page/Theme/theme_provider.dart';
// import 'package:signup_login_page/screen/Buyer/buyerLogicHandler.dart';
// import 'package:signup_login_page/screen/Buyer/favouriteButton.dart';
// import 'package:signup_login_page/screen/Buyer/wishlistPage.dart';
// import 'package:signup_login_page/screen/Buyer/buyerProfile.dart';
// import 'package:signup_login_page/screen/Chat/screens/buyer/chat_list_screen.dart';
// import 'package:signup_login_page/screen/Chat/screens/buyer/chat_screen.dart';
// import 'package:signup_login_page/screen/Weather/screens/weather_screen.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:firebase_auth/firebase_auth.dart';
// import '../screen/login.dart';
// import '../screen/signup.dart';
// import '../screen/Buyer/productDetailsPage.dart';
// import 'package:badges/badges.dart' as badges;

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   // UI data
//   final List<String> imageList = [
//     'assets/kisan/kisan1.jpg',
//     'assets/kisan/kisan2.jpg',
//     'assets/kisan/kisan3.jpg',
//     'assets/kisan/kisan4.jpg',
//     'assets/kisan/kisan5.jpeg',
//   ];

//   int cartItemCount = 0;
//   static const int _pageSize = 20;
//   int _currentPage = 0;

//   String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

//   String? _selectedSellerId;
//   bool _isLoadingSellers = true;
//   Map<String, String> sellerNamesById = {};

//   Future<void> fetchSellerNames() async {
//     setState(() => _isLoadingSellers = true);

//     try {
//       // Step 1: Get all unique sellerIds from 'products' collection
//       final productsQuery =
//           await FirebaseFirestore.instance.collection('products').get();
//       final Set<String> sellerIdsWithProducts = {
//         for (var doc in productsQuery.docs) doc['sellerId'] as String,
//       };

//       if (sellerIdsWithProducts.isEmpty) {
//         setState(() {
//           sellerNamesById = {};
//           _isLoadingSellers = false;
//         });
//         return;
//       }

//       // Step 2: Chunk seller IDs into batches of 10
//       List<String> allIds = sellerIdsWithProducts.toList();
//       List<Map<String, String>> chunkedResults = [];

//       for (var i = 0; i < allIds.length; i += 10) {
//         final chunk = allIds.sublist(
//           i,
//           i + 10 > allIds.length ? allIds.length : i + 10,
//         );
//         final usersQuery =
//             await FirebaseFirestore.instance
//                 .collection('users')
//                 .where(FieldPath.documentId, whereIn: chunk)
//                 .get();

//         final Map<String, String> chunkNames = {
//           for (var doc in usersQuery.docs)
//             doc.id: (doc['name'] as String?) ?? 'Unknown',
//         };

//         chunkedResults.add(chunkNames);
//       }

//       // Merge all chunks into a single map
//       final Map<String, String> names = {};
//       for (var map in chunkedResults) {
//         names.addAll(map);
//       }

//       setState(() {
//         sellerNamesById = names;
//         _isLoadingSellers = false;
//       });
//     } catch (e) {
//       print('Error fetching seller names: $e');
//       setState(() => _isLoadingSellers = false);
//     }
//   }

//   void _openSellerFilterDialog() {
//     showModalBottomSheet(
//       context: context,
//       builder: (ctx) {
//         if (_isLoadingSellers) {
//           return SizedBox(
//             height: 200,
//             child: Center(child: CircularProgressIndicator()),
//           );
//         }

//         final entries = sellerNamesById.entries.toList()
//                   ..sort(
//               (a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()),
//             );

//         return SafeArea(
//           child: ListView.builder(
//             itemCount: entries.length + 1,
//             itemBuilder: (c, i) {
//               if (i == 0) {
//                 return ListTile(
//                   title: Text('All Sellers'),
//                   selected: _selectedSellerId == null,
//                   onTap: () {
//                     setState(() => _selectedSellerId = null);
//                     Navigator.pop(ctx);
//                   },
//                 );
//               }
//               final e = entries[i - 1];
//               return ListTile(
//                 title: Text(e.value),
//                 selected: _selectedSellerId == e.key,
//                 onTap: () {
//                   setState(() => _selectedSellerId = e.key);
//                   Navigator.pop(ctx);
//                 },
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   // Search & voice
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _searchFocus = FocusNode();
//   String searchQuery = '';
//   Timer? _debounce;
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   String _localeId = 'en_IN';

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     _initSpeech();
//     fetchSellerNames();
//   }

//   Future<void> _initSpeech() async {
//     if (await _speech.initialize()) {
//       final sys = await _speech.systemLocale();
//       _localeId = sys?.localeId ?? _localeId;
//     }
//   }

//   void _toggleListening() async {
//     if (_isListening) {
//       _speech.stop();
//       setState(() => _isListening = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Stopped listening')));
//     } else if (await _speech.initialize()) {
//       setState(() => _isListening = true);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Listening...')));
//       _speech.listen(
//         localeId: _localeId,
//         onResult: (res) {
//           setState(() {
//             _searchController.text = res.recognizedWords;
//             searchQuery = res.recognizedWords;
//           });
//         },
//       );
//     }
//   }

//   // Create this helper widget for the badge
//   Widget buildWishlistBadge(int count) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 0.0),
//       child: badges.Badge(
//         position: badges.BadgePosition.topEnd(top: -5, end: -5),
//         showBadge: count > 0,
//         badgeContent: Text(
//           '$count',
//           style: const TextStyle(color: Colors.white, fontSize: 10),
//         ),
//         badgeStyle: const badges.BadgeStyle(
//           badgeColor: Colors.red,
//           padding: EdgeInsets.all(6),
//         ),
//         child: IconButton(
//           icon: Icon(Icons.favorite),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => WishlistPage()),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   bool _showSearch = false; // new

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _searchController.dispose();
//     _searchFocus.dispose();
//     super.dispose();
//   }

//   bool get _isSearching =>
//       _searchFocus.hasFocus || searchQuery.trim().isNotEmpty;

//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final h = MediaQuery.of(context).size.height;
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,

//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         scrolledUnderElevation: 0,
//         leadingWidth: 115,
//         leading:
//             isDark
//                 ? Image.asset(
//                   "assets/kisan/logoL.png",
//                 ) // light logo for dark theme
//                 : Image.asset("assets/kisan/logoD.png"),

//         actions: [
//           SizedBox(width: w * 0.05),
//           FirebaseAuth.instance.currentUser != null
//               ? StreamBuilder<QuerySnapshot>(
//                 stream:
//                     FirebaseFirestore.instance
//                         .collection('chats')
//                         .where('buyerId', isEqualTo: currentUserId)
//                         .snapshots(),
//                 builder: (context, snap) {
//                   // compute total unread
//                   int totalUnread = 0;
//                   if (snap.hasData) {
//                     totalUnread = snap.data!.docs.fold(0, (sum, doc) {
//                       final data = doc.data()! as Map<String, dynamic>;
//                       return sum + (data['unreadCountForBuyer'] as int? ?? 0);
//                     });
//                   }
//                   return badges.Badge(
//                     showBadge: totalUnread > 0,
//                     position: badges.BadgePosition.topEnd(top: -4, end: 1),
//                     badgeAnimation: badges.BadgeAnimation.fade(),
//                     badgeStyle: badges.BadgeStyle(
//                       badgeColor: Colors.red,
//                       padding: EdgeInsets.all(6),
//                       elevation: 0,
//                     ),
//                     badgeContent: Text(
//                       totalUnread.toString(),
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     child: IconButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (_) =>
//                                     BuyerChatListScreen(buyerId: currentUserId),
//                           ),
//                         );
//                       },
//                       icon: Icon(
//                         Icons.send_and_archive,
//                         color:
//                             Theme.of(context).brightness == Brightness.dark
//                                 ? Colors.white
//                                 : Colors.black,
//                       ),
//                     ),
//                   );
//                 },
//               )
//               : SizedBox.shrink(),

//           // Hides the widget completely
//           Consumer(
//             builder: (context, ref, _) {
//               final themeMode = ref.watch(themeProvider);
//               final isDark = themeMode == ThemeMode.dark;

//               return IconButton(
//                 icon: Icon(
//                   isDark ? Icons.light_mode : Icons.dark_mode,
//                   color: isDark ? Colors.white : Colors.black,
//                 ),
//                 tooltip:
//                     isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
//                 onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
//               );
//             },
//           ),

//           // Wishlist Page....Icon
//           StreamBuilder<QuerySnapshot>(
//             stream:
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser?.uid)
//                     .collection('wishlist')
//                     .snapshots(),
//             builder: (context, snapshot) {
//               int count = snapshot.data?.docs.length ?? 0;
//               return buildWishlistBadge(count);
//             },
//           ),

//           //Search icon
//           IconButton(
//             icon: Icon(_showSearch ? Icons.close : Icons.search),
//             onPressed: () {
//               setState(() {
//                 _showSearch = !_showSearch;
//                 if (!_showSearch) {
//                   _searchController.clear();
//                   searchQuery = '';
//                   _searchFocus.unfocus();
//                 }
//               });
//             },
//           ),
//           StreamBuilder<User?>(
//             stream: FirebaseAuth.instance.authStateChanges(),
//             builder: (context, snapshot) {
//               final user = snapshot.data;

//               return PopupMenuButton<String>(
//                 icon: const Icon(Icons.menu),
//                 onSelected: (val) {
//                   if (val == 'profile' && user != null) {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => BuyerDashboard()),
//                     );
//                   } else if (val == 'logout') {
//                     FirebaseAuth.instance.signOut();
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (_) => const HomePage()),
//                     );
//                   } else if (val == 'Login') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const Login()),
//                     );
//                   } else if (val == 'Signup') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const Signup()),
//                     );
//                   } else if (val == 'weather') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => WeatherHomePage()),
//                     );
//                   } else if (val == 'news') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => AgriNewsPage()),
//                     );
//                   }
//                 },
//                 itemBuilder: (context) {
//                   List<PopupMenuEntry<String>> items = [];

//                   if (user != null) {
//                     items.addAll([
//                       PopupMenuItem(
//                         value: 'profile',
//                         child: Text('profile'.tr()),
//                       ),
//                       PopupMenuItem(
//                         value: 'weather',
//                         child: Text('agriweather'.tr()),
//                       ),
//                       PopupMenuItem(
//                         value: 'news',
//                         child: Text("agriNews".tr()),
//                       ),
//                       PopupMenuItem<String>(
//                         enabled: false,
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<Locale>(
//                             value: context.locale,
//                             icon: const Icon(Icons.language),
//                             dropdownColor: Colors.white,
//                             onChanged: (Locale? locale) {
//                               if (locale != null) {
//                                 context.setLocale(locale);
//                                 Navigator.pop(context); // close the menu
//                               }
//                             },
//                             items: const [
//                               DropdownMenuItem(
//                                 value: Locale('en'),
//                                 child: Text(
//                                   'English',
//                                   style: TextStyle(fontSize: 15),
//                                 ),
//                               ),
//                               DropdownMenuItem(
//                                 value: Locale('hi'),
//                                 child: Text(
//                                   'हिंदी',
//                                   style: TextStyle(fontSize: 15),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       PopupMenuItem(
//                         value: 'logout',
//                         child: Row(
//                           children: [
//                             Icon(Icons.login, color: Colors.redAccent),
//                             SizedBox(width: 8),
//                             Text(
//                               'logout'.tr(),
//                               style: TextStyle(
//                                 color: Colors.redAccent,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ]);
//                   } else {
//                     items.addAll([
//                       PopupMenuItem(value: 'Login', child: Text('login'.tr())),
//                       PopupMenuItem(
//                         value: 'Signup',
//                         child: Text('signup'.tr()),
//                       ),
//                       PopupMenuItem(
//                         value: 'weather',
//                         child: Text('agriweather'.tr()),
//                       ),
//                       PopupMenuItem(
//                         value: 'news',
//                         child: Text("agriNews".tr()),
//                       ),
//                       PopupMenuItem<String>(
//                         enabled: false,
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<Locale>(
//                             value: context.locale,
//                             icon: const Icon(Icons.language),
//                             dropdownColor: Colors.white,
//                             onChanged: (Locale? locale) {
//                               if (locale != null) {
//                                 context.setLocale(locale);
//                                 Navigator.pop(context); // close the menu
//                               }
//                             },
//                             items: const [
//                               DropdownMenuItem(
//                                 value: Locale('en'),
//                                 child: Text(
//                                   'English',
//                                   style: TextStyle(fontSize: 15),
//                                 ),
//                               ),
//                               DropdownMenuItem(
//                                 value: Locale('hi'),
//                                 child: Text(
//                                   'हिंदी',
//                                   style: TextStyle(fontSize: 15),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ]);
//                   }
//                   return items;
//                 },
//               );
//             },
//           ),
//         ],
//       ),

//       body: Column(
//         children: [
//           // It will be visible only when _showSearch is true - Saurabh
//           if (_showSearch)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
//               child: TextField(
//                 focusNode: _searchFocus,
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'search'.tr(),
//                   prefixIcon: const Icon(Icons.search),
//                   suffixIcon: IconButton(
//                     icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
//                     onPressed: _toggleListening,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onChanged: (v) {
//                   _debounce?.cancel();
//                   _debounce = Timer(const Duration(milliseconds: 300), () {
//                     setState(() => searchQuery = v.trim());
//                   });
//                 },
//               ),
//             ),

//           // 2) Expanded area: full home or filtered results
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream:
//                   FirebaseFirestore.instance
//                       .collection('products')
//                       .orderBy('createdAt', descending: true)
//                       .where('approved', isEqualTo: true)
//                       .snapshots(),
//               builder: (ctx, snap) {
//                 if (snap.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final docs = snap.data?.docs ?? [];

//                 //  ➤ Apply seller filter first:
//                 final afterSellerFilter =
//                     _selectedSellerId == null
//                         ? docs
//                         : docs
//                             .where(
//                               (doc) => doc['sellerId'] == _selectedSellerId,
//                             )
//                             .toList();

//                 if (docs.isEmpty) {
//                   return const Center(child: Text('No products found'));
//                 }

//                 final isSearching = _isSearching;
//                 final filtered =
//                     afterSellerFilter.where((doc) {
//                       if (!isSearching) return true;
//                       final name = (doc['name'] ?? '').toString().toLowerCase();
//                       final desc =
//                           (doc['description'] ?? '').toString().toLowerCase();
//                       final q = searchQuery.toLowerCase();
//                       return name.contains(q) || desc.contains(q);
//                     }).toList();

//                 if (isSearching && filtered.isEmpty) {
//                   return const Center(child: Text('No matching grains found'));
//                 }

//                 // ─── SLICE OUT CURRENT PAGE ────────────────────────────────
//                 final totalItems = filtered.length;
//                 final totalPages = (totalItems / _pageSize).ceil();
//                 // clamp currentPage
//                 _currentPage = min(_currentPage, max(0, totalPages - 1));
//                 final start = _currentPage * _pageSize;
//                 final end = min(start + _pageSize, totalItems);
//                 final pageDocs = filtered.sublist(start, end);

//                 // FULL HOME: carousel + welcome + grid
//                 if (!isSearching) {
//                   return Column(
//                     children: [
//                       // --- Full-width Carousel ---
//                       SizedBox(
//                         width: double.infinity,
//                         height: w > 500 ? 270 : 170,
//                         child: CarouselSlider(
//                           options: CarouselOptions(
//                             height: double.infinity,
//                             autoPlay: true,
//                             autoPlayInterval: const Duration(seconds: 5),
//                             viewportFraction: 1.0,
//                           ),
//                           items:
//                               imageList
//                                   .map(
//                                     (url) => SizedBox(
//                                       width: double.infinity,
//                                       child: Image.asset(
//                                         url,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   )
//                                   .toList(),
//                         ),
//                       ),

//                       Padding(
//                         padding: const EdgeInsets.all(10),
//                         child: Column(
//                           children: [
//                             Text(
//                               'welcome'.tr(),
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: w > 600 ? 18 : 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () => _openSellerFilterDialog(),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.filter_list),
//                             SizedBox(width: 5,),
//                             Text("Filter by Seller"),
//                           ],
//                         ),
//                       ),

//                       // --- Grid of all products ---
//                       Expanded(child: _buildGrid(pageDocs)),
//                       if (totalPages > 1)
//                         SafeArea(
//                           top: false,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 IconButton(
//                                   icon: Icon(Icons.chevron_left),
//                                   onPressed:
//                                       _currentPage > 0
//                                           ? () => setState(() => _currentPage--)
//                                           : null,
//                                 ),
//                                 Text('Page ${_currentPage + 1} of $totalPages'),
//                                 IconButton(
//                                   icon: Icon(Icons.chevron_right),
//                                   onPressed:
//                                       _currentPage < totalPages - 1
//                                           ? () => setState(() => _currentPage++)
//                                           : null,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                     ],
//                   );
//                 }
//                 // SEARCH RESULTS: just the filtered grid
//                 return _buildGrid(filtered);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGrid(List<QueryDocumentSnapshot> docs) {
//     final w = MediaQuery.of(context).size.width;

//     return RefreshIndicator(
//       onRefresh: () async {
//         setState(() {});
//       },
//       child: GridView.builder(
//         padding: const EdgeInsets.all(8),
//         shrinkWrap: true,
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount:
//               w > 1000
//                   ? 4
//                   : w > 600
//                   ? 3
//                   : 2,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//           childAspectRatio: w < 400 ? 0.55 : 0.7,
//         ),
//         itemCount: docs.length,
//         itemBuilder: (c, i) {
//           final data = docs[i].data()! as Map<String, dynamic>;
//           final images = data['imageUrls'] as List<dynamic>? ?? [];
//           // Inside the _buildGrid method's itemBuilder:
//           return FutureBuilder<Map<String, String>>(
//             future: getSellerContactDetails(data['sellerId']),
//             builder: (c2, sellerSnap) {
//               if (!sellerSnap.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               final seller = sellerSnap.data!;
//               return _ProductCard(
//                 productId: docs[i].id, // Corrected variable reference
//                 product: data,
//                 images: images,
//                 address:
//                     seller['address'] ?? 'Address not available', // Handle null
//                 phone:
//                     seller['phoneNumber'] ??
//                     'Phone not available', // Handle null
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// // Your existing ProductCard with full build method…
// class _ProductCard extends StatelessWidget {
//   final Map<String, dynamic> product;
//   final List<dynamic> images;
//   final String address;
//   final String phone;
//   final String productId;

//   const _ProductCard({
//     required this.productId,
//     required this.product,
//     required this.images,
//     required this.address,
//     required this.phone,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext ctx) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // Available width for this card:
//         final cardW = constraints.maxWidth;
//         final cardH = constraints.maxHeight;

//         // Scale factors:
//         final imgH = cardW * 0.6; // image is 60% of card width
//         final padding = cardW * 0.05; // 5% padding
//         final titleFS = cardW * 0.08; // fontSize ~8% of width
//         final subtitleFS = cardW * 0.06; // fontSize ~6% of width
//         final iconSize = cardW * 0.13; // icon ~10% of width
//         final h = cardH * 0.4;

//         return GestureDetector(
//           onTap:
//               () => Navigator.push(
//                 ctx,
//                 MaterialPageRoute(
//                   builder:
//                       (_) => ProductDetailsPage(
//                         productData: product,
//                         productId: productId,
//                       ),
//                 ),
//               ),
//           child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(cardW * 0.03),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // 1) Image
//                 Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius: const BorderRadius.vertical(
//                         top: Radius.circular(12),
//                       ),
//                       child: SizedBox(
//                         width: double.infinity,
//                         height: imgH,
//                         child:
//                             images.isNotEmpty
//                                 ? CarouselSlider(
//                                   options: CarouselOptions(
//                                     height: imgH,
//                                     autoPlay: true,
//                                     viewportFraction: 1.0,
//                                   ),
//                                   items:
//                                       images
//                                           .map(
//                                             (url) => Image.network(
//                                               url,
//                                               fit: BoxFit.cover,
//                                               width: double.infinity,
//                                             ),
//                                           )
//                                           .toList(),
//                                 )
//                                 : (product['imageUrl'] != null
//                                     ? Image.network(
//                                       product['imageUrl'],
//                                       fit: BoxFit.cover,
//                                       width: double.infinity,
//                                       height: imgH,
//                                     )
//                                     : Container(
//                                       width: double.infinity,
//                                       height: imgH,
//                                       color: Colors.grey[200],
//                                       child: const Icon(
//                                         Icons.image_not_supported,
//                                         size: 40,
//                                         color: Colors.grey,
//                                       ),
//                                     )),
//                       ),
//                     ),

//                     // 2) Favorite icon in top-right
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: Material(
//                         // so the circle ripple works if you want it
//                         color: Colors.white.withOpacity(0.7),
//                         shape: const CircleBorder(),
//                         child: Padding(
//                           padding: const EdgeInsets.all(4),
//                           child: FavoriteButton(productId: productId),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 // 2) Text Info
//                 Padding(
//                   padding: EdgeInsets.all(padding),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Title + Location
//                       Row(
//                         children: [
//                           Expanded(
//                             flex: 4,
//                             child: Text(
//                               (product['name'] ?? '').toString().tr(),
//                               style: TextStyle(
//                                 fontSize: titleFS,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           Icon(
//                             Icons.location_on,
//                             size: iconSize * 0.6,
//                             color: Colors.red,
//                           ),
//                           SizedBox(width: cardW * 0.02),
//                           Flexible(
//                             flex: 2,
//                             child: Text(
//                               address,
//                               style: TextStyle(fontSize: subtitleFS),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: padding * 0.5),

//                       // Price + Rating
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             '₹${product['price'] ?? '0'} / ${product['unit']}',
//                             style: TextStyle(
//                               fontSize: subtitleFS,
//                               color: Colors.green,
//                             ),
//                           ),
//                           FutureBuilder<QuerySnapshot>(
//                             future:
//                                 FirebaseFirestore.instance
//                                     .collection('products')
//                                     .doc(productId)
//                                     .collection('reviews')
//                                     .get(),
//                             builder: (ctx, snap) {
//                               // while loading, show a greyed‑out star with “–”
//                               if (snap.connectionState ==
//                                   ConnectionState.waiting) {
//                                 return Row(
//                                   children: [
//                                     Icon(
//                                       Icons.star,
//                                       size: iconSize * 0.6,
//                                       color: Colors.grey,
//                                     ),
//                                     SizedBox(width: cardW * 0.01),
//                                     Text(
//                                       '-',
//                                       style: TextStyle(fontSize: subtitleFS),
//                                     ),
//                                   ],
//                                 );
//                               }

//                               // no reviews → show 0.0
//                               final reviews = snap.data?.docs ?? [];
//                               if (reviews.isEmpty) {
//                                 return Row(
//                                   children: [
//                                     Icon(
//                                       Icons.star,
//                                       size: iconSize * 0.6,
//                                       color: Colors.amber,
//                                     ),
//                                     SizedBox(width: cardW * 0.01),
//                                     Text(
//                                       '0.0',
//                                       style: TextStyle(fontSize: subtitleFS),
//                                     ),
//                                   ],
//                                 );
//                               }

//                               // compute average
//                               final ratings =
//                                   reviews
//                                       .map(
//                                         (r) =>
//                                             double.tryParse(
//                                               r['rating'].toString(),
//                                             ) ??
//                                             0,
//                                       )
//                                       .toList();
//                               final avg =
//                                   ratings.reduce((a, b) => a + b) /
//                                   ratings.length;

//                               return Row(
//                                 children: [
//                                   Icon(
//                                     Icons.star,
//                                     size: iconSize * 0.6,
//                                     color: Colors.amber,
//                                   ),
//                                   SizedBox(width: cardW * 0.01),
//                                   Text(
//                                     avg.toStringAsFixed(1),
//                                     style: TextStyle(fontSize: subtitleFS),
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: padding * 0.5),

//                       // Description
//                       Text(
//                         (product['description'] ?? '').toString().substring(
//                               0,
//                               min(40, (product['description'] ?? '').length),
//                             ) +
//                             ((product['description'] ?? '').length > 40
//                                 ? '…'
//                                 : ''),
//                         style: TextStyle(fontSize: subtitleFS * 0.9),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),

//                 const Divider(height: 1),

//                 // 3) Actions
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: h / 10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _commButton(
//                         ctx,
//                         'assets/whatsapp.png',
//                         iconSize,
//                         () => _requireLogin(
//                           ctx,
//                           () => launchWhatsApp(ctx, phone),
//                         ),
//                       ),
//                       _commButton(
//                         ctx,
//                         null,
//                         iconSize,
//                         () => _requireLogin(ctx, () => launchSMS(ctx, phone)),
//                         icon: Icons.sms,
//                         color: Colors.green,
//                       ),
//                       _commButton(
//                         ctx,
//                         null,
//                         iconSize,
//                         () => _startChat(ctx),
//                         icon: Icons.send_outlined,
//                         color: Colors.green,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _commButton(
//     BuildContext ctx,
//     String? assetPath,
//     double size,
//     VoidCallback onTap, {
//     IconData icon = Icons.help,
//     Color color = Colors.black,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child:
//           assetPath != null
//               ? Image.asset(assetPath, height: size)
//               : Icon(icon, size: size, color: color),
//     );
//   }

//   void _requireLogin(BuildContext ctx, VoidCallback action) {
//     if (FirebaseAuth.instance.currentUser == null) {
//       Navigator.push(ctx, MaterialPageRoute(builder: (_) => const Login()));
//     } else {
//       action();
//     }
//   }

//   Future<void> _startChat(BuildContext ctx) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(
//         ctx,
//       ).showSnackBar(const SnackBar(content: Text('Please login first')));
//       return;
//     }

//     final buyerId = user.uid;
//     final sellerId = product['sellerId'] as String;
//     final fs = FirebaseFirestore.instance;
//     final q =
//         await fs
//             .collection('chats')
//             .where('buyerId', isEqualTo: buyerId)
//             .where('sellerId', isEqualTo: sellerId)
//             .limit(1)
//             .get();

//     String chatId;
//     if (q.docs.isNotEmpty) {
//       chatId = q.docs.first.id;
//     } else {
//       final doc = await fs.collection('chats').add({
//         'buyerId': buyerId,
//         'sellerId': sellerId,
//         'lastMessage': '',
//         'lastMessageTime': FieldValue.serverTimestamp(),
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//       chatId = doc.id;
//     }

//     Navigator.push(
//       ctx,
//       MaterialPageRoute(
//         builder: (_) => BuyerChatScreen(currentUserId: buyerId, chatId: chatId),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:math';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:signup_login_page/News/Screens/newsUI2.dart';
// import 'package:signup_login_page/Theme/theme_provider.dart';
// import 'package:signup_login_page/screen/Buyer/buyerLogicHandler.dart';
// import 'package:signup_login_page/screen/Buyer/favouriteButton.dart';
// import 'package:signup_login_page/screen/Buyer/wishlistPage.dart';
// import 'package:signup_login_page/screen/Buyer/buyerProfile.dart';
// import 'package:signup_login_page/screen/Chat/screens/buyer/chat_list_screen.dart';
// import 'package:signup_login_page/screen/Chat/screens/buyer/chat_screen.dart';
// import 'package:signup_login_page/screen/Weather/screens/weather_screen.dart';
// import 'package:speech_to_text/speech_to_text.dart' as stt;
// import 'package:firebase_auth/firebase_auth.dart';
// import '../screen/login.dart';
// import '../screen/signup.dart';
// import '../screen/Buyer/productDetailsPage.dart';
// import 'package:badges/badges.dart' as badges;

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});
//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   // UI data
//   final List<String> imageList = [
//     'assets/kisan/kisan1.jpg',
//     'assets/kisan/kisan2.jpg',
//     'assets/kisan/kisan3.jpg',
//     'assets/kisan/kisan4.jpg',
//     'assets/kisan/kisan5.jpeg',
//   ];

//   int cartItemCount = 0;
//   static const int _pageSize = 20;
//   int _currentPage = 0;

//   String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

//   String? _selectedSellerId;
//   bool _isLoadingSellers = true;
//   Map<String, String> sellerNamesById = {};

//   double? _minPrice;
//   double? _maxPrice;
//     double? _minRating;

//     List<Map<String, double>> priceRanges = [
//     {'min': 0, 'max': 100},
//     {'min': 101, 'max': 500},
//     {'min': 501, 'max': 1000},
//     {'min': 1001, 'max': 5000},
//     {'min': 5001, 'max': 10000},
//   ];

//   double? selectedMinPrice;
//   double? selectedMaxPrice;

//     Map<String, double> ratingMap = {};

//   Future<void> fetchRatings(List<QueryDocumentSnapshot> docs) async {
//     ratingMap.clear();
//     for (final doc in docs) {
//       final productId = doc.id;
//       final reviewsSnap =
//           await FirebaseFirestore.instance
//               .collection('products')
//               .doc(productId)
//               .collection('reviews')
//               .get();
//       if (reviewsSnap.docs.isNotEmpty) {
//         final ratings =
//             reviewsSnap.docs
//                 .map((r) => double.tryParse(r['rating'].toString()) ?? 0)
//                 .toList();
//         final avg = ratings.reduce((a, b) => a + b) / ratings.length;
//         ratingMap[productId] = avg;
//       } else {
//         ratingMap[productId] = 0;
//       }
//     }
//   }

//   Future<void> fetchSellerNames() async {
//     setState(() => _isLoadingSellers = true);

//     try {
//       // Step 1: Get all unique sellerIds from 'products' collection
//       final productsQuery =
//           await FirebaseFirestore.instance.collection('products').get();
//       final Set<String> sellerIdsWithProducts = {
//         for (var doc in productsQuery.docs) doc['sellerId'] as String,
//       };

//       if (sellerIdsWithProducts.isEmpty) {
//         setState(() {
//           sellerNamesById = {};
//           _isLoadingSellers = false;
//         });
//         return;
//       }

//       // Step 2: Chunk seller IDs into batches of 10
//       List<String> allIds = sellerIdsWithProducts.toList();
//       List<Map<String, String>> chunkedResults = [];

//       for (var i = 0; i < allIds.length; i += 10) {
//         final chunk = allIds.sublist(
//           i,
//           i + 10 > allIds.length ? allIds.length : i + 10,
//         );
//         final usersQuery =
//             await FirebaseFirestore.instance
//                 .collection('users')
//                 .where(FieldPath.documentId, whereIn: chunk)
//                 .get();

//         final Map<String, String> chunkNames = {
//           for (var doc in usersQuery.docs)
//             doc.id: (doc['name'] as String?) ?? 'Unknown',
//         };

//         chunkedResults.add(chunkNames);
//       }

//       // Merge all chunks into a single map
//       final Map<String, String> names = {};
//       for (var map in chunkedResults) {
//         names.addAll(map);
//       }

//       setState(() {
//         sellerNamesById = names;
//         _isLoadingSellers = false;
//       });
//     } catch (e) {
//       print('Error fetching seller names: $e');
//       setState(() => _isLoadingSellers = false);
//     }
//   }

//   void _openSellerFilterDialog() {
//     double minPrice = _minPrice ?? 0;
//     double maxPrice = _maxPrice ?? 10000;
//       double minRating = _minRating ?? 0;

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       builder: (ctx) {
//         if (_isLoadingSellers) {
//           return SizedBox(
//             height: 200,
//             child: Center(child: CircularProgressIndicator()),
//           );
//         }

//         final entries =
//             sellerNamesById.entries.toList()..sort(
//               (a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()),
//             );

//         return StatefulBuilder(
//           builder: (ctx, setModalState) {
//             return SafeArea(
//               child: Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Row(
//                       children: [
//                         Text(
//                           'Filter by Seller',
//                           style: TextStyle(fontWeight: FontWeight.bold),
//                         ),
//                         Spacer(),
//                         TextButton(
//                           onPressed: () {
//                             setState(() {
//                               _selectedSellerId = null;
//                               _minPrice = null;
//                               _maxPrice = null;
//                               _minRating = null;
//                             });
//                             Navigator.pop(ctx);
//                           },
//                           child: Text('Clear All'),
//                         ),
//                       ],
//                     ),
//                     ListTile(
//                       title: Text('All Sellers'),
//                       selected: _selectedSellerId == null,
//                       onTap: () {
//                         setState(() => _selectedSellerId = null);
//                         Navigator.pop(ctx);
//                       },
//                     ),
//                     ...entries.map(
//                       (e) => ListTile(
//                         title: Text(e.value),
//                         selected: _selectedSellerId == e.key,
//                         onTap: () {
//                           setState(() => _selectedSellerId = e.key);
//                           Navigator.pop(ctx);
//                         },
//                       ),
//                     ),
//                     Divider(),
//                     Text(
//                       'Filter by Price',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Column(
//                       children:
//                           priceRanges.map((range) {
//                             final label =
//                                 '₹${range['min']!.toInt()} - ₹${range['max']!.toInt()}';
//                             final isSelected =
//                                 minPrice == range['min'] &&
//                                 maxPrice == range['max'];
//                             return ListTile(
//                               title: Text(label),
//                               selected: isSelected,
//                               onTap: () {
//                                 setModalState(() {
//                                   minPrice = range['min']!;
//                                   maxPrice = range['max']!;
//                                 });
//                               },
//                             );
//                           }).toList(),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text('Min: ₹${minPrice.round()}'),
//                         Text('Max: ₹${maxPrice.round()}'),
//                       ],
//                     ),
//                     Divider(),
//                     Text(
//                       'Filter by Rating',
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                     Slider(
//                       value: minRating,
//                       min: 0,
//                       max: 5,
//                       divisions: 5,
//                       label: minRating.toStringAsFixed(1),
//                       onChanged: (value) {
//                         setModalState(() {
//                           minRating = value;
//                         });
//                       },
//                     ),
//                     Text('Min Rating: ${minRating.toStringAsFixed(1)} ⭐'),

//                     SizedBox(height: 12),
//                     ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           _minPrice = minPrice;
//                           _maxPrice = maxPrice;
//                               _minRating = minRating;

//                         });
//                         Navigator.pop(ctx);
//                       },
//                       child: Text('Apply Filters'),
//                     ),
//                     // TextButton(
//                     //   onPressed: () {
//                     //     setState(() {
//                     //       _selectedSellerId = null;
//                     //       _minPrice = null;
//                     //       _maxPrice = null;
//                     //       _minRating = null;
//                     //     });
//                     //     Navigator.pop(ctx);
//                     //   },
//                     //   child: Text('Clear All Filters'),
//                     // ),

//                   ],
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }

//   // Search & voice
//   final TextEditingController _searchController = TextEditingController();
//   final FocusNode _searchFocus = FocusNode();
//   String searchQuery = '';
//   Timer? _debounce;
//   late stt.SpeechToText _speech;
//   bool _isListening = false;
//   String _localeId = 'en_IN';

//   @override
//   void initState() {
//     super.initState();
//     _speech = stt.SpeechToText();
//     _initSpeech();
//     fetchSellerNames();
//   }

//   Future<void> _initSpeech() async {
//     if (await _speech.initialize()) {
//       final sys = await _speech.systemLocale();
//       _localeId = sys?.localeId ?? _localeId;
//     }
//   }

//   void _toggleListening() async {
//     if (_isListening) {
//       _speech.stop();
//       setState(() => _isListening = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Stopped listening')));
//     } else if (await _speech.initialize()) {
//       setState(() => _isListening = true);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('Listening...')));
//       _speech.listen(
//         localeId: _localeId,
//         onResult: (res) {
//           setState(() {
//             _searchController.text = res.recognizedWords;
//             searchQuery = res.recognizedWords;
//           });
//         },
//       );
//     }
//   }

//   // Create this helper widget for the badge
//   Widget buildWishlistBadge(int count) {
//     return Padding(
//       padding: const EdgeInsets.only(right: 0.0),
//       child: badges.Badge(
//         position: badges.BadgePosition.topEnd(top: -5, end: -5),
//         showBadge: count > 0,
//         badgeContent: Text(
//           '$count',
//           style: const TextStyle(color: Colors.white, fontSize: 10),
//         ),
//         badgeStyle: const badges.BadgeStyle(
//           badgeColor: Colors.red,
//           padding: EdgeInsets.all(6),
//         ),
//         child: IconButton(
//           icon: Icon(Icons.favorite),
//           onPressed: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => WishlistPage()),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   bool _showSearch = false; // new

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _searchController.dispose();
//     _searchFocus.dispose();
//     super.dispose();
//   }

//   bool get _isSearching =>
//       _searchFocus.hasFocus || searchQuery.trim().isNotEmpty;

//   @override
//   Widget build(BuildContext context) {
//     final w = MediaQuery.of(context).size.width;
//     final h = MediaQuery.of(context).size.height;
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,

//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         scrolledUnderElevation: 0,
//         leadingWidth: 115,
//         leading:
//             isDark
//                 ? Image.asset(
//                   "assets/kisan/logoL.png",
//                 ) // light logo for dark theme
//                 : Image.asset("assets/kisan/logoD.png"),

//         actions: [
//           SizedBox(width: w * 0.05),
//           FirebaseAuth.instance.currentUser != null
//               ? StreamBuilder<QuerySnapshot>(
//                 stream:
//                     FirebaseFirestore.instance
//                         .collection('chats')
//                         .where('buyerId', isEqualTo: currentUserId)
//                         .snapshots(),
//                 builder: (context, snap) {
//                   // compute total unread
//                   int totalUnread = 0;
//                   if (snap.hasData) {
//                     totalUnread = snap.data!.docs.fold(0, (sum, doc) {
//                       final data = doc.data()! as Map<String, dynamic>;
//                       return sum + (data['unreadCountForBuyer'] as int? ?? 0);
//                     });
//                   }
//                   return badges.Badge(
//                     showBadge: totalUnread > 0,
//                     position: badges.BadgePosition.topEnd(top: -4, end: 1),
//                     badgeAnimation: badges.BadgeAnimation.fade(),
//                     badgeStyle: badges.BadgeStyle(
//                       badgeColor: Colors.red,
//                       padding: EdgeInsets.all(6),
//                       elevation: 0,
//                     ),
//                     badgeContent: Text(
//                       totalUnread.toString(),
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     child: IconButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder:
//                                 (_) =>
//                                     BuyerChatListScreen(buyerId: currentUserId),
//                           ),
//                         );
//                       },
//                       icon: Icon(
//                         Icons.send_and_archive,
//                         color:
//                             Theme.of(context).brightness == Brightness.dark
//                                 ? Colors.white
//                                 : Colors.black,
//                       ),
//                     ),
//                   );
//                 },
//               )
//               : SizedBox.shrink(),

//           // Hides the widget completely
//           Consumer(
//             builder: (context, ref, _) {
//               final themeMode = ref.watch(themeProvider);
//               final isDark = themeMode == ThemeMode.dark;

//               return IconButton(
//                 icon: Icon(
//                   isDark ? Icons.light_mode : Icons.dark_mode,
//                   color: isDark ? Colors.white : Colors.black,
//                 ),
//                 tooltip:
//                     isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
//                 onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
//               );
//             },
//           ),

//           // Wishlist Page....Icon
//           StreamBuilder<QuerySnapshot>(
//             stream:
//                 FirebaseFirestore.instance
//                     .collection('users')
//                     .doc(FirebaseAuth.instance.currentUser?.uid)
//                     .collection('wishlist')
//                     .snapshots(),
//             builder: (context, snapshot) {
//               int count = snapshot.data?.docs.length ?? 0;
//               return buildWishlistBadge(count);
//             },
//           ),

//           //Search icon
//           IconButton(
//             icon: Icon(_showSearch ? Icons.close : Icons.search),
//             onPressed: () {
//               setState(() {
//                 _showSearch = !_showSearch;
//                 if (!_showSearch) {
//                   _searchController.clear();
//                   searchQuery = '';
//                   _searchFocus.unfocus();
//                 }
//               });
//             },
//           ),
//           StreamBuilder<User?>(
//             stream: FirebaseAuth.instance.authStateChanges(),
//             builder: (context, snapshot) {
//               final user = snapshot.data;

//               return PopupMenuButton<String>(
//                 icon: const Icon(Icons.menu),
//                 onSelected: (val) {
//                   if (val == 'profile' && user != null) {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => BuyerDashboard()),
//                     );
//                   } else if (val == 'logout') {
//                     FirebaseAuth.instance.signOut();
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(builder: (_) => const HomePage()),
//                     );
//                   } else if (val == 'Login') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const Login()),
//                     );
//                   } else if (val == 'Signup') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const Signup()),
//                     );
//                   } else if (val == 'weather') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => WeatherHomePage()),
//                     );
//                   } else if (val == 'news') {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => AgriNewsPage()),
//                     );
//                   }
//                 },
//                 itemBuilder: (context) {
//                   List<PopupMenuEntry<String>> items = [];

//                   if (user != null) {
//                     items.addAll([
//                       PopupMenuItem(
//                         value: 'profile',
//                         child: Text('profile'.tr()),
//                       ),
//                       PopupMenuItem(
//                         value: 'weather',
//                         child: Text('agriweather'.tr()),
//                       ),
//                       PopupMenuItem(
//                         value: 'news',
//                         child: Text("agriNews".tr()),
//                       ),
//                       PopupMenuItem<String>(
//                         enabled: false,
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<Locale>(
//                             value: context.locale,
//                             icon: const Icon(Icons.language),
//                             dropdownColor: Colors.white,
//                             onChanged: (Locale? locale) {
//                               if (locale != null) {
//                                 context.setLocale(locale);
//                                 Navigator.pop(context); // close the menu
//                               }
//                             },
//                             items: const [
//                               DropdownMenuItem(
//                                 value: Locale('en'),
//                                 child: Text(
//                                   'English',
//                                   style: TextStyle(fontSize: 15),
//                                 ),
//                               ),
//                               DropdownMenuItem(
//                                 value: Locale('hi'),
//                                 child: Text(
//                                   'हिंदी',
//                                   style: TextStyle(fontSize: 15),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                       PopupMenuItem(
//                         value: 'logout',
//                         child: Row(
//                           children: [
//                             Icon(Icons.login, color: Colors.redAccent),
//                             SizedBox(width: 8),
//                             Text(
//                               'logout'.tr(),
//                               style: TextStyle(
//                                 color: Colors.redAccent,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ]);
//                   } else {
//                     items.addAll([
//                       PopupMenuItem(value: 'Login', child: Text('login'.tr())),
//                       PopupMenuItem(
//                         value: 'Signup',
//                         child: Text('signup'.tr()),
//                       ),
//                       PopupMenuItem(
//                         value: 'weather',
//                         child: Text('agriweather'.tr()),
//                       ),
//                       PopupMenuItem(
//                         value: 'news',
//                         child: Text("agriNews".tr()),
//                       ),
//                       PopupMenuItem<String>(
//                         enabled: false,
//                         child: DropdownButtonHideUnderline(
//                           child: DropdownButton<Locale>(
//                             value: context.locale,
//                             icon: const Icon(Icons.language),
//                             dropdownColor: Colors.white,
//                             onChanged: (Locale? locale) {
//                               if (locale != null) {
//                                 context.setLocale(locale);
//                                 Navigator.pop(context); // close the menu
//                               }
//                             },
//                             items: const [
//                               DropdownMenuItem(
//                                 value: Locale('en'),
//                                 child: Text(
//                                   'English',
//                                   style: TextStyle(fontSize: 15),
//                                 ),
//                               ),
//                               DropdownMenuItem(
//                                 value: Locale('hi'),
//                                 child: Text(
//                                   'हिंदी',
//                                   style: TextStyle(fontSize: 15),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ]);
//                   }
//                   return items;
//                 },
//               );
//             },
//           ),
//         ],
//       ),

//       body: Column(
//         children: [
//           // It will be visible only when _showSearch is true - Saurabh
//           if (_showSearch)
//             Padding(
//               padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
//               child: TextField(
//                 focusNode: _searchFocus,
//                 controller: _searchController,
//                 decoration: InputDecoration(
//                   hintText: 'search'.tr(),
//                   prefixIcon: const Icon(Icons.search),
//                   suffixIcon: IconButton(
//                     icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
//                     onPressed: _toggleListening,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onChanged: (v) {
//                   _debounce?.cancel();
//                   _debounce = Timer(const Duration(milliseconds: 300), () {
//                     setState(() => searchQuery = v.trim());
//                   });
//                 },
//               ),
//             ),

//           // 2) Expanded area: full home or filtered results
//           Expanded(
//             child: StreamBuilder<QuerySnapshot>(
//               stream:
//                   FirebaseFirestore.instance
//                       .collection('products')
//                       .orderBy('createdAt', descending: true)
//                       .where('approved', isEqualTo: true)
//                       .snapshots(),
//               builder: (ctx, snap) {
//                 if (snap.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 }

//                 final docs = snap.data?.docs ?? [];

//                 //  ➤ Apply seller filter first:
//                 final filtered =
//                     docs.where((doc) {
//                       final productId = doc.id;

//                       // 1) Seller filter
//                       final sellerMatches =
//                           _selectedSellerId == null ||
//                           doc['sellerId'] == _selectedSellerId;

//                       // 2) Price filter
//                       final price =
//                           double.tryParse(doc['price'].toString()) ?? 0;
//                       final priceMatches =
//                           (_minPrice == null || price >= _minPrice!) &&
//                           (_maxPrice == null || price <= _maxPrice!);

//                       // 3) Rating filter (from ratingMap)
//                       final avgRating = ratingMap[productId] ?? 0;
//                       final ratingMatches =
//                           _minRating == null || avgRating >= _minRating!;

//                       // 4) Search filter
//                       final name = (doc['name'] ?? '').toString().toLowerCase();
//                       final desc =
//                           (doc['description'] ?? '').toString().toLowerCase();
//                       final q = searchQuery.toLowerCase();
//                       final searchMatches =
//                           !_isSearching || name.contains(q) || desc.contains(q);

//                       return sellerMatches &&
//                           priceMatches &&
//                           ratingMatches &&
//                           searchMatches;
//                     }).toList();

//                 final isSearching = _isSearching;

//                 if (isSearching && filtered.isEmpty) {
//                   return const Center(child: Text('No matching grains found'));
//                 }

//                 // ─── SLICE OUT CURRENT PAGE ────────────────────────────────
//                 final totalItems = filtered.length;
//                 final totalPages = (totalItems / _pageSize).ceil();
//                 // clamp currentPage
//                 _currentPage = min(_currentPage, max(0, totalPages - 1));
//                 final start = _currentPage * _pageSize;
//                 final end = min(start + _pageSize, totalItems);
//                 final pageDocs = filtered.sublist(start, end);

//                 // FULL HOME: carousel + welcome + grid
//                 if (!isSearching) {
//                   return Column(
//                     children: [
//                       // --- Full-width Carousel ---
//                       SizedBox(
//                         width: double.infinity,
//                         height: w > 500 ? 270 : 170,
//                         child: CarouselSlider(
//                           options: CarouselOptions(
//                             height: double.infinity,
//                             autoPlay: true,
//                             autoPlayInterval: const Duration(seconds: 5),
//                             viewportFraction: 1.0,
//                           ),
//                           items:
//                               imageList
//                                   .map(
//                                     (url) => SizedBox(
//                                       width: double.infinity,
//                                       child: Image.asset(
//                                         url,
//                                         fit: BoxFit.cover,
//                                       ),
//                                     ),
//                                   )
//                                   .toList(),
//                         ),
//                       ),

//                       Padding(
//                         padding: const EdgeInsets.all(10),
//                         child: Column(
//                           children: [
//                             Text(
//                               'welcome'.tr(),
//                               textAlign: TextAlign.center,
//                               style: TextStyle(
//                                 fontSize: w > 600 ? 18 : 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () => _openSellerFilterDialog(),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.filter_list),
//                             SizedBox(width: 5),
//                             Text("Filter Grains"),
//                           ],
//                         ),
//                       ),

//                       // --- Grid of all products ---
//                       Expanded(child: _buildGrid(pageDocs)),
//                       if (totalPages > 1)
//                         SafeArea(
//                           top: false,
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(vertical: 8),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 IconButton(
//                                   icon: Icon(Icons.chevron_left),
//                                   onPressed:
//                                       _currentPage > 0
//                                           ? () => setState(() => _currentPage--)
//                                           : null,
//                                 ),
//                                 Text('Page ${_currentPage + 1} of $totalPages'),
//                                 IconButton(
//                                   icon: Icon(Icons.chevron_right),
//                                   onPressed:
//                                       _currentPage < totalPages - 1
//                                           ? () => setState(() => _currentPage++)
//                                           : null,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                     ],
//                   );
//                 }
//                 // SEARCH RESULTS: just the filtered grid
//                 return _buildGrid(filtered);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildGrid(List<QueryDocumentSnapshot> docs) {
//     final w = MediaQuery.of(context).size.width;

//     return RefreshIndicator(
//       onRefresh: () async {
//         setState(() {});
//       },
//       child: GridView.builder(
//         padding: const EdgeInsets.all(8),
//         shrinkWrap: true,
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount:
//               w > 1000
//                   ? 4
//                   : w > 600
//                   ? 3
//                   : 2,
//           crossAxisSpacing: 10,
//           mainAxisSpacing: 10,
//           childAspectRatio: w < 400 ? 0.55 : 0.7,
//         ),
//         itemCount: docs.length,
//         itemBuilder: (c, i) {
//           final data = docs[i].data()! as Map<String, dynamic>;
//           final images = data['imageUrls'] as List<dynamic>? ?? [];
//           // Inside the _buildGrid method's itemBuilder:
//           return FutureBuilder<Map<String, String>>(
//             future: getSellerContactDetails(data['sellerId']),
//             builder: (c2, sellerSnap) {
//               if (!sellerSnap.hasData) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               final seller = sellerSnap.data!;
//               return _ProductCard(
//                 productId: docs[i].id, // Corrected variable reference
//                 product: data,
//                 images: images,
//                 address:
//                     seller['address'] ?? 'Address not available', // Handle null
//                 phone:
//                     seller['phoneNumber'] ??
//                     'Phone not available', // Handle null
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// // Your existing ProductCard with full build method…
// class _ProductCard extends StatelessWidget {
//   final Map<String, dynamic> product;
//   final List<dynamic> images;
//   final String address;
//   final String phone;
//   final String productId;

//   const _ProductCard({
//     required this.productId,
//     required this.product,
//     required this.images,
//     required this.address,
//     required this.phone,
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext ctx) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         // Available width for this card:
//         final cardW = constraints.maxWidth;
//         final cardH = constraints.maxHeight;

//         // Scale factors:
//         final imgH = cardW * 0.6; // image is 60% of card width
//         final padding = cardW * 0.05; // 5% padding
//         final titleFS = cardW * 0.08; // fontSize ~8% of width
//         final subtitleFS = cardW * 0.06; // fontSize ~6% of width
//         final iconSize = cardW * 0.13; // icon ~10% of width
//         final h = cardH * 0.4;

//         return GestureDetector(
//           onTap:
//               () => Navigator.push(
//                 ctx,
//                 MaterialPageRoute(
//                   builder:
//                       (_) => ProductDetailsPage(
//                         productData: product,
//                         productId: productId,
//                       ),
//                 ),
//               ),
//           child: Card(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(cardW * 0.03),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Stack(
//                   children: [
//                     ClipRRect(
//                       borderRadius: const BorderRadius.vertical(
//                         top: Radius.circular(12),
//                       ),
//                       child: SizedBox(
//                         width: double.infinity,
//                         height: imgH,
//                         child:
//                             images.isNotEmpty
//                                 ? CarouselSlider(
//                                   options: CarouselOptions(
//                                     height: imgH,
//                                     autoPlay: true,
//                                     viewportFraction: 1.0,
//                                   ),
//                                   items:
//                                       images
//                                           .map(
//                                             (url) => Image.network(
//                                               url,
//                                               fit: BoxFit.cover,
//                                               width: double.infinity,
//                                             ),
//                                           )
//                                           .toList(),
//                                 )
//                                 : (product['imageUrl'] != null
//                                     ? Image.network(
//                                       product['imageUrl'],
//                                       fit: BoxFit.cover,
//                                       width: double.infinity,
//                                       height: imgH,
//                                     )
//                                     : Container(
//                                       width: double.infinity,
//                                       height: imgH,
//                                       color: Colors.grey[200],
//                                       child: const Icon(
//                                         Icons.image_not_supported,
//                                         size: 40,
//                                         color: Colors.grey,
//                                       ),
//                                     )),
//                       ),
//                     ),

//                     // 2) Favorite icon in top-right
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: Material(
//                         // so the circle ripple works if you want it
//                         color: Colors.white.withOpacity(0.7),
//                         shape: const CircleBorder(),
//                         child: Padding(
//                           padding: const EdgeInsets.all(4),
//                           child: FavoriteButton(productId: productId),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 // 2) Text Info
//                 Padding(
//                   padding: EdgeInsets.all(padding),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Title + Location
//                       Row(
//                         children: [
//                           Expanded(
//                             flex: 4,
//                             child: Text(
//                               (product['name'] ?? '').toString().tr(),
//                               style: TextStyle(
//                                 fontSize: titleFS,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                           Icon(
//                             Icons.location_on,
//                             size: iconSize * 0.6,
//                             color: Colors.red,
//                           ),
//                           SizedBox(width: cardW * 0.02),
//                           Flexible(
//                             flex: 2,
//                             child: Text(
//                               address,
//                               style: TextStyle(fontSize: subtitleFS),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: padding * 0.5),

//                       // Price + Rating
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           // Text(
//                           //   '₹${product['price'] ?? '0'} / ${product['unit']}',
//                           //   style: TextStyle(
//                           //     fontSize: subtitleFS,
//                           //     color: Colors.green,
//                           //   ),
//                           // ),
//                           Text(
//                             '₹${product['price'] ?? '0'} / ${product['unit']}',
//                             style: TextStyle(
//                               fontSize: subtitleFS,
//                               color: Colors.green,
//                             ),
//                           ),
//                           FutureBuilder<QuerySnapshot>(
//                             future:
//                                 FirebaseFirestore.instance
//                                     .collection('products')
//                                     .doc(productId)
//                                     .collection('reviews')
//                                     .get(),
//                             builder: (ctx, snap) {
//                               // while loading, show a greyed‑out star with “–”
//                               if (snap.connectionState ==
//                                   ConnectionState.waiting) {
//                                 return Row(
//                                   children: [
//                                     Icon(
//                                       Icons.star,
//                                       size: iconSize * 0.6,
//                                       color: Colors.grey,
//                                     ),
//                                     SizedBox(width: cardW * 0.01),
//                                     Text(
//                                       '-',
//                                       style: TextStyle(fontSize: subtitleFS),
//                                     ),
//                                   ],
//                                 );
//                               }

//                               // no reviews → show 0.0
//                               final reviews = snap.data?.docs ?? [];
//                               if (reviews.isEmpty) {
//                                 return Row(
//                                   children: [
//                                     Icon(
//                                       Icons.star,
//                                       size: iconSize * 0.6,
//                                       color: Colors.amber,
//                                     ),
//                                     SizedBox(width: cardW * 0.01),
//                                     Text(
//                                       '0.0',
//                                       style: TextStyle(fontSize: subtitleFS),
//                                     ),
//                                   ],
//                                 );
//                               }

//                               // compute average
//                               final ratings =
//                                   reviews
//                                       .map(
//                                         (r) =>
//                                             double.tryParse(
//                                               r['rating'].toString(),
//                                             ) ??
//                                             0,
//                                       )
//                                       .toList();
//                               final avg =
//                                   ratings.reduce((a, b) => a + b) /
//                                   ratings.length;

//                               return Row(
//                                 children: [
//                                   Icon(
//                                     Icons.star,
//                                     size: iconSize * 0.6,
//                                     color: Colors.amber,
//                                   ),
//                                   SizedBox(width: cardW * 0.01),
//                                   Text(
//                                     avg.toStringAsFixed(1),
//                                     style: TextStyle(fontSize: subtitleFS),
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),
//                         ],
//                       ),

//                       SizedBox(height: padding * 0.5),

//                       // Description
//                       Text(
//                         (product['description'] ?? '').toString().substring(
//                               0,
//                               min(40, (product['description'] ?? '').length),
//                             ) +
//                             ((product['description'] ?? '').length > 40
//                                 ? '…'
//                                 : ''),
//                         style: TextStyle(fontSize: subtitleFS * 0.9),
//                         maxLines: 2,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                     ],
//                   ),
//                 ),

//                 const Divider(height: 1),

//                 // 3) Actions
//                 Padding(
//                   padding: EdgeInsets.symmetric(vertical: h / 10),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _commButton(
//                         ctx,
//                         'assets/whatsapp.png',
//                         iconSize,
//                         () => _requireLogin(
//                           ctx,
//                           () => launchWhatsApp(ctx, phone),
//                         ),
//                       ),
//                       _commButton(
//                         ctx,
//                         null,
//                         iconSize,
//                         () => _requireLogin(ctx, () => launchSMS(ctx, phone)),
//                         icon: Icons.sms,
//                         color: Colors.green,
//                       ),
//                       _commButton(
//                         ctx,
//                         null,
//                         iconSize,
//                         () => _startChat(ctx),
//                         icon: Icons.send_outlined,
//                         color: Colors.green,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _commButton(
//     BuildContext ctx,
//     String? assetPath,
//     double size,
//     VoidCallback onTap, {
//     IconData icon = Icons.help,
//     Color color = Colors.black,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child:
//           assetPath != null
//               ? Image.asset(assetPath, height: size)
//               : Icon(icon, size: size, color: color),
//     );
//   }

//   void _requireLogin(BuildContext ctx, VoidCallback action) {
//     if (FirebaseAuth.instance.currentUser == null) {
//       Navigator.push(ctx, MaterialPageRoute(builder: (_) => const Login()));
//     } else {
//       action();
//     }
//   }

//   Future<void> _startChat(BuildContext ctx) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) {
//       ScaffoldMessenger.of(
//         ctx,
//       ).showSnackBar(const SnackBar(content: Text('Please login first')));
//       return;
//     }

//     final buyerId = user.uid;
//     final sellerId = product['sellerId'] as String;
//     final fs = FirebaseFirestore.instance;
//     final q =
//         await fs
//             .collection('chats')
//             .where('buyerId', isEqualTo: buyerId)
//             .where('sellerId', isEqualTo: sellerId)
//             .limit(1)
//             .get();

//     String chatId;
//     if (q.docs.isNotEmpty) {
//       chatId = q.docs.first.id;
//     } else {
//       final doc = await fs.collection('chats').add({
//         'buyerId': buyerId,
//         'sellerId': sellerId,
//         'lastMessage': '',
//         'lastMessageTime': FieldValue.serverTimestamp(),
//         'createdAt': FieldValue.serverTimestamp(),
//       });
//       chatId = doc.id;
//     }

//     Navigator.push(
//       ctx,
//       MaterialPageRoute(
//         builder: (_) => BuyerChatScreen(currentUserId: buyerId, chatId: chatId),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:signup_login_page/News/Screens/newsUI2.dart';
import 'package:signup_login_page/Theme/theme_provider.dart';
import 'package:signup_login_page/screen/Buyer/buyerLogicHandler.dart';
import 'package:signup_login_page/screen/Buyer/favouriteButton.dart';
import 'package:signup_login_page/screen/Buyer/wishlistPage.dart';
import 'package:signup_login_page/screen/Buyer/buyerProfile.dart';
import 'package:signup_login_page/screen/Chat/screens/buyer/chat_list_screen.dart';
import 'package:signup_login_page/screen/Chat/screens/buyer/chat_screen.dart';
import 'package:signup_login_page/screen/Weather/screens/weather_screen.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:firebase_auth/firebase_auth.dart';
import '../screen/login.dart';
import '../screen/signup.dart';
import '../screen/Buyer/productDetailsPage.dart';
import 'package:badges/badges.dart' as badges;

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // UI data
  final List<String> imageList = [
    'assets/kisan/kisan1.jpg',
    'assets/kisan/kisan2.jpg',
    'assets/kisan/kisan3.jpg',
    'assets/kisan/kisan4.jpg',
    'assets/kisan/kisan5.jpeg',
  ];

  int cartItemCount = 0;
  static const int _pageSize = 20;
  int _currentPage = 0;

  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  String? _selectedSellerId;
  bool _isLoadingSellers = true;
  Map<String, String> sellerNamesById = {};

  double? _minPrice;
  double? _maxPrice;
  double? _minRating;

  List<Map<String, double>> priceRanges = [
    {'min': 0, 'max': 100},
    {'min': 101, 'max': 500},
    {'min': 501, 'max': 1000},
    {'min': 1001, 'max': 5000},
    {'min': 5001, 'max': 10000},
  ];

  double? selectedMinPrice;
  double? selectedMaxPrice;

  Map<String, double> ratingMap = {};

  Future<void> fetchRatings(List<QueryDocumentSnapshot> docs) async {
    final Map<String, double> newMap = {};
    for (final doc in docs) {
      final productId = doc.id;
      final reviewsSnap =
          await FirebaseFirestore.instance
              .collection('products')
              .doc(productId)
              .collection('reviews')
              .get();
      double avg = 0;
      if (reviewsSnap.docs.isNotEmpty) {
        final ratings =
            reviewsSnap.docs
                .map((r) => double.tryParse(r['rating'].toString()) ?? 0)
                .toList();
        avg = ratings.reduce((a, b) => a + b) / ratings.length;
      }
      newMap[productId] = avg;
    }
    // **Wrap in setState** so the UI re-runs with the new ratings:
    setState(() {
      ratingMap = newMap;
    });
  }

  Future<void> fetchSellerNames() async {
    setState(() => _isLoadingSellers = true);

    try {
      // Step 1: Get all unique sellerIds from 'products' collection
      final productsQuery =
          await FirebaseFirestore.instance.collection('products').get();
      final Set<String> sellerIdsWithProducts = {
        for (var doc in productsQuery.docs) doc['sellerId'] as String,
      };

      if (sellerIdsWithProducts.isEmpty) {
        setState(() {
          sellerNamesById = {};
          _isLoadingSellers = false;
        });
        return;
      }

      // Step 2: Chunk seller IDs into batches of 10
      List<String> allIds = sellerIdsWithProducts.toList();
      List<Map<String, String>> chunkedResults = [];

      for (var i = 0; i < allIds.length; i += 10) {
        final chunk = allIds.sublist(
          i,
          i + 10 > allIds.length ? allIds.length : i + 10,
        );
        final usersQuery =
            await FirebaseFirestore.instance
                .collection('users')
                .where(FieldPath.documentId, whereIn: chunk)
                .get();

        final Map<String, String> chunkNames = {
          for (var doc in usersQuery.docs)
            doc.id: (doc['name'] as String?) ?? 'Unknown',
        };

        chunkedResults.add(chunkNames);
      }

      // Merge all chunks into a single map
      final Map<String, String> names = {};
      for (var map in chunkedResults) {
        names.addAll(map);
      }

      setState(() {
        sellerNamesById = names;
        _isLoadingSellers = false;
      });
    } catch (e) {
      print('Error fetching seller names: $e');
      setState(() => _isLoadingSellers = false);
    }
  }

  void _openSellerSelectionDialog() {
    final allEntries =
        sellerNamesById.entries.toList()..sort(
          (a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()),
        );
    List<MapEntry<String, String>> filtered = List.from(allEntries);
    TextEditingController searchCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: searchCtrl,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search sellers…',
                      ),
                      onChanged: (q) {
                        setModalState(() {
                          filtered =
                              allEntries
                                  .where(
                                    (e) => e.value.toLowerCase().contains(
                                      q.toLowerCase(),
                                    ),
                                  )
                                  .toList();
                        });
                      },
                    ),
                    SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length + 1,
                        itemBuilder: (ctx, i) {
                          if (i == 0) {
                            return ListTile(
                              title: Text('All Sellers'),
                              selected: _selectedSellerId == null,
                              onTap: () {
                                setState(() => _selectedSellerId = null);
                                Navigator.pop(ctx);
                              },
                              onLongPress: () {
                                // also clear on long press
                                setState(() => _selectedSellerId = null);
                                setModalState(() => {});
                              },
                            );
                          }
                          final e = filtered[i - 1];
                          final isSel = _selectedSellerId == e.key;
                          return ListTile(
                            title: Text(e.value),
                            selected: isSel,
                            onTap: () {
                              setState(() => _selectedSellerId = e.key);
                              Navigator.pop(ctx);
                            },
                            onLongPress: () {
                              if (isSel) {
                                setState(() => _selectedSellerId = null);
                                setModalState(() => {});
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openSellerFilterDialog() {
    double minPrice = _minPrice ?? 0;
    double maxPrice = _maxPrice ?? 10000;
    double minRating = _minRating ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- SELLER PICKER TILE ---
                    ListTile(
                      title: Text('Select Seller'),
                      subtitle: Text(
                        _selectedSellerId == null
                            ? 'All Sellers'
                            : sellerNamesById[_selectedSellerId]!,
                      ),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.pop(ctx);
                        _openSellerSelectionDialog();
                      },
                    ),
                    Divider(),

                    // --- PRICE FILTERS ---
                    Text(
                      'Filter by Price',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...priceRanges.map((range) {
                      final label =
                          '₹${range['min']!.toInt()} - ₹${range['max']!.toInt()}';
                      final isSelected =
                          minPrice == range['min'] && maxPrice == range['max'];
                      return ListTile(
                        title: Text(label),
                        selected: isSelected,
                        onTap:
                            () => setModalState(() {
                              minPrice = range['min']!;
                              maxPrice = range['max']!;
                            }),
                      );
                    }),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Min: ₹${minPrice.round()}'),
                        Text('Max: ₹${maxPrice.round()}'),
                      ],
                    ),
                    Divider(),

                    // --- RATING SLIDER ---
                    Text(
                      'Filter by Rating',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Slider(
                      value: minRating,
                      min: 0,
                      max: 5,
                      divisions: 5,
                      label: minRating.toStringAsFixed(1),
                      onChanged: (v) => setModalState(() => minRating = v),
                    ),
                    Text('Min Rating: ${minRating.toStringAsFixed(1)} ⭐'),

                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _minPrice = minPrice;
                              _maxPrice = maxPrice;
                              _minRating = minRating;
                            });
                            Navigator.pop(ctx);
                          },
                          child: Text('Apply Filters'),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedSellerId = null;
                              _minPrice = null;
                              _maxPrice = null;
                              _minRating = null;
                            });
                            Navigator.pop(ctx);
                          },
                          child: Text('Clear All Filters'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNoResults(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodySmall!.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Search & voice
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  String searchQuery = '';
  Timer? _debounce;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _localeId = 'en_IN';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    fetchSellerNames();
  }

  Future<void> _initSpeech() async {
    if (await _speech.initialize()) {
      final sys = await _speech.systemLocale();
      _localeId = sys?.localeId ?? _localeId;
    }
  }

  void _toggleListening() async {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Stopped listening')));
    } else if (await _speech.initialize()) {
      setState(() => _isListening = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Listening...')));
      _speech.listen(
        localeId: _localeId,
        onResult: (res) {
          setState(() {
            _searchController.text = res.recognizedWords;
            searchQuery = res.recognizedWords;
          });
        },
      );
    }
  }

  // Create this helper widget for the badge
  Widget buildWishlistBadge(int count) {
    return Padding(
      padding: const EdgeInsets.only(right: 0.0),
      child: badges.Badge(
        position: badges.BadgePosition.topEnd(top: -5, end: -5),
        showBadge: count > 0,
        badgeContent: Text(
          '$count',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        badgeStyle: const badges.BadgeStyle(
          badgeColor: Colors.red,
          padding: EdgeInsets.all(6),
        ),
        child: IconButton(
          icon: Icon(Icons.favorite),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => WishlistPage()),
            );
          },
        ),
      ),
    );
  }

  bool _showSearch = false; // new

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  bool get _isSearching =>
      _searchFocus.hasFocus || searchQuery.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        leadingWidth: 115,
        leading:
            isDark
                ? Image.asset(
                  "assets/kisan/logoL.png",
                ) // light logo for dark theme
                : Image.asset("assets/kisan/logoD.png"),

        actions: [
          SizedBox(width: w * 0.05),
          FirebaseAuth.instance.currentUser != null
              ? StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection('chats')
                        .where('buyerId', isEqualTo: currentUserId)
                        .snapshots(),
                builder: (context, snap) {
                  // compute total unread
                  int totalUnread = 0;
                  if (snap.hasData) {
                    totalUnread = snap.data!.docs.fold(0, (sum, doc) {
                      final data = doc.data()! as Map<String, dynamic>;
                      return sum + (data['unreadCountForBuyer'] as int? ?? 0);
                    });
                  }
                  return badges.Badge(
                    showBadge: totalUnread > 0,
                    position: badges.BadgePosition.topEnd(top: -4, end: 1),
                    badgeAnimation: badges.BadgeAnimation.fade(),
                    badgeStyle: badges.BadgeStyle(
                      badgeColor: Colors.red,
                      padding: EdgeInsets.all(6),
                      elevation: 0,
                    ),
                    badgeContent: Text(
                      totalUnread.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    BuyerChatListScreen(buyerId: currentUserId),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.send_and_archive,
                        color:
                            Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                      ),
                    ),
                  );
                },
              )
              : SizedBox.shrink(),

          // Hides the widget completely
          Consumer(
            builder: (context, ref, _) {
              final themeMode = ref.watch(themeProvider);
              final isDark = themeMode == ThemeMode.dark;

              return IconButton(
                icon: Icon(
                  isDark ? Icons.light_mode : Icons.dark_mode,
                  color: isDark ? Colors.white : Colors.black,
                ),
                tooltip:
                    isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
              );
            },
          ),

          // Wishlist Page....Icon
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
                    .collection('wishlist')
                    .snapshots(),
            builder: (context, snapshot) {
              int count = snapshot.data?.docs.length ?? 0;
              return buildWishlistBadge(count);
            },
          ),

          //Search icon
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchController.clear();
                  searchQuery = '';
                  _searchFocus.unfocus();
                }
              });
            },
          ),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data;

              return PopupMenuButton<String>(
                icon: const Icon(Icons.menu),
                onSelected: (val) {
                  if (val == 'profile' && user != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BuyerDashboard()),
                    );
                  } else if (val == 'logout') {
                    FirebaseAuth.instance.signOut();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                    );
                  } else if (val == 'Login') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Login()),
                    );
                  } else if (val == 'Signup') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const Signup()),
                    );
                  } else if (val == 'weather') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => WeatherHomePage()),
                    );
                  } else if (val == 'news') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AgriNewsPage()),
                    );
                  }
                },
                itemBuilder: (context) {
                  List<PopupMenuEntry<String>> items = [];

                  if (user != null) {
                    items.addAll([
                      PopupMenuItem(
                        value: 'profile',
                        child: Text('profile'.tr()),
                      ),
                      PopupMenuItem(
                        value: 'weather',
                        child: Text('agriweather'.tr()),
                      ),
                      PopupMenuItem(
                        value: 'news',
                        child: Text("agriNews".tr()),
                      ),
                      PopupMenuItem<String>(
                        enabled: false,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Locale>(
                            value: context.locale,
                            icon: const Icon(Icons.language),
                            dropdownColor: Colors.white,
                            onChanged: (Locale? locale) {
                              if (locale != null) {
                                context.setLocale(locale);
                                Navigator.pop(context); // close the menu
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                value: Locale('en'),
                                child: Text(
                                  'English',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              DropdownMenuItem(
                                value: Locale('hi'),
                                child: Text(
                                  'हिंदी',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.login, color: Colors.redAccent),
                            SizedBox(width: 8),
                            Text(
                              'logout'.tr(),
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]);
                  } else {
                    items.addAll([
                      PopupMenuItem(value: 'Login', child: Text('login'.tr())),
                      PopupMenuItem(
                        value: 'Signup',
                        child: Text('signup'.tr()),
                      ),
                      PopupMenuItem(
                        value: 'weather',
                        child: Text('agriweather'.tr()),
                      ),
                      PopupMenuItem(
                        value: 'news',
                        child: Text("agriNews".tr()),
                      ),
                      PopupMenuItem<String>(
                        enabled: false,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<Locale>(
                            value: context.locale,
                            icon: const Icon(Icons.language),
                            dropdownColor: Colors.white,
                            onChanged: (Locale? locale) {
                              if (locale != null) {
                                context.setLocale(locale);
                                Navigator.pop(context); // close the menu
                              }
                            },
                            items: const [
                              DropdownMenuItem(
                                value: Locale('en'),
                                child: Text(
                                  'English',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              DropdownMenuItem(
                                value: Locale('hi'),
                                child: Text(
                                  'हिंदी',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]);
                  }
                  return items;
                },
              );
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // It will be visible only when _showSearch is true - Saurabh
          if (_showSearch)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              child: TextField(
                focusNode: _searchFocus,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'search'.tr(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    onPressed: _toggleListening,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onChanged: (v) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 300), () {
                    setState(() => searchQuery = v.trim());
                  });
                },
              ),
            ),

          // 2) Expanded area: full home or filtered results
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('products')
                      .orderBy('createdAt', descending: true)
                      .where('approved', isEqualTo: true)
                      .snapshots(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snap.data?.docs ?? [];

                // If we haven’t fetched ratings for all products yet, do it:
                if (ratingMap.length != docs.length) {
                  fetchRatings(docs);
                }

                //  ➤ Apply seller filter first:
                final filtered =
                    docs.where((doc) {
                      final productId = doc.id;

                      // 1) Seller filter
                      final sellerMatches =
                          _selectedSellerId == null ||
                          doc['sellerId'] == _selectedSellerId;

                      // 2) Price filter
                      final price =
                          double.tryParse(doc['price'].toString()) ?? 0;
                      final priceMatches =
                          (_minPrice == null || price >= _minPrice!) &&
                          (_maxPrice == null || price <= _maxPrice!);

                      // 3) Rating filter (from ratingMap)
                      final avgRating = ratingMap[productId] ?? 0;
                      final ratingMatches =
                          _minRating == null || avgRating >= _minRating!;

                      // 4) Search filter
                      final name = (doc['name'] ?? '').toString().toLowerCase();
                      final desc =
                          (doc['description'] ?? '').toString().toLowerCase();
                      final q = searchQuery.toLowerCase();
                      final searchMatches =
                          !_isSearching || name.contains(q) || desc.contains(q);

                      return sellerMatches &&
                          priceMatches &&
                          ratingMatches &&
                          searchMatches;
                    }).toList();

                final isSearching = _isSearching;

                if (filtered.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ① Always let them tweak the filters again:
                      GestureDetector(
                        onTap: _openSellerFilterDialog,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.filter_list),
                            SizedBox(width: 8),
                            Text(
                              "Modify Filters",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),

                      // ② The styled “no results” message:
                      Expanded(
                        child: _buildNoResults(
                          'No products match the applied filters.',
                        ),
                      ),
                    ],
                  );
                }

                // ─── SLICE OUT CURRENT PAGE ────────────────────────────────
                final totalItems = filtered.length;
                final totalPages = (totalItems / _pageSize).ceil();
                // clamp currentPage
                _currentPage = min(_currentPage, max(0, totalPages - 1));
                final start = _currentPage * _pageSize;
                final end = min(start + _pageSize, totalItems);
                final pageDocs = filtered.sublist(start, end);

                // FULL HOME: carousel + welcome + grid
                if (!isSearching) {
                  return Column(
                    children: [
                      // --- Full-width Carousel ---
                      SizedBox(
                        width: double.infinity,
                        height: w > 500 ? 270 : 170,
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: double.infinity,
                            autoPlay: true,
                            autoPlayInterval: const Duration(seconds: 5),
                            viewportFraction: 1.0,
                          ),
                          items:
                              imageList
                                  .map(
                                    (url) => SizedBox(
                                      width: double.infinity,
                                      child: Image.asset(
                                        url,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(
                              'welcome'.tr(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: w > 600 ? 18 : 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _openSellerFilterDialog(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.filter_list),
                            SizedBox(width: 5),
                            Text("Filter Grains"),
                          ],
                        ),
                      ),

                      // --- Grid of all products ---
                      Expanded(child: _buildGrid(pageDocs)),
                      if (totalPages > 1)
                        SafeArea(
                          top: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.chevron_left),
                                  onPressed:
                                      _currentPage > 0
                                          ? () => setState(() => _currentPage--)
                                          : null,
                                ),
                                Text('Page ${_currentPage + 1} of $totalPages'),
                                IconButton(
                                  icon: Icon(Icons.chevron_right),
                                  onPressed:
                                      _currentPage < totalPages - 1
                                          ? () => setState(() => _currentPage++)
                                          : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                }
                // SEARCH RESULTS: just the filtered grid
                return _buildGrid(filtered);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<QueryDocumentSnapshot> docs) {

    final size = MediaQuery.of(context).size;
    final w = size.width;
    final crossAxisCount = w < 400 ? 2 : 2;
    final spacing = 10.0;
    final itemWidth = (w - (crossAxisCount + 1) * spacing)/crossAxisCount;
    final itemHeight = size.height * 0.3;
    final aspectRatio = itemWidth / itemHeight;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: aspectRatio,
        ),
        itemCount: docs.length,
        itemBuilder: (c, i) {
          final data = docs[i].data()! as Map<String, dynamic>;
          final images = data['imageUrls'] as List<dynamic>? ?? [];
          // Inside the _buildGrid method's itemBuilder:
          return FutureBuilder<Map<String, String>>(
            future: getSellerContactDetails(data['sellerId']),
            builder: (c2, sellerSnap) {
              if (!sellerSnap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final seller = sellerSnap.data!;
              return _ProductCard(
                productId: docs[i].id, // Corrected variable reference
                product: data,
                images: images,
                address:
                    seller['address'] ?? 'Address not available', // Handle null
                phone:
                    seller['phoneNumber'] ??
                    'Phone not available', // Handle null
              );
            },
          );
        },
      ),
    );
  }
}

// Your existing ProductCard with full build method…
class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final List<dynamic> images;
  final String address;
  final String phone;
  final String productId;

  const _ProductCard({
    required this.productId,
    required this.product,
    required this.images,
    required this.address,
    required this.phone,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext ctx) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Available width for this card:
        final cardW = constraints.maxWidth;
        final cardH = constraints.maxHeight;

        // Scale factors:
        final imgH = cardW * 0.6; // image is 60% of card width
        final padding = cardW * 0.05; // 5% padding
        final titleFS = cardW * 0.08; // fontSize ~8% of width
        final subtitleFS = cardW * 0.06; // fontSize ~6% of width
        final iconSize = cardW * 0.13; // icon ~10% of width
        final h = cardH * 0.4;

        return GestureDetector(
          onTap:
              () => Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder:
                      (_) => ProductDetailsPage(
                        productData: product,
                        productId: productId,
                      ),
                ),
              ),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cardW * 0.03),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: imgH,
                        child:
                            images.isNotEmpty
                                ? CarouselSlider(
                                  options: CarouselOptions(
                                    height: imgH,
                                    autoPlay: true,
                                    viewportFraction: 1.0,
                                  ),
                                  items:
                                      images
                                          .map(
                                            (url) => Image.network(
                                              url,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                            ),
                                          )
                                          .toList(),
                                )
                                : (product['imageUrl'] != null
                                    ? Image.network(
                                      product['imageUrl'],
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: imgH,
                                    )
                                    : Container(
                                      width: double.infinity,
                                      height: imgH,
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    )),
                      ),
                    ),

                    // 2) Favorite icon in top-right
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Material(
                        // so the circle ripple works if you want it
                        color: Colors.white.withOpacity(0.7),
                        shape: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: FavoriteButton(productId: productId),
                        ),
                      ),
                    ),
                  ],
                ),

                // 2) Text Info
                Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title + Location
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Text(
                              (product['name'] ?? '').toString().tr(),
                              style: TextStyle(
                                fontSize: titleFS,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.location_on,
                            size: iconSize * 0.6,
                            color: Colors.red,
                          ),
                          SizedBox(width: cardW * 0.02),
                          Flexible(
                            flex: 2,
                            child: Text(
                              address,
                              style: TextStyle(fontSize: subtitleFS),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: padding * 0.5),

                      // Price + Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Text(
                          //   '₹${product['price'] ?? '0'} / ${product['unit']}',
                          //   style: TextStyle(
                          //     fontSize: subtitleFS,
                          //     color: Colors.green,
                          //   ),
                          // ),
                          Text(
                            '₹${product['price'] ?? '0'} / ${product['unit']}',
                            style: TextStyle(
                              fontSize: subtitleFS,
                              color: Colors.green,
                            ),
                          ),
                          FutureBuilder<QuerySnapshot>(
                            future:
                                FirebaseFirestore.instance
                                    .collection('products')
                                    .doc(productId)
                                    .collection('reviews')
                                    .get(),
                            builder: (ctx, snap) {
                              // while loading, show a greyed‑out star with “–”
                              if (snap.connectionState ==
                                  ConnectionState.waiting) {
                                return Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: iconSize * 0.6,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: cardW * 0.01),
                                    Text(
                                      '-',
                                      style: TextStyle(fontSize: subtitleFS),
                                    ),
                                  ],
                                );
                              }

                              // no reviews → show 0.0
                              final reviews = snap.data?.docs ?? [];
                              if (reviews.isEmpty) {
                                return Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: iconSize * 0.6,
                                      color: Colors.amber,
                                    ),
                                    SizedBox(width: cardW * 0.01),
                                    Text(
                                      '0.0',
                                      style: TextStyle(fontSize: subtitleFS),
                                    ),
                                  ],
                                );
                              }

                              // compute average
                              final ratings =
                                  reviews
                                      .map(
                                        (r) =>
                                            double.tryParse(
                                              r['rating'].toString(),
                                            ) ??
                                            0,
                                      )
                                      .toList();
                              final avg =
                                  ratings.reduce((a, b) => a + b) /
                                  ratings.length;

                              return Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: iconSize * 0.6,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: cardW * 0.01),
                                  Text(
                                    avg.toStringAsFixed(1),
                                    style: TextStyle(fontSize: subtitleFS),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: padding * 0.5),

                      // Description
                      Text(
                        (product['description'] ?? '').toString().substring(
                              0,
                              min(40, (product['description'] ?? '').length),
                            ) +
                            ((product['description'] ?? '').length > 40
                                ? '…'
                                : ''),
                        style: TextStyle(fontSize: subtitleFS * 0.9),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // 3) Actions
                Padding(
                  padding: EdgeInsets.symmetric(vertical: h / 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _commButton(
                        ctx,
                        'assets/whatsapp.png',
                        iconSize,
                        () => _requireLogin(
                          ctx,
                          () => launchWhatsApp(ctx, phone),
                        ),
                      ),
                      _commButton(
                        ctx,
                        null,
                        iconSize,
                        () => _requireLogin(ctx, () => launchSMS(ctx, phone)),
                        icon: Icons.sms,
                        color: Colors.green,
                      ),
                      _commButton(
                        ctx,
                        null,
                        iconSize,
                        () => _startChat(ctx),
                        icon: Icons.send_outlined,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _commButton(
    BuildContext ctx,
    String? assetPath,
    double size,
    VoidCallback onTap, {
    IconData icon = Icons.help,
    Color color = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child:
          assetPath != null
              ? Image.asset(assetPath, height: size)
              : Icon(icon, size: size, color: color),
    );
  }

  void _requireLogin(BuildContext ctx, VoidCallback action) {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.push(ctx, MaterialPageRoute(builder: (_) => const Login()));
    } else {
      action();
    }
  }

  Future<void> _startChat(BuildContext ctx) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        ctx,
      ).showSnackBar(const SnackBar(content: Text('Please login first')));
      return;
    }

    final buyerId = user.uid;
    final sellerId = product['sellerId'] as String;
    final fs = FirebaseFirestore.instance;
    final q =
        await fs
            .collection('chats')
            .where('buyerId', isEqualTo: buyerId)
            .where('sellerId', isEqualTo: sellerId)
            .limit(1)
            .get();

    String chatId;
    if (q.docs.isNotEmpty) {
      chatId = q.docs.first.id;
    } else {
      final doc = await fs.collection('chats').add({
        'buyerId': buyerId,
        'sellerId': sellerId,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      chatId = doc.id;
    }

    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => BuyerChatScreen(currentUserId: buyerId, chatId: chatId),
      ),
    );
  }
}
