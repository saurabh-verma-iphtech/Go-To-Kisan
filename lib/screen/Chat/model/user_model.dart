class ChatUser {
  final String id;
  final String name;
  final String email;
  final String userType; // Buyer or Seller
  final String address;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    required this.userType,
    required this.address,
  });

  factory ChatUser.fromMap(String id, Map<String, dynamic> map) {
    return ChatUser(
      id: id,
      name: map['name'],
      email: map['email'],
      userType: map['userType'],
      address: map['address'],
    );
  }
}
