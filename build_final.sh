#!/bin/bash
# Dark Launcher APK Builder - Versión Simple

cd /workspaces/DarkLauncher

# Intentar múltiples rutas de SDK
SDK_PATHS=(
  "/home/codespace/Android/Sdk"
  "$HOME/Android/Sdk"
  "/usr/lib/android-sdk"
  "/opt/android-sdk"
)

SDK=""
for path in "${SDK_PATHS[@]}"; do
  if [ -d "$path/platforms" ] 2>/dev/null; then
    SDK="$path"
    break
  fi
done

if [ -z "$SDK" ]; then
  echo "ERROR: Android SDK no encontrado"
  echo "Rutas intentadas:"
  for path in "${SDK_PATHS[@]}"; do
    echo "  - $path"
  done
  exit 1
fi

echo "SDK encontrado: $SDK"
export ANDROID_SDK_ROOT="$SDK"

# Compilar
echo ""
echo "Compilando..."
./gradlew clean :app_pojavlauncher:assembleDebug -Pandroid.sdk.dir="$SDK" --no-daemon -x lint 2>&1

# Mostrar resultado
echo ""
if [ -f "app_pojavlauncher/build/outputs/apk/debug/app_pojavlauncher-debug.apk" ]; then
  echo "✓ APK generado en:"
  echo "app_pojavlauncher/build/outputs/apk/debug/app_pojavlauncher-debug.apk"
else
  echo "ERROR: APK no se generó"
  exit 1
fi
