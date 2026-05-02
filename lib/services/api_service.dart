import 'dart:convert';
import 'dart:convert' show utf8, base64Url;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/negocio.dart';
import '../models/resena.dart';
import '../models/producto.dart';
import '../models/promocion.dart';
import '../models/usuario.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io';

class ApiService {
  static const String baseUrl = 'http://192.168.20.9:5067';
  static const int _timeoutSeconds = 30;

  // ============================================================
  // CLASE DE EXCEPCIÓN PERSONALIZADA
  // ============================================================

  static void _logError(String method, dynamic error) {
    print('❌ $method: $error');
  }

  static String _extractErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (data is String) return data;
      if (data['message'] is String) return data['message'];
      if (data['title'] is String) return data['title'];
      if (data['error'] is String) return data['error'];
      if (data['errors'] is Map) {
        final errors = data['errors'] as Map;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          return firstError.first.toString();
        }
        return firstError.toString();
      }
      return response.body.isNotEmpty && response.body.length < 200 
          ? response.body 
          : 'Error ${response.statusCode}';
    } catch (e) {
      return 'Error ${response.statusCode}';
    }
  }

  static String _getDefaultMessage(int statusCode) {
    switch (statusCode) {
      case 400: return 'Datos inválidos. Verifica la información.';
      case 401: return 'Tu sesión ha expirado. Inicia sesión nuevamente.';
      case 403: return 'No tienes permiso para realizar esta acción.';
      case 404: return 'Recurso no encontrado.';
      case 409: return 'Ya has reseñado este negocio anteriormente.';
      case 500: return 'Error en el servidor. Intenta más tarde.';
      default: return 'Error $statusCode. Intenta nuevamente.';
    }
  }

  // ============================================================
  // MÉTODOS PRIVADOS
  // ============================================================

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> _get(String path) async {
    return await http
        .get(Uri.parse('$baseUrl/$path'), headers: await _getHeaders())
        .timeout(const Duration(seconds: _timeoutSeconds));
  }

  static Future<http.Response> _post(String path, dynamic body) async {
    return await http
        .post(
          Uri.parse('$baseUrl/$path'),
          headers: await _getHeaders(),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: _timeoutSeconds));
  }

  static Future<http.Response> _put(String path, dynamic body) async {
    return await http
        .put(
          Uri.parse('$baseUrl/$path'),
          headers: await _getHeaders(),
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: _timeoutSeconds));
  }

  static Future<http.Response> _delete(String path) async {
    return await http
        .delete(Uri.parse('$baseUrl/$path'), headers: await _getHeaders())
        .timeout(const Duration(seconds: _timeoutSeconds));
  }

  // ============================================================
  // AUTENTICACIÓN
  // ============================================================

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setInt('usuarioId', data['id']);
        return data;
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('login', e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> register(
    String nombre,
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'nombre': nombre,
              'email': email,
              'password': password,
              'confirmPassword': password,
            }),
          )
          .timeout(const Duration(seconds: _timeoutSeconds));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('register', e);
      rethrow;
    }
  }

  // ============================================================
  // NEGOCIOS
  // ============================================================

  static Future<List<Negocio>> getNegociosCercanos(
    double latitud,
    double longitud, {
    int radioMetros = 1000,
  }) async {
    try {
      final url = '$baseUrl/api/negocios/cercanos?latitud=$latitud&longitud=$longitud&radioMetros=$radioMetros';
      final response = await _get(url.replaceFirst('$baseUrl/', ''));
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Negocio.fromJson(json)).toList();
      } else {
        throw Exception(_getDefaultMessage(response.statusCode));
      }
    } catch (e) {
      _logError('getNegociosCercanos', e);
      rethrow;
    }
  }

  static Future<Negocio> getNegocio(int id) async {
    try {
      final response = await _get('api/negocios/$id');
      
      if (response.statusCode == 200) {
        return Negocio.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(_getDefaultMessage(response.statusCode));
      }
    } catch (e) {
      _logError('getNegocio', e);
      rethrow;
    }
  }

  static Future<List<Negocio>> getNegociosCercanosConFiltro(
    double latitud,
    double longitud, {
    int radioMetros = 1000,
    String? tipo,
  }) async {
    try {
      var url = 'api/negocios/cercanos?latitud=$latitud&longitud=$longitud&radioMetros=$radioMetros';
      if (tipo != null && tipo.isNotEmpty && tipo != 'Todos') {
        url += '&tipo=$tipo';
      }
      
      final response = await _get(url);
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Negocio.fromJson(json)).toList();
      } else {
        throw Exception(_getDefaultMessage(response.statusCode));
      }
    } catch (e) {
      _logError('getNegociosCercanosConFiltro', e);
      rethrow;
    }
  }

  static Future<List<String>> getCategorias() async {
    try {
      final response = await _get('api/negocios/categorias');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => e.toString()).toList();
      } else {
        throw Exception(_getDefaultMessage(response.statusCode));
      }
    } catch (e) {
      _logError('getCategorias', e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> registrarNegocio({
    required String nombre,
    required String tipo,
    required String direccion,
    String? telefono,
    String? whatsapp,
    String? horario,
    required double latitud,
    required double longitud,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final propietarioId = prefs.getInt('usuarioId') ?? 0;
      
      final response = await _post('api/negocios', {
        'nombre': nombre,
        'descripcion': 'Registrado por dueño',
        'tipo': tipo,
        'direccion': direccion,
        'telefono': telefono ?? '',
        'horario': horario ?? '',
        'propietarioId': propietarioId,
        'latitud': latitud,
        'longitud': longitud,
      });
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('registrarNegocio', e);
      rethrow;
    }
  }

  static Future<void> actualizarNegocio(
    int negocioId, {
    required String nombre,
    required String tipo,
    required String direccion,
    String? telefono,
    String? whatsapp,
    String? horario,
    required double latitud,
    required double longitud,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final propietarioId = prefs.getInt('usuarioId') ?? 0;
      
      final response = await _put('api/negocios/$negocioId', {
        'nombre': nombre,
        'descripcion': 'Registrado por dueño',
        'tipo': tipo,
        'direccion': direccion,
        'telefono': telefono ?? '',
        'horario': horario ?? '',
        'propietarioId': propietarioId,
        'latitud': latitud,
        'longitud': longitud,
        'activo': true,
      });
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('actualizarNegocio', e);
      rethrow;
    }
  }

  static Future<List<Negocio>> getNegociosPendientes() async {
    try {
      final response = await _get('api/negocios/pendientes');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Negocio.fromJson(json)).toList();
      } else {
        throw Exception(_getDefaultMessage(response.statusCode));
      }
    } catch (e) {
      _logError('getNegociosPendientes', e);
      rethrow;
    }
  }

  static Future<void> aprobarNegocio(int negocioId) async {
    try {
      final response = await _put('api/negocios/aprobar/$negocioId', {});
      if (response.statusCode != 200) {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('aprobarNegocio', e);
      rethrow;
    }
  }

  static Future<void> rechazarNegocio(int negocioId) async {
    try {
      final response = await _put('api/negocios/rechazar/$negocioId', {});
      if (response.statusCode != 200) {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('rechazarNegocio', e);
      rethrow;
    }
  }

  // ============================================================
  // RESEÑAS - OPTIMIZADO
  // ============================================================

  static Future<List<Resena>> getResenasPorNegocio(int negocioId) async {
    try {
      final response = await _get('api/reseñas/negocio/$negocioId');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Resena.fromJson(json)).toList();
      } else {
        throw Exception(_getDefaultMessage(response.statusCode));
      }
    } catch (e) {
      _logError('getResenasPorNegocio', e);
      rethrow;
    }
  }

  static Future<void> createResena(
    int negocioId,
    int calificacion,
    String comentario,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getInt('usuarioId');
      
      if (usuarioId == null) {
        throw Exception('Usuario no autenticado. Inicia sesión nuevamente.');
      }
      
      // Validaciones
      if (calificacion < 1 || calificacion > 5) {
        throw Exception('La calificación debe estar entre 1 y 5 estrellas');
      }
      if (comentario.trim().isEmpty) {
        throw Exception('El comentario no puede estar vacío');
      }
      if (comentario.length > 1000) {
        throw Exception('El comentario no puede exceder los 1000 caracteres');
      }
      
      final response = await _post('api/reseñas', {
        'usuarioId': usuarioId,
        'negocioId': negocioId,
        'calificacion': calificacion,
        'comentario': comentario.trim(),
      });
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return;
      } else if (response.statusCode == 409) {
        throw Exception('Ya has reseñado este negocio anteriormente.');
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('createResena', e);
      rethrow;
    }
  }

  // ============================================================
  // FAVORITOS
  // ============================================================

  static Future<void> toggleFavorito(int negocioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getInt('usuarioId');
      
      if (usuarioId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      final checkResponse = await _get('api/favoritos/verificar?usuarioId=$usuarioId&negocioId=$negocioId');
      
      if (checkResponse.statusCode == 200) {
        final esFavorito = jsonDecode(checkResponse.body);
        
        if (esFavorito) {
          final response = await _delete('api/favoritos?usuarioId=$usuarioId&negocioId=$negocioId');
          if (response.statusCode != 200 && response.statusCode != 204) {
            throw Exception(_extractErrorMessage(response));
          }
        } else {
          final response = await _post('api/favoritos', {
            'usuarioId': usuarioId,
            'negocioId': negocioId,
          });
          if (response.statusCode != 200 && response.statusCode != 201) {
            throw Exception(_extractErrorMessage(response));
          }
        }
      }
    } catch (e) {
      _logError('toggleFavorito', e);
      rethrow;
    }
  }

  static Future<List<Negocio>> getFavoritos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getInt('usuarioId');
      
      if (usuarioId == null) {
        throw Exception('Usuario no autenticado');
      }
      
      final response = await _get('api/favoritos/negocios/usuario/$usuarioId');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Negocio.fromJson(json)).toList();
      } else {
        throw Exception(_getDefaultMessage(response.statusCode));
      }
    } catch (e) {
      _logError('getFavoritos', e);
      rethrow;
    }
  }

  static Future<bool> esFavorito(int negocioId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usuarioId = prefs.getInt('usuarioId');
      
      if (usuarioId == null) return false;
      
      final response = await _get('api/favoritos/verificar?usuarioId=$usuarioId&negocioId=$negocioId');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ============================================================
  // PRODUCTOS
  // ============================================================

  static Future<List<Producto>> getProductosPorNegocio(int negocioId) async {
    try {
      final response = await _get('api/productos/negocio/$negocioId');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Producto.fromJson(json)).toList();
      } else {
        throw Exception(_getDefaultMessage(response.statusCode));
      }
    } catch (e) {
      _logError('getProductosPorNegocio', e);
      rethrow;
    }
  }

  static Future<Producto> crearProducto({
    required int negocioId,
    required String nombre,
    String? descripcion,
    double? precio,
    bool destacado = true,
  }) async {
    try {
      final response = await _post('api/productos', {
        'negocioId': negocioId,
        'nombre': nombre,
        'descripcion': descripcion ?? '',
        'precio': precio,
        'destacado': destacado,
      });
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Producto.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('crearProducto', e);
      rethrow;
    }
  }

  static Future<void> actualizarProducto({
    required int id,
    required String nombre,
    String? descripcion,
    double? precio,
    bool destacado = true,
  }) async {
    try {
      final response = await _put('api/productos/$id', {
        'nombre': nombre,
        'descripcion': descripcion ?? '',
        'precio': precio,
        'destacado': destacado,
      });
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('actualizarProducto', e);
      rethrow;
    }
  }

  static Future<void> eliminarProducto(int id) async {
    try {
      final response = await _delete('api/productos/$id');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('eliminarProducto', e);
      rethrow;
    }
  }

  // ============================================================
  // PROMOCIONES
  // ============================================================

  static Future<List<Promocion>> getPromocionesActivasPorNegocio(int negocioId) async {
    try {
      final response = await _get('api/promociones/activas');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data
            .map((json) => Promocion.fromJson(json))
            .where((p) => p.negocioId == negocioId && p.estaVigente)
            .toList();
      } else {
        throw Exception(_getDefaultMessage(response.statusCode));
      }
    } catch (e) {
      _logError('getPromocionesActivasPorNegocio', e);
      rethrow;
    }
  }

  static Future<List<Promocion>> getPromocionesPorNegocio(int negocioId) async {
    try {
      final response = await _get('api/promociones/negocio/$negocioId');
      
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((json) => Promocion.fromJson(json)).toList();
      } else {
        throw Exception(_getDefaultMessage(response.statusCode));
      }
    } catch (e) {
      _logError('getPromocionesPorNegocio', e);
      rethrow;
    }
  }

  static Future<Promocion> crearPromocion({
    required int negocioId,
    required String titulo,
    required String descripcion,
    required int descuento,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    bool activa = true,
  }) async {
    try {
      final response = await _post('api/promociones', {
        'negocioId': negocioId,
        'titulo': titulo,
        'descripcion': descripcion,
        'descuento': descuento,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin.toIso8601String(),
        'activa': activa,
      });
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Promocion.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('crearPromocion', e);
      rethrow;
    }
  }

  static Future<void> actualizarPromocion({
    required int id,
    required String titulo,
    required String descripcion,
    required int descuento,
    required DateTime fechaInicio,
    required DateTime fechaFin,
    required bool activa,
  }) async {
    try {
      final response = await _put('api/promociones/$id', {
        'titulo': titulo,
        'descripcion': descripcion,
        'descuento': descuento,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin.toIso8601String(),
        'activa': activa,
      });
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('actualizarPromocion', e);
      rethrow;
    }
  }

  static Future<void> eliminarPromocion(int id) async {
    try {
      final response = await _delete('api/promociones/$id');
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('eliminarPromocion', e);
      rethrow;
    }
  }

  // ============================================================
  // IMÁGENES DEL NEGOCIO
  // ============================================================

  static Future<String> subirImagenNegocio(int negocioId, File imagen) async {
    try {
      if (!await imagen.exists()) {
        throw Exception('El archivo de imagen no existe');
      }
      
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }
      
      final bytes = await imagen.readAsBytes();
      final uri = Uri.parse('$baseUrl/api/negocios/subir-imagen');
      final request = http.MultipartRequest('POST', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['negocioId'] = negocioId.toString();
      
      final multipartFile = http.MultipartFile.fromBytes(
        'imagen',
        bytes,
        filename: 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('subirImagenNegocio', e);
      rethrow;
    }
  }

  static Future<String> actualizarFotoNegocio(int negocioId, File foto) async {
    try {
      if (!await foto.exists()) {
        throw Exception('El archivo de foto no existe');
      }
      
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }
      
      final bytes = await foto.readAsBytes();
      final uri = Uri.parse('$baseUrl/api/negocios/$negocioId/foto');
      final request = http.MultipartRequest('PUT', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      
      final multipartFile = http.MultipartFile.fromBytes(
        'foto',
        bytes,
        filename: 'foto_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['imagenUrl'];
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('actualizarFotoNegocio', e);
      rethrow;
    }
  }

  static Future<void> eliminarFotoNegocio(int negocioId) async {
    try {
      final response = await _delete('api/negocios/$negocioId/foto');
      
      if (response.statusCode != 200) {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('eliminarFotoNegocio', e);
      rethrow;
    }
  }

  // ============================================================
  // FOTOS DE PERFIL
  // ============================================================

  static Future<String> actualizarFotoPerfil(File foto) async {
    try {
      if (!await foto.exists()) {
        throw Exception('El archivo de foto no existe');
      }
      
      final token = await getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }
      
      final bytes = await foto.readAsBytes();
      final uri = Uri.parse('$baseUrl/api/usuarios/perfil/foto');
      final request = http.MultipartRequest('PUT', uri);
      
      request.headers['Authorization'] = 'Bearer $token';
      
      final multipartFile = http.MultipartFile.fromBytes(
        'foto',
        bytes,
        filename: 'perfil_${DateTime.now().millisecondsSinceEpoch}.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['fotoPerfilUrl'];
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('actualizarFotoPerfil', e);
      rethrow;
    }
  }

  static Future<void> eliminarFotoPerfil() async {
    try {
      final response = await _delete('api/usuarios/perfil/foto');
      
      if (response.statusCode != 200) {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('eliminarFotoPerfil', e);
      rethrow;
    }
  }

  // ============================================================
  // PERFIL DE USUARIO
  // ============================================================

  static Future<Usuario> getPerfil() async {
    try {
      final response = await _get('api/usuarios/perfil');
      
      if (response.statusCode == 200) {
        return Usuario.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(_getDefaultMessage(response.statusCode));
      }
    } catch (e) {
      _logError('getPerfil', e);
      rethrow;
    }
  }

  static Future<void> actualizarPerfil({
    required String nombre,
    String? telefono,
  }) async {
    try {
      final response = await _put('api/usuarios/perfil', {
        'nombre': nombre,
        'telefono': telefono ?? '',
      });
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('actualizarPerfil', e);
      rethrow;
    }
  }

  // ============================================================
  // RECUPERAR CONTRASEÑA
  // ============================================================

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(const Duration(seconds: _timeoutSeconds));
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('forgotPassword', e);
      rethrow;
    }
  }

  static Future<void> resetPassword({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'token': token,
              'newPassword': newPassword,
              'confirmPassword': confirmPassword,
            }),
          )
          .timeout(const Duration(seconds: _timeoutSeconds));
      
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('resetPassword', e);
      rethrow;
    }
  }

  // ============================================================
  // GOOGLE LOGIN
  // ============================================================

  static Future<Map<String, dynamic>> loginWithGoogle(String serverAuthCode) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/google-login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'serverAuthCode': serverAuthCode}),
          )
          .timeout(const Duration(seconds: _timeoutSeconds));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setInt('usuarioId', data['id']);
        return data;
      } else {
        throw Exception(_extractErrorMessage(response));
      }
    } catch (e) {
      _logError('loginWithGoogle', e);
      rethrow;
    }
  }

  // ============================================================
  // UTILIDADES
  // ============================================================

  static Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    if (token == null || token.isEmpty) return '';
    
    try {
      final parts = token.split('.');
      if (parts.length != 3) return '';
      
      String normalized = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      switch (normalized.length % 4) {
        case 2: normalized += '==';
        case 3: normalized += '=';
      }
      final payload = json.decode(utf8.decode(base64Url.decode(normalized)));
      
      return payload['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? '';
    } catch (e) {
      return '';
    }
  }
}