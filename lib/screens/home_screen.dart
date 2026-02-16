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
  int _currentIndex = 0; // Controla qué pestaña del navbar está activa

  @override
  Widget build(BuildContext context) {
    // CORRECCIÓN: Escuchamos a MoviesProvider (la lógica), no al Widget
    final moviesProvider = context.watch<MoviesProvider>();
    
    // Definimos las 3 vistas que se intercambiarán
    final List<Widget> views = [
      // VISTA 0: Inicio / Catálogo
      // Si está cargando, muestra spinner. Si no, muestra el Grid con los objetos Movie
      moviesProvider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : MovieGrid(moviesList: moviesProvider.movies),

      // VISTA 1: Favoritos
      // Pasamos solo la lista de IDs (Strings) que están en favoritos
      MovieGrid(movieIds: moviesProvider.favorites),

      // VISTA 2: Descargas
      // Pasamos los IDs de descarga y activamos la bandera isDownloadSection
      MovieGrid(movieIds: moviesProvider.downloads, isDownloadSection: true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_currentIndex)),
        centerTitle: true,
      ),
      // IndexedStack mantiene el estado de las vistas (no recarga al cambiar de tab)
      body: IndexedStack(
        index: _currentIndex,
        children: views,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download_done),
            label: 'Descargas',
          ),
        ],
      ),
    );
  }

  // Método auxiliar para cambiar el título del AppBar según la pestaña
  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Catálogo OMDb';
      case 1: return 'Mis Favoritos';
      case 2: return 'Descargas';
      default: return 'Películas';
    }
  }
}