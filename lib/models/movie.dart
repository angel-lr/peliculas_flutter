class Movie {
  final int id;           // Antes era String imdbID
  final String title;
  final int year;         // La API devuelve un número (1994), no un String
  final String imageUrl;  // Antes era Poster
  final String description;
  final String genre;
  final double stars;

  Movie({
    required this.id,
    required this.title,
    required this.year,
    required this.imageUrl,
    required this.description,
    required this.genre,
    required this.stars,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Sin Título',
      // Convertimos a String para mostrarlo fácil, aunque venga como int
      year: json['year'] ?? 0,
      // La API a veces usa 'imageUrl' y en otros ejemplos 'image_url', prevenimos ambos
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? 'https://via.placeholder.com/300x450',
      description: json['description'] ?? '',
      genre: json['genre'] ?? 'Desconocido',
      // Convertimos a double de forma segura (por si viene int o double)
      stars: (json['stars'] as num?)?.toDouble() ?? 0.0,
    );
  }
}