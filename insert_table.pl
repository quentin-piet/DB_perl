  #!/usr/bin/perl

  use strict;
  use warnings;
  use Text::CSV;
  use Tie::Handle::CSV;
  use DBI;

  my $dbh = DBI->connect("DBI:Pg:dbname=qpiet;host=dbserver","qpiet","passwd",{'RaiseError' => 1});

  my $file = "mart_export.csv";
  my $fh = Tie::Handle::CSV->new ($file, header => 1);
  my $genesid = $dbh-> prepare("INSERT into uniprot(uniprotid,genestableid,TranscriptStableId,PlantReactomeReactID) VALUES(?, ?, ?, ?)");
  while (my $csv_line = <$fh>) {
    my $line =  $csv_line->{"UniProtKB/TrEMBL ID"};
    my $line2 = $csv_line->{"Gene stable ID"};
    my $line3 = $csv_line->{"Transcript stable ID"};
    my $line4 = $csv_line->{"Plant Reactome Reaction ID"};
    $genesid->execute($line, $line2, $line3, $line4);
   }

  my $file = "seq.csv";
  my $fh = Tie::Handle::CSV->new ($file, header => 1, sep_char => "\t") or die "can'topen\n";
  my $genesid = $dbh-> prepare("INSERT into proteines(entry,proteinname,length,sequence) VALUES(?, ?, ?, ?)");
   while (my $csv_line = <$fh>) {
    my $line =  $csv_line->{"Entry"};
    my $line2 = $csv_line->{"Protein names"};
    my $line3 = $csv_line->{"Length"};
    my $line4 = $csv_line->{"Sequence"};
    $genesid->execute($line, $line2, $line3, $line4);
   }
  
  
  my $file = "seq.csv";
  my $fh = Tie::Handle::CSV->new ($file, header => 1, sep_char => "\t") or die "can'topen\n";
  my $genesid = $dbh-> prepare("INSERT into genes(entry,GeneName,GenSynonyms,GeneOntology) VALUES(?, ?, ?, ?)");
   while (my $csv_line = <$fh>) {
    my $line =  $csv_line->{"Entry"};
    my $line2 = $csv_line->{"Gene names"};
    my $line3 = $csv_line->{"Gene names  (synonym )"};
    my $line4 = $csv_line->{"Gene ontology (GO)"};
    $genesid->execute($line, $line2, $line3, $line4);
  }


  my $file = "seq.csv";
  my $fh = Tie::Handle::CSV->new ($file, header => 1, sep_char => "\t") or die "can'topen\n";
  my $genesid = $dbh-> prepare("INSERT into infos(entry,EntryName,Status,Organism,EnsmblPlantTranscript) VALUES(?, ?, ?, ?, ?)");
   while (my $csv_line = <$fh>) {
    my $line =  $csv_line->{"Entry"};
    my $line2 = $csv_line->{"Entry name"};
    my $line3 = $csv_line->{"Status"};
    my $line4 = $csv_line->{"Organism"};
    my $line5 = $csv_line->{"EnsemblPlants transcript"};
    $genesid->execute($line, $line2, $line3, $line4, $line5);
}

  close $fh;
  $dbh->disconnect();
