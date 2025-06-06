// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:signup_login_page/screen/admin/user_details_page.dart';

// import '../Buyer/buyerLogicHandler.dart';

// class UserManagementPage extends StatefulWidget {
//   @override
//   _UserManagementPageState createState() => _UserManagementPageState();
// }

// class _UserManagementPageState extends State<UserManagementPage> {
//   String selectedRole = 'All';
//   String searchQuery = '';

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // 🔽 Filter & Search
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             children: [
//               // Role Filter
//               Text('Filter by Role: ', style: TextStyle(fontWeight: FontWeight.bold)),
//               SizedBox(width: 10),
//               DropdownButton<String>(
//                 value: selectedRole,
//                 items: ['All', 'Buyer', 'Seller']
//                     .map((role) => DropdownMenuItem(
//                   value: role,
//                   child: Text(role),
//                 ))
//                     .toList(),
//                 onChanged: (value) {
//                   if (value != null) {
//                     setState(() => selectedRole = value);
//                   }
//                 },
//               ),
//               SizedBox(width: 20),
//               // Search Input
//               Expanded(
//                 child: TextField(
//                   decoration: InputDecoration(
//                     hintText: "Search by name or email...",
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.search),
//                   ),
//                   onChanged: (value) {
//                     setState(() => searchQuery = value.toLowerCase());
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // 📋 User List
//         Expanded(
//           child: StreamBuilder<QuerySnapshot>(
//             stream: FirebaseFirestore.instance
//                 .collection('users')
//                 .orderBy('name')
//                 .snapshots(),
//             builder: (context, snapshot) {
//               if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

//               final filteredUsers = snapshot.data!.docs.where((doc) {
//                 final data = doc.data() as Map<String, dynamic>;
//                 final name = data['name']?.toString().toLowerCase() ?? '';
//                 final email = data['email']?.toString().toLowerCase() ?? '';
//                 final userType = data['userType'] ?? '';

//                 final matchesRole = selectedRole == 'All' || userType == selectedRole;
//                 final matchesSearch =
//                     searchQuery.isEmpty || name.contains(searchQuery) || email.contains(searchQuery);

//                 return matchesRole && matchesSearch;
//               }).toList();

//               if (filteredUsers.isEmpty) {
//                 return Center(child: Text("No users match the filter/search."));
//               }

//               return ListView.builder(
//                 itemCount: filteredUsers.length,
//                 itemBuilder: (context, index) {
//                   final doc = filteredUsers[index];
//                   final user = doc.data() as Map<String, dynamic>;
//                   final userId = doc.id;

//                   return Card(
//                     margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                     child: ListTile(
//                       leading: CircleAvatar(
//                         backgroundImage: user['profileImage'] != null
//                             ? NetworkImage(user['profileImage'])
//                             : null,
//                         child: user['profileImage'] == null ? Icon(Icons.person) : null,
//                       ),
//                       title: Text(user['name'] ?? 'No Name'),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(user['email'] ?? ''),
//                           SizedBox(height: 4),
//                           _buildUserTypeBadge(user['userType']),
//                         ],
//                       ),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           // Communication buttons in a row
//                           Padding(
//                             padding: const EdgeInsets.all(10.0),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceAround,
//                               children: [
//                                 GestureDetector(
//                                   onTap: () {
//                                       launchWhatsApp(context, user['phoneNumber']);
//                                   },
//                                   child: Image.asset(
//                                     'assets/whatsapp.png',
//                                     height:28,
//                                   ),
//                                 ),
//                                 SizedBox(width: 15,),
//                                 GestureDetector(
//                                   onTap: () {
//                                       launchSMS(context, user['phoneNumber']);
//                                   },
//                                   child: Icon(
//                                     Icons.sms,
//                                     size:28,
//                                     color: Colors.green,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.delete, color: Colors.red),
//                             onPressed: () => _confirmDeleteUser(context, userId),
//                           ),
//                         ],
//                       ),
//                       onTap: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => UserDetailPage(userId: userId),
//                           ),
//                         );
//                       },
//                     ),
//                   );
//                 },
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildUserTypeBadge(String? role) {
//     Color color;
//     String text;

//     switch (role) {
//       case 'Seller':
//         color = Colors.orange;
//         text = 'Seller';
//         break;
//       case 'Buyer':
//         color = Colors.green;
//         text = 'Buyer';
//         break;
//       default:
//         color = Colors.grey;
//         text = 'Unknown';
//     }

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(color: color, fontWeight: FontWeight.bold),
//       ),
//     );
//   }

//   void _confirmDeleteUser(BuildContext context, String userId) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text("Delete User"),
//         content: Text("Are you sure you want to permanently delete this user?"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () => Navigator.pop(context, true),
//             child: Text("Delete"),
//           ),
//         ],
//       ),
//     );

//     if (confirm == true) {
//       await FirebaseFirestore.instance.collection('users').doc(userId).delete();
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("User deleted")),
//       );
//     }
//   }
// }


