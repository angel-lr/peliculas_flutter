import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peliculas/models/movie.dart';
import 'package:peliculas/providers/movies_provider.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    final moviesProvider = context.watch<MoviesProvider>();
    // Obtenemos la calificación actual del usuario (0 si no ha calificado)
    final int myRating = moviesProvider.getUserRating(movie.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Appbar elástica con la imagen de fondo
          SliverAppBar(
            expandedHeight: 400,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    movie.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                        stops: [0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sección de Calificación
                    const Text('Tu Calificación:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          iconSize: 40,
                          icon: Icon(
                            // Si el índice es menor a la calificación, pintamos la estrella
                            index < myRating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            // Guardamos la calificación (index + 1 porque el índice empieza en 0)
                            moviesProvider.rateMovie(movie.id, index + 1);
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    
                    // Descripción
                    const Text('Sinopsis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Text(
                      movie.description.isNotEmpty ? movie.description : 'Sin descripción disponible.',
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                    
                    const SizedBox(height: 20),
                    // Info extra
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 5),
                        Text('Año: ${movie.year}'),
                        const Spacer(),
                        const Icon(Icons.star_rate_rounded, size: 20, color: Colors.grey),
                        Text('Global: ${movie.stars}'),
                      ],
                    )
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}