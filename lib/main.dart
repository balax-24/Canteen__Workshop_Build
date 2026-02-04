import 'package:canteenpreorder/cart_provider.dart';
import 'package:canteenpreorder/landing_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Canteen Pre-Order',
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: Colors.red,
          scaffoldBackgroundColor: Colors.black,
          colorScheme: const ColorScheme.dark(
            primary: Colors.red,
            secondary: Colors.red,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.black,
            elevation: 0,
          ),
        ),
        home: const LandingPage(),
      ),
    );
  }
}
