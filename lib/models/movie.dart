import 'package:hive/hive.dart';

part 'movie.g.dart';

@HiveType(typeId: 0)
class Movie extends HiveObject {
  @HiveField(0)
  String imageUrl;

  @HiveField(1)
  String title;

  @HiveField(2)
  String genre;

  @HiveField(3)
  String ageRating;

  @HiveField(4)
  String duration;

  @HiveField(5)
  double score;

  @HiveField(6)
  String description;

  @HiveField(7)
  String year;

  Movie({
    required this.imageUrl,
    required this.title,
    required this.genre,
    required this.ageRating,
    required this.duration,
    required this.score,
    required this.description,
    required this.year,
  });

  @override
  String toString() => 'Movie{title: $title, score: $score}';
}