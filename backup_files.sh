#!/usr/bin/bash

backup_files() {
    local backup_dir=$1
    local file_backup_path=$2
    local backup_file="${backup_dir}/backup-files-$(date +%Y%m%d).tar.gz"

    # Kompresja plików/katalogu
    tar -czvf "$backup_file" -C "$file_backup_path" . > /dev/null 2>&1
    echo "$backup_file"  # Dodaj to na końcu funkcji
}

# Sprawdzenie, czy podano jakiekolwiek argumenty
if [ $# -eq 0 ]; then
    echo "Ten skrypt nie jest wywoływalny, po pomoc skorzystaj udaj się do pomocy skyptu 'backup_script.sh'"
    exit 1
fi