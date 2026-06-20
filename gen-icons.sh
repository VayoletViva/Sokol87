#!/usr/bin/env bash
# Генерация PNG-иконок приложения из resources/icon.svg
# и раскладка по mipmap-папкам Android.
# Запускать ПОСЛЕ `npx cap add android`.
#
# Нужен один из конвертеров: rsvg-convert | inkscape | cairosvg (python) | ImageMagick+librsvg
set -e
cd "$(dirname "$0")"

SVG="resources/icon.svg"
OUT="resources"

conv() { # conv <size> <outfile>
  local sz=$1 out=$2
  if command -v rsvg-convert >/dev/null;   then rsvg-convert -w $sz -h $sz "$SVG" -o "$out"
  elif command -v inkscape >/dev/null;     then inkscape "$SVG" -w $sz -h $sz -o "$out" 2>/dev/null
  elif python3 -c "import cairosvg" 2>/dev/null; then python3 -c "import cairosvg;cairosvg.svg2png(url='$SVG',write_to='$out',output_width=$sz,output_height=$sz)"
  else convert -background none -density 384 "$SVG" -resize ${sz}x${sz} "$out"
  fi
}

echo "▸ генерация PNG-иконок..."
for sz in 48 72 96 144 192 512; do conv $sz "$OUT/icon-$sz.png"; done

# раскладка по mipmap (если папка android уже создана)
if [ -d android ]; then
  echo "▸ раскладка по android/app/src/main/res/mipmap-*..."
  declare -A M=( [mdpi]=48 [hdpi]=72 [xhdpi]=96 [xxhdpi]=144 [xxxhdpi]=192 )
  for d in "${!M[@]}"; do
    dir="android/app/src/main/res/mipmap-$d"
    mkdir -p "$dir"
    cp "$OUT/icon-${M[$d]}.png" "$dir/ic_launcher.png"
    cp "$OUT/icon-${M[$d]}.png" "$dir/ic_launcher_round.png"
    cp "$OUT/icon-${M[$d]}.png" "$dir/ic_launcher_foreground.png"
  done
  echo "  ✓ иконки разложены"
else
  echo "  ! папки android нет — сначала npx cap add android, потом запусти снова"
fi
echo "готово."
