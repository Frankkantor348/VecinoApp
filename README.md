# 🏪 VeciNoApp

Aplicación móvil para descubrir negocios cercanos en tu barrio.

## 📱 Características actuales

- ✅ Autenticación con email/contraseña
- ✅ Búsqueda de negocios cercanos por ubicación
- ✅ Sistema de reseñas y calificaciones (1-5 estrellas)
- ✅ Lista de favoritos
- ✅ Contacto directo por WhatsApp
- ✅ Panel de administración para gestionar negocios
- ✅ Modo oscuro/claro
- ✅ Gestión de productos y promociones
- ⚠️ Google Sign-In (en desarrollo - no funcional)

## 🛠️ Tecnologías utilizadas

| Tecnología | Propósito |
|------------|-----------|
| Flutter | Framework principal |
| Dart | Lenguaje de programación |
| Geolocator | Permisos y ubicación |
| SharedPreferences | Almacenamiento local |
| url_launcher | WhatsApp y enlaces |

## 📋 Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versión 3.0 o superior)
- [Android Studio](https://developer.android.com/studio) o VS Code
- Dispositivo Android (físico o emulador)
- **Backend .NET corriendo** (repositorio separado)

## 🚀 Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/Frankkantor348/VecinoApp.git
cd VecinoApp
2. Instalar dependencias
bash

flutter pub get

3. Configurar el backend

La app necesita un backend .NET corriendo. Configura la URL en lib/services/api_service.dart:
dart

static const String baseUrl = 'http://TU_IP:5067';

4. Ejecutar la app
bash

flutter run

🔐 Credenciales de prueba
Email	Contraseña
test@vecinoapp.com	Abc123
📁 Estructura del proyecto
text

lib/
├── models/          # Modelos de datos
├── screens/         # Pantallas de la aplicación
├── services/        # Servicios (API, autenticación)
├── widgets/         # Widgets reutilizables
└── utils/           # Utilidades y temas

❓ Solución de problemas comunes
Error de conexión con el backend

    Verifica que la baseUrl en api_service.dart sea correcta

    Asegúrate de que el backend esté corriendo

    Si usas dispositivo físico, ambos deben estar en la misma red WiFi

Error de compilación
bash

flutter clean
flutter pub get
flutter run

⚠️ Estado del proyecto
Funcionalidad	Estado
Login con email	✅ Funcional
Google Sign-In	⚠️ No funcional (requiere configuración adicional en Google Cloud Console)
Reseñas	✅ Funcional
Favoritos	✅ Funcional
WhatsApp	✅ Funcional
📞 Contacto

Desarrollador: Frank Kantor y Dilan Jimenez
GitHub: Frankkantor348
📄 Licencia

Proyecto académico - Todos los derechos reservados.

La aplicación es completamente funcional. Para ejecutarla correctamente, necesitas:

    ✅ Clonar el repositorio

    ✅ Configurar Firebase (crear proyecto y descargar google-services.json)

    ✅ Configurar el backend (o usar el enlace proporcionado)

    ✅ Ejecutar flutter pub get y flutter run






