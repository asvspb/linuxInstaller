#!/bin/bash

# Переменная, указывающая текущую директорию, где хранятся архивы
archives_dir="$(pwd)"


# Создаем директорию, если она не существует
mkdir -p ~/Programs

# Находим архивы, содержащие ключевые слова
find "$archives_dir" -type f -name "*pycharm*" -o -name "*PhpStorm*" -o -name "*Postman*" -o -name "*jetbra*" | while read -r archive; do
    echo "Разархивирование архива: $archive"
    
    # Определяем тип архива с помощью команды 'file'
    archive_type=$(file -b --mime-type "$archive")
    
    # Проверяем тип архива и разархивируем соответствующим образом
    if [[ "$archive_type" == "application/zip" ]]; then
        unzip -q "$archive" -d ~/Programs/
    elif [[ "$archive_type" == "application/gzip" ]]; then
        tar -xzf "$archive" -C ~/Programs/
    else
        echo "Неизвестный тип архива: $archive_type"
    fi
done

echo "Все архивы были разархивированы и перемещены в ~/Programs/"
