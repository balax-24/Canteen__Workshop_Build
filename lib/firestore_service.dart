import 'dart:convert';
import 'dart:io';

import 'package:canteenpreorder/cart_provider.dart';
import 'package:canteenpreorder/food.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

// Data model for an order
class Order {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime timestamp;
  String status;

  Order({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.timestamp,
    required this.status,
  });

  // Convert Order object to a Map for JSON encoding
  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items
            .map((item) => {
                  'food_name': item.food.name,
                  'food_price': item.food.price,
                  'quantity': item.quantity,
                })
            .toList(),
        'totalAmount': totalAmount,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
      };

  // Create an Order object from a Map (from JSON)
  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsFromJson = json['items'] as List;
    List<CartItem> cartItems = itemsFromJson.map((item) {
      return CartItem(
        food: Food(name: item['food_name'], price: item['food_price'], imagePath: ''),
        quantity: item['quantity'],
      );
    }).toList();

    return Order(
      id: json['id'],
      items: cartItems,
      totalAmount: json['totalAmount'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'],
    );
  }
}

// Service to handle all local JSON file operations
class LocalDataService {
  static const _fileName = 'orders.json';
  final Uuid _uuid = const Uuid();

  // Get the application's documents directory path
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // Get the local file reference
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  // Read all orders from the JSON file
  Future<List<Order>> _readOrders() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return []; // If the file doesn't exist, return an empty list
      }
      final contents = await file.readAsString();
      if (contents.isEmpty) {
        return []; // If the file is empty, return an empty list
      }
      final List<dynamic> json = jsonDecode(contents);
      return json.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      // If any error occurs, return an empty list
      print("Error reading orders: $e");
      return [];
    }
  }

  // Write a list of orders to the JSON file
  Future<void> _writeOrders(List<Order> orders) async {
    final file = await _localFile;
    final jsonList = orders.map((order) => order.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  // Add a new order to the JSON file
  Future<void> addOrder(List<CartItem> cartItems, double totalAmount) async {
    final orders = await _readOrders();
    final newOrder = Order(
      id: _uuid.v4(),
      items: cartItems,
      totalAmount: totalAmount,
      timestamp: DateTime.now(),
      status: 'pending',
    );
    orders.insert(0, newOrder); // Add new orders to the beginning of the list
    await _writeOrders(orders);
  }

  // Get all orders, sorted by timestamp
  Future<List<Order>> getOrders() async {
    final orders = await _readOrders();
    orders.sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Sort descending
    return orders;
  }

  // Update the status of a specific order
  Future<void> updateOrderStatus(String orderId, String status) async {
    final orders = await _readOrders();
    final orderIndex = orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      orders[orderIndex].status = status;
      await _writeOrders(orders);
    }
  }
}
