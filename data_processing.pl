#!/usr/bin/perl

use strict;
use warnings;
use File::Copy;
use FindBin;
use lib $FindBin::Bin;
use BackupUtilis qw(calculate_checksum compress_file encrypt_file calculate_directory_checksum);

sub show_help {
    print <<'HELP';
Użycie: data_processing.pl ścieżka_do_pliku_katalogu klucz_szyfrowania
Skrypt do obliczania sumy kontrolnej, kompresji i szyfrowania pliku lub katalogu.

Parametry:
  ścieżka_do_pliku_katalogu - Ścieżka do pliku lub katalogu, który ma być przetworzony.
  klucz_szyfrowania         - Klucz używany do szyfrowania pliku lub archiwum katalogu.

Opis:
  Skrypt po kolei wykonuje następujące operacje:
    1. Oblicza sumę kontrolną SHA256 pliku lub każdego pliku w katalogu.
    2. Kompresuje plik/katalog.
    3. Szyfruje skompresowany plik lub archiwum katalogu.

Przykład:
  data_processing.pl /ścieżka/do/pliku myEncryptionKey
  data_processing.pl /ścieżka/do/katalogu myEncryptionKey
HELP
    exit 0;
}

if (grep { $_ eq '-h' || $_ eq '--help' } @ARGV) {
    show_help();
}

die "Użycie: $0 ścieżka_do_pliku klucz_szyfrowania\n" unless @ARGV == 2;

my ($path, $encryption_key) = @ARGV;

if (-d $path) {
    my $checksum = calculate_directory_checksum($path);
    print "Suma kontrolna katalogu: $checksum\n";
} elsif (-f $path) {
    my $checksum = calculate_checksum($path);
    print "Suma kontrolna pliku: $checksum\n";

    my $compressed_file = $path;
    # Sprawdzanie, czy plik jest już skompresowany (ma rozszerzenie .gz)
    unless ($path =~ /\.gz$/) {
        $compressed_file = compress_file($path);
    }

    my ($encrypted_file, $encryption_key_used) = encrypt_file($compressed_file, $encryption_key);
    print "Zaszyfrowany plik: $encrypted_file\n";
    print "Klucz do odszyfrowania: $encryption_key_used\n";
} else {
    die "Podana ścieżka nie istnieje: $path\n";
}
