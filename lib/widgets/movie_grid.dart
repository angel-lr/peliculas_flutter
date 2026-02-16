import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peliculas/providers/movies_provider.dart';
import 'package:peliculas/models/movie.dart';

class MovieGrid extends StatelessWidget {
  // Puede recibir la lista completa (Home) o una lista de IDs (Favoritos/Descargas)
  final List<Movie>? moviesList; 
  final List<int>? movieIds; 
  final bool isDownloadSection;

  const MovieGrid({
    super.key, 
    this.moviesList,
    this.movieIds,
    this.isDownloadSection = false
  });

  @override
  Widget build(BuildContext context) {
    // Escuchamos los cambios del Provider (favoritos, descargas, etc.)
    final moviesProvider = context.watch<MoviesProvider>();
    
    // 1. Lógica para filtrar qué películas mostrar
    List<Movie> moviesToShow = [];

    if (moviesList != null) {
      // Caso Home: mostramos la lista directa que viene de la API
      moviesToShow = moviesList!;
    } else if (movieIds != null) {
      // Caso Favoritos/Descargas: Filtramos de la lista global buscando por ID
      moviesToShow = moviesProvider.movies
          .where((movie) => movieIds!.contains(movie.id))
          .toList();
    }

    // 2. Estado Vacío (Si no hay pelis o favoritos)
    if (moviesToShow.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.movie_filter_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              isDownloadSection ? 'No hay descargas aún.' : 'No hay películas para mostrar.',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    // 3. Grid Adaptativo (OrientationBuilder)
    return OrientationBuilder(
      builder: (context, orientation) {
        // Vertical = 2 columnas, Horizontal = 4 columnas
        final int gridColumns = (orientation == Orientation.portrait) ? 2 : 4;

        return GridView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: moviesToShow.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridColumns,
            childAspectRatio: 0.65, // Relación ancho/alto (poster vertical)
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final movie = moviesToShow[index];
            
            // Verificamos si esta peli ya está en favoritos o descargada
            final isFavorite = moviesProvider.favorites.contains(movie.id);
            final isDownloaded = moviesProvider.downloads.contains(movie.id);

            return Card(
              elevation: 4,
              clipBehavior: Clip.antiAlias, // Corta la imagen si se sale de los bordes redondos
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // --- CAPA 1: IMAGEN ---
                  Image.network(
                    movie.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                    },
                    errorBuilder: (context, error, stackTrace) => 
                        const Center(child: Icon(Icons.broken_image, color: Colors.grey)),
                  ),
                  
                  // --- CAPA 2: DEGRADADO NEGRO (Para que el texto se lea) ---
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(8, 30, 8, 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            movie.title,
                            style: const TextStyle(
                              color: Colors.white, 
                              fontWeight: FontWeight.bold,
                              fontSize: 14
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          // Estrellas
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 14),
                              Text(
                                " ${movie.stars}",
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  // --- CAPA 3: BOTÓN FAVORITO (Arriba Derecha) ---
                  Positioned(
                    top: 5,
                    right: 5,
                    child: CircleAvatar(
                      backgroundColor: Colors.black54,
                      radius: 18,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.white,
                          size: 20,
                        ),
                        onPressed: () => moviesProvider.toggleFavorite(movie.id),
                      ),
                    ),
                  ),

                  // --- CAPA 4: BOTÓN DESCARGA (Arriba Izquierda) ---
                  Positioned(
                    top: 5,
                    left: 5,
                    child: isDownloaded 
                      ? const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 14,
                          child: Icon(Icons.check_circle, color: Colors.green, size: 28),
                        )
                      : CircleAvatar(
                          backgroundColor: Colors.black54,
                          radius: 18,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.download_rounded, color: Colors.white, size: 20),
                            onPressed: () async {
                               // 1. Feedback inmediato al usuario
                               ScaffoldMessenger.of(context).hideCurrentSnackBar();
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                   content: Text('Descargando "${movie.title}"...'),
                                   duration: const Duration(seconds: 1),
                                 )
                               );
                               
                               // 2. Llamada a la descarga real en el Provider
                               final success = await moviesProvider.downloadImage(
                                 movie.imageUrl, 
                                 movie.title, 
                                 movie.id
                               );

                               // 3. Notificar resultado final
                               if (context.mounted) {
                                 ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                 if (success) {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     const SnackBar(
                                       content: Text('¡Imagen guardada en Descargas!'),
                                       backgroundColor: Colors.green,
                                     )
                                   );
                                 } else {
                                   ScaffoldMessenger.of(context).showSnackBar(
                                     const SnackBar(
                                       content: Text('Error al guardar. Revisa permisos.'),
                                       backgroundColor: Colors.red,
                                     )
                                   );
                                 }
                               }
                            },
                          ),
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