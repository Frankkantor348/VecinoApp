class Negocio {
  final int id;
  final String nombre;
  final String descripcion;
  final String tipo;
  final String direccion;
  final String? telefono;
  final String? horario;
  final String? imagenUrl;
  final bool activo;
  final DateTime fechaRegistro;
  final int propietarioId;
  final String? nombrePropietario;
  final double? latitud;
  final double? longitud;
  final double? calificacionPromedio;
  final int? totalResenas;

  Negocio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.tipo,
    required this.direccion,
    this.telefono,
    this.horario,
    this.imagenUrl,
    required this.activo,
    required this.fechaRegistro,
    required this.propietarioId,
    this.nombrePropietario,
    this.latitud,
    this.longitud,
    this.calificacionPromedio,
    this.totalResenas,
  });

  factory Negocio.fromJson(Map<String, dynamic> json) {
    return Negocio(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      tipo: json['tipo'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      horario: json['horario'],
      imagenUrl: json['imagenUrl'],
      activo: json['activo'],
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
      propietarioId: json['propietarioId'],
      nombrePropietario: json['nombrePropietario'],
      latitud: json['latitud'],
      longitud: json['longitud'],
      calificacionPromedio: json['calificacionPromedio']?.toDouble(),
      totalResenas: json['totalResenas'],
    );
  }
}