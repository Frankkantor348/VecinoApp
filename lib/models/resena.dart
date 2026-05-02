class Resena {
  final int id;
  final int usuarioId;
  final int negocioId;
  final int calificacion;
  final String comentario;
  final DateTime fecha;
  final String nombreUsuario;
  final String nombreNegocio;

  Resena({
    required this.id,
    required this.usuarioId,
    required this.negocioId,
    required this.calificacion,
    required this.comentario,
    required this.fecha,
    required this.nombreUsuario,
    required this.nombreNegocio,
  });

  factory Resena.fromJson(Map<String, dynamic> json) {
    return Resena(
      id: json['id'],
      usuarioId: json['usuarioId'],
      negocioId: json['negocioId'],
      calificacion: json['calificacion'],
      comentario: json['comentario'],
      fecha: DateTime.parse(json['fecha']),
      nombreUsuario: json['nombreUsuario'],
      nombreNegocio: json['nombreNegocio'],
    );
  }
}