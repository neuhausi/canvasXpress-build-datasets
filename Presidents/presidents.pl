#!/usr/bin/perl -w

use strict;
use Data::Dumper;

my ($data, $sum, $votes, $electoral);

open (FILE, "./electoral-votes.txt") or die "Couldn't open electoral-votes.txt: $!\n";
while (<FILE>) {
  chomp;
  s/\r//;
  my (@line) = split("\t", $_);
  $votes->{uc($line[0])} = $line[1];
}
close FILE;

open( FILE, "./1976-2020-president.csv" ) or die "Couldn't open 1976-2020-president.csv: $!\n";
$_ = <FILE>;
while (<FILE>) {
  chomp;
  s/\r//;
  my (@line) = split("\t", $_);
  if (!$data->{$line[0]}{$line[1]}{$line[14]}) {
    $data->{$line[0]}{$line[1]}{$line[14]} = 0;
  }
  $data->{$line[0]}{$line[1]}{$line[14]} += $line[10];
  if (!$sum->{$line[0]}{$line[14]}) {
    $sum->{$line[0]}{$line[14]} = 0;
  }
  $sum->{$line[0]}{$line[14]} += $line[10];

}
close FILE;

my ($year, $state, $dem, $rep, $lib, $otr, $dvt, $rvt, $win);

open( FILE, ">./presidents.csv" ) or die "Couldn't open president.csv: $!\n";
print FILE "Year\tState\tRepublican\tDemocrat\tLibertarian\tOther\tVotes\tWinner\n";
foreach $year (sort keys %$data) {
  foreach $state (sort keys %{$data->{$year}}) {
    $dem = $data->{$year}{$state}{DEMOCRAT} || 0;
    $rep = $data->{$year}{$state}{REPUBLICAN} || 0;
    $lib = $data->{$year}{$state}{LIBERTARIAN} || 0;
    $otr = $data->{$year}{$state}{OTHER} || 0;
    $win = $rep > $dem ? 'Republican' : 'Democrat';
    if (!$electoral->{$year}{DEMOCRAT}) {
      $electoral->{$year}{DEMOCRAT} = 0;
    }
    if (!$electoral->{$year}{REPUBLICAN}) {
      $electoral->{$year}{REPUBLICAN} = 0;
    }
    if ($rep > $dem) {
      $electoral->{$year}{REPUBLICAN} += $votes->{$state};
    } else {
      $electoral->{$year}{DEMOCRAT} += $votes->{$state};
    }
    print FILE "$year\t$state\t$rep\t$dem\t$lib\t$otr\t$votes->{$state}\t$win\n";
  }
}
close FILE;

open( FILE, ">./presidents-totals.csv" ) or die "Couldn't open president.csv: $!\n";
print FILE "Year\tRepublican\tDemocrat\tLibertarian\tOther\tRepublican Electoral Votes\tDemocrat Electoral Votes\tWinner\n";
foreach $year (sort keys %$sum) {
  $dem = $sum->{$year}{DEMOCRAT} || 0;
  $rep = $sum->{$year}{REPUBLICAN} || 0;
  $lib = $sum->{$year}{LIBERTARIAN} || 0;
  $otr = $sum->{$year}{OTHER} || 0;
  $dvt = $electoral->{$year}{DEMOCRAT} || 0;
  $rvt = $electoral->{$year}{REPUBLICAN} || 0;
  $win = $rvt > $dvt ? 'Republican' : 'Democrat';
  print FILE "$year\t$rep\t$dem\t$lib\t$otr\t$rvt\t$dvt\t$win\n";
}
close FILE;
