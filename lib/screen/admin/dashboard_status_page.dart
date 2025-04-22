import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardStatsPage extends StatelessWidget {
  Future<Map<String, int>> getCounts() async {
    final users = await FirebaseFirestore.instance.collection('users').get();
    final products = await FirebaseFirestore.instance.collection('products').get();

    final buyers = users.docs.where((u) => u['userRole'] == 'buyer').length;
    final sellers = users.docs.where((u) => u['userRole'] == 'seller').length;
    final admins = users.docs.where((u) => u['userRole'] == 'admin').length;

    return {
      'buyers': buyers,
      'sellers': sellers,
      'admins': admins,
      'products': products.docs.length,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, int>>(
      future: getCounts(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final data = snapshot.data!;
        return GridView.count(
          crossAxisCount: 2,
          children: [
            StatCard(label: 'Buyers', count: data['buyers']!),
            StatCard(label: 'Sellers', count: data['sellers']!),
            StatCard(label: 'Admins', count: data['admins']!),
            StatCard(label: 'Total Products', count: data['products']!),
          ],
        );
      },
    );
  }
}

class StatCard extends StatelessWidget {
  final String label;
  final int count;

  const StatCard({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Center(
        child: ListTile(
          title: Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('$count', style: TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}
