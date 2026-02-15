import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peliculas/providers/movies_provider.dart';

class MovieGrid extends StatelessWidget {
  final List<int> movieIds; // Recibe la lista de IDs a mostrar
  final bool isDownloadSection; // Para saber si mostramos icono de descarga o check

  const MovieGrid({
    super.key, 
    required this.movieIds, 
    this.isDownloadSection = false
  });

  @override
  Widget build(BuildContext context) {
    final moviesProvider = context.watch<MoviesProvider>();

    if (movieIds.isEmpty) {
      return const Center(child: Text('No hay películas aquí aún.'));
    }

    return OrientationBuilder(
      builder: (context, orientation) {
        final int gridColumns = (orientation == Orientation.portrait) ? 2 : 4;

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: movieIds.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridColumns,
            childAspectRatio: 0.65, // Un poco más alto para los botones
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final int movieId = movieIds[index];
            final isFavorite = moviesProvider.favorites.contains(movieId);
            final isDownloaded = moviesProvider.downloads.contains(movieId);

            return Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Fondo / Imagen simulada
                  Container(
                    color: Colors.grey[300],
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.movie, size: 50, color: Colors.grey),
                        Text('Película #$movieId'),
                      ],
                    ),
                  ),
                  
                  // Botón de Favorito (Arriba Derecha)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () => moviesProvider.toggleFavorite(movieId),
                    ),
                  ),

                  // Botón de Descarga (Abajo Derecha)
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: isDownloaded 
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : IconButton(
                          icon: const Icon(Icons.download_rounded),
                          onPressed: () {
                             // Mostramos un SnackBar para dar feedback visual
                             ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(content: Text('Descargando...'), duration: Duration(seconds: 1))
                             );
                             moviesProvider.simulateDownload(movieId);
                          },
                        ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}