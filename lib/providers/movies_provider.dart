import 'dart:io'; // Para manejar archivos (File)
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; // Peticiones HTTP rápidas
import 'package:path_provider/path_provider.dart'; // Directorios temporales
import 'package:gal/gal.dart'; // Guardar en Galería
import 'package:peliculas/models/movie.dart'; // Tu modelo

class MoviesProvider extends ChangeNotifier {
  // Estado de carga
  bool isLoading = false;
  
  // Lista principal de películas (Catálogo)
  List<Movie> movies = [];
  
  // Listas de IDs para gestión local
  final List<int> _favorites = [];
  final List<int> _downloads = []; // IDs de pelis descargadas
  
  // Mapa para guardar calificaciones: ID Película -> Estrellas (1-5)
  final Map<int, int> _myRatings = {};

  // Variable para controlar el orden de las calificaciones
  bool _sortAscending = false; // false = De Mayor a Menor (5 -> 1)

  // Getters para acceder a las listas privadas desde fuera
  List<int> get favorites => _favorites;
  List<int> get downloads => _downloads;

  // Constructor: Inicia la carga apenas se crea el Provider
  MoviesProvider() {
    getAllMovies();
  }

  // --- 1. CARGA DE PELÍCULAS (API) ---
  Future<void> getAllMovies() async {
    isLoading = true;
    notifyListeners();
    
    try {
      // Usamos Dio para la petición GET
      final response = await Dio().get('https://devsapihub.com/api-movies');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        // Convertimos el JSON a objetos Movie
        movies = data.map((item) => Movie.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error cargando películas: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // --- 2. GESTIÓN DE FAVORITOS ---
  void toggleFavorite(int id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
  }

  // --- 3. SISTEMA DE DESCARGAS (Con Galería) ---
  Future<bool> downloadImage(String url, String title, int id) async {
    try {
      // A. Pedimos permiso (Android < 10) o verificamos acceso
      // La librería 'gal' maneja esto internamente, pero es bueno saberlo.

      // B. Obtenemos una carpeta temporal donde descargar primero
      final Directory tempDir = await getTemporaryDirectory();
      // Limpiamos el nombre del archivo para evitar caracteres raros
      final String cleanTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '');
      final String tempPath = '${tempDir.path}/${cleanTitle}_$id.jpg';

      // C. Descargamos el archivo a la carpeta temporal
      await Dio().download(url, tempPath);

      // D. Movemos el archivo a la Galería oficial del usuario
      // Esto hace que aparezca en Google Photos / Galería inmediatamente
      await Gal.putImage(tempPath, album: 'PeliculasApp'); 

      // E. Si todo salió bien, actualizamos la lista visual
      if (!_downloads.contains(id)) {
        _downloads.add(id);
        notifyListeners(); // Actualiza el icono de descarga en el Grid
      }
      
      return true; // Éxito

    } catch (e) {
      print('Error al descargar: $e');
      return false; // Falló
    }
  }

  // Simulación antigua (por si acaso la necesitas, aunque la de arriba es la buena)
  void simulateDownload(int id) {
    if (!_downloads.contains(id)) {
      _downloads.add(id);
      notifyListeners();
    }
  }

  // --- 4. SISTEMA DE CALIFICACIONES ---
  
  // Obtener la calificación de una película específica (0 si no tiene)
  int getUserRating(int id) {
    return _myRatings[id] ?? 0;
  }

  // Guardar una calificación
  void rateMovie(int id, int rating) {
    _myRatings[id] = rating;
    notifyListeners();
  }

  // Obtener lista de películas calificadas (Ordenadas)
  List<Movie> getRatedMovies() {
    // 1. Filtramos solo las que tienen calificación
    List<Movie> ratedList = movies.where((m) => _myRatings.containsKey(m.id)).toList();

    // 2. Ordenamos según la variable _sortAscending
    ratedList.sort((a, b) {
      int ratingA = _myRatings[a.id]!;
      int ratingB = _myRatings[b.id]!;
      
      return _sortAscending 
          ? ratingA.compareTo(ratingB) // Menor a Mayor (1, 2, 3...)
          : ratingB.compareTo(ratingA); // Mayor a Menor (5, 4, 3...)
    });

    return ratedList;
  }

  // Cambiar el orden de visualización
  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    notifyListeners();
  }
}