import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:signup_login_page/screen/admin/user_details_page.dart';

import '../Buyer/buyerLogicHandler.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  String selectedRole = 'All';
  String searchQuery = '';

  // ─── Pagination State ─────────────────────────────────────────────────────
  static const int _pageSize = 10;
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔽 Filter & Search
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Role Filter
              Text(
                'Filter by Role: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              DropdownButton<String>(
                value: selectedRole,
                items:
                    ['All', 'Buyer', 'Seller']
                        .map(
                          (role) =>
                              DropdownMenuItem(value: role, child: Text(role)),
                        )
                        .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedRole = value;
                      _currentPage = 0; // reset to first page
                    });
                  }
                },
              ),
              SizedBox(width: 20),
              // Search Input
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search by name or email...",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                      _currentPage = 0; // reset to first page
                    });
                  },
                ),
              ),
            ],
          ),
        ),

        // 📋 User List + Pagination Controls
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('name')
                    .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());

              // 1) Filter
              final allFiltered =
                  snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    final email =
                        (data['email'] ?? '').toString().toLowerCase();
                    final userType = data['userType'] ?? '';

                    final matchesRole =
                        selectedRole == 'All' || userType == selectedRole;
                    final matchesSearch =
                        searchQuery.isEmpty ||
                        name.contains(searchQuery) ||
                        email.contains(searchQuery);

                    return matchesRole && matchesSearch;
                  }).toList();

              if (allFiltered.isEmpty) {
                return Center(child: Text("No users match the filter/search."));
              }

              // 2) Pagination calculations
              final totalItems = allFiltered.length;
              final totalPages = (totalItems / _pageSize).ceil();
              final start = _currentPage * _pageSize;
              final end = min(start + _pageSize, totalItems);
              final pageUsers = allFiltered.sublist(start, end);

              return Column(
                children: [
                  // 3) Current page list
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: pageUsers.length,
                      itemBuilder: (context, index) {
                        final doc = pageUsers[index];
                        final user = doc.data() as Map<String, dynamic>;
                        final userId = doc.id;

                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  user['profileImage'] != null
                                      ? NetworkImage(user['profileImage'])
                                      : null,
                              child:
                                  user['profileImage'] == null
                                      ? Icon(Icons.person)
                                      : null,
                            ),
                            title: Text(user['name'] ?? 'No Name'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(user['email'] ?? '',overflow: TextOverflow.ellipsis,),
                                SizedBox(height: 4),
                                _buildUserTypeBadge(user['userType']),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Communication buttons
                                GestureDetector(
                                  onTap:
                                      () => launchWhatsApp(
                                        context,
                                        user['phoneNumber'],
                                      ),
                                  child: Image.asset(
                                    'assets/whatsapp.png',
                                    height: 28,
                                  ),
                                ),
                                SizedBox(width: 15),
                                GestureDetector(
                                  onTap:
                                      () => launchSMS(
                                        context,
                                        user['phoneNumber'],
                                      ),
                                  child: Icon(
                                    Icons.sms,
                                    size: 28,
                                    color: Colors.green,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed:
                                      () => _confirmDeleteUser(context, userId),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => UserDetailPage(userId: userId),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // 4) Pager below the list, inside safe area
                  if (totalPages > 1)
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed:
                                  _currentPage > 0
                                      ? () => setState(() => _currentPage--)
                                      : null,
                            ),
                            Text('Page ${_currentPage + 1} of $totalPages'),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
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
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUserTypeBadge(String? role) {
    Color color;
    String text;
    switch (role) {
      case 'Seller':
        color = Colors.orange;
        text = 'Seller';
        break;
      case 'Buyer':
        color = Colors.green;
        text = 'Buyer';
        break;
      default:
        color = Colors.grey;
        text = 'Unknown';
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Delete User"),
            content: Text(
              "Are you sure you want to permanently delete this user?",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: Text("Delete"),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("User deleted")));
    }
  }
}
