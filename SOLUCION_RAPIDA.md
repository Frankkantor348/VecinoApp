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


# 🗺️ SOLUCIÓN RÁPIDA - Error de Mapa Gris

## 📋 Tu certificado debug

| Dato | Valor |
|------|-------|
| **Package Name** | `com.vecinoapp.app` |
| **SHA-1 Debug** | `B8:EC:9C:2A:7D:E3:1C:37:25:08:6D:90:DA:03:E2:4D:82:9B:D2:4E` |

---

## 🔴 PROBLEMA: Mapa Aparece Gris ❌

### ¿Por qué ocurre?

La API Key de Google Maps NO está validada para tu certificado de desarrollo.

---

## ✅ SOLUCIÓN (10 minutos)

### Paso 1: Ve a Google Cloud Console

🔗 [https://console.cloud.google.com](https://console.cloud.google.com)

- Selecciona tu proyecto (o crea uno nuevo)
- Si no tienes proyecto, crea uno nuevo: "VecinoApp-Maps"

---

### Paso 2: Habilita Google Maps API

1. Ve a **APIs & Services** → **Enabled APIs & Services**
2. Haz clic en **+ ENABLE APIS AND SERVICES**
3. Busca **"Maps SDK for Android"**
4. Haz clic en **ENABLE**

---

### Paso 3: Configura tu API Key

1. Ve a **APIs & Services** → **Credentials**
2. Encuentra tu API Key para Google Maps (o créala):
   - **Create Credentials** → **API Key**
   - Copia la clave generada
3. Haz clic en el ícono de **lápiz** para editar la clave
4. En **Application restrictions**, selecciona: **Android apps**
5. Haz clic en **ADD PACKAGE NAME AND FINGERPRINT**
6. Agrega tu app:
   - **Package name:** `com.vecinoapp.app`
   - **SHA-1:** `B8:EC:9C:2A:7D:E3:1C:37:25:08:6D:90:DA:03:E2:4D:82:9B:D2:4E`
7. Haz clic en **DONE**
8. En **API restrictions**, selecciona: **Restrict key** → **Maps SDK for Android**
9. Haz clic en **SAVE**

---

### Paso 4: Agrega la API Key en tu proyecto

Abre el archivo: `android/app/src/main/AndroidManifest.xml`

Agrega dentro de `<application>`:

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="TU_API_KEY_AQUI" />

Paso 5: Espera y prueba

⏱️ Espera 5-10 minutos para que los cambios se propaguen.

Luego ejecuta:
bash

cd D:\Proyectos.Net\frontend\vecinoapp_clean

# Limpiar cache
flutter clean

# Obtener dependencias
flutter pub get

# Ejecutar la app
flutter run

🧪 Verificación final

Ejecuta estos comandos en orden:
bash

cd D:\Proyectos.Net\frontend\vecinoapp_clean

# Limpia el cache
flutter clean

# Obtén las dependencias
flutter pub get

# Ejecuta la app
flutter run

📊 Checklist de configuración

    ¿Tienes un proyecto en Google Cloud Console?

    ¿Habilitaste Maps SDK for Android?

    ¿Configuraste tu API Key con restricción de Android app?

    ¿Registraste el Package name y SHA-1 correcto?

    ¿Agregaste la API Key en AndroidManifest.xml?

    ¿Ejecutaste flutter clean?

    ¿Ejecutaste flutter run?

🔍 Si el mapa sigue en gris después de 10 minutos
1. Verifica la API Key

    Ve a Google Cloud Console → Credentials

    Verifica que la API Key esté activa

    Verifica que Maps SDK for Android esté habilitada

2. Verifica el SHA-1

Ejecuta este comando y confirma que el SHA-1 sea el mismo:
bash

cd android
./gradlew signingReport

Busca Variant: debug → SHA1: B8:EC:9C:2A:7D:E3:1C:37:25:08:6D:90:DA:03:E2:4D:82:9B:D2:4E
3. Limpieza completa
bash

# Desinstala la app completamente
adb uninstall com.vecinoapp.app

# Limpia todo
flutter clean

# Reconstruye
flutter pub get
flutter run

4. Ver logs detallados
bash

flutter run -v 2>&1 | findstr "Maps"

💡 Tips importantes
Tip	Explicación
⏱️ Espera después de cambios	Los cambios en Google Cloud pueden tardar 5-10 minutos
🧹 Siempre haz flutter clean	Antes de probar cambios importantes
📝 Verifica nombres exactos	El package name debe ser exactamente com.vecinoapp.app
🔑 Re-stringe tu API Key	Nunca dejes una API Key sin restricciones
📝 Nota importante

Google Sign-In no está disponible en esta versión. La autenticación se realiza mediante email y contraseña.

Credenciales de prueba:

    Email: test@vecinoapp.com

    Contraseña: Abc123

🔗 Enlaces útiles

    Google Cloud Console

    Maps SDK for Android documentation

    Obtener tu huella SHA-1

🆘 ¿Sigue sin funcionar?

Si después de seguir todos los pasos el mapa sigue en gris:

    Revisa la consola de Android Studio para errores específicos

    Ejecuta: flutter run -v y busca errores de "Maps" o "API Key"

    Contacta al desarrollador con los logs de error

text





## 💡 Tips importantes

1. **Espera después de cambios en Google Cloud**: Los cambios pueden tardar 5-10 minutos
2. **Limpia siempre antes de probar**: `flutter clean` es tu amigo
3. **Verifica nombres exactos**: El package name debe ser exactamente `com.vecinoapp.app`
4. **Los archivos importan**: `google-services.json` debe estar en `android/app/` NO en otro lado

---

## 🔗 Enlaces útiles

- Firebase Console: https://console.firebase.google.com
- Google Cloud Console: https://console.cloud.google.com
- Documentación Google Sign-In Flutter: https://pub.dev/packages/google_sign_in
- Documentación Google Maps Flutter: https://pub.dev/packages/google_maps_flutter

