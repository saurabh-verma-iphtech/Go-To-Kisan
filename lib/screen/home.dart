import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signup_login_page/screen/Buyer/productDetailsPage.dart';
import 'package:signup_login_page/screen/Buyer/profile.dart';
import 'package:signup_login_page/screen/login.dart';
import 'package:signup_login_page/screen/signup.dart';
import 'package:signup_login_page/services/MicSpeakerCode.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:signup_login_page/screen/home.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> imageList = [
    'https://eg72s2n2avc.exactdn.com/wp-content/uploads/2022/09/sunset-and-wheat-field-wallpaper-hd-beautiful-desktop-background-hd-wallpapers-of-sunset-field-free-download.jpg',
    'https://images.livemint.com/rf/Image-621x414/LiveMint/Period2/2016/10/18/Photos/Processed/maha1-kvDH--621x414@LiveMint.JPG',
    'https://images.pexels.com/photos/96715/pexels-photo-96715.jpeg?cs=srgb&dl=pexels-alejandro-barron-21404-96715.jpg&fm=jpg',
    'https://thumbs.dreamstime.com/b/different-corn-plantation-524311.jpg',
    'https://pressinstitute.in/wp-content/uploads/2023/09/img-43.jpg',
  ];

  // *******************************************************************
  TextEditingController _searchController = TextEditingController();
  String searchQuery = '';
  Timer? _debounce;

  // late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceInput = '';
  stt.SpeechToText _speech = stt.SpeechToText();
  String _localeId = 'en_IN'; // default fallback

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    bool available = await _speech.initialize();

    if (available) {
      // Fetch supported locales
      List<stt.LocaleName> locales = await _speech.locales();

      // Get system locale
      final systemLocale = await _speech.systemLocale();

      // Find a matching locale from the supported list
      _localeId = systemLocale?.localeId ?? 'en_IN';

      print('🌍 Using locale: $_localeId');
    }
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('Speech status: $status'),
      onError: (error) => print('Speech error: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        localeId: _localeId,
        onResult: (result) {
          setState(() {
            _voiceInput = result.recognizedWords;
            _searchController.text = _voiceInput;
            searchQuery = _voiceInput;
          });
        },
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // *******************************************************************

  // To get Seller Address
  Future<Map<String, String>> getSellerContactDetails(String sellerId) async {
    DocumentSnapshot sellerSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(sellerId)
            .get();

    if (sellerSnapshot.exists) {
      final data = sellerSnapshot.data() as Map<String, dynamic>;
      return {
        'address': data['address'] ?? 'No Address',
        'phoneNumber': data['phoneNumber'] ?? '',
      };
    }
    return {'address': 'No Address', 'phoneNumber': ''};
  }



  String formatPhoneForWhatsapp(String rawPhone) {
    final phone = rawPhone.trim().replaceAll(RegExp(r'\D'), '');
    if (phone.length == 10) {
      return '91$phone'; // Assuming India country code
    }
    return phone; // Return as-is if not 10 digits
  }


  // Function to launch WhatsApp
 Future<void> _launchWhatsApp(String rawPhone) async {
    if (rawPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }

    final phoneNumber = formatPhoneForWhatsapp(rawPhone);
    final Uri whatsappUri = Uri.parse("https://wa.me/$phoneNumber");

    print('Launching WhatsApp with: $whatsappUri');

    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch WhatsApp')),
      );
    }
  }


