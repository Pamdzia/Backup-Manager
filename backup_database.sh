#!/usr/bin/bash

backup_database() {
    local backup_dir=$1
    local db_name=$2
    local db_user=$3
    local db_pass=$4
    local backup_file="${backup_dir}/backup-db-$(date +%Y%m%d).sql"

    if [ ! -d "$backup_dir" ]; then
        echo "Błąd: Katalog docelowy backupu nie istnieje: $backup_dir" >&2
        return 1
    fi

    if [ -z "$db_name" ] || [ -z "$db_user" ] || [ -z "$db_pass" ]; then
        echo "Błąd: Nie podano pełnych danych do bazy danych (nazwa, użytkownik, hasło)." >&2
        return 1
    fi

    export MYSQL_PWD="$db_pass"

    # Próba połączenia z bazą danych
    if ! mysql -u "$db_user" -e "use $db_name" ; then
        echo "Błąd: Nie można połączyć się z bazą danych $db_name. Sprawdź poprawność danych logowania i nazwy bazy danych." >&2
        unset MYSQL_PWD
        return 1
    fi

    if ! mysqldump -u "$db_user" "$db_name" > "$backup_file"; then
        echo "Błąd: Nie udało się utworzyć kopii zapasowej bazy danych." >&2
        unset MYSQL_PWD
        return 1
    fi

    unset MYSQL_PWD
    echo "$backup_file"
    return 0
}

if [ $# -eq 0 ]; then
    echo "Ten skrypt nie jest wywoływalny, po pomoc skorzystaj udaj się do pomocy skyptu 'backup_script.sh'"
    exit 1
fi
