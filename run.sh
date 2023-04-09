#!/bin/sh

# Стартовый скрипт для пакета Restreamer

# Сначала запустите программу импорта. Она прочитает db.dir из файла конфигурации, чтобы
# найти старый v1.json. Он будет преобразован в новый формат db.

./bin/import
if [ $? -ne 0 ]; then
    exit 1
fi

# Запустите программу миграции FFmpeg. В случае наличия двоичного файла FFmpeg 5, программа создаст файл
# резервную копию текущей БД и изменит параметры FFmpeg так, чтобы они были совместимы.
# с FFmpeg 5.

./bin/ffmigrate
if [ $? -ne 0 ]; then
    exit 1
fi

# Создайте подсказку для интерфейса администратора, если отсутствует index.html

if ! [ -f "${CORE_STORAGE_DISK_DIR}/index.html" ]; then
    cp /core/ui-root/index.html /core/ui-root/index_icon.svg ${CORE_STORAGE_DISK_DIR}
fi

# Теперь запустите ядро с возможно преобразованной конфигурацией.

./bin/core
