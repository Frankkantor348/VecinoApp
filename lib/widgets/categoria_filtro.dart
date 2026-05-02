import 'package:flutter/material.dart';

class CategoriaFiltro extends StatelessWidget {
  final List<String> categorias;
  final String? categoriaSeleccionada;
  final Function(String?) onCategoriaSeleccionada;

  const CategoriaFiltro({
    super.key,
    required this.categorias,
    this.categoriaSeleccionada,
    required this.onCategoriaSeleccionada,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // 👈 ELIMINAR EL "Todos" FIJO DE AQUÍ
          // ...categorias.map((categoria) { ... })
          
          // Mostrar SOLO las categorías que vienen del padre
          ...categorias.map((categoria) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(categoria),
                selected: categoriaSeleccionada == categoria,
                onSelected: (_) => onCategoriaSeleccionada(categoria),
                backgroundColor: Colors.grey.shade200,
                selectedColor: const Color(0xFF2E7D32),
                labelStyle: TextStyle(
                  color: categoriaSeleccionada == categoria ? Colors.white : Colors.black87,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}