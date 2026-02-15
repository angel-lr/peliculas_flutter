import 'package:flutter/material.dart';

class MoviesProvider extends ChangeNotifier {
  bool isLoading = false;
  List<dynamic> movies = []; // Por ahora son índices simulados
  
  // Listas para guardar los IDs de las películas
  final List<int> _favorites = [];
  final List<int> _downloads = [];

  List<int> get favorites => _favorites;
  List<int> get downloads => _downloads;

  MoviesProvider() {
    getOnDisplayMovies();
  }

  Future<void> getOnDisplayMovies() async {
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
    // Simulamos que cargamos 20 películas
    movies = List.generate(20, (index) => index);
    isLoading = false;
    notifyListeners();
  }

  // Lógica de Favoritos
  void toggleFavorite(int id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
  }

  // Simulación de descarga
  Future<void> simulateDownload(int id) async {
    // Si ya está descargada, no hacemos nada (o podrías borrarla)
    if (_downloads.contains(id)) return;

    // Aquí simularíamos la descarga real del archivo
    await Future.delayed(const Duration(seconds: 2)); // Simula tiempo de espera
    
    _downloads.add(id);
    notifyListeners();
  }
}