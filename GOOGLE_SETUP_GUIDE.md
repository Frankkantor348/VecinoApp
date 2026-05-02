# 🔧 Guía de Configuración Google - Vecinoapp

## Tu Información de Certificado

- **SHA-1 Debug**: `96:D7:94:C9:50:04:21:31:B6:CA:F9:66:B9:7C:95:99:0A:0A:17:59`
- **Application ID**: `com.vecinoapp.app`
- **Package Name**: `com.vecinoapp.app`

---

## ❌ PROBLEMA 1: Google Sign-In No Funciona

### Causa
Falta el archivo `google-services.json` en `android/app/`

### Solución

#### Opción A: Usar Firebase (Recomendado)

1. Ve a https://console.firebase.google.com
2. Si tienes un proyecto existente de Vecinoapp, selecciónalo
3. Si no, crea uno nuevo: **"Proyecto Vecinoapp"**
4. En **Configuración del Proyecto** → **Configuración General**
5. Agrega una aplicación Android:
   - **Package name**: `com.vecinoapp.app`
   - **SHA-1 debug**: `96:D7:94:C9:50:04:21:31:B6:CA:F9:66:B9:7C:95:99:0A:0A:17:59`
6. Descarga `google-services.json`
7. Coloca el archivo en: **`android/app/google-services.json`**
8. Ejecuta: `flutter clean && flutter pub get && flutter run`

#### Opción B: Si usas Google Cloud Console directamente

1. Ve a https://console.cloud.google.com
2. Selecciona tu proyecto
3. Ve a **APIs & Services** → **Credentials**
4. Crea una OAuth 2.0 Client ID de tipo "Android"
5. Registra:
   - **Package name**: `com.vecinoapp.app`
   - **SHA-1**: `96:D7:94:C9:50:04:21:31:B6:CA:F9:66:B9:7C:95:99:0A:0A:17:59`

---

## ❌ PROBLEMA 2: Mapa Google Aparece Gris

### Causa
La clave de API de Google Maps NO está validada para tu certificado debug.

### Solución

1. Ve a https://console.cloud.google.com
2. Selecciona tu proyecto
3. **APIs & Services** → **Enabled APIs & Services**
4. Busca y HABILITA:
   - ✅ **Maps SDK for Android**
   - ✅ **Places API** (opcional, para búsqueda de lugares)
5. Ve a **Credentials**
6. Selecciona tu API Key para Google Maps
7. En **Application restrictions**, selecciona:
   - **Android apps**
8. Agrega tu app:
   - **Package name**: `com.vecinoapp.app`
   - **SHA-1**: `96:D7:94:C9:50:04:21:31:B6:CA:F9:66:B9:7C:95:99:0A:0A:17:59`
9. Guarda los cambios
10. Espera 5-10 minutos para que se propaguen
11. Ejecuta nuevamente: `flutter clean && flutter run`

---

## ⚙️ Verificación de Configuración Actual

### ✅ Ya Configurado
- ✅ AndroidManifest.xml tiene Google Maps API Key
- ✅ Permisos de ubicación en AndroidManifest.xml
- ✅ Dependencias instaladas (google_sign_in, google_maps_flutter)

### ❌ Falta
- ❌ `google-services.json` (CRÍTICO para Google Sign-In)
- ❌ SHA-1 registrado en Google Cloud Console

---

## 🧪 Después de la Configuración

Ejecuta estos comandos en orden:

```bash
cd d:\Proyectos.Net\frontend\vecinoapp_clean

# Limpiar cache
flutter clean

# Obtener dependencias
flutter pub get

# Si tienes google-services.json, rebuildeará con eso
flutter run
```

Si sigue mostrando mapa gris después de 10 minutos:
1. Verifica que la API Key está activa en Google Cloud Console
2. Asegúrate que "Maps SDK for Android" está habilitada
3. Limpia el cache: `flutter clean`
4. Desinstala la app: `adb uninstall com.vecinoapp.app`
5. Ejecuta nuevamente: `flutter run`

---

## 📞 Soporte

Si necesitas más ayuda:
1. Revisa la consola de Android Studio para errores
2. Ejecuta: `flutter run -v` para logs detallados
3. Busca errores de "Google Maps" o "Google Sign-In" en los logs

