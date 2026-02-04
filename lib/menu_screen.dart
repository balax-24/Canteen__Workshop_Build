import 'package:canteenpreorder/cart_provider.dart';
import 'package:canteenpreorder/food.dart';
import 'package:canteenpreorder/history_order_status_page.dart';
import 'package:canteenpreorder/ordering_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  // This list and its items must be `const`.
  final List<Food> foodItems = const [
    Food(name: 'Samosa', price: 10.00, imagePath: ''),
    Food(name: 'Vada Pav', price: 15.00, imagePath: ''),
    Food(name: 'Idli', price: 20.00, imagePath: ''),
    Food(name: 'Dosa', price: 30.00, imagePath: ''),
    Food(name: 'Poha', price: 25.00, imagePath: ''),
    Food(name: 'Chole Bhature', price: 40.00, imagePath: ''),
    Food(name: 'Paratha', price: 25.00, imagePath: ''),
    Food(name: 'Biryani', price: 60.00, imagePath: ''),
    Food(name: 'Noodles', price: 45.00, imagePath: ''),
    Food(name: 'Sandwich', price: 35.00, imagePath: ''),
    Food(name: 'Burger', price: 50.00, imagePath: ''),
    Food(name: 'Fries', price: 30.00, imagePath: ''),
    Food(name: 'Coffee', price: 15.00, imagePath: ''),
    Food(name: 'Tea', price: 10.00, imagePath: ''),
    Food(name: 'Juice', price: 20.00, imagePath: ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Canteen Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HistoryOrderStatusPage(),
                ),
              );
            },
          ),
          Consumer<CartProvider>(
            builder: (context, cart, child) => Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OrderingPage(),
                      ),
                    );
                  },
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.red,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        cart.itemCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: foodItems.length,
        itemBuilder: (context, index) {
          final food = foodItems[index];
          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: const Icon(Icons.fastfood, color: Colors.red), // Placeholder icon
              title: Text(food.name, style: const TextStyle(color: Colors.white)),
              subtitle: Text('\u20b9${food.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white70)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white, // This sets the text color
                ),
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false).addItem(food);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${food.name} added to cart'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text('Add'),
              ),
            ),
          );
        },
      ),
    );
  }
}
