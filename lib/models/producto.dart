class Producto {
  final int id;
  final int negocioId;
  final String nombre;
  final String? descripcion;
  final double? precio;
  final bool destacado;
  final String nombreNegocio;

  Producto({
    required this.id,
    required this.negocioId,
    required this.nombre,
    this.descripcion,
    this.precio,
    required this.destacado,
    required this.nombreNegocio,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      negocioId: json['negocioId'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: json['precio']?.toDouble(),
      destacado: json['destacado'],
      nombreNegocio: json['nombreNegocio'],
    );
  }
}