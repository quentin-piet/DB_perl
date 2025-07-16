#!/usr/bin/perl
use warnings;
use strict;
use DBI;




################################################# MAIN ##################################################################

my $dbh = DBI->connect("DBI:Pg:dbname=qpiet;host=dbserver","qpiet","***",{'RaiseError' => 1});


my $input = '';
while ( $input ne 'q' ) {
    DisplayMenu();
    print "\n\n";
    if ( $input eq '1' ) {
        AddProtein();
    }
    if ( $input eq '2' ) {
		ModifSeq();
    }
    if ( $input eq '3' ) {
		ProtEnsemblPlant();
    }
    if ($input eq '4' ) {
		GenEnsemblPlant();
	}
    if ($input eq '5' ) {
		SelectProtLength();
	}
    if ($input eq '6' ) {
		ProtCaract();
	}
}

$dbh->disconnect();

################################################# Functions #############################################################
sub DisplayMenu {

    #system("clear");
    print "=============================================\n";
    print "\n";
    print "Enter your choice: ";
    print "\n";
    print "1- Ajouter une protéine:\n";
    print "2- Modifier une séquence protéique\n";
    print "3- Afficher les protéines (ID Uniprot) référencées dans EnsemblPlants\n";
    print "4- Afficher les gènes référencés dans EnsemblPlant\n";
    print "5- Afficher protéines dont l >= n choisit par l'utilisateur\n";
    print "6- Afficher caractéritiques d'une protéine (via ECnumber)\n";
    print "q- quit\n";
    print "\n";
    print "\n";

    print "=============================================\n";
    print "\n";

    $input = <STDIN>;
    chomp($input);

}

sub AddProtein {
	my $protName;
	my $entry;
	my $seqLength;
	my $protSeq;
  print"\n";
  print"nom de la protéine:\n";
  $protName = <>;
  chomp($protName);
  print"Entry UNIPROT:\n";
  $entry = <>;
  chomp($entry);
  print "ajouter une séquence (y/n) ?\n";
  my $l_answer= <>;
  chomp($l_answer);
  if ($l_answer eq 'y') {
    print "sequence:\n";
    $protSeq = <>;
    chomp($protSeq);
    $seqLength = length( $protSeq );
  }
  my $genesid = $dbh-> prepare("INSERT into proteines(entry,proteinname,length,sequence) VALUES(?,?,?,?)") or die "an error occured\n";
  $genesid->execute($entry, $protName,$seqLength, $protSeq);


}

sub ModifSeq {
  print "Entry of the sequence to update:\n";
  my $entry = <>;
  chomp($entry);
  my $sth = $dbh -> prepare("SELECT entry FROM proteines WHERE entry = '$entry'");
  $sth -> execute();
  my @t = $sth -> fetchrow_array();
  print $t[0];
  if ($t[0] eq $entry){
	  print"new sequence:\n";
	  my $protSeq = <>;
	  chomp($protSeq);
	  my $seqLength= length($protSeq);
	  $sth = $dbh -> prepare("UPDATE proteines sequence SET sequence = '$protSeq', length = '$seqLength' WHERE entry = '$entry'");
	  $sth->execute() or die "an error occured, couldn't update the sequence!\n";
	} 
  else{
	  print "Couldn't find the entry in the database!\n";
  }

}

sub	ProtEnsemblPlant{
	my $sth = $dbh -> prepare("SELECT DISTINCT UniprotId FROM uniprot"); #table uniprot est issue du fichier EnsmblPlant
	$sth -> execute();
	print "resultats\n\n";
	my $count = 0;
	while(my @t = $sth -> fetchrow_array()){
		$count +=1;
		print "$t[0]\n";

	}
	print"nombre de lignes: $count\n";
}

