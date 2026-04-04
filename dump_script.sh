#!/bin/bash
# improved_dump_with_skipped.sh – дамп с отчётом о пропущенных файлах
# Исправлена ошибка с пустыми массивами при set -u

set -euo pipefail

# ---------- НАСТРОЙКИ ----------
MAX_LINES_PER_FILE=5000
MAX_TOTAL_SIZE_MB=10

INCLUDE_ROOT_DIRS=("lib" "pkgs")
INCLUDE_ROOT_FILES=("pubspec.yaml" "README.md" "analysis_options.yaml" ".gitignore")
EXCLUDE_DIRS=(".dart_tool" ".git" "ios/Pods" "macos/Pods" "android/.gradle" "build" "ios" "android" ".idea" "linux" "macos" "windows" "web") 
BINARY_EXTENSIONS=("png" "jpg" "jpeg" "gif" "bmp" "ico" "mp3" "mp4" "avi" "mov" "pdf" "doc" "docx" "zip" "tar" "gz" "rar" "7z" "class" "o" "so" "dll" "exe" "pyc" "pyo")
# ---------------------------------

if ! command -v file &> /dev/null; then
    echo "Предупреждение: команда 'file' не найдена, буду использовать упрощённую проверку бинарных файлов." >&2
    USE_FILE=false
else
    USE_FILE=true
fi

PROJECT_NAME=$(grep '^name:' pubspec.yaml 2>/dev/null | head -n1 | awk '{print $2}') || true
if [ -z "$PROJECT_NAME" ]; then
    PROJECT_NAME=$(basename "$PWD")
    echo "Предупреждение: имя проекта не найдено в pubspec.yaml, использую имя папки: $PROJECT_NAME" >&2
fi

OUT="${PROJECT_NAME}_dump.md"
> "$OUT"

