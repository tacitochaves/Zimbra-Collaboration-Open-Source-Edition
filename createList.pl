#!/bin/env perl

use strict;
use warnings;

my $email = {
    create   => '/opt/zimbra/bin/zmprov',
    list_dir => '/home/chaves/list/'
};

opendir my $list_dir, $email->{list_dir} or die "Error opening directory.\n";
my @list_dir = readdir $list_dir;

my $hashref = {};

for my $ld ( @list_dir ) {
    chomp $ld;

    next unless $ld =~ m/.list/;
    $ld =~ s/.list//;

    open my $fh, "<", "$ld.list" or die "Não foi possível carregar o arquivo\n";
    my @l = <$fh>;

    chomp @l;

    $hashref->{$ld} = \@l;
}

for my $list ( keys %{$hashref} ) {
    next if scalar @{ $hashref->{$list} } == 0;

    print "$email->{create} cdl $list\n";

    print "$email->{create} adlm $list ", join " ", @{ $hashref->{$list} }, "\n";
}
