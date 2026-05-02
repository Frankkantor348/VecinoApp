# 🗺️ Guía de Configuración - Google Maps para VecinoApp

## 📋 Tu información de la app

| Dato | Valor |
|------|-------|
| **Package Name** | `com.vecinoapp.app` |
| **SHA-1 Debug** | `B8:EC:9C:2A:7D:E3:1C:37:25:08:6D:90:DA:03:E2:4D:82:9B:D2:4E` |

---

## ❌ PROBLEMA: Google Maps Aparece en Gris

### Causa
La clave de API de Google Maps NO está validada para tu certificado debug.

### Solución paso a paso

#### 1. Habilitar las APIs necesarias

Ve a [Google Cloud Console](https://console.cloud.google.com/)

1. Selecciona tu proyecto
2. Ve a **APIs & Services** → **Enabled APIs & Services**
3. Busca y **HABILITA**:
   - ✅ **Maps SDK for Android**
   - ✅ **Places API** (opcional, para búsqueda de lugares)

#### 2. Configurar la API Key

1. En **APIs & Services** → **Credentials**
2. Selecciona tu API Key para Google Maps (o crea una nueva)
3. En **Application restrictions**, selecciona: **Android apps**
4. Haz clic en **Agregar package name y huella digital**
5. Agrega tu app:
   - **Package name:** `com.vecinoapp.app`
   - **SHA-1:** `B8:EC:9C:2A:7D:E3:1C:37:25:08:6D:90:DA:03:E2:4D:82:9B:D2:4E`
6. Guarda los cambios

#### 3. Esperar la propagación

⏱️ **Espera 5-10 minutos** para que los cambios se propaguen en los servidores de Google.

#### 4. Reconstruir la app

```bash
cd D:\Proyectos.Net\frontend\vecinoapp_clean

# Limpiar caché
flutter clean

# Obtener dependencias
flutter pub get

# Ejecutar la app
flutter run

✅ Verificación de configuración actual
Ya configurado en el proyecto

    ✅ AndroidManifest.xml tiene la API Key de Google Maps

    ✅ Permisos de ubicación en AndroidManifest.xml

    ✅ Dependencias instaladas (google_maps_flutter)

Lo que debes hacer tú

    ⚠️ Habilitar Maps SDK for Android en Google Cloud Console

    ⚠️ Restringir tu API Key con tu package name y SHA-1

🧪 Después de la configuración

Ejecuta estos comandos en orden:
bash

cd D:\Proyectos.Net\frontend\vecinoapp_clean

# Limpiar cache
flutter clean

# Obtener dependencias
flutter pub get

# Ejecutar la app
flutter run

Si el mapa sigue en gris después de 10 minutos:

    Verifica que la API Key está activa en Google Cloud Console

    Asegúrate que "Maps SDK for Android" está habilitada

    Verifica que el SHA-1 sea el correcto ejecutando:
    bash

    cd android
    ./gradlew signingReport

    Limpia todo y reconstruye:
    bash

    flutter clean
    flutter pub get
    flutter run

📝 Nota importante

Google Sign-In no está disponible en esta versión. La autenticación se realiza mediante email y contraseña.

Credenciales de prueba:

    Email: test@vecinoapp.com

    Contraseña: Abc123

📞 Soporte

Si necesitas más ayuda:

    Revisa la consola de Android Studio para errores

    Ejecuta: flutter run -v para logs detallados

    Busca errores relacionados con "Google Maps" en los logs

🔗 Enlaces útiles

    Google Cloud Console

    Maps SDK for Android documentation

    Obtener tu huella SHA-1

