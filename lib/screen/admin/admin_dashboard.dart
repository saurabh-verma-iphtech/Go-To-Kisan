import 'package:flutter/material.dart';
import 'package:signup_login_page/screen/admin/product_mgt_page.dart';
import 'package:signup_login_page/screen/admin/user_mgt_page.dart';
import 'package:signup_login_page/screen/home.dart';

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int selectedIndex = 0;

  final pages = [
    UserManagementPage(),
    ProductManagementPage(),
  ];

  void logout(BuildContext context) {
    // Navigate to the Login screen and replace the AdminDashboard
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel")),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                if (index == 2) {
                  // Handle Log Out separately
                  logout(context);
                } else {
                  selectedIndex = index;
                }
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_bag),
                label: Text('Products'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.login_outlined, color: Colors.black),
                label: Text('Log Out'),
              ),
            ],
          ),
          Expanded(child: pages[selectedIndex]),
        ],
      ),
    );
  }
}
