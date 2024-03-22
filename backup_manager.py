#!/usr/bin/env python3

import subprocess
import argparse
import sys
import os
import tkinter as tk
from tkinter import messagebox

parser = argparse.ArgumentParser(description="""
Backup Manager GUI - Program do zarządzania tworzeniem kopii zapasowych.

Ten program umożliwia tworzenie kopii zapasowych plików oraz baz danych. Użytkownik może wybrać typ backupu (pliki lub baza danych), a także podać odpowiednie ścieżki i dane dostępowe do bazy danych.
!Uwaga! Program nie umożliwia backupowania na zdalny serwer, w celu zabezpieczenia się przed utrratą danych przy awarii sprzętu, wykonaj backup na nośnik przenośny

Opcje programu:
- Wybór typu backupu: pliki lub baza danych
- Podanie ścieżki do katalogu z backupem
- Podanie ścieżki do plików do backupu
- Podanie nazwy bazy danych, użytkownika i hasła (dla backupu bazy danych)

FAQ:

Niezainstalowana biblioteka Tkinter:
Aby zainstalować Tkinter, użyj odpowiedniego polecenia dla Twojego systemu operacyjnego.
- Debian/Ubuntu (i pochodne): sudo apt-get install python3-tk
- Fedora: sudo dnf install python3-tkinter
- Arch Linux: sudo pacman -S tk
- Windows: Zwykle Tkinter jest instalowany domyślnie z Pythonem.
- macOS: Użyj Homebrew (brew install python-tk) lub upewnij się, że Tkinter jest zainstalowany z Pythonem.

Problem z interfejsem graficznym X11:
Jeśli program jest uruchamiany na serwerze bez dostępu do wyświetlacza graficznego, konieczne jest skonfigurowanie X11 Forwarding.
1. Na serwerze upewnij się, że X11 Forwarding jest włączone w SSH (X11Forwarding yes w /etc/ssh/sshd_config).
2. Zainstaluj 'xauth' na serwerze.
3. Użyj 'ssh -X nazwa_użytkownika@adres_serwera' aby połączyć się z serwerem z włączonym X11 Forwarding.
4. Upewnij się, że na komputerze lokalnym masz działające środowisko X11 (np. Xming na Windows, XQuartz na macOS, w większości dystrybucji Linuxa jest ono domyślne).

""", formatter_class=argparse.RawTextHelpFormatter)

args = parser.parse_args()

try:
    import tkinter as tk
    from tkinter import messagebox
except ImportError:
    print("Błąd: biblioteka tkinter nie jest zainstalowana. Instrukcja jak zainstalować znajduje się w zakładzie FAQ w pomocy.")
    sys.exit(1)

def on_close():
    if messagebox.askokcancel("Wyjście", "Czy na pewno chcesz wyjść z programu?"):
        root.destroy()

def run_backup(dir_entry, file_path_entry, db_name_entry, db_user_entry, db_pass_entry, backup_type_var, message_box):
    print("Funkcja run_backup została wywołana")
    backup_dir = dir_entry.get()
    file_path = file_path_entry.get()
    db_name = db_name_entry.get()
    db_user = db_user_entry.get()
    db_pass = db_pass_entry.get()
    backup_type = backup_type_var.get()

    script_path = os.path.dirname(__file__)
    bash_script_path = os.path.join(script_path, 'backup_script.sh')

    command = ["bash", bash_script_path, '-t', backup_dir, file_path, db_name, db_user, db_pass, backup_type]

    message_box.delete('1.0', tk.END)

    try:
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout, stderr = process.communicate()
        if process.returncode == 0:
            messagebox.showinfo("Sukces", "Backup zakończony sukcesem.")
            message_box.insert(tk.END, "Backup zakończony sukcesem.\n" + stdout.decode())
        else:
            messagebox.showerror("Błąd", "Wystąpił błąd podczas backupu.\n" + stderr.decode())
            message_box.insert(tk.END, f"Błąd podczas wykonywania backupu:\n{stderr.decode()}\n")
    except Exception as e:
        messagebox.showerror("Błąd", f"Wystąpił błąd: {e}")
        message_box.insert(tk.END, f"Wystąpił błąd: {str(e)}\n")

def show_database_options():
    db_name_label.pack()
    db_name_entry.pack()
    db_user_label.pack()
    db_user_entry.pack()
    db_pass_label.pack()
    db_pass_entry.pack()
    file_path_label.pack_forget()
    file_path_entry.pack_forget()

def show_file_options():
    file_path_label.pack()
    file_path_entry.pack()
    db_name_label.pack_forget()
    db_name_entry.pack_forget()
    db_user_label.pack_forget()
    db_user_entry.pack_forget()
    db_pass_label.pack_forget()
    db_pass_entry.pack_forget()

try:
    root = tk.Tk()
    root.title("Backup Manager")

    root.protocol("WM_DELETE_WINDOW", on_close)  # Ustawienie obsługi zdarzenia zamknięcia okna


    backup_button_frame = tk.Frame(root)
    backup_button_frame.pack(fill=tk.X, pady=10)

    backup_type_var = tk.StringVar(value="files")

    backup_button = tk.Button(backup_button_frame, text="Uruchom Backup", command=lambda: run_backup(
        dir_entry, file_path_entry, db_name_entry, db_user_entry, db_pass_entry, backup_type_var, message_box))
    backup_button.pack()

    files_rb = tk.Radiobutton(root, text="Pliki", variable=backup_type_var, value="files", command=show_file_options)
    files_rb.pack()
    database_rb = tk.Radiobutton(root, text="Baza danych", variable=backup_type_var, value="database", command=show_database_options)
    database_rb.pack()

    message_box = tk.Text(root, height=10, width=50)
    message_box.pack()

    dir_label = tk.Label(root, text="Ścieżka do katalogu z backupem:")
    dir_label.pack()
    dir_entry = tk.Entry(root)
    dir_entry.pack()

    file_path_label = tk.Label(root, text="Ścieżka do plików do backupu:")
    file_path_label.pack()
    file_path_entry = tk.Entry(root)
    file_path_entry.pack()

    db_name_label = tk.Label(root, text="Nazwa bazy danych:")
    db_name_label.pack()
    db_name_entry = tk.Entry(root)
    db_name_entry.pack()

    db_user_label = tk.Label(root, text="Użytkownik bazy danych:")
    db_user_label.pack()
    db_user_entry = tk.Entry(root)
    db_user_entry.pack()

    db_pass_label = tk.Label(root, text="Hasło bazy danych:")
    db_pass_label.pack()
    db_pass_entry = tk.Entry(root, show="*")
    db_pass_entry.pack()

    show_file_options()

    root.mainloop()
except tk.TclError as e:
    print(f"Błąd: Nie można zainicjalizować interfejsu graficznego tkinter. {e}")
    sys.exit(1)
