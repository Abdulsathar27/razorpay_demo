import 'package:flutter/material.dart';
import 'package:razorpaydemo/models/movie_model.dart';
import 'package:razorpaydemo/views/movie_card.dart';



class HomeScreen extends StatelessWidget {

  HomeScreen({super.key});

  final MovieModel movie = MovieModel(
    name: "Avengers",
    image: "assets/images/movie.jpg",
    price: 500,
  );

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Movies"),
      ),

      body: Center(
        child: MovieCard(movie: movie),
      ),
    );
  }
}