String formatPhoneForSMS(String phone) {
    phone = phone.replaceAll(RegExp(r'[^\d]'), ''); // remove any symbols/spaces
    if (!phone.startsWith('91')) {
      phone = '91$phone';
    }
    return phone;
  }

  Future<void> _launchSMS(String rawPhone) async {
    final phoneNumber = formatPhoneForSMS(rawPhone); // see below

    final Uri smsUri = Uri.parse("sms:$phoneNumber");

    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not launch SMS')));
    }
  }


  Future<void> _startChat(BuildContext context, String sellerId) async {
    if (FirebaseAuth.instance.currentUser == null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    var time = DateTime.now();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final imageHeight =
        screenWidth > 1000
            ? 280
            : screenWidth > 600
            ? 220
            : 180;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Go To Kisan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 47, 138, 47),
        actions: [
          FirebaseAuth.instance.currentUser != null
              ? PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'profile') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BuyerDashboard()),
                    );
                  } else if (value == 'logout') {
                    FirebaseAuth.instance.signOut();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged out successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => HomePage()),
                    );
                  }
                },
                icon: const Icon(Icons.menu),
                itemBuilder:
                    (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'profile',
                        child: Text('Profile'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('Logout'),
                      ),
                    ],
              )
              : PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == "Login") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  } else if (value == "Signup") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Signup()),
                    );
                  }
                },
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(value: "Login", child: Text("Login")),
                      const PopupMenuItem(
                        value: "Signup",
                        child: Text("Signup"),
                      ),
                    ],
              ),
        ],
      ),
      body: Column(
        children: [
          // Top banner carousel
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: screenWidth > 600 ? 300 : 200,
            child: CarouselSlider(
              options: CarouselOptions(
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 5),
                aspectRatio: 16 / 9,
                viewportFraction: 1.0,
                enlargeCenterPage: true,
                scrollPhysics: const BouncingScrollPhysics(),
              ),
              items:
                  imageList.map((image) {
                    return ClipRRect(
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: screenWidth > 600 ? 300 : 200,
                      ),
                    );
                  }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(
                  "Welcome to Go To Kisan - Your one-stop solution for buying & selling agricultural products!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth > 600 ? 18 : 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Card(
                  elevation: 3,
                  shadowColor: Colors.green,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder<String>(
                      stream: Stream.periodic(const Duration(seconds: 1), (_) {
                        return DateFormat(
                          'd MMMM y | hh:MM:ss a',
                        ).format(DateTime.now());
                      }),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return const CircularProgressIndicator();
                        return Text(
                          snapshot.data!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search grains (in Hindi or English)...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: MicSpeakerWidget(
                  onListeningStart: () {
                    setState(() {
                      _isListening = true;
                    });
                  },
                  onListeningStop: () {
                    setState(() {
                      _isListening = false;
                    });
                  },
                ),

                // Add the MicSpeakerWidget here
              ),
              onChanged: (value) {
                if (_debounce?.isActive ?? false) _debounce!.cancel();

                _debounce = Timer(const Duration(milliseconds: 300), () {
                  setState(() {
                    searchQuery = value;
                  });
                });
              },
            ),
          ),

          // Always display products regardless of login status
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('products')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading products'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                var allProducts = snapshot.data!.docs;

                // Filter products based on search query (supports Hindi and English)
                bool wordStartsWith(String text, String query) {
                  return text
                      .split(RegExp(r'\s+')) // split by spaces
                      .any((word) => word.startsWith(query));
                }

                var products =
                    allProducts.where((doc) {
                      final name = (doc['name'] ?? '').toString().toLowerCase();
                      final desc =
                          (doc['description'] ?? '').toString().toLowerCase();
                      final query = searchQuery.toLowerCase().trim();

                      if (query.isEmpty)
                        return true; // show all if search is empty

                      return wordStartsWith(name, query) ||
                          wordStartsWith(desc, query);
                    }).toList();

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(5),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          screenWidth > 1000
                              ? 4
                              : screenWidth > 600
                              ? 3
                              : 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio:
                          screenWidth < 400
                              ? 0.55
                              : 0.64, // Adjust for vertical space
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      var product =
                          products[index].data() as Map<String, dynamic>;
                      List<dynamic> imageUrls = product['imageUrls'] ?? [];
                      return FutureBuilder<Map<String, String>>(
                        future: getSellerContactDetails(product['sellerId']),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          final sellerDetails = snapshot.data!;
                          String address = sellerDetails['address']!;
                          String phone = sellerDetails['phoneNumber']!;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => ProductDetailsPage(
                                        productData: product,
                                      ),
                                ),
                              );
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Image carousel or fallback image
                                  if (imageUrls.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      child: SizedBox(
                                        height: screenWidth > 600 ? 160 : 120,
                                        width: double.infinity,
                                        child: CarouselSlider(
                                          options: CarouselOptions(
                                            height:
                                                screenWidth > 600 ? 160 : 120,
                                            autoPlay: true,
                                            viewportFraction: 1.0,
                                            enlargeCenterPage: false,
                                          ),
                                          items:
                                              imageUrls.map((url) {
                                                return Image.network(
                                                  url,
                                                  fit: BoxFit.fill,
                                                  width: double.infinity,
                                                );
                                              }).toList(),
                                        ),
                                      ),
                                    )
                                  else if (product['imageUrl'] != null)
                                    ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        product['imageUrl'],
                                        width: double.infinity,
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else
                                    const SizedBox(
                                      height: 120,
                                      child: Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 40,
                                        ),
                                      ),
                                    ),
                                  // Product details and communication buttons
                                  Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Product Name and Seller Address
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                product['name'] ?? 'No Name',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              address.length > 10
                                                  ? '${address.substring(0, 10)}...'
                                                  : address,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        // Price
                                        Text(
                                          '₹${product['price'] ?? '0'} / ${product['unit']}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Description
                                        Text(
                                          (product['description'] ?? '')
                                                      .toString()
                                                      .length >
                                                  40
                                              ? '${(product['description'] ?? '').toString().substring(0, 40)}...'
                                              : product['description'] ?? '',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        const SizedBox(height: 20),
                                        // Communication Buttons
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              // WhatsApp Button
                                              GestureDetector(
                                                onTap: () {
                                                  if (FirebaseAuth
                                                          .instance
                                                          .currentUser ==
                                                      null) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                Login(),
                                                      ),
                                                    );
                                                  } else {
                                                    _launchWhatsApp(phone);
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
                                                  child: Image.asset(
                                                    'assets/whatsapp.png',
                                                    height: screenHeight / 33,
                                                  ),
                                                ),
                                              ),
                                              // SMS Button
                                              GestureDetector(
                                                onTap: () {
                                                  if (FirebaseAuth
                                                          .instance
                                                          .currentUser ==
                                                      null) {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder:
                                                            (context) =>
                                                                Login(),
                                                      ),
                                                    );
                                                  } else {
                                                    _launchSMS(phone);
                                                  }
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    4.0,
                                                  ),
                                                  // child: Image.asset('assets/talk.png',height: screenHeight/30,),
                                                  child: Icon(
                                                    Icons.sms,
                                                    color: Colors.green,
                                                    size: screenHeight / 30,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
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
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
