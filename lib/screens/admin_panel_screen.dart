import 'package:flutter/material.dart';
import 'package:vecinoapp/services/api_service.dart';
import 'package:vecinoapp/models/negocio.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  List<Negocio> _negociosPendientes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarPendientes();
  }

  Future<void> _cargarPendientes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final pendientes = await ApiService.getNegociosPendientes();
      setState(() {
        _negociosPendientes = pendientes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _aprobarNegocio(Negocio negocio) async {
    try {
      await ApiService.aprobarNegocio(negocio.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ ${negocio.nombre} aprobado'), backgroundColor: Colors.green),
      );
      _cargarPendientes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rechazarNegocio(Negocio negocio) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rechazar negocio'),
        content: Text('¿Estás seguro de rechazar "${negocio.nombre}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ApiService.rechazarNegocio(negocio.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('❌ ${negocio.nombre} rechazado'), backgroundColor: Colors.orange),
                );
                _cargarPendientes();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text('Rechazar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Error: $_error'))
              : _negociosPendientes.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 64, color: Colors.green),
                          SizedBox(height: 16),
                          Text(
                            'No hay negocios pendientes',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _negociosPendientes.length,
                      itemBuilder: (context, index) {
                        final negocio = _negociosPendientes[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  negocio.nombre,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text('Tipo: ${negocio.tipo}'),
                                Text('Dirección: ${negocio.direccion}'),
                                if (negocio.telefono != null) Text('Teléfono: ${negocio.telefono}'),
                                Text('Propietario ID: ${negocio.propietarioId}'),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _aprobarNegocio(negocio),
                                        icon: const Icon(Icons.check),
                                        label: const Text('Aprobar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => _rechazarNegocio(negocio),
                                        icon: const Icon(Icons.close),
                                        label: const Text('Rechazar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
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