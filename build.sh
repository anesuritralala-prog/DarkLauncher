#!/bin/bash
set -e

echo "=== Compilando APK Dark Launcher ==="

# Usar la ruta del SDK si se pasó, sino asumir esta
SDK="${ANDROID_SDK_ROOT:-/home/codespace/.oh-my-zsh/plugins/sdk}"

# Aceptar licencias (ignora si falla)
yes 2>/dev/null | sdkmanager --sdk_root="$SDK" --licenses >/dev/null 2>&1 || true

# Instalar NDK (ignora si falla o ya existe)
sdkmanager --sdk_root="$SDK" "ndk;28.2.13676358" >/dev/null 2>&1 || true

# Compilar APK
echo "Compilando... (esto puede tardar varios minutos)"
./gradlew clean :app_pojavlauncher:assembleDebug \
  -Pandroid.sdk.dir="$SDK" \
  --no-daemon \
  -x lint \
  2>&1 | tail -50

# Buscar APK
APK=$(find app_pojavlauncher/build/outputs/apk -name "*.apk" 2>/dev/null | head -1)

if [ -n "$APK" ]; then
  echo ""
  echo "✓ ¡APK COMPILADO EXITOSAMENTE!"
  echo ""
  echo "Ruta: $APK"
  echo "Tamaño: $(ls -lh "$APK" | awk '{print $5}')"
  echo ""
else
  echo "ERROR: No se encontró APK. Revisa los errores arriba."
  exit 1
fi
