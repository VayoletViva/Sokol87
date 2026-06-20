# СОКОЛ-87 → APK

Готовая среда для упаковки игры **СОКОЛ-87** (один HTML-файл, offline) в Android-приложение `.apk` через **Capacitor**.

Игра уже лежит в `www/index.html`. Тебе остаётся только собрать APK одним из трёх способов ниже.

---

## Что внутри

```
sokol-apk/
├── www/index.html              ← сама игра (готова, offline)
├── capacitor.config.json       ← конфиг приложения (landscape, fullscreen)
├── package.json                ← зависимости Capacitor + скрипты
├── build-apk.sh                ← автосборка одной командой
├── .github/workflows/
│   └── build-apk.yml           ← облачная сборка (GitHub Actions)
└── README.md                   ← этот файл
```

Параметры приложения (меняй в `capacitor.config.json`):
- **Имя:** СОКОЛ-87
- **ID пакета:** `com.celesteal.sokol87`
- **Ориентация:** альбомная (landscape), экран не гаснет, полноэкранный режим

---

## ⭐ Способ 1 — ОНЛАЙН (GitHub Actions) — без установки SDK

Самый простой, если не хочешь ставить Android SDK. Собирает APK в облаке.

1. Создай репозиторий на GitHub, залей туда содержимое папки `sokol-apk/`.
2. Открой вкладку **Actions** в репозитории.
3. Выбери workflow **«Сборка APK (СОКОЛ-87)»** → **Run workflow**.
4. Через ~5 минут скачай готовый APK из раздела **Artifacts** (`sokol87-debug-apk`).

> Файл `.github/workflows/build-apk.yml` уже настроен — ставит Node, JDK, Android SDK, собирает и отдаёт APK артефактом.

---

## 📱 Способ 2 — ЛОКАЛЬНО НА ANDROID (Termux)

Собрать APK прямо на телефоне. Дольше в настройке, но без ПК.

```bash
# 1. В Termux ставим пакеты
pkg update && pkg upgrade -y
pkg install nodejs openjdk-17 gradle git wget unzip -y

# 2. Android SDK command-line tools
mkdir -p ~/android-sdk/cmdline-tools
cd ~/android-sdk/cmdline-tools
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-*.zip && mv cmdline-tools latest

# 3. переменные окружения (добавь в ~/.bashrc)
export ANDROID_SDK_ROOT=$HOME/android-sdk
export PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

# 4. компоненты SDK
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
yes | sdkmanager --licenses

# 5. собираем игру
cd ~/sokol-apk
bash build-apk.sh
```

> ⚠️ Termux + Android SDK — тяжёлая связка, сборка может занять время и место. Если тормозит — используй Способ 1 (онлайн).

Готовый APK: `~/sokol-apk/sokol87-debug.apk`

---

## 💻 Способ 3 — НА ПК (Windows / Linux / Mac)

Классический путь, самый стабильный.

**Что нужно:**
- [Node.js 18+](https://nodejs.org)
- [JDK 17](https://adoptium.net/) (Temurin)
- [Android Studio](https://developer.android.com/studio) (он принесёт Android SDK)

```bash
cd sokol-apk

# автосборка
bash build-apk.sh          # Linux / Mac / Git Bash на Windows
```

Или вручную через npm-скрипты:

```bash
npm install
npx cap add android        # создаст папку android/
npx cap sync android
npm run build:debug        # соберёт debug APK
```

Готовый APK:
`android/app/build/outputs/apk/debug/app-debug.apk`

**Через Android Studio (GUI):**
```bash
npm install && npx cap add android && npx cap sync android
npm run open               # откроет проект в Android Studio
```
Дальше: Build → Build Bundle(s)/APK(s) → Build APK(s).

---

## Debug vs Release

- `build-apk.sh` и `npm run build:debug` собирают **debug APK** — ставится сразу, удобно для себя.
- Для публикации в Google Play нужен **подписанный release APK/AAB**:

```bash
# создать ключ подписи (один раз)
keytool -genkey -v -keystore sokol.keystore -alias sokol -keyalg RSA -keysize 2048 -validity 10000

# дальше настроить подпись в android/app/build.gradle (signingConfigs)
npm run build:release
```

---

## Обновление игры

Если правишь `www/index.html` — просто пересинхронизируй и пересобери:

```bash
npx cap sync android
npm run build:debug
```

---

## Возможные проблемы

| Проблема | Решение |
|---|---|
| `SDK location not found` | Создай `android/local.properties` со строкой `sdk.dir=/путь/к/android-sdk` |
| `licenses not accepted` | `yes \| sdkmanager --licenses` |
| `gradlew: Permission denied` | `chmod +x android/gradlew` |
| Чёрный экран в приложении | Проверь, что `www/index.html` открывается в обычном браузере |
| Не та ориентация | Параметр `screenOrientation` в `AndroidManifest.xml` (патчится автоматически) |

---

Игра полностью офлайновая — интернет для работы не нужен. Управление, настройки, кампания и прогресс сохраняются на устройстве.
