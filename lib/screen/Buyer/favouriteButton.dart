import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:signup_login_page/services/wishlistService.dart';

class FavoriteButton extends StatelessWidget {
  final String productId;
  const FavoriteButton({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return SizedBox();
    }
    final userId = user.uid;
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(productId);

    return StreamBuilder<DocumentSnapshot>(
      stream: docRef.snapshots(),
      builder: (ctx, snap) {
        // If no data yet, show a grey heart placeholder:
        if (snap.connectionState == ConnectionState.waiting) {
          return const Icon(Icons.favorite_border, color: Colors.grey);
        }

        final isFav = snap.hasData && snap.data!.exists;
        return GestureDetector(
          onTap: () async {
            // Toggle the wishlist entry:
            await WishlistService.toggleWishlist(productId);
          },
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder:
                (child, anim) => ScaleTransition(
                  scale: anim,
                  child: FadeTransition(opacity: anim, child: child),
                ),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFav),
              color: isFav ? Colors.red : Colors.grey,
              size: 18,
            ),
          ),
        );
      },
    );
  }
}
