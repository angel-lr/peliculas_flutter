import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peliculas/providers/movies_provider.dart';
import 'package:peliculas/widgets/movie_grid.dart'; // Importamos el widget nuevo

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Controla qué pestaña está activa

  @override
  Widget build(BuildContext context) {
    // Obtenemos el provider
    final moviesProvider = context.watch<MoviesProvider>();
    
    // Definimos las 3 vistas aquí
    final List<Widget> views = [
      // 1. Vista Home: Muestra TODAS las películas (casteamos a int)
      moviesProvider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : MovieGrid(movieIds: List<int>.from(moviesProvider.movies)),

      // 2. Vista Favoritos: Filtra solo favoritos
      MovieGrid(movieIds: moviesProvider.favorites),

      // 3. Vista Descargas: Filtra solo descargas
      MovieGrid(movieIds: moviesProvider.downloads, isDownloadSection: true),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle(_currentIndex)),
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

  String _getTitle(int index) {
    switch (index) {
      case 0: return 'Catálogo';
      case 1: return 'Mis Favoritos';
      case 2: return 'Descargas';
      default: return 'Películas';
    }
  }
}