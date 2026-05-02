class Usuario {
  final int id;
  final String nombre;
  final String email;
  final String? telefono;
  final String? fotoPerfilUrl;
  final DateTime fechaRegistro;
  final int totalResenas;
  final int totalFavoritos;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    this.telefono,
    this.fotoPerfilUrl,
    required this.fechaRegistro,
    required this.totalResenas,
    required this.totalFavoritos,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      email: json['email'],
      telefono: json['telefono'],
      fotoPerfilUrl: json['fotoPerfilUrl'],
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
      totalResenas: json['totalResenas'] ?? 0,
      totalFavoritos: json['totalFavoritos'] ?? 0,
    );
  }
}