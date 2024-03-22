#!/bin/bash
#Klaudia Ropel Skrypty1

show_help() {
    echo "Skrypt do tworzenia kopii zapasowych plików lub bazy danych."
    echo
    echo "Przykłady użycia (bez konieczności dodatkowej konfiguracji):"
    echo "  $0 files /backup/directory /data/directory"
    echo "  $0 database /backup/directory my_database my_user my_password"
    echo
    echo "Parametry:"
    echo "  ścieżka_do_katalogu_z_backupem - Lokalizacja, gdzie ma być zapisany backup."
    echo "  ścieżka_do_plików_do_backupu   - Pliki lub katalog, które mają być zbackupowane (tylko dla typu 'files')."
    echo "  nazwa_bazy_danych              - Nazwa bazy danych do zbackupowania (tylko dla typu 'database')."
    echo "  użytkownik_bazy_danych         - Użytkownik bazy danych (tylko dla typu 'database')."
    echo "  hasło_bazy_danych              - Hasło do bazy danych (tylko dla typu 'database')."
    echo "  typ_backupu                    - Typ backupu: 'files' dla plików, 'database' dla bazy danych."
    echo
    echo "Opcje:"
    echo "  -h, --help                     - Wyświetla tę pomoc."
    echo
    echo "Informacje dodatkowe:"
    echo "  Skrypt nie wymaga specjalnych opcji poza wymaganymi parametrami do określenia typu backupu i ścieżek."
    echo "  Upewnij się, że masz odpowiednie uprawnienia do wykonywania backupu."
}

post_backup_processing() {
    backup_file=$1
    encryption_key=X3Y6Z9W0x2rT5v8uQ1lF4jI7sK3mN6pU  # Istnieje możliwość zmiany defaultowego klucza
    perl_script_path="./data_processing.pl"

    /usr/bin/perl "$perl_script_path" "$backup_file" "$encryption_key"
}

# Dodanie obsługi opcji -t
USE_TERMINAL_MODE=false
while getopts ":ht" opt; do
  case $opt in
    h)
      show_help
      exit 0
      ;;
    t)
      USE_TERMINAL_MODE=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

# Sprawdzenie, czy podano jakiekolwiek argumenty
if [ $# -eq 0 ] && ! $USE_TERMINAL_MODE; then
    echo "Nie podałeś żadnych argumentów. Po informacje jak korzystać z programu, zajrzyj do pomocy dodając -h lub --help." >&2
    exit 1
fi

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${script_dir}/backup_files.sh"
source "${script_dir}/backup_database.sh"

if $USE_TERMINAL_MODE; then
  # Tradycyjna logika skryptu
  backup_dir=$1
  file_backup_path=$2
  db_name=$3
  db_user=$4
  db_pass=$5
  backup_type=$6

  if [ "$backup_type" = "files" ]; then
      if [ ! -e "$file_backup_path" ]; then
          echo "Błąd: Podana ścieżka do plików do backupu nie istnieje: $file_backup_path" >&2
          exit 1
      elif [ ! -d "$backup_dir" ]; then
          echo "Błąd: Podany katalog do zapisu backupu nie istnieje: $backup_dir" >&2
          exit 1
      fi
      backup_file="$(backup_files "$backup_dir" "$file_backup_path")"
      post_backup_processing "$backup_file"

  elif [ "$backup_type" = "database" ]; then
      backup_file="$(backup_database "$backup_dir" "$db_name" "$db_user" "$db_pass")"
      backup_status=$?
      if [ $backup_status -eq 0 ]; then
          post_backup_processing "$backup_file"
      else
          echo "Błąd: Nie udało się utworzyć backupu bazy danych." >&2
          exit 1
      fi
  else
      echo "Niepoprawny typ backupu: wybierz 'files' lub 'database'" >&2
      exit 1
  fi
else
  # Nowa logika skryptu bez pustych argumentów
  backup_type=$1
  backup_dir=$2

  if [ "$backup_type" = "files" ]; then
    file_backup_path=$3
    if [ ! -e "$file_backup_path" ]; then
        echo "Błąd: Podana ścieżka do plików do backupu nie istnieje: $file_backup_path" >&2
        exit 1
    elif [ ! -d "$backup_dir" ]; then
        echo "Błąd: Podany katalog do zapisu backupu nie istnieje: $backup_dir" >&2
        exit 1
    fi
    backup_file="$(backup_files "$backup_dir" "$file_backup_path")"
    post_backup_processing "$backup_file"

  elif [ "$backup_type" = "database" ]; then
    db_name=$3
    db_user=$4
    db_pass=$5
    backup_file="$(backup_database "$backup_dir" "$db_name" "$db_user" "$db_pass")"
    backup_status=$?
    if [ $backup_status -eq 0 ]; then
        post_backup_processing "$backup_file"
    else
        echo "Błąd: Nie udało się utworzyć backupu bazy danych." >&2
        exit 1
    fi
  else
    echo "Niepoprawny typ backupu: wybierz 'files' lub 'database'" >&2
    exit 1
  fi
fi

