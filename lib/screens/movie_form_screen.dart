import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../models/movie.dart';
import '../providers/movie_provider.dart';

class MovieFormScreen extends StatefulWidget {
  final Movie? movie;

  const MovieFormScreen({super.key, this.movie});

  @override
  State<MovieFormScreen> createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends State<MovieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();
  final _titleController = TextEditingController();
  final _genreController = TextEditingController();
  final _durationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _yearController = TextEditingController();

  final _dateFormatter = MaskTextInputFormatter(
    mask: '##/##/####',
    filter: {"#": RegExp(r'[0-9]')},
  );

  String _selectedAgeRating = 'Livre';
  double _currentScore = 0.0;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.movie != null) {
      _isEditing = true;
      _imageUrlController.text = widget.movie!.imageUrl;
      _titleController.text = widget.movie!.title;
      _genreController.text = widget.movie!.genre;
      _selectedAgeRating = widget.movie!.ageRating;
      _durationController.text = widget.movie!.duration;
      _currentScore = widget.movie!.score;
      _descriptionController.text = widget.movie!.description;
      _yearController.text = widget.movie!.year;
    }
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _titleController.dispose();
    _genreController.dispose();
    _durationController.dispose();
    _descriptionController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _saveMovie() async {
    if (_formKey.currentState!.validate()) {
      final movieProvider = Provider.of<MovieProvider>(context, listen: false);

      if (_isEditing) {
        final existingMovie = widget.movie!;
        existingMovie
          ..imageUrl = _imageUrlController.text
          ..title = _titleController.text
          ..genre = _genreController.text
          ..ageRating = _selectedAgeRating
          ..duration = _durationController.text
          ..score = _currentScore
          ..description = _descriptionController.text
          ..year = _yearController.text;

        await movieProvider.updateMovie(existingMovie);
      } else {
        final newMovie = Movie(
          imageUrl: _imageUrlController.text,
          title: _titleController.text,
          genre: _genreController.text,
          ageRating: _selectedAgeRating,
          duration: _durationController.text,
          score: _currentScore,
          description: _descriptionController.text,
          year: _yearController.text,
        );

        await movieProvider.addMovie(newMovie);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Filme atualizado!' : 'Filme adicionado!'),
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: Text(_isEditing ? 'Editar Filme' : 'Cadastrar Filme',
            style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Url Imagem',
                  border: UnderlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                validator: (value) => value == null || value.isEmpty
                    ? 'Por favor, insira Url Imagem.'
                    : null,
                onChanged: (_) {
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              if (_imageUrlController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _imageUrlController.text,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image,
                            size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              _buildTextField(_titleController, 'Título'),
              const SizedBox(height: 16),
              _buildTextField(_genreController, 'Gênero'),
              const SizedBox(height: 16),
              _buildDropdownAgeRating(),
              const SizedBox(height: 16),
              _buildTextField(_durationController, 'Duração'),
              const SizedBox(height: 16),
              _buildRatingBar(),
              const SizedBox(height: 16),
              _buildTextField(
                _yearController,
                'Data de Lançamento',
                keyboardType: TextInputType.number,
                inputFormatters: [_dateFormatter],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a data.';
                  }
                  if (!_dateFormatter.isFill()) {
                    return 'Data incompleta.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Descrição', maxLines: 4),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveMovie,
        shape: const CircleBorder(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.save, color: Colors.white),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const UnderlineInputBorder(),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      validator: validator ??
          (value) => value == null || value.isEmpty
              ? 'Por favor, insira $label.'
              : null,
    );
  }

  Widget _buildDropdownAgeRating() {
    return DropdownButtonFormField<String>(
      value: _selectedAgeRating,
      decoration: const InputDecoration(
        labelText: 'Faixa Etária',
        border: UnderlineInputBorder(),
      ),
      onChanged: (value) {
        setState(() {
          _selectedAgeRating = value!;
        });
      },
      items: ['Livre', '10', '12', '14', '16', '18']
          .map((age) => DropdownMenuItem(value: age, child: Text(age)))
          .toList(),
    );
  }

  Widget _buildRatingBar() {
    return Row(
      children: [
        const Text('Nota:'),
        const SizedBox(width: 8),
        RatingBar.builder(
          initialRating: _currentScore,
          minRating: 0,
          direction: Axis.horizontal,
          allowHalfRating: false,
          itemCount: 5,
          itemBuilder: (context, _) => const Icon(
            Icons.star,
            color: Colors.amber,
          ),
          itemSize: 32,
          onRatingUpdate: (rating) {
            setState(() {
              _currentScore = rating;
            });
          },
        ),
      ],
    );
  }
}