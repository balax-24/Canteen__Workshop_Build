import 'package:canteenpreorder/firestore_service.dart'; // This now contains LocalDataService
import 'package:flutter/material.dart';

class SellerOrderStatusPage extends StatefulWidget {
  const SellerOrderStatusPage({super.key});

  @override
  State<SellerOrderStatusPage> createState() => _SellerOrderStatusPageState();
}

class _SellerOrderStatusPageState extends State<SellerOrderStatusPage> {
  final LocalDataService _dataService = LocalDataService();
  late Future<List<Order>> _ordersFuture;

  @override
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

  void _updateStatus(String orderId, String status) async {
    await _dataService.updateOrderStatus(orderId, status);
    _refreshOrders();
  }

  Widget _buildStatusDropdown(String orderId, String currentStatus) {
    return DropdownButton<String>(
      value: currentStatus,
      dropdownColor: Colors.grey[800],
      style: const TextStyle(color: Colors.white),
      items: <String>['pending', 'preparing', 'ready', 'completed']
          .map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          _updateStatus(orderId, newValue);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Orders'),
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
                child: Text('No orders yet.', style: TextStyle(color: Colors.white, fontSize: 18)));
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
                      Text('Order ID: ${order.id.substring(0, 8)}', // Shortened ID
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
                          _buildStatusDropdown(order.id, order.status),
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
