import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/movie.dart';

class MovieProvider with ChangeNotifier {
  late Box<Movie> _moviesBox;
  List<Movie> _movies = [];
  bool _isLoading = false;

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;

  MovieProvider() {
    _init();
  }

  Future<void> _init() async {
    _moviesBox = Hive.box<Movie>('movies');
    await loadMovies();
  }

  Future<void> loadMovies() async {
    _isLoading = true;
    notifyListeners();

    _movies = _moviesBox.values.toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMovie(Movie movie) async {
    await _moviesBox.add(movie);
    await loadMovies();
  }

  Future<void> updateMovie(Movie movie) async {
    await movie.save();
    await loadMovies();
  }

  Future<void> deleteMovie(Movie movie) async {
    await movie.delete();
    await loadMovies();
  }
}
