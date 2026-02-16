import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peliculas/providers/movies_provider.dart';
import 'package:peliculas/widgets/movie_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final moviesProvider = context.watch<MoviesProvider>();
    
    // Obtenemos la lista calificada y ordenada para la 4ta pestaña
    final ratedMovies = moviesProvider.getRatedMovies();

    final List<Widget> views = [
      // 0. Catálogo
      moviesProvider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : MovieGrid(moviesList: moviesProvider.movies),
      // 1. Favoritos
      MovieGrid(movieIds: moviesProvider.favorites),
      // 2. Descargas
      MovieGrid(movieIds: moviesProvider.downloads, isDownloadSection: true),
      // 3. NUEVA PESTAÑA: Mis Calificaciones
      MovieGrid(moviesList: ratedMovies),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_currentIndex)),
        centerTitle: true,
        actions: [
          // Solo mostramos el botón de filtro si estamos en la pestaña de "Calificaciones" (Índice 3)
          if (_currentIndex == 3)
            IconButton(
              icon: Icon(Icons.sort_by_alpha), // Icono de orden
              tooltip: 'Cambiar orden (Asc/Desc)',
              onPressed: () {
                moviesProvider.toggleSortOrder();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Orden actualizado'), duration: Duration(milliseconds: 500)),
                );
              },
            )
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: views,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Necesario cuando hay mas de 3 items para que no se pongan blancos
        currentIndex: _currentIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
          BottomNavigationBarItem(icon: Icon(Icons.download_done), label: 'Descargas'),
          // Nuevo item
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Calificadas'),
        ],
      ),
    );
  }

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Catálogo OMDb';
      case 1: return 'Mis Favoritos';
      case 2: return 'Descargas';
      case 3: return 'Mis Reseñas'; // Título nuevo
      default: return 'Películas';
    }
  }
}