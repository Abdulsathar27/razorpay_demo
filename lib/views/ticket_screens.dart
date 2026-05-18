import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpaydemo/controller/payment_controller.dart';

import '../models/movie_model.dart';

class TicketScreen extends StatelessWidget {
  final MovieModel movie;

  const TicketScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: Text(movie.name)),
      body: Consumer<PaymentController>(
        builder: (context, controller, child) {
          return TweenAnimationBuilder(
            duration: const Duration(seconds: 1),
            tween: Tween<double>(begin: 0, end: 1),
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: movie.name,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(movie.image, height: 350),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    movie.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ticket Price: Rs.${movie.price}',
                    style: const TextStyle(color: Colors.white70, fontSize: 22),
                  ),
                  const SizedBox(height: 40),
                  controller.isLoading
                      ? const CircularProgressIndicator()
                      : AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 15,
                            ),
                          ),
                          onPressed:
                              () => controller.openPayment(
                                context: context,
                                amountInRupees: movie.price,
                                itemName: movie.name,
                              ),
                          child: const Text(
                            'Book Ticket',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
