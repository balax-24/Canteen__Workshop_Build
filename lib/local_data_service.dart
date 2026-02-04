import 'dart:convert';
import 'dart:io';

import 'package:canteenpreorder/cart_provider.dart';
import 'package:canteenpreorder/food.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items
            .map((item) => {
                  'name': item.food.name,
                  'price': item.food.price,
                  'quantity': item.quantity,
                })
            .toList(),
        'totalAmount': totalAmount,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
      };

  factory Order.fromJson(Map<String, dynamic> json) {
    var itemsFromJson = json['items'] as List;
    List<CartItem> cartItems = itemsFromJson.map((item) {
      return CartItem(
          food: Food(name: item['name'], price: item['price'], imagePath: ''),
          quantity: item['quantity']);
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

class LocalDataService {
  static const _fileName = 'orders.json';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  Future<List<Order>> _readOrders() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> json = jsonDecode(contents);
      return json.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      print("Error reading orders: $e");
      return [];
    }
  }

  Future<void> _writeOrders(List<Order> orders) async {
    final file = await _localFile;
    final jsonList = orders.map((order) => order.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<void> addOrder(List<CartItem> cartItems, double totalAmount) async {
    final orders = await _readOrders();
    const uuid = Uuid();
    final newOrder = Order(
      id: uuid.v4(),
      items: cartItems,
      totalAmount: totalAmount,
      timestamp: DateTime.now(),
      status: 'pending',
    );
    orders.insert(0, newOrder); // Add to the top of the list
    await _writeOrders(orders);
  }

  Future<List<Order>> getOrders() async {
    return await _readOrders();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    final orders = await _readOrders();
    final orderIndex = orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      orders[orderIndex].status = status;
      await _writeOrders(orders);
    }
  }
}
