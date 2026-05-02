import 'package:flutter/material.dart';
import 'package:vecinoapp/services/api_service.dart';
import '../models/promocion.dart';

class GestionPromocionesScreen extends StatefulWidget {
  final int negocioId;
  final String negocioNombre;

  const GestionPromocionesScreen({
    super.key,
    required this.negocioId,
    required this.negocioNombre,
  });

  @override
  State<GestionPromocionesScreen> createState() => _GestionPromocionesScreenState();
}

class _GestionPromocionesScreenState extends State<GestionPromocionesScreen> {
  List<Promocion> _promociones = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPromociones();
  }

  Future<void> _cargarPromociones() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final promociones = await ApiService.getPromocionesPorNegocio(widget.negocioId);
      
      print('========== PROMOCIONES CARGADAS ==========');
      for (var p in promociones) {
        print('ID: ${p.id}, Descuento: ${p.descuento}, Activa: ${p.activa}');
      }
      
      setState(() {
        _promociones = promociones;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error cargando promociones: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _agregarPromocion() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _PromocionDialog(negocioId: widget.negocioId),
    );
    if (result == true) {
      await _cargarPromociones();
    }
  }

  Future<void> _editarPromocion(Promocion promocion) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _PromocionDialog(
        negocioId: widget.negocioId,
        promocion: promocion,
      ),
    );
    if (result == true) {
      await Future.delayed(const Duration(milliseconds: 300));
      await _cargarPromociones();
    }
  }

  Future<void> _eliminarPromocion(Promocion promocion) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar promoción'),
        content: Text('¿Eliminar "${promocion.titulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        await ApiService.eliminarPromocion(promocion.id);
        await _cargarPromociones();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Promoción eliminada')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Promociones - ${widget.negocioNombre}'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _agregarPromocion,
            tooltip: 'Agregar promoción',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _promociones.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_offer, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No hay promociones'),
                          SizedBox(height: 8),
                          Text('Toca + para agregar'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _promociones.length,
                      itemBuilder: (context, index) {
                        final promocion = _promociones[index];
                        final estaVigente = promocion.estaVigente;
                        final estaActiva = promocion.activa;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: estaActiva 
                                      ? (estaVigente ? Colors.orange.shade50 : Colors.yellow.shade50)
                                      : Colors.grey.shade100,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    topRight: Radius.circular(12),
                                  ),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade200,
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${promocion.descuento}%',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            promocion.titulo,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            promocion.descripcion,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: !estaActiva 
                                            ? Colors.red.shade100
                                            : (estaVigente 
                                                ? Colors.green.shade100 
                                                : Colors.orange.shade100),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        !estaActiva 
                                            ? 'Inactiva' 
                                            : (estaVigente ? 'Vigente' : 'Expirada'),
                                        style: TextStyle(
                                          color: !estaActiva 
                                              ? Colors.red.shade800
                                              : (estaVigente 
                                                  ? Colors.green.shade800 
                                                  : Colors.orange.shade800),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        '${_formatearFecha(promocion.fechaInicio)} - ${_formatearFecha(promocion.fechaFin)}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
                                      onPressed: () => _editarPromocion(promocion),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                      onPressed: () => _eliminarPromocion(promocion),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}

// Diálogo para agregar/editar promoción CON descuento y activa
class _PromocionDialog extends StatefulWidget {
  final int negocioId;
  final Promocion? promocion;

  const _PromocionDialog({
    required this.negocioId,
    this.promocion,
  });

  @override
  State<_PromocionDialog> createState() => _PromocionDialogState();
}

class _PromocionDialogState extends State<_PromocionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _descuentoController = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;
  bool _activa = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.promocion != null) {
      _tituloController.text = widget.promocion!.titulo;
      _descripcionController.text = widget.promocion!.descripcion;
      _descuentoController.text = widget.promocion!.descuento.toString();
      _fechaInicio = widget.promocion!.fechaInicio;
      _fechaFin = widget.promocion!.fechaFin;
      _activa = widget.promocion!.activa;
      
      print('========== EDITANDO PROMOCIÓN ==========');
      print('ID: ${widget.promocion!.id}');
      print('Descuento actual: ${widget.promocion!.descuento}');
      print('Activa actual: ${widget.promocion!.activa}');
      print('FechaInicio: $_fechaInicio');
      print('FechaFin: $_fechaFin');
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _descuentoController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha(bool esInicio) async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (fecha != null) {
      setState(() {
        if (esInicio) {
          _fechaInicio = fecha;
        } else {
          _fechaFin = fecha;
        }
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_fechaInicio == null || _fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona fechas de inicio y fin')),
      );
      return;
    }
    
    if (_fechaInicio!.isAfter(_fechaFin!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de inicio no puede ser después de la fecha de fin')),
      );
      return;
    }
    
    print('========== GUARDANDO PROMOCIÓN ==========');
    print('NegocioId: ${widget.negocioId}');
    print('Título: ${_tituloController.text}');
    print('Descripción: ${_descripcionController.text}');
    print('Descuento: ${int.parse(_descuentoController.text)}');
    print('FechaInicio: $_fechaInicio');
    print('FechaFin: $_fechaFin');
    print('Activa: $_activa');
    print('Es edición: ${widget.promocion != null}');
    if (widget.promocion != null) {
      print('ID a actualizar: ${widget.promocion!.id}');
    }
    
    setState(() => _isLoading = true);
    try {
      if (widget.promocion == null) {
        await ApiService.crearPromocion(
          negocioId: widget.negocioId,
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          descuento: int.parse(_descuentoController.text),
          fechaInicio: _fechaInicio!,
          fechaFin: _fechaFin!,
          activa: _activa,
        );
        print('✅ Promoción creada exitosamente');
      } else {
        await ApiService.actualizarPromocion(
          id: widget.promocion!.id,
          titulo: _tituloController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          descuento: int.parse(_descuentoController.text),
          fechaInicio: _fechaInicio!,
          fechaFin: _fechaFin!,
          activa: _activa,
        );
        print('✅ Promoción actualizada exitosamente');
      }
      
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('❌ Error al guardar promoción: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.promocion == null ? 'Agregar promoción' : 'Editar promoción'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descuentoController,
                decoration: const InputDecoration(
                  labelText: 'Descuento (%) *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent),
                ),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v!.isEmpty) return 'Campo obligatorio';
                  final descuento = int.tryParse(v);
                  if (descuento == null || descuento < 0 || descuento > 100) {
                    return 'Descuento entre 0 y 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Período de vigencia',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                tileColor: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                title: const Text('Fecha de inicio'),
                subtitle: Text(_fechaInicio != null
                    ? '${_fechaInicio!.day}/${_fechaInicio!.month}/${_fechaInicio!.year}'
                    : 'Seleccionar fecha'),
                trailing: const Icon(Icons.calendar_today, color: Colors.green),
                onTap: () => _seleccionarFecha(true),
              ),
              const SizedBox(height: 8),
              ListTile(
                tileColor: Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                title: const Text('Fecha de fin'),
                subtitle: Text(_fechaFin != null
                    ? '${_fechaFin!.day}/${_fechaFin!.month}/${_fechaFin!.year}'
                    : 'Seleccionar fecha'),
                trailing: const Icon(Icons.calendar_today, color: Colors.red),
                onTap: () => _seleccionarFecha(false),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              // 👈 SWITCH PARA ACTIVAR/DESACTIVAR PROMOCIÓN
              SwitchListTile(
                title: const Text(
                  'Promoción activa',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _activa 
                      ? 'Visible para los usuarios' 
                      : 'Oculta para los usuarios',
                  style: TextStyle(
                    fontSize: 12,
                    color: _activa ? Colors.green : Colors.red,
                  ),
                ),
                value: _activa,
                onChanged: (value) => setState(() => _activa = value),
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                inactiveTrackColor: Colors.red.shade100,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _guardar,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Guardar'),
        ),
      ],
    );
  }
}