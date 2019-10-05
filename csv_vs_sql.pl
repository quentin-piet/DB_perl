#!/usr/bin/perl

use strict;
use warnings;
use Text::CSV;
use Tie::Handle::CSV;
use Text::CSV::Separator qw(get_separator);

print "longueur minimale: ";
my $def_length = <>;

my $file = "seq.csv";
my $separator = get_separator(path => "uniprot-arabidopsisthalianaSequence.csv",
                              lucky => 1);

my $fh = Tie::Handle::CSV->new( $file, header => 1, sep_char => "$separator" ) or die "can'topen\n";

print"\n";


while (my $line = <$fh>){
  my $length = $line->{"Length"};
  my $org = $line->{"Organism"};
  my $entry = $line->{"Entry"};
   print "Entry: $entry    \tLength: $length\n" if ($length >= $def_length && $org eq 'Arabidopsis thaliana (Mouse-ear cress)');
}
close $fh;
