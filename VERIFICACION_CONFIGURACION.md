# 🔍 Verificación de Configuración - Google Maps

Este archivo te ayuda a verificar si todo está configurado correctamente para Google Maps.

---

## 1️⃣ Verifica que AndroidManifest.xml tiene la API Key

**PowerShell:**
```powershell
Select-String -Path "android/app/src/main/AndroidManifest.xml" -Pattern "com.google.android.geo.API_KEY"

Deberías ver algo como:
xml

<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSyCwSfgQMtHsJehWQuB0Rb03cOag4XqPhJs" />

2️⃣ Verifica los permisos de ubicación

PowerShell:
powershell

Select-String -Path "android/app/src/main/AndroidManifest.xml" -Pattern "ACCESS_FINE_LOCATION"

Deberías ver:
xml

<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

3️⃣ Verifica el Application ID

PowerShell:
powershell

Select-String -Path "android/app/build.gradle.kts" -Pattern "applicationId"

Deberías ver algo como:
kotlin

applicationId = "com.vecinoapp.app"

4️⃣ Verifica que las dependencias están instaladas
powershell

cd D:\Proyectos.Net\frontend\vecinoapp_clean

# Lista las dependencias
flutter pub list

# Busca específicamente Google Maps
flutter pub list | findstr "google_maps"

Deberías ver:

    google_maps_flutter

5️⃣ Valida que el proyecto está sano
powershell

cd D:\Proyectos.Net\frontend\vecinoapp_clean

# Revisa la salud del proyecto
flutter analyze

# O más detallado
flutter doctor -v

6️⃣ Comando completo de diagnóstico

Copia y ejecuta este comando en PowerShell:
powershell

$projectPath = "D:\Proyectos.Net\frontend\vecinoapp_clean"
cd $projectPath

Write-Host "=== VERIFICACIÓN DE CONFIGURACIÓN GOOGLE MAPS ===" -ForegroundColor Green

Write-Host "`n1. Verificando Application ID..." -ForegroundColor Yellow
$appId = Select-String -Path "android/app/build.gradle.kts" -Pattern 'applicationId = "(.*)"'
if ($appId) {
    Write-Host "✅ Application ID: $appId" -ForegroundColor Green
} else {
    Write-Host "❌ No se encontró applicationId" -ForegroundColor Red
}

Write-Host "`n2. Verificando permisos de ubicación..." -ForegroundColor Yellow
$perms = Select-String -Path "android/app/src/main/AndroidManifest.xml" -Pattern "ACCESS_FINE_LOCATION"
if ($perms) {
    Write-Host "✅ Permisos de ubicación CONFIGURADOS" -ForegroundColor Green
} else {
    Write-Host "❌ Permisos de ubicación NO CONFIGURADOS" -ForegroundColor Red
}

Write-Host "`n3. Verificando Google Maps API Key..." -ForegroundColor Yellow
$apiKey = Select-String -Path "android/app/src/main/AndroidManifest.xml" -Pattern "com.google.android.geo.API_KEY"
if ($apiKey) {
    Write-Host "✅ Google Maps API Key CONFIGURADA" -ForegroundColor Green
} else {
    Write-Host "❌ Google Maps API Key NO CONFIGURADA" -ForegroundColor Red
}

Write-Host "`n4. Verificando dependencias..." -ForegroundColor Yellow
$deps = flutter pub list 2>&1 | Select-String "google_maps_flutter"
if ($deps) {
    Write-Host "✅ google_maps_flutter INSTALADA" -ForegroundColor Green
} else {
    Write-Host "❌ google_maps_flutter NO está instalada" -ForegroundColor Red
}

Write-Host "`n=== FIN DE VERIFICACIÓN ===" -ForegroundColor Green

🚨 Próximos Pasos Después de la Verificación
Si API Key NO está configurada:

    Ve a Google Cloud Console

    Habilita Maps SDK for Android

    Crea o edita tu API Key

    Agrega restricción de Android apps con:

        Package name: com.vecinoapp.app

        SHA-1: B8:EC:9C:2A:7D:E3:1C:37:25:08:6D:90:DA:03:E2:4D:82:9B:D2:4E

Si todo está bien:
bash

flutter clean
flutter pub get
flutter run

📱 Flujo de Prueba Manual
bash

# 1. Limpia completamente
flutter clean

# 2. Obtén dependencias
flutter pub get

# 3. Ejecuta con logs detallados
flutter run -v

# 4. En la app:
#    - Inicia sesión con email: test@vecinoapp.com / Abc123
#    - Busca negocios cercanos
#    - Verifica que el mapa se ve correctamente

⚠️ Errores Comunes
Problema	Solución
Mapa gris	SHA-1 no registrado en Google Cloud Console para la API Key
Ubicación no se obtiene	Permisos no otorgados en el dispositivo
Errores después de cambios	Ejecuta flutter clean
Sigue fallando	Desinstala app: adb uninstall com.vecinoapp.app
🔗 Enlaces útiles

    Google Cloud Console

    Maps SDK for Android

    Obtener tu huella SHA-1

📝 Nota importante

Google Sign-In no está disponible en esta versión. La autenticación se realiza mediante email y contraseña.

Credenciales de prueba:

    Email: test@vecinoapp.com

    Contraseña: Abc123








