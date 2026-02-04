import 'package:canteenpreorder/cart_provider.dart';
import 'package:canteenpreorder/firestore_service.dart'; // This now contains LocalDataService
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OrderingPage extends StatelessWidget {
  const OrderingPage({super.key});

  void _showPaymentDialog(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final dataService = LocalDataService();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Choose Payment Method', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pay with UPI',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 10),
            // Assuming you add a qr_code.png in an assets folder
            // Image.asset('assets/qr_code.png', height: 150, width: 150),
            const SizedBox(height: 10),
            const Text(
              'balaharish0202-2@okhdfcbank',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.red),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white, // FIX: This makes the text white
              ),
              onPressed: () {
                dataService.addOrder(cart.items.values.toList(), cart.totalAmount);
                Navigator.of(ctx).pop(); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order Placed Successfully!')),
                );
                cart.clear();
                Navigator.of(context).pop(); // Go back to the menu screen
              },
              child: const Text('Cash on Delivery'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Close', style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Order'),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(
                    child: Text(
                      'Your cart is empty.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    itemCount: cart.items.length,
                    itemBuilder: (ctx, i) {
                      final cartItem = cart.items.values.toList()[i];
                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 4,
                          ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(cartItem.food.name, style: const TextStyle(color: Colors.white)),
                            subtitle: Text(
                              'Total: \u20b9${(cartItem.food.price * cartItem.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, color: Colors.red),
                                  onPressed: () {
                                    cart.removeSingleItem(cartItem.food.name);
                                  },
                                ),
                                Text('${cartItem.quantity}', style: const TextStyle(color: Colors.white)),
                                IconButton(
                                  icon: const Icon(Icons.add, color: Colors.green),
                                  onPressed: () {
                                    cart.addItem(cartItem.food);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(color: Colors.red),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                Text(
                  '\u20b9${cart.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 24.0, left: 16.0, right: 16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white, // FIX: This makes the text white
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                onPressed: cart.totalAmount <= 0
                    ? null
                    : () {
                        _showPaymentDialog(context);
                      },
                child: const Text(
                  'PROCEED TO PAYMENT',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
