import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peliculas/config/theme/app_theme.dart'; // Ajusta el nombre del paquete
import 'package:peliculas/providers/movies_provider.dart';
import 'package:peliculas/screens/home_screen.dart';

void main() {
  runApp(const AppState());
}

// Widget para manejar el estado global de la App (Provider)
class AppState extends StatelessWidget {
  const AppState({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Aquí inicializamos el proveedor de películas
        ChangeNotifierProvider(create: (_) => MoviesProvider(), lazy: false),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catálogo de Películas',
      theme: AppTheme().getTheme(), // Uso de archivo de tema separado
      home: const HomeScreen(),
    );
  }
}