import 'package:flutter/material.dart';
import 'package:vecinoapp/services/api_service.dart';

class FavoritoIcon extends StatefulWidget {
  final int negocioId;
  final double size;

  const FavoritoIcon({
    super.key,
    required this.negocioId,
    this.size = 28,
  });

  @override
  State<FavoritoIcon> createState() => _FavoritoIconState();
}

class _FavoritoIconState extends State<FavoritoIcon> {
  bool _isFavorito = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _verificarFavorito();
  }

  Future<void> _verificarFavorito() async {
    try {
      final esFavorito = await ApiService.esFavorito(widget.negocioId);
      setState(() {
        _isFavorito = esFavorito;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFavorito() async {
    setState(() => _isLoading = true);
    try {
      await ApiService.toggleFavorito(widget.negocioId);
      setState(() {
        _isFavorito = !_isFavorito;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isFavorito ? '✅ Agregado a favoritos' : '❌ Eliminado de favoritos'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    }
    
    return IconButton(
      icon: Icon(
        _isFavorito ? Icons.favorite : Icons.favorite_border,
        color: _isFavorito ? Colors.red : Colors.grey,
        size: widget.size,
      ),
      onPressed: _toggleFavorito,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}