import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:vecinoapp/services/api_service.dart';
import 'dart:io';
import '../widgets/imagen_con_edicion.dart';

class RegistrarNegocioScreen extends StatefulWidget {
  final int? negocioId;
  final Map<String, dynamic>? negocioData;

  const RegistrarNegocioScreen({super.key, this.negocioId, this.negocioData});

  @override
  State<RegistrarNegocioScreen> createState() => _RegistrarNegocioScreenState();
}

class _RegistrarNegocioScreenState extends State<RegistrarNegocioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _tipoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _horarioController = TextEditingController();

  LatLng? _ubicacionSeleccionada;
  GoogleMapController? _mapController;
  final Location _location = Location();

  bool _isLoading = false;
  bool _isMapReady = false;
  
  File? _imagenSeleccionada;
  String? _imagenUrlActual;

  @override
  void initState() {
    super.initState();
    _obtenerUbicacionActual();
    _cargarDatosSiEdicion();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _nombreController.dispose();
    _tipoController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _whatsappController.dispose();
    _horarioController.dispose();
    super.dispose();
  }

  void _cargarDatosSiEdicion() {
    if (widget.negocioData != null) {
      _nombreController.text = widget.negocioData!['nombre'] ?? '';
      _tipoController.text = widget.negocioData!['tipo'] ?? '';
      _direccionController.text = widget.negocioData!['direccion'] ?? '';
      _telefonoController.text = widget.negocioData!['telefono'] ?? '';
      _whatsappController.text = widget.negocioData!['whatsapp'] ?? widget.negocioData!['telefono'] ?? '';
      _horarioController.text = widget.negocioData!['horario'] ?? '';
      
      final lat = widget.negocioData!['latitud'];
      final lng = widget.negocioData!['longitud'];
      if (lat != null && lng != null) {
        _ubicacionSeleccionada = LatLng(lat.toDouble(), lng.toDouble());
      }
      
      _imagenUrlActual = widget.negocioData!['imagenUrl'];
      print('📸 Imagen URL actual: $_imagenUrlActual');
    }
  }

  Future<void> _obtenerUbicacionActual() async {
    try {
      print('📍 Solicitando ubicación del dispositivo...');
      
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        print('⚠️ Servicios de ubicación deshabilitados');
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          print('❌ Usuario rechazó habilitar servicios de ubicación');
          _mostrarAdvertencia('Servicios de ubicación deshabilitados');
          _asignarUbicacionPorDefecto();
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        print('⚠️ Solicitando permiso de ubicación...');
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          print('❌ Usuario rechazó permisos de ubicación');
          _mostrarAdvertencia('Permisos de ubicación requeridos');
          _asignarUbicacionPorDefecto();
          return;
        }
      }

      try {
        print('🔄 Obteniendo coordenadas GPS...');
        final locationData = await _location.getLocation().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            print('⏱️ Timeout al obtener ubicación');
            throw Exception('Timeout al obtener la ubicación');
          },
        );

        if (locationData.latitude == null || locationData.longitude == null) {
          throw Exception('No se pudieron obtener las coordenadas');
        }

        setState(() {
          _ubicacionSeleccionada = LatLng(
            locationData.latitude!,
            locationData.longitude!,
          );
          _isMapReady = true;
        });
        
        print('✅ Ubicación obtenida: ${locationData.latitude}, ${locationData.longitude}');

        if (_mapController != null && _ubicacionSeleccionada != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _ubicacionSeleccionada!,
                zoom: 16,
              ),
            ),
          );
        }
      } catch (e) {
        print('❌ Error al obtener ubicación GPS: $e');
        _mostrarAdvertencia('Error al obtener ubicación GPS: $e');
        _asignarUbicacionPorDefecto();
      }
    } catch (e) {
      print('❌ Error en obtener ubicación: $e');
      _asignarUbicacionPorDefecto();
    }
  }

  void _asignarUbicacionPorDefecto() {
    print('📍 Usando ubicación por defecto (Bogotá)');
    setState(() {
      _ubicacionSeleccionada = const LatLng(4.6097, -74.0817);
      _isMapReady = true;
    });
  }

  void _mostrarAdvertencia(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _actualizarFoto(File foto) async {
    print('📸 _actualizarFoto llamado');
    print('📸 Foto path: ${foto.path}');
    setState(() => _imagenSeleccionada = foto);
    
    if (widget.negocioId != null) {
      try {
        setState(() => _isLoading = true);
        final nuevaUrl = await ApiService.actualizarFotoNegocio(widget.negocioId!, foto);
        print('✅ Foto actualizada en servidor: $nuevaUrl');
        setState(() => _imagenUrlActual = nuevaUrl);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto actualizada correctamente')),
          );
        }
      } catch (e) {
        print('❌ Error al actualizar foto: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al actualizar foto: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _eliminarFoto() async {
    print('📸 _eliminarFoto llamado');
    if (widget.negocioId != null && _imagenUrlActual != null) {
      try {
        setState(() => _isLoading = true);
        await ApiService.eliminarFotoNegocio(widget.negocioId!);
        print('✅ Foto eliminada del servidor');
        setState(() {
          _imagenUrlActual = null;
          _imagenSeleccionada = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto eliminada correctamente')),
          );
        }
      } catch (e) {
        print('❌ Error al eliminar foto: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar foto: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      setState(() => _imagenSeleccionada = null);
    }
  }

  Future<void> _registrarNegocio() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa los campos obligatorios')),
      );
      return;
    }
    
    if (_ubicacionSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la ubicación en el mapa')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      int? negocioId = widget.negocioId;
      
      if (negocioId == null) {
        // ========== CREAR NEGOCIO NUEVO ==========
        print('📝 Creando nuevo negocio...');
        final response = await ApiService.registrarNegocio(
          nombre: _nombreController.text.trim(),
          tipo: _tipoController.text.trim(),
          direccion: _direccionController.text.trim(),
          telefono: _telefonoController.text.trim(),
          whatsapp: _whatsappController.text.trim(),
          horario: _horarioController.text.trim(),
          latitud: _ubicacionSeleccionada!.latitude,
          longitud: _ubicacionSeleccionada!.longitude,
        );
        
        negocioId = response['id'];
        print('✅ Negocio creado con ID: $negocioId');
        
        // Subir imagen si hay una seleccionada
        if (_imagenSeleccionada != null && negocioId != null) {
          print('📸 Subiendo imagen para el nuevo negocio...');
          try {
            final imageUrl = await ApiService.subirImagenNegocio(negocioId, _imagenSeleccionada!);
            print('✅ Imagen subida: $imageUrl');
            
            // Actualizar la URL de imagen localmente
            setState(() {
              _imagenUrlActual = imageUrl;
            });
          } catch (e) {
            print('❌ Error al subir imagen: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Negocio creado, pero error con la foto: $e')),
            );
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Negocio registrado. Pendiente de aprobación.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // ========== ACTUALIZAR NEGOCIO EXISTENTE ==========
        print('✏️ Actualizando negocio ID: $negocioId');
        await ApiService.actualizarNegocio(
          negocioId,
          nombre: _nombreController.text.trim(),
          tipo: _tipoController.text.trim(),
          direccion: _direccionController.text.trim(),
          telefono: _telefonoController.text.trim(),
          whatsapp: _whatsappController.text.trim(),
          horario: _horarioController.text.trim(),
          latitud: _ubicacionSeleccionada!.latitude,
          longitud: _ubicacionSeleccionada!.longitude,
        );
        print('✅ Negocio actualizado');
        
        // Manejar la imagen si se seleccionó una nueva
        if (_imagenSeleccionada != null) {
          print('📸 Actualizando imagen...');
          try {
            final newImageUrl = await ApiService.actualizarFotoNegocio(negocioId, _imagenSeleccionada!);
            print('✅ Imagen actualizada: $newImageUrl');
            setState(() {
              _imagenUrlActual = newImageUrl;
            });
          } catch (e) {
            print('❌ Error al actualizar imagen: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Negocio actualizado, pero error con la foto: $e')),
            );
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Negocio actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error general: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.negocioId != null ? 'Editar mi negocio' : 'Registrar mi negocio'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Foto del negocio',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: ImagenConEdicion(
                        imagenUrl: _imagenUrlActual,
                        onImagenSeleccionada: _actualizarFoto,
                        onImagenEliminada: _eliminarFoto,
                        esPerfil: false,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre del negocio *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: _tipoController,
                      decoration: const InputDecoration(
                        labelText: 'Tipo (panadería, tienda, etc.) *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: _direccionController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: _telefonoController,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: _whatsappController,
                      decoration: const InputDecoration(
                        labelText: 'WhatsApp',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    
                    TextFormField(
                      controller: _horarioController,
                      decoration: const InputDecoration(
                        labelText: 'Horario (ej: Lun-Dom 8am-8pm)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    const Text(
                      'Ubicación del negocio',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: !_isMapReady || _ubicacionSeleccionada == null
                          ? Container(
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 12),
                                    Text('📍 Obteniendo ubicación...'),
                                  ],
                                ),
                              ),
                            )
                          : Stack(
                              children: [
                                GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: _ubicacionSeleccionada!,
                                    zoom: 16,
                                  ),
                                  onMapCreated: (controller) {
                                    print('✅ GoogleMap widget creado');
                                    _mapController = controller;
                                  },
                                  onTap: (latLng) {
                                    setState(() {
                                      _ubicacionSeleccionada = latLng;
                                    });
                                  },
                                  markers: {
                                    Marker(
                                      markerId: const MarkerId('selected'),
                                      position: _ubicacionSeleccionada!,
                                      draggable: true,
                                      onDragEnd: (newPosition) {
                                        setState(() {
                                          _ubicacionSeleccionada = newPosition;
                                        });
                                      },
                                      infoWindow: const InfoWindow(title: '📍 Tu negocio aquí'),
                                    ),
                                  },
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: true,
                                  zoomControlsEnabled: true,
                                ),
                                // Mostrar advertencia si el mapa aparece gris
                                if (_ubicacionSeleccionada != null)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.black87,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '📍 ${_ubicacionSeleccionada!.latitude.toStringAsFixed(4)}, '
                                        '${_ubicacionSeleccionada!.longitude.toStringAsFixed(4)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        border: Border.all(color: Colors.blue.shade200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '📌 Instrucciones:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '• Toca el mapa para mover el marcador\n'
                            '• Arrastra el marcador para ajustar la ubicación\n'
                            '• Si el mapa está gris, verifica que Google Maps API Key esté habilitada',
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registrarNegocio,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                widget.negocioId != null ? 'Actualizar negocio' : 'Registrar negocio',
                                style: const TextStyle(fontSize: 16, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}