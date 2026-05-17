import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:razorpaydemo/controller/payment_controller.dart';
import 'package:razorpaydemo/models/movie_model.dart';



class TicketScreen extends StatelessWidget {

  final MovieModel movie;

  const TicketScreen({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(movie.name),
      ),

      body: Consumer<PaymentController>(

        builder: (context, controller, child) {

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [

              Hero(
                tag: movie.name,

                child: Image.asset(
                  movie.image,
                  height: 250,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Price : ₹${movie.price}",
                style: const TextStyle(
                  fontSize: 24,
                ),
              ),

              const SizedBox(height: 30),

              controller.isLoading

                  ? const CircularProgressIndicator()

                  : ElevatedButton(

                onPressed: () {

                  controller.openPayment(
                    context: context,
                  );
                },

                child: const Text(
                  "Pay Now",
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}