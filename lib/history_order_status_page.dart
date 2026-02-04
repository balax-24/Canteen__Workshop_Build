import 'package:canteenpreorder/firestore_service.dart'; // This now contains LocalDataService
import 'package:flutter/material.dart';

class HistoryOrderStatusPage extends StatefulWidget {
  const HistoryOrderStatusPage({super.key});

  @override
  State<HistoryOrderStatusPage> createState() => _HistoryOrderStatusPageState();
}

class _HistoryOrderStatusPageState extends State<HistoryOrderStatusPage> {
  final LocalDataService _dataService = LocalDataService();
  late Future<List<Order>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _dataService.getOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = _dataService.getOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshOrders,
          ),
        ],
      ),
      body: FutureBuilder<List<Order>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.red));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('You have no order history.', style: TextStyle(color: Colors.white, fontSize: 18)));
          }

          final orders = snapshot.data!;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                color: Colors.grey[900],
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order ID: ${order.id.substring(0, 8)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...order.items.map((item) {
                        return Text('${item.food.name} x ${item.quantity}',
                            style: const TextStyle(color: Colors.white70));
                      }).toList(),
                      const SizedBox(height: 8),
                      Text('Total: \u20b9${order.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Status:', style: TextStyle(color: Colors.white, fontSize: 16)),
                          Text(
                            order.status.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
