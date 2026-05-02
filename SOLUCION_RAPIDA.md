# 🚀 SOLUCIÓN RÁPIDA - Errores de Google Login y Mapa Gris

## Tu Certificado Debug
```
SHA-1: 96:D7:94:C9:50:04:21:31:B6:CA:F9:66:B9:7C:95:99:0A:0A:17:59
ApplicationID: com.vecinoapp.app
```

---

## 🔴 PROBLEMA 1: Mapa Aparece Gris ❌

### ¿Por qué ocurre?
La API Key de Google Maps NO está validada para tu certificado de desarrollo.

### ✅ SOLUCIÓN (10 minutos)

#### Paso 1: Ve a Google Cloud Console
- 🔗 https://console.cloud.google.com
- Selecciona tu proyecto (o crea uno nuevo)

#### Paso 2: Habilita Google Maps API
- Ve a **APIs & Services** → **Enabled APIs & Services**
- Busca "Maps SDK for Android"
- Click en **ENABLE**

#### Paso 3: Registra tu certificado
- Ve a **APIs & Services** → **Credentials**
- Encuentra tu **API Key** para Google Maps
- Click en la clave
- En **Application restrictions**:
  - Selecciona **Android apps**
  - Click **ADD PACKAGE NAME AND FINGERPRINT**
  - Package name: `com.vecinoapp.app`
  - SHA-1: `96:D7:94:C9:50:04:21:31:B6:CA:F9:66:B9:7C:95:99:0A:0A:17:59`
- Click **SAVE**

#### Paso 4: Espera y prueba
- Espera **5-10 minutos** para que se propague
- Ejecuta:
  ```bash
  flutter clean
  flutter run
  ```

**⏱️ Si sigue gris después de 10 minutos:**
1. Verifica que Maps SDK for Android esté habilitada
2. Verifica que el SHA-1 está correctamente registrado
3. Limpia: `flutter clean` y `flutter run`

---

## 🔴 PROBLEMA 2: Google Sign-In No Funciona ❌

### ¿Por qué ocurre?
Falta el archivo `google-services.json` en Android y el OAuth 2.0 Client ID no está configurado.

### ✅ SOLUCIÓN (15 minutos)

#### Opción A: Usando Firebase (RECOMENDADO) ⭐

**Paso 1: Configura Firebase**
- 🔗 https://console.firebase.google.com
- Crea un proyecto o selecciona "Vecinoapp"
- Ve a **Project Settings** (⚙️ en esquina superior izquierda)

**Paso 2: Agrega tu app Android**
- Click en **Add App** → **Android**
- Android package name: `com.vecinoapp.app`
- SHA-1: `96:D7:94:C9:50:04:21:31:B6:CA:F9:66:B9:7C:95:99:0A:0A:17:59`
- Click **Continue** → **Download google-services.json**

**Paso 3: Coloca el archivo**
- Descargado: `google-services.json`
- Cópialo a: `android/app/google-services.json`

**Paso 4: Verifica que google_sign_in esté habilitado en Firebase**
- En Firebase Console → **Build** → **Authentication**
- Habilita **Google** como proveedor

**Paso 5: Prueba**
```bash
cd d:\Proyectos.Net\frontend\vecinoapp_clean
flutter clean
flutter pub get
flutter run
```

---

#### Opción B: Configurar en Google Cloud Console (si prefieres)

1. Ve a https://console.cloud.google.com
2. **APIs & Services** → **Credentials**
3. **Create Credentials** → **OAuth 2.0 Client IDs**
4. Application type: **Android**
5. Package name: `com.vecinoapp.app`
6. SHA-1: `96:D7:94:C9:50:04:21:31:B6:CA:F9:66:B9:7C:95:99:0A:0A:17:59`
7. Create

---

## 🧪 Verificación Final

Ejecuta estos comandos en orden:

```bash
# Navega al proyecto
cd d:\Proyectos.Net\frontend\vecinoapp_clean

# Limpia el cache y archivos previos
flutter clean

# Obtén las dependencias
flutter pub get

# Ejecuta con logs detallados
flutter run -v
```

---

## 📊 Checklist de Configuración

- [ ] SHA-1 registrado en Google Cloud Console
- [ ] Maps SDK for Android habilitada
- [ ] OAuth 2.0 Client ID creado para Android
- [ ] `google-services.json` descargado y colocado en `android/app/`
- [ ] `flutter clean` ejecutado
- [ ] `flutter run` ejecutado sin errores

---

## 🆘 Si aún hay problemas...

### Mapa sigue gris:
```bash
# Desinstala la app completamente
adb uninstall com.vecinoapp.app

# Limpia y ejecuta nuevamente
flutter clean
flutter run
```

### Google Login sigue fallando:
1. Verifica que `google-services.json` existe en `android/app/`
2. Verifica el contenido del archivo (no debe estar vacío)
3. Revisa los logs:
   ```bash
   flutter run -v | findstr "Google\|Sign\|error"
   ```

### Logs detallados:
```bash
# Ver todos los logs de Google
flutter run -v 2>&1 | findstr "Google"

# Ver errores específicos
adb logcat | findstr "Google\|Maps"
```

---

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

