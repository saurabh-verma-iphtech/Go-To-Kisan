import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;

  /// Toggles the existence of the wishlist doc under
  /// users/{uid}/wishlist/{productId}
  static Future<void> toggleWishlist(String productId) async {
    final user = _auth.currentUser!;
    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .doc(productId);

    final snap = await docRef.get();
    if (snap.exists) {
      await docRef.delete();
      print('Removed $productId from wishlist of ${user.uid}');
    } else {
      await docRef.set({'addedAt': FieldValue.serverTimestamp()});
      print('Added $productId to wishlist of ${user.uid}');
    }
  }

  /// Returns true if users/{uid}/wishlist/{productId} exists
  static Future<bool> isInWishlist(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final snap =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('wishlist')
            .doc(productId)
            .get();
    return snap.exists;
  }

  /// Stream of productIds in the wishlist subcollection
  static Stream<List<String>> wishlistStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('wishlist')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  /// One‐time fetch of all productIds in wishlist
  static Future<List<String>> getWishlistProductIds() async {
    final user = _auth.currentUser!;
    final snap =
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('wishlist')
            .get();
    return snap.docs.map((d) => d.id).toList();
  }
}
