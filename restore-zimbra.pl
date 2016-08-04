#!/bin/env perl

use strict;
use warnings;

use POSIX qw(strftime);

my $mail = {
    create  => '/opt/zimbra/bin/zmprov',
    restore => '/opt/zimbra/bin/zmmailbox',
    tgz_dir => '/mnt/zimbra/',
    txt_dir => '/mnt/zimbra/data'
};

# file tgz
opendir my $tgz_dir, $mail->{tgz_dir} or die "Error opening directory.\n";
my @tgz_list = readdir $tgz_dir;
closedir $tgz_dir;

# file txt
opendir my $txt_dir, $mail->{txt_dir} or die "Error opening directory.\n";
my @txt_list = readdir $txt_dir;
closedir $txt_dir;

# log file
open my $log, ">>", "/var/log/zimbra-restore.log" or die "Could not create the log file.\n";

print $log "Tool: Backup Agent/Restore to Zimbra Collaboration Open Source Edition.","\n";
print $log "Client: TChaves","\n";
print $log "Powered by: TChaves","\n\n";
print $log "Account restoration started to - ",get_date(),"\n\n";
print $log "Creating accounts and restoring message boxes.\n";

# create and import
for my $file ( sort { $a cmp $b } @tgz_list ) {
    next unless $file =~ m/.tgz$/;

    $file =~ s/.tgz//;

    # creating account
    system("$mail->{create} ca $file mudar123");
    print $log "\t","Account: \t$file \tsuccessfully created!\t", get_date(),"\n";

    # importing data
    system("$mail->{restore} -z -m $file postRestURL '//?fmt=tgz&resolve=reset' $mail->{tgz_dir}$file.tgz");
    print $log "\t","Message Box: \t$file \tsuccessfully imported!\t",get_date(),"\n";
}

my $ref = [];

for ( @txt_list ) {
    next unless m/.txt$/;

    push @{$ref}, _toHash($_);
}

print $log "\nImporting additional data Password and Display Name.\n";
for my $hash ( @{$ref} ) {
    for my $account ( keys %{$hash} ) {
        system("$mail->{create} ma $account\@tchaves.com.br userPassword \'$hash->{$account}->{Password}\' displayName \'$hash->{$account}->{'Display Name'}\'");
        print $log "\t","Password and Display Name of the \t$account\@tchaves.com.br \tsuccessfully updated! - ",get_date(),"\n";
    }
}

print $log "\n","Account restoration completed to - ",get_date(),"\n";
close $log;

# creating hash
sub _toHash {
    my $file = shift;

    open my $fh, "<", "$mail->{txt_dir}/$file" or die "Não foi possível abrir o arquivo!\n";
    my @list = <$fh>;
    close $fh;

    $file =~ s/.txt//;

    my $hash = {};

    for my $data ( @list ) {
        chomp $data;
        my ($key, $value) = split ": ", $data;

        $hash->{$file}->{$key} = $value;
    }

    return $hash;
}

# capture data
sub get_date {
    return strftime "%d/%m/%Y %X", localtime;
}
