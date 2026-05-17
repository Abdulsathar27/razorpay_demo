import 'package:flutter/material.dart';
import 'package:razorpaydemo/models/movie_model.dart';



class MovieCard extends StatelessWidget {

  final MovieModel movie;

  const MovieCard({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(

      onTap: () {

        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (_) => TicketScreen(movie: movie),
        //   ),
        // );
      },

      child: Hero(
        tag: movie.name,

        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              Image.asset(
                movie.image,
                height: 250,
                width: 200,
                fit: BoxFit.cover,
              ),

              const SizedBox(height: 10),

              Text(
                movie.name,
                style: const TextStyle(
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}