is_excluded_dir() {
    local path="$1"
    path="${path#./}"
    for excl in "${EXCLUDE_DIRS[@]}"; do
        if [[ "$path" == "$excl" || "$path" == "$excl"/* || "$path" == */"$excl" || "$path" == */"$excl"/* ]]; then
            return 0
        fi
    done
    return 1
}

is_text_file() {
    local file="$1"
    if $USE_FILE; then
        file -b --mime-type "$file" | grep -q '^text/'
    else
        ! head -c 1024 "$file" 2>/dev/null | grep -q -P '\x00'
    fi
}

# Сбор файлов
all_files=()
for dir in "${INCLUDE_ROOT_DIRS[@]}"; do
    if [ -d "./$dir" ]; then
        while IFS= read -r -d '' file; do
            all_files+=("$file")
        done < <(find "./$dir" -type f -print0 2>/dev/null || true)
    fi
done

for fname in "${INCLUDE_ROOT_FILES[@]}"; do
    if [ -f "./$fname" ]; then
        all_files+=("./$fname")
    fi
done

# Убираем дубликаты
if [ ${#all_files[@]} -gt 0 ]; then
    mapfile -t all_files < <(printf "%s\n" "${all_files[@]}" | sort -u)
fi

included_files=()
skipped_files=()
total_size=0
total_lines=0

process_file() {
    local file="$1"
    
    if is_excluded_dir "$file"; then
        skipped_files+=("$file|исключённая директория")
        return
    fi

    if ! is_text_file "$file"; then
        skipped_files+=("$file|бинарный файл")
        return
    fi

    local ext="${file##*.}"
    for bext in "${BINARY_EXTENSIONS[@]}"; do
        if [[ "$ext" == "$bext" ]]; then
            skipped_files+=("$file|бинарное расширение")
            return
        fi
    done

    local lines size
    lines=$(wc -l < "$file" 2>/dev/null || echo "0")
    size=$(wc -c < "$file" 2>/dev/null || echo "0")

    if [ "$MAX_TOTAL_SIZE_MB" -gt 0 ]; then
        local new_total=$((total_size + size))
        local new_total_mb=$((new_total / 1048576))
        if [ "$new_total_mb" -gt "$MAX_TOTAL_SIZE_MB" ]; then
            skipped_files+=("$file|превышен общий лимит размера дампа")
            return
        fi
    fi

    included_files+=("$file|$lines|$size")
    total_size=$((total_size + size))
    total_lines=$((total_lines + lines))
}

for file in "${all_files[@]+"${all_files[@]}"}"; do
    [ -n "$file" ] && process_file "$file"
done

# Сортировка с проверкой на пустоту
sorted_included=()
sorted_skipped=()

if [ ${#included_files[@]} -gt 0 ]; then
    mapfile -t sorted_included < <(printf "%s\n" "${included_files[@]}" | sort)
fi

if [ ${#skipped_files[@]} -gt 0 ]; then
    mapfile -t sorted_skipped < <(printf "%s\n" "${skipped_files[@]}" | sort)
fi

# --- Запись дампа ---
{
    echo "# Дамп проекта $PROJECT_NAME"
    echo ""
    echo "**Всего обработано файлов:** ${#all_files[@]}"
    echo "**Включено:** ${#included_files[@]}"
    echo "**Пропущено:** ${#skipped_files[@]}"
    echo ""
    
    echo "## Включённые файлы"
    echo ""
    if [ ${#sorted_included[@]} -gt 0 ]; then
        echo "| Файл | Строк | Размер (байт) |"
        echo "|------|-------|---------------|"
        for entry in "${sorted_included[@]}"; do
            IFS='|' read -r path lines size <<< "$entry"
            echo "| \`$path\` | $lines | $size |"
        done
    else
        echo "_Нет включённых файлов_"
    fi
    echo ""
    echo "---"
    echo ""
    
    echo "## Пропущенные файлы"
    echo ""
    if [ ${#sorted_skipped[@]} -gt 0 ]; then
        echo "| Файл | Причина |"
        echo "|------|---------|"
        for entry in "${sorted_skipped[@]}"; do
            IFS='|' read -r path reason <<< "$entry"
            echo "| \`$path\` | $reason |"
        done
    else
        echo "_Нет пропущенных файлов_"
    fi
    echo ""
    echo "---"
    echo ""
    
    echo "## Содержимое включённых файлов"
    echo ""

    for entry in "${sorted_included[@]+"${sorted_included[@]}"}"; do
        [ -z "$entry" ] && continue
        IFS='|' read -r path lines size <<< "$entry"
        
        case "${path##*.}" in
            dart) lang="dart" ;;
            yaml|yml) lang="yaml" ;;
            json) lang="json" ;;
            md)   lang="markdown" ;;
            lock) lang="yaml" ;;
            gradle) lang="groovy" ;;
            plist) lang="xml" ;;
            pbxproj) lang="javascript" ;;
            sh)   lang="bash" ;;
            *)    lang="" ;;
        esac

        echo "### Файл: \`$path\` (строк: $lines, размер: $size байт)"
        echo ""
        if [ -n "$lang" ]; then
            echo "\`\`\`$lang"
        else
            echo "\`\`\`"
        fi

        if [ "$lines" -le "$MAX_LINES_PER_FILE" ]; then
            cat "$path" 2>/dev/null || echo "<!-- Ошибка чтения файла -->"
        else
            head -n "$MAX_LINES_PER_FILE" "$path" 2>/dev/null || echo "<!-- Ошибка чтения файла -->"
            echo ""
            echo "# --- Обрезано после $MAX_LINES_PER_FILE строк ---"
        fi
        echo "\`\`\`"
        echo ""
    done

    echo "---"
    echo "**Суммарно строк в включённых файлах:** $total_lines"
    echo "**Суммарный размер включённых файлов:** $total_size байт (~$((total_size / 1024)) КБ)"
} >> "$OUT"

echo "Готово! Дамп сохранён в $OUT"
echo "Включено файлов: ${#included_files[@]}, пропущено: ${#skipped_files[@]}"