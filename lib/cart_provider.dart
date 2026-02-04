import 'package:canteenpreorder/food.dart';
import 'package:flutter/material.dart';

class CartItem {
  final Food food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.food.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(Food food) {
    if (_items.containsKey(food.name)) {
      _items.update(
        food.name,
        (existingCartItem) => CartItem(
          food: existingCartItem.food,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        food.name,
        () => CartItem(
          food: food,
        ),
      );
    }
    notifyListeners();
  }

  void removeSingleItem(String foodName) {
    if (!_items.containsKey(foodName)) {
      return;
    }
    if (_items[foodName]!.quantity > 1) {
      _items.update(
          foodName,
          (existingCartItem) => CartItem(
              food: existingCartItem.food,
              quantity: existingCartItem.quantity - 1));
    } else {
      _items.remove(foodName);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
