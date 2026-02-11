#!/bin/bash
set -e

echo "=========================================="
echo "Dark Launcher APK Builder"
echo "=========================================="
echo ""

# Detectar si ya existe Android SDK
SDK_ROOT="$HOME/Android/Sdk"
if [ ! -d "$SDK_ROOT/platforms" ]; then
  echo "❌ Android SDK no encontrado en $SDK_ROOT"
  echo ""
  echo "Instalando Android SDK..."
  mkdir -p "$SDK_ROOT"
  
  # Descargar SDK Tools
  echo "Descargando Android SDK Command-line tools..."
  cd /tmp
  wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O sdk-tools.zip || {
    echo "ERROR: No se pudo descargar SDK. Verifica tu conexión a internet."
    exit 1
  }
  
  unzip -q sdk-tools.zip
  mkdir -p "$SDK_ROOT/cmdline-tools/latest"
  mv cmdline-tools/* "$SDK_ROOT/cmdline-tools/latest/"
  rm -rf cmdline-tools sdk-tools.zip
  
  export PATH="$SDK_ROOT/cmdline-tools/latest/bin:$PATH"
  
  # Aceptar licencias
  echo "Aceptando licencias..."
  yes | sdkmanager --sdk_root="$SDK_ROOT" --licenses >/dev/null 2>&1
  
  # Instalar componentes requeridos
  echo "Instalando componentes del SDK..."
  sdkmanager --sdk_root="$SDK_ROOT" "platforms;android-33" "build-tools;33.0.0" "ndk;28.2.13676358" >/dev/null 2>&1
fi

export ANDROID_SDK_ROOT="$SDK_ROOT"
export PATH="$SDK_ROOT/cmdline-tools/latest/bin:$PATH"

echo "✓ SDK configurado: $ANDROID_SDK_ROOT"
echo ""

# Asegurar Java 17
if ! java -version 2>&1 | grep -E '"?17' >/dev/null 2>&1; then
  echo "Instalando Java 17..."
  sudo apt-get update -qq >/dev/null 2>&1
  sudo apt-get install -y openjdk-17-jdk >/dev/null 2>&1
fi

export JAVA_HOME=$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")
export PATH="$JAVA_HOME/bin:$PATH"

echo "✓ Java: $(java -version 2>&1 | head -1)"
echo ""

# Compilar APK
echo "Compilando Dark Launcher APK..."
echo "(esto puede tardar 5-10 minutos)"
echo ""

cd /workspaces/DarkLauncher

./gradlew clean :app_pojavlauncher:assembleDebug \
  -Pandroid.sdk.dir="$ANDROID_SDK_ROOT" \
  --no-daemon \
  -x lint \
  -q

# Buscar APK
APK=$(find app_pojavlauncher/build/outputs/apk/debug -name "*.apk" 2>/dev/null | head -1)

if [ -z "$APK" ]; then
  echo "❌ ERROR: APK no se generó"
  exit 1
fi

echo ""
echo "=========================================="
echo "✓ ¡APK COMPILADO EXITOSAMENTE!"
echo "=========================================="
echo ""
echo "Ruta: $APK"
echo "Tamaño: $(ls -lh "$APK" | awk '{print $5}')"
echo ""
echo "Para descargar:"
echo "1. Abre Files en Codespaces"
echo "2. Navega a: app_pojavlauncher/build/outputs/apk/debug/"
echo "3. Click derecho en el .apk → Download"
echo ""
