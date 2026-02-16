import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:dio/dio.dart'; 
import 'package:path_provider/path_provider.dart'; 
import 'package:gal/gal.dart'; 
import 'package:peliculas/models/movie.dart'; 

class MoviesProvider extends ChangeNotifier { 
  bool isLoading = false; 
  List<Movie> movies = []; 
  final List<int> _favorites = [];
  final List<int> _downloads = [];  
  final Map<int, int> _myRatings = {}; 
  bool _sortAscending = false;  
 
  List<int> get favorites => _favorites;
  List<int> get downloads => _downloads;
 
  MoviesProvider() {
    getAllMovies();
  }

  // CARGA DE PELÍCULAS
  Future<void> getAllMovies() async {
    isLoading = true;
    notifyListeners();
    
    try { 
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
  Future<bool> downloadImage(String url, String title, int id) async {
    try { 
      final Directory tempDir = await getTemporaryDirectory(); 
      final String cleanTitle = title.replaceAll(RegExp(r'[^\w\s]+'), '');
      final String tempPath = '${tempDir.path}/${cleanTitle}_$id.jpg'; 
      await Dio().download(url, tempPath); 
      await Gal.putImage(tempPath, album: 'PeliculasApp');  
      if (!_downloads.contains(id)) {
        _downloads.add(id);
        notifyListeners(); 
      }
      
      return true; 

    } catch (e) {
      print('Error al descargar: $e');
      return false; 
    }
  } 
  void simulateDownload(int id) {
    if (!_downloads.contains(id)) {
      _downloads.add(id);
      notifyListeners();
    }
  } 
  int getUserRating(int id) {
    return _myRatings[id] ?? 0;
  } 
  void rateMovie(int id, int rating) {
    _myRatings[id] = rating;
    notifyListeners();
  } 
  List<Movie> getRatedMovies() { 
    List<Movie> ratedList = movies.where((m) => _myRatings.containsKey(m.id)).toList();
 
    ratedList.sort((a, b) {
      int ratingA = _myRatings[a.id]!;
      int ratingB = _myRatings[b.id]!;
      
      return _sortAscending 
          ? ratingA.compareTo(ratingB) 
          : ratingB.compareTo(ratingA); 
    });

    return ratedList;
  }
 
  void toggleSortOrder() {
    _sortAscending = !_sortAscending;
    notifyListeners();
  }
}