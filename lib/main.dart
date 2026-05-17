import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpaydemo/views/home_screens.dart';

import 'controller/payment_controller.dart';

void main() {

  runApp(

    ChangeNotifierProvider(

      create: (_) => PaymentController(),

      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      home: HomeScreen(),
    );
  }
}