sub GenEnsemblPlant{
	my $sth = $dbh -> prepare("SELECT DISTINCT Genes.entry, Genes.GeneName FROM Genes JOIN Uniprot on Genes.entry = Uniprot.UniprotId and Genes.entry = Uniprot.UniprotId");
	$sth -> execute();
	my @attributs = ('entry', 'Gene Names');
	my @results;
	my $count = 0;
	while(my @t = $sth -> fetchrow_array()){
		$count += 1;
		my $chaine = join ':', @t;
		print "$chaine\n";
		push @results, $t[0];
		push @results, $t[1];
	}

	print 'nombre de lignes:' . $count . "\n";
	print '\nEnregistrer les resultats dans un fichier ? (y/n)';
	my $save=<>;
	chomp($save);
	HtmlOutput(\@results, \@attributs, $count) if ($save eq 'y');	
}




sub SelectProtLength{

	print "longueur minimum de la séquence:\n";
	my $length = <>;
	chomp ($length);
	my $sth = $dbh -> prepare("SELECT proteines.entry, proteines.length from proteines join infos on proteines.entry = infos.entry and organism = 'Arabidopsis thaliana (Mouse-ear cress)' WHERE proteines.length >= $length");
	$sth -> execute();
	my @attributs = ('entry', 'length');
	my @results;
	
	print "results:\n\n";
	print "entry:longueur\n\n";
	my $count = 0;
	while(my @t = $sth -> fetchrow_array()){
		$count += 1;
		my $chaine = join ':', @t; 
		print "$chaine\n";
		push @results, $t[0];
		push @results, $t[1];
	}

	print 'nombre de lignes:' . $count . "\n";
	print '\nEnregistrer les resultats dans un fichier ? (y/n)';
	my $save=<>;
	chomp($save);
	HtmlOutput(\@results, \@attributs, $count) if ($save eq 'y');
}

sub ProtCaract{
	print "EC Number: ";
	my $Ec_nb = <>;
	chomp ($Ec_nb);
	my $sth = $dbh -> prepare("SELECT proteines.entry, proteines.length from proteines join infos on proteines.entry = infos.entry and organism = 'Arabidopsis thaliana (Mouse-ear cress)' where ProteinName ~ '^.*$Ec_nb.*'");
	$sth -> execute();

	my @attributs = ('entry','length');
	my @results;
	
	print "\nresultats restreint à A.thaliana :\n";
	print "\n";
	print"entry:longueur\n\n";
	my $count = 0;
	while(my @t = $sth -> fetchrow_array()){
		$count += 1;
		my $chaine = join ':', @t;
		print "$chaine\n";
		push @results, $t[0];
		push @results, $t[1];
	}
	print "\n";
	print "nombre de lignes: $count \n";
	print "\nEnregistrer les resultats dans un fichier ? (y/n)";
	my $save=<>;
	chomp($save);
	HtmlOutput(\@results, \@attributs, $count) if ($save eq 'y');

	
	}

sub HtmlOutput{
my ($results_ref, $attributs_ref, $count) = @_;
my @results = @$results_ref;
my @attributs = @$attributs_ref;

my $count = $count;
my $nb_att=scalar @attributs;
my $nb_results = scalar @results;


print "nom du fichier:\n";
my $filename = <>;
chomp ($filename);
$filename = $filename.".html";
open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";

print $fh "<p></p>";
print $fh "nb de lignes: $count"; 
print $fh "<HTML>
<HEAD>
<TITLE>resultats requetes</TITLE>
</HEAD>
<BODY>
<TABLE border=1 width=200px height=auto>\n";
print $fh "<tr>\n";

for (my $i = 0; $i < $nb_att; $i++) {
  print $fh "<th>$attributs[$i]</th>";
  }
print $fh "</tr>\n";

for (my $p = 0; $p < $nb_results ; $p=$p+$nb_att) {
  print $fh "<tr>\n";
  for (my $var = 0 ; $var < $nb_att; $var++) {
    if ($p+$var < $nb_results) {
      print $fh "<td>$results[$p+$var]</td>\n";

    }
  }
  print $fh "</tr>\n";

}


print $fh "</TABLE>
</BODY>
</HTML>";



close $fh;
print "done\n";
}
