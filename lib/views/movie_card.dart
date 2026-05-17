import 'package:flutter/material.dart';
import 'package:razorpaydemo/views/ticket_screens.dart';

import '../models/movie_model.dart';


class MovieCard extends StatelessWidget {

  final MovieModel movie;

  const MovieCard({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {

    return TweenAnimationBuilder(

      duration: const Duration(seconds: 2),

      tween: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ),

      curve: Curves.easeInOut,

      builder: (context, value, child) {

        return Transform.scale(
          scale: value,
          child: child,
        );
      },

      child: GestureDetector(

        onTap: () {

          Navigator.push(

            context,

            MaterialPageRoute(

              builder: (_) => TicketScreen(
                movie: movie,
              ),
            ),
          );
        },

        child: Hero(

          tag: movie.name,

          child: Container(

            width: 220,

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(20),

              boxShadow: [

                BoxShadow(

                  color: Colors.black.withValues(alpha: 0.2),

                  blurRadius: 10,

                  offset: const Offset(0, 5),
                ),
              ],
            ),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [

                ClipRRect(

                  borderRadius: const BorderRadius.only(

                    topLeft: Radius.circular(20),

                    topRight: Radius.circular(20),
                  ),

                  child: Image.asset(

                    movie.image,

                    height: 320,

                    width: 220,

                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 15),

                Text(

                  movie.name,

                  style: const TextStyle(

                    fontSize: 28,

                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}