#!/usr/bin/perl
use warnings;
use strict;
use DBI;

my $dbh = DBI->connect("DBI:Pg:dbname=qpiet;host=dbserver","qpiet","passwd",{'RaiseError' => 1});
$dbh->do('DROP TABLE IF EXISTS PROTEINES') or die "Impossible de supprimer la table PROTEINES\n\n";
$dbh->do('DROP TABLE IF EXISTS UNIPROT') or die "Impossible de supprimer la table Uniprot\n\n";
$dbh->do('DROP TABLE IF EXISTS GENES') or die "Impossible de supprimer la table Genes\n\n";
$dbh->do('DROP TABLE IF EXISTS INFOS') or die "Impossible de supprimer la table Infos\n\n";



$dbh -> do("create table Proteines(Entry varchar(25) primary key, ProteinName varchar(1000), Length int, Sequence varchar(20000) )");
$dbh -> do("create table Genes(Entry varchar(25) primary key, GeneName varchar(1000), GenSynonyms varchar(1000), GeneOntology varchar(20000) )");
$dbh -> do("create table Infos(Entry varchar(25) primary key, EntryName varchar(1000), Status varchar(25), Organism varchar(5000), EnsmblPlantTranscript varchar(20000))");
$dbh -> do("create table Uniprot(UniprotId varchar(25), GeneStableId varchar(15), TranscriptStableId varchar(15), PlantReactomeReactID varchar(20), primary key(UniprotId,TranscriptStableId, PlantReactomeReactID) )");

$dbh->disconnect();
