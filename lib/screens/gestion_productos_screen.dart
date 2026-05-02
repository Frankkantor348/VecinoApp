import 'package:flutter/material.dart';
import 'package:vecinoapp/services/api_service.dart';
import '../models/producto.dart';

class GestionProductosScreen extends StatefulWidget {
  final int negocioId;
  final String negocioNombre;

  const GestionProductosScreen({
    super.key,
    required this.negocioId,
    required this.negocioNombre,
  });

  @override
  State<GestionProductosScreen> createState() => _GestionProductosScreenState();
}

class _GestionProductosScreenState extends State<GestionProductosScreen> {
  List<Producto> _productos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final productos = await ApiService.getProductosPorNegocio(widget.negocioId);
      if (!mounted) return;
      setState(() {
        _productos = productos;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _agregarProducto() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _ProductoDialog(
        negocioId: widget.negocioId,
      ),
    );
    if (result == true && mounted) {
      _cargarProductos();
    }
  }

  Future<void> _editarProducto(Producto producto) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _ProductoDialog(
        negocioId: widget.negocioId,
        producto: producto,
      ),
    );
    if (result == true && mounted) {
      _cargarProductos();
    }
  }

  Future<void> _eliminarProducto(Producto producto) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${producto.nombre}"?'),
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
        await ApiService.eliminarProducto(producto.id);
        if (mounted) {
          _cargarProductos();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Producto eliminado')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Productos - ${widget.negocioNombre}'),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _agregarProducto,
            tooltip: 'Agregar producto',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _productos.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No hay productos'),
                          SizedBox(height: 8),
                          Text('Toca + para agregar'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _productos.length,
                      itemBuilder: (context, index) {
                        final producto = _productos[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.inventory, size: 30, color: Colors.green),
                            ),
                            title: Text(
                              producto.nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (producto.descripcion != null && producto.descripcion!.isNotEmpty)
                                  Text(producto.descripcion!),
                                if (producto.precio != null)
                                  Text(
                                    '\$${producto.precio!.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if (producto.destacado)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Destacado',
                                      style: TextStyle(fontSize: 10, color: Colors.orange),
                                    ),
                                  ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editarProducto(producto),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _eliminarProducto(producto),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

// Diálogo para agregar/editar producto
class _ProductoDialog extends StatefulWidget {
  final int negocioId;
  final Producto? producto;

  const _ProductoDialog({
    required this.negocioId,
    this.producto,
  });

  @override
  State<_ProductoDialog> createState() => _ProductoDialogState();
}

class _ProductoDialogState extends State<_ProductoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _precioController = TextEditingController();
  bool _destacado = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.producto != null) {
      _nombreController.text = widget.producto!.nombre;
      _descripcionController.text = widget.producto!.descripcion ?? '';
      _precioController.text = widget.producto!.precio?.toString() ?? '';
      _destacado = widget.producto!.destacado;
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _precioController.dispose();
    super.dispose();
  }

  // Función para limpiar el precio (elimina puntos y reemplaza coma)
  double? _parsePrecio(String texto) {
    if (texto.isEmpty) return null;
    
    // Eliminar puntos (separadores de miles)
    String limpio = texto.replaceAll('.', '');
    // Reemplazar coma por punto (separador decimal)
    limpio = limpio.replaceAll(',', '.');
    
    return double.tryParse(limpio);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      final precio = _parsePrecio(_precioController.text);
      
      if (widget.producto == null) {
        await ApiService.crearProducto(
          negocioId: widget.negocioId,
          nombre: _nombreController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          precio: precio,
          destacado: _destacado,
        );
      } else {
        await ApiService.actualizarProducto(
          id: widget.producto!.id,
          nombre: _nombreController.text.trim(),
          descripcion: _descripcionController.text.trim(),
          precio: precio,
          destacado: _destacado,
        );
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
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
      title: Text(widget.producto == null ? 'Agregar producto' : 'Editar producto'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _precioController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  prefixText: '\$',
                  hintText: 'Ej: 70000 o 70.000',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Producto destacado'),
                value: _destacado,
                onChanged: (value) => setState(() => _destacado = value),
                activeColor: Colors.green,
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