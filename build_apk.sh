#!/bin/bash
set -e

echo "=== Dark Launcher APK Build Script ==="
echo ""

# 1) Detectar SDK
echo "[1/6] Detectando Android SDK..."
SDK_ROOT="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-$HOME/Android/Sdk}}"
if [ ! -d "$SDK_ROOT" ]; then
  echo "ERROR: No se encontró Android SDK en $SDK_ROOT"
  echo "Exporta ANDROID_SDK_ROOT con la ruta correcta:"
  echo "  export ANDROID_SDK_ROOT=/ruta/al/sdk"
  echo "  bash build_apk.sh"
  exit 1
fi
export ANDROID_SDK_ROOT="$SDK_ROOT"
export PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/tools/bin:$PATH"
echo "✓ SDK encontrado: $ANDROID_SDK_ROOT"
echo ""

# 2) Aceptar licencias
echo "[2/6] Aceptando licencias del SDK..."
yes | sdkmanager --sdk_root="$ANDROID_SDK_ROOT" --licenses 2>/dev/null || true
echo "✓ Licencias procesadas"
echo ""

# 3) Instalar NDK
echo "[3/6] Instalando NDK 28.2.13676358..."
sdkmanager --sdk_root="$ANDROID_SDK_ROOT" "ndk;28.2.13676358" 2>&1 | tail -5
echo "✓ NDK instalado"
echo ""

# 4) Verificar Java 17
echo "[4/6] Verificando Java 17..."
if ! java -version 2>&1 | grep -E '"?17' >/dev/null 2>&1; then
  echo "Java 17 no encontrado. Intentando instalar openjdk-17-jdk..."
  sudo apt-get update -qq
  sudo apt-get install -y openjdk-17-jdk >/dev/null 2>&1
fi
export JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")
export PATH="$JAVA_HOME/bin:$PATH"
JAVA_VERSION=$(java -version 2>&1 | head -1)
echo "✓ Java: $JAVA_VERSION"
echo ""

# 5) Build APK
echo "[5/6] Compilando APK (esto puede tardar 5-10 minutos)..."
./gradlew clean :app_pojavlauncher:assembleDebug \
  -Pandroid.sdk.dir="$ANDROID_SDK_ROOT" \
  --no-daemon \
  -x lint \
  -q

echo "✓ Build completado"
echo ""

# 6) Localizar APK
echo "[6/6] Localizando APK..."
APK_PATH=$(find app_pojavlauncher -type f -name "*debug*.apk" | head -n1)
if [ -z "$APK_PATH" ]; then
  echo "ERROR: No se encontró el APK generado"
  exit 1
fi
echo ""
echo "======================================"
echo "✓ APK compilado exitosamente"
echo "======================================"
echo ""
echo "Ruta del APK:"
echo "  $APK_PATH"
echo ""
echo "Tamaño:"
ls -lh "$APK_PATH" | awk '{print "  " $5}'
echo ""
echo "Para descargar:"
echo "  1) Abre Files en Codespaces"
echo "  2) Navega hasta la ruta del APK"
echo "  3) Click derecho → Download"
echo ""
