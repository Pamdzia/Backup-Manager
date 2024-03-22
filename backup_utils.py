#!/usr/bin/env python3
#Klaudia Ropel Skrypty1

from subprocess import Popen, PIPE
import sys, os

def show_help():
    help_message = """

Skrypt backup_utils.py: przeniesione zotały wybrane funkcje z głównego skryptu backup_manager.py (funkcja pokazujaca help i funkcja wywolujaca skrypt bash)

Skrypt backup_manager: 

Backup Manager GUI

W programie użyta jest biblioteka 'tkinter'.

Użycie: [ścieżka do katalogu z backupem] [ścieżka do plików do backupu] [nazwa bazy danych] [użytkownik bazy danych] [hasło bazy danych] [typ backupu]
Interfejs użytkownika do zarządzania tworzeniem kopii zapasowych.
    """
    print(help_message)
    sys.exit(0)

def run_backup(dir_entry, file_path_entry, db_name_entry, db_user_entry, db_pass_entry, backup_type_var, message_box):
    backup_dir = dir_entry.get()
    file_path = file_path_entry.get()
    db_name = db_name_entry.get()
    db_user = db_user_entry.get()
    db_pass = db_pass_entry.get()
    backup_type = backup_type_var.get()
    print("Aktualny katalog:", os.getcwd())

    # Wywołanie skryptu Bash z przekazanymi argumentami
    process = Popen(["./backup_script.sh", backup_dir, file_path, db_name, db_user, db_pass, backup_type], stdout=PIPE, stderr=PIPE)
    output, error = process.communicate()
    # Wyświetlanie wyników w polu tekstowym (to potem zmienic na okienko wyskakujace)
    if process.returncode == 0:
        message = "Backup zakończony sukcesem\n" + output.decode()
    else:
        message = "Błąd podczas wykonywania backupu\n" + error.decode()

    # Wyczyszczenie poprzednich wiadomości i wyświetlenie nowej
    message_box.delete('1.0', tk.END)
    message_box.insert(tk.END, message)

# Próba zaimportowania tkinter
try:
    import tkinter as tk
except ImportError:
    print("Błąd: biblioteka tkinter nie jest zainstalowana. Aby ją zainstalować skorzystaj z pip install tk")
    sys.exit(1)
