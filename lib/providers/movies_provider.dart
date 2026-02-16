import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Usamos Dio para descargas avanzadas
import 'package:permission_handler/permission_handler.dart';
import 'package:peliculas/models/movie.dart';

class MoviesProvider extends ChangeNotifier {
  bool isLoading = false;
  List<Movie> movies = [];
  
  // Listas de IDs (Enteros para esta API)
  final List<int> _favorites = [];
  final List<int> _downloads = [];

  List<int> get favorites => _favorites;
  List<int> get downloads => _downloads;

  MoviesProvider() {
    getAllMovies();
  }

  // CARGA RÁPIDA (1 sola petición)
  Future<void> getAllMovies() async {
    isLoading = true;
    notifyListeners();
    
    try {
      // Usamos Dio también aquí por ser más robusto
      final response = await Dio().get('https://devsapihub.com/api-movies');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        movies = data.map((item) => Movie.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error cargando películas: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  void toggleFavorite(int id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
  }

  // LÓGICA DE DESCARGA REAL
  Future<bool> downloadImage(String url, String title, int id) async {
    try {
      // 1. Verificar Permisos (Solo necesario en Android < 13)
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      // Si el permiso se deniega permanentemente o falla, intentamos guardar igual
      // (En Android 13+ a veces no se necesita permiso para la carpeta pública Downloads)

      // 2. Definir la ruta: Carpeta pública de Descargas
      final String fileName = '${title.replaceAll(" ", "_")}_$id.jpg';
      final String savePath = '/storage/emulated/0/Download/$fileName';

      // 3. Descargar el archivo
      await Dio().download(url, savePath);
      
      // 4. Agregamos a la lista de "Descargados" visualmente
      if (!_downloads.contains(id)) {
        _downloads.add(id);
        notifyListeners();
      }
      return true; // Éxito

    } catch (e) {
      print('Error al descargar: $e');
      return false; // Falló
    }
  }
}