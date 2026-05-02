class Favorito {
  final int id;
  final int usuarioId;
  final int negocioId;
  final String nombreUsuario;
  final String nombreNegocio;
  final String direccionNegocio;

  Favorito({
    required this.id,
    required this.usuarioId,
    required this.negocioId,
    required this.nombreUsuario,
    required this.nombreNegocio,
    required this.direccionNegocio,
  });

  factory Favorito.fromJson(Map<String, dynamic> json) {
    return Favorito(
      id: json['id'],
      usuarioId: json['usuarioId'],
      negocioId: json['negocioId'],
      nombreUsuario: json['nombreUsuario'],
      nombreNegocio: json['nombreNegocio'],
      direccionNegocio: json['direccionNegocio'],
    );
  }
}