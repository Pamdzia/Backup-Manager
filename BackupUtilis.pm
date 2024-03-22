package BackupUtilis;

use strict;
use warnings;
use Exporter qw(import);
use Digest::SHA qw(sha256_hex);

our @EXPORT_OK = qw(calculate_checksum compress_file encrypt_file calculate_directory_checksum);

sub calculate_checksum {
    my ($filename) = @_;
    open(my $fh, '<', $filename) or die "Nie można otworzyć pliku '$filename': $!";
    my $checksum = sha256_hex(<$fh>);
    close($fh);
    return $checksum;
}

sub compress_file {
    my ($filename) = @_;
    unless (-f $filename) {
        die "Błąd: Podana ścieżka nie istnieje lub jest katalogiem: $filename\n";
    }

    my $compressed_file = $filename . '.gz';
    my $status = system("gzip -c $filename > $compressed_file");
    die "Kompresja nie powiodła się: $!" if $status;
    return $compressed_file;
}

sub encrypt_file {
    my ($filename, $encryption_key) = @_;
    my $module_loaded = eval {
        require Crypt::CBC;
        require Crypt::Rijndael;
        Crypt::CBC->import();
        Crypt::Rijndael->import();
        1;
    };

    if ($module_loaded) {
        my $cipher = Crypt::CBC->new(-key => $encryption_key, -cipher => 'Crypt::Rijndael');
        my $data = '';
        {
            local $/;
            open(my $fh, '<', $filename) or die "Nie można otworzyć pliku '$filename': $!";
            $data = <$fh>;
            close($fh);
        }
        my $encrypted_data = $cipher->encrypt($data);
        open(my $fh, '>', "$filename.enc") or die "Nie można otworzyć pliku '$filename.enc': $!";
        print $fh $encrypted_data;
        close($fh);
        return ("$filename.enc", $encryption_key);
    } else {
        my $openssl_check = `openssl version`;
        if ($? == 0) {
            # Przekierowanie stderr do /dev/null, aby ukryć ostrzeżenia
            my $status = system("openssl enc -aes-256-cbc -salt -in $filename -out $filename.enc -pass pass:$encryption_key 2>/dev/null");
            die "Szyfrowanie nie powiodło się: $!" if $status;
            return ("$filename.enc", $encryption_key);
        } else {
            die "Szyfrowanie niemożliwe: moduł Crypt::CBC nie jest zainstalowany, a openssl nie jest dostępny w systemie.";
        }
    }
}

sub calculate_directory_checksum {
    my ($dirname) = @_;
    my $checksum = '';

    opendir(my $dh, $dirname) or die "Nie można otworzyć katalogu '$dirname': $!";
    my @files = readdir($dh);
    closedir($dh);

    foreach my $file (sort @files) {
        next if $file eq '.' or $file eq '..';
        my $full_path = "$dirname/$file";

        if (-d $full_path) {
            $checksum .= calculate_directory_checksum($full_path);
        } elsif (-f $full_path) {
            $checksum .= calculate_checksum($full_path);
        }
    }

    return sha256_hex($checksum);
}

1;
