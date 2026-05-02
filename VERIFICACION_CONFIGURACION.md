# 🔍 Verificación de Configuración - Google Maps y Google Sign-In

Este archivo te ayuda a verificar si todo está configurado correctamente.

## 1️⃣ Verifica que AndroidManifest.xml tiene la API Key

```bash
# Windows PowerShell - Busca en AndroidManifest.xml
Select-String -Path "android/app/src/main/AndroidManifest.xml" -Pattern "com.google.android.geo.API_KEY"
```

**Deberías ver algo como:**
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyCwSfgQMtHsJehWQuB0Rb03cOag4XqPhJs" />
```

---

## 2️⃣ Verifica que google-services.json existe

```bash
# Windows PowerShell
Test-Path "android/app/google-services.json"
```

**Deberías ver:** `True`

Si es `False`, el archivo NO existe. Necesitas descargarlo desde Firebase.

---

## 3️⃣ Verifica los permisos en AndroidManifest.xml

```bash
# Busca permisos de ubicación
Select-String -Path "android/app/src/main/AndroidManifest.xml" -Pattern "ACCESS_FINE_LOCATION"
```

**Deberías ver:**
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
```

---

## 4️⃣ Verifica el Application ID

```bash
# Busca el applicationId en build.gradle.kts
Select-String -Path "android/app/build.gradle.kts" -Pattern "applicationId"
```

**Deberías ver algo como:**
```
applicationId = "com.vecinoapp.app"
```

---

## 5️⃣ Verifica que las dependencias están instaladas

```bash
cd d:\Proyectos.Net\frontend\vecinoapp_clean

# Lista las dependencias
flutter pub list

# Busca específicamente Google Sign-In y Google Maps
flutter pub list | findstr "google"
```

**Deberías ver:**
- `google_sign_in`
- `google_maps_flutter`

---

## 6️⃣ Valida que el proyecto está sano

```bash
cd d:\Proyectos.Net\frontend\vecinoapp_clean

# Revisa la salud del proyecto
flutter analyze

# O más detallado
flutter doctor -v
```

---

## 7️⃣ Comando completo de diagnóstico

Copia y ejecuta este comando en PowerShell:

```powershell
$projectPath = "d:\Proyectos.Net\frontend\vecinoapp_clean"
cd $projectPath

Write-Host "=== VERIFICACIÓN DE CONFIGURACIÓN GOOGLE ===" -ForegroundColor Green

Write-Host "`n1. Verificando google-services.json..." -ForegroundColor Yellow
if (Test-Path "android/app/google-services.json") {
    Write-Host "✅ google-services.json EXISTE" -ForegroundColor Green
} else {
    Write-Host "❌ google-services.json NO EXISTE - NECESITAS DESCARGARLO" -ForegroundColor Red
}

Write-Host "`n2. Verificando Application ID..." -ForegroundColor Yellow
$appId = Select-String -Path "android/app/build.gradle.kts" -Pattern 'applicationId = "(.*)"'
if ($appId) {
    Write-Host "✅ $appId" -ForegroundColor Green
} else {
    Write-Host "❌ No se encontró applicationId" -ForegroundColor Red
}

Write-Host "`n3. Verificando permisos de ubicación..." -ForegroundColor Yellow
$perms = Select-String -Path "android/app/src/main/AndroidManifest.xml" -Pattern "ACCESS_FINE_LOCATION"
if ($perms) {
    Write-Host "✅ Permisos de ubicación CONFIGURADOS" -ForegroundColor Green
} else {
    Write-Host "❌ Permisos de ubicación NO CONFIGURADOS" -ForegroundColor Red
}

Write-Host "`n4. Verificando Google Maps API Key..." -ForegroundColor Yellow
$apiKey = Select-String -Path "android/app/src/main/AndroidManifest.xml" -Pattern "com.google.android.geo.API_KEY"
if ($apiKey) {
    Write-Host "✅ Google Maps API Key CONFIGURADA" -ForegroundColor Green
} else {
    Write-Host "❌ Google Maps API Key NO CONFIGURADA" -ForegroundColor Red
}

Write-Host "`n5. Verificando dependencias..." -ForegroundColor Yellow
$deps = flutter pub list 2>&1 | Select-String "google_sign_in|google_maps_flutter"
if ($deps) {
    Write-Host "✅ Dependencias de Google INSTALADAS" -ForegroundColor Green
} else {
    Write-Host "❌ Algunas dependencias NO están instaladas" -ForegroundColor Red
}

Write-Host "`n=== FIN DE VERIFICACIÓN ===" -ForegroundColor Green
```

---

## 🚨 Próximos Pasos Después de la Verificación

1. **Si google-services.json NO existe:**
   - Ve a https://console.firebase.google.com
   - Descarga google-services.json
   - Colócalo en `android/app/`

2. **Si API Key NO está configurada:**
   - Ve a https://console.cloud.google.com
   - Agrega tu SHA-1 a la API Key

3. **Si todo está bien:**
   ```bash
   flutter clean
   flutter run
   ```

---

## 📱 Flujo de Prueba Manual

```bash
# 1. Limpia completamente
flutter clean

# 2. Obtén dependencias
flutter pub get

# 3. Ejecuta con logs detallados
flutter run -v

# 4. En la app:
#    - Intenta iniciar sesión con Google
#    - Intenta registrar un negocio (ve el mapa)
```

---

## ⚠️ Errores Comunes

| Problema | Solución |
|----------|----------|
| Mapa gris | SHA-1 no registrado en Google Cloud Console |
| Google Login falla | google-services.json no existe o está mal |
| Ubicación no se obtiene | Permisos no otorgados en el dispositivo |
| Errores después de cambios | Ejecuta `flutter clean` |
| Sigue fallando | Desinstala app: `adb uninstall com.vecinoapp.app` |

