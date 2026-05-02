import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vecinoapp/services/api_service.dart';

class ImagenPerfil extends StatefulWidget {
  final String? fotoUrl;
  final double tamano;
  final VoidCallback onFotoActualizada;

  const ImagenPerfil({
    super.key,
    this.fotoUrl,
    this.tamano = 100,
    required this.onFotoActualizada,
  });

  @override
  State<ImagenPerfil> createState() => _ImagenPerfilState();
}

class _ImagenPerfilState extends State<ImagenPerfil> {
  File? _imagenSeleccionada;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  String _getImagenUrl(String? imagenUrl) {
    if (imagenUrl == null || imagenUrl.isEmpty) return '';
    if (imagenUrl.startsWith('http')) return imagenUrl;
    return 'http://10.0.2.2:5067$imagenUrl';
  }

  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() => _isLoading = true);
        
        final file = File(pickedFile.path);
        final nuevaUrl = await ApiService.actualizarFotoPerfil(file);
        
        setState(() {
          _imagenSeleccionada = file;
          _isLoading = false;
        });
        
        widget.onFotoActualizada();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto de perfil actualizada')),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _eliminarFoto() async {
    try {
      setState(() => _isLoading = true);
      await ApiService.eliminarFotoPerfil();
      setState(() {
        _imagenSeleccionada = null;
        _isLoading = false;
      });
      widget.onFotoActualizada();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto de perfil eliminada')),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _mostrarOpciones() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar foto'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Elegir de galería'),
              onTap: () {
                Navigator.pop(context);
                _seleccionarImagen(ImageSource.gallery);
              },
            ),
            if (widget.fotoUrl != null || _imagenSeleccionada != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _eliminarFoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _mostrarOpciones,
      child: Stack(
        children: [
          CircleAvatar(
            radius: widget.tamano / 2,
            backgroundColor: Colors.green.shade100,
            backgroundImage: _isLoading
                ? null
                : (_imagenSeleccionada != null
                    ? FileImage(_imagenSeleccionada!)
                    : (widget.fotoUrl != null && widget.fotoUrl!.isNotEmpty
                        ? NetworkImage(_getImagenUrl(widget.fotoUrl))
                        : null)),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : (widget.fotoUrl == null && _imagenSeleccionada == null)
                    ? Icon(Icons.person, size: widget.tamano / 2, color: Colors.grey[600])
                    : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                onPressed: _mostrarOpciones,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                iconSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}