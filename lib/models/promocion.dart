class Promocion {
  final int id;
  final int negocioId;
  final String titulo;
  final String descripcion;
  final int descuento; // Agregado para representar el porcentaje de descuento  
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final bool activa;
  final String nombreNegocio;

  Promocion({
    required this.id,
    required this.negocioId,
    required this.titulo,
    required this.descripcion,
    required this.descuento,
    required this.fechaInicio,
    required this.fechaFin,
    required this.activa,
    required this.nombreNegocio,
  });

  factory Promocion.fromJson(Map<String, dynamic> json) {
    return Promocion(
      id: json['id'],
      negocioId: json['negocioId'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      descuento: json['descuento'], // Asegúrate de que el JSON tenga este campo
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaFin: DateTime.parse(json['fechaFin']),
      activa: json['activa'],
      nombreNegocio: json['nombreNegocio'],
    );
  }
  bool get estaVigente {
    final hoy = DateTime.now();
    return activa && fechaInicio.isBefore(hoy) && fechaFin.isAfter(hoy);
  }
}
