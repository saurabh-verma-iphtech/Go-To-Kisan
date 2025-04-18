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
import 'package:signup_login_page/screen/Buyer/wishlistPage.dart';
import 'package:signup_login_page/screen/Buyer/favouriteButton.dart';
import 'package:signup_login_page/screen/Buyer/buyerProfile.dart';
import 'package:signup_login_page/screen/Review%20System/reviewService.dart';
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
    'https://eg72s2n2avc.exactdn.com/wp-content/uploads/2022/09/sunset-and-wheat-field-wallpaper-hd-beautiful-desktop-background-hd-wallpapers-of-sunset-field-free-download.jpg',
    'https://images.livemint.com/rf/Image-621x414/LiveMint/Period2/2016/10/18/Photos/Processed/maha1-kvDH--621x414@LiveMint.JPG',
    'https://images.pexels.com/photos/96715/pexels-photo-96715.jpeg?cs=srgb&dl=pexels-alejandro-barron-21404-96715.jpg&fm=jpg',
    'https://thumbs.dreamstime.com/b/different-corn-plantation-524311.jpg',
    'https://pressinstitute.in/wp-content/uploads/2023/09/img-43.jpg',
  ];

  int cartItemCount = 0;

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
    // final h = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        title:
            Text(
              'go_to_kisan'.tr(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                // color: Colors.white,
              ),
            ).tr(),
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        actions: [
          badges.Badge(
            position: badges.BadgePosition.topEnd(top: -3, end: -18),
            badgeAnimation: badges.BadgeAnimation.fade(),
            badgeStyle: badges.BadgeStyle(
              badgeColor: Colors.transparent,
              padding: EdgeInsets.all(1),
              elevation: 0,
            ),
            badgeContent: Text(
              "news".tr(),
              // style: TextStyle(color: Colors.white),
            ),
            child: IconButton(
              icon: Icon(Icons.newspaper_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AgriNewsPage()),
                );
              },
            ),
          ),
          SizedBox(width: w / 35),
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
          //search icon
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
            ),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (val) {
              if (val == 'profile' &&
                  FirebaseAuth.instance.currentUser != null) {
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
              }
            },
            itemBuilder: (context) {
              List<PopupMenuEntry<String>> items = [];

              // If user is logged in
              if (FirebaseAuth.instance.currentUser != null) {
                items.addAll([
                  PopupMenuItem(value: 'profile', child: Text('profile'.tr())),
                  PopupMenuItem(value: 'logout', child: Text('logout'.tr())),
                ]);
              } else {
                items.addAll([
                  PopupMenuItem(value: 'Login', child: Text('login'.tr())),
                  PopupMenuItem(value: 'Signup', child: Text('signup'.tr())),
                ]);
              }

              // Add language selector as a non-selectable PopupMenuItem
              items.add(
                PopupMenuItem<String>(
                  enabled: false, // prevents it from being "selectable"
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<Locale>(
                      value: context.locale,
                      icon: const Icon(Icons.language),
                      dropdownColor: Colors.white,
                      onChanged: (Locale? locale) {
                        if (locale != null) {
                          context.setLocale(locale);
                          Navigator.pop(
                            context,
                          ); // close the popup after selection
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: Locale('en'),
                          child: Text('English'),
                        ),
                        DropdownMenuItem(
                          value: Locale('hi'),
                          child: Text('हिंदी'),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              return items;
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
                      .snapshots(),
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data?.docs ?? [];
                if (docs.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                final isSearching = _isSearching;
                final filtered =
                    docs.where((doc) {
                      if (!isSearching) return true;
                      final name = (doc['name'] ?? '').toString().toLowerCase();
                      final desc =
                          (doc['description'] ?? '').toString().toLowerCase();
                      final q = searchQuery.toLowerCase();
                      return name.contains(q) || desc.contains(q);
                    }).toList();

                if (isSearching && filtered.isEmpty) {
                  return const Center(child: Text('No matching grains found'));
                }

                // FULL HOME: carousel + welcome + grid
                if (!isSearching) {
                  return Column(
                    children: [
                      // --- Full-width Carousel ---
                      SizedBox(
                        width: double.infinity,
                        height: w > 600 ? 300 : 200,
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
                                      child: Image.network(
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

                      // --- Grid of all products ---
                      Expanded(child: _buildGrid(filtered)),
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
    final w = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount:
              w > 1000
                  ? 4
                  : w > 600
                  ? 3
                  : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: w < 400 ? 0.55 : 0.7,
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
  });

  @override
  Widget build(BuildContext ctx) {
    final w = MediaQuery.of(ctx).size.width;
    final h = MediaQuery.of(ctx).size.height;

    if (images.isNotEmpty) {
    } else if (product['imageUrl'] != null) {
    } else {}

    // Calculate a responsive image height:
    final imageHeight = w > 600 ? 160.0 : 120.0;

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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        // Give the card a fixed aspect ratio so it shrinks/grows nicely:
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Image + Favorite overlay
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: imageHeight,
                    child:
                        images.isNotEmpty
                            ? CarouselSlider(
                              options: CarouselOptions(
                                height: imageHeight,
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
                                  height: imageHeight,
                                )
                                : Container(
                                  width: double.infinity,
                                  height: imageHeight,
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

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name + location row
                    Row(
                      children: [
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              // Get current language code
                              final locale = context.locale.languageCode;

                              // Get the base key for translation
                              final rawName =
                                  (product['name'] ?? 'unknown')
                                      .toString()
                                      .toLowerCase()
                                      .trim();
                              String translated = rawName.tr();

                              // Capitalize only if locale is English
                              if (locale == 'en' && translated.isNotEmpty) {
                                translated =
                                    translated[0].toUpperCase() +
                                    translated.substring(1);
                              }

                              return Text(
                                translated,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.blue,
                        ),
                        Text(
                          address.length > 12
                              ? '${address.substring(0, 12)}…'
                              : address,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${product['price'] ?? '0'} / ${product['unit']}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        // Add average rating display
                        FutureBuilder<double>(
                          future: ReviewService.getAverageRating(
                            productId,
                          ), // Use the service method
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text("Rating: ...");
                            }
                            if (snapshot.hasError) {
                              return const Text("Rating: N/A");
                            }

                            final rating = snapshot.data ?? 0.0;
                            return Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.green,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(rating.toStringAsFixed(1)),
                              ],
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Text(
                      (product['description'] ?? '').toString().substring(
                            0,
                            min(40, (product['description'] ?? '').length),
                          ) +
                          ((product['description'] ?? '').length > 40
                              ? '…'
                              : ''),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10),
                    ),

                    const Spacer(),

                    // Communication buttons in a row
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (FirebaseAuth.instance.currentUser == null) {
                                Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                    builder: (_) => const Login(),
                                  ),
                                );
                              } else {
                                launchWhatsApp(ctx, phone);
                              }
                            },
                            child: Image.asset(
                              'assets/whatsapp.png',
                              height: h / 31,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (FirebaseAuth.instance.currentUser == null) {
                                Navigator.push(
                                  ctx,
                                  MaterialPageRoute(
                                    builder: (_) => const Login(),
                                  ),
                                );
                              } else {
                                launchSMS(ctx, phone);
                              }
                            },
                            child: Icon(
                              Icons.sms,
                              size: h / 28,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
