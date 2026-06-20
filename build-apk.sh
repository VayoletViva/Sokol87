#!/usr/bin/env bash
# ============================================================
#  СОКОЛ-87 — автоматическая сборка APK через Capacitor
#  Использование:  bash build-apk.sh
#  Требует: Node.js 18+, JDK 17, Android SDK (см. README.md)
# ============================================================
set -e

APP_ID="com.celesteal.sokol87"
APP_NAME="СОКОЛ-87"

echo "════════════════════════════════════════════"
echo "  СОКОЛ-87 · сборка APK (Capacitor)"
echo "════════════════════════════════════════════"

# 1. зависимости
if [ ! -d node_modules ]; then
  echo "▸ установка зависимостей npm..."
  npm install
fi

# 2. инициализация Capacitor (только если ещё не инициализирован)
if [ ! -f capacitor.config.json ] && [ ! -f capacitor.config.ts ]; then
  echo "▸ инициализация Capacitor..."
  npx cap init "$APP_NAME" "$APP_ID" --web-dir=www
fi

# 3. добавить платформу Android (только если папки android ещё нет)
if [ ! -d android ]; then
  echo "▸ добавление платформы Android..."
  npx cap add android
fi

# 4. синхронизация web -> android
echo "▸ синхронизация веб-ассетов..."
npx cap sync android

# 5. твики AndroidManifest: landscape + fullscreen + keep screen on
echo "▸ патч AndroidManifest (landscape/fullscreen)..."
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
  # ориентация: только альбомная
  if ! grep -q 'screenOrientation' "$MANIFEST"; then
    sed -i 's/android:name="\.MainActivity"/android:name=".MainActivity"\n            android:screenOrientation="sensorLandscape"\n            android:keepScreenOn="true"/' "$MANIFEST"
  fi
fi

# 6. патч стилей: полноэкранный режим без тайтлбара
STYLES="android/app/src/main/res/values/styles.xml"
if [ -f "$STYLES" ]; then
  echo "▸ патч стилей (immersive fullscreen)..."
  python3 - "$STYLES" <<'PYEOF' || true
import sys,re
p=sys.argv[1]
s=open(p).read()
if 'windowFullscreen' not in s:
    # добавить флаги фуллскрина в основную тему приложения
    s=s.replace('</style>',
        '    <item name="android:windowFullscreen">true</item>\n'
        '    <item name="android:windowContentOverlay">@null</item>\n'
        '</style>',1)
    open(p,'w').write(s)
PYEOF
fi

# 7. сборка debug APK
echo "▸ сборка debug APK (gradlew assembleDebug)..."
cd android
chmod +x gradlew 2>/dev/null || true
./gradlew assembleDebug
cd ..

APK_PATH="android/app/build/outputs/apk/debug/app-debug.apk"
echo ""
echo "════════════════════════════════════════════"
if [ -f "$APK_PATH" ]; then
  cp "$APK_PATH" "./sokol87-debug.apk"
  echo "  ✓ ГОТОВО:  sokol87-debug.apk"
  echo "  Установи на телефон и играй (offline)."
else
  echo "  ! APK не найден. Проверь вывод Gradle выше."
fi
echo "════════════════════════════════════════════"
