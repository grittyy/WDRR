#!/usr/bin/perl

# to do batch wdrr locally with hpc

my $usage = <<USAGE;

  Usage: $0 <folder-of-fasta-files> <output-folder>

USAGE

use strict;
use Cwd;
use File::Spec;
use File::Basename;
use LWP::Simple;
use Parallel::ForkManager;

$|=1;   # Output prior
my $path = dirname(File::Spec->rel2abs(__FILE__));  # Path of this script
my $cmdline = "$0 ".join(' ',@ARGV);

# Main body of the script goes:
`mkdir -p $ARGV[1]`;

foreach my $f (`ls $ARGV[0]/*`) {
    chomp $f;
    open(my $fh, '<', $f) or die $!;
    my %seq;
    my $id = '';
    while (<$fh>) {
        if (/^>(\S+)/) {
            $id = $1;
            $seq{$id} = $_;
        } else {
            $seq{$id} .= $_;
        }
    }
    close $fh;
    
    $f =~ s/(.*\/)//;
    my $p = $1;
    
    my @k = sort keys %seq;
    my $pm = new Parallel::ForkManager(20);
    foreach my $i (0..$#k) {
        next if (-s "/home/cwang/wdrr/$ARGV[1]/$f-$i.wdr" > 581);
        #while (`ssh cwang\@hpc-su "squeue | grep cwang | grep 'PD' | head -1"`) {
        ##while (`ps ux | grep 'wdrr-2015.pl' | wc -l` > 8) {
            sleep 1;
        #}
        print STDERR "$f-$i...\n";
        $pm->start and next; # 开始 fork
        open(my $ofh, '>', "$ARGV[1]/$f-$i.fasta") or die $!;
        print $ofh $seq{$k[$i]};
        close $ofh;
        `ssh cwang\@hpc-su "srun -N 1 -c 3 perl /home/cwang/wdrr/bin/wdrr-2015.pl -i /home/cwang/wdrr/$ARGV[1]/$f-$i.fasta -cpu 3 -d /home/cwang/wdrr/blastdb/nr90 -h 1 -o /home/cwang/wdrr/$ARGV[1]/$f-$i.wdr 2>/home/cwang/wdrr/$ARGV[1]/$f-$i.err >/home/cwang/wdrr/$ARGV[1]/$f-$i.info"`;
        #`perl /home/cwang/wdrr/bin/wdrr-2015.pl -i /home/cwang/wdrr/$ARGV[1]/$f-$i.fasta -cpu 3 -d /home/cwang/wdrr/blastdb/nr90 -h 1 -o /home/cwang/wdrr/$ARGV[1]/$f-$i.wdr 2>/home/cwang/wdrr/$ARGV[1]/$f-$i.err >/home/cwang/wdrr/$ARGV[1]/$f-$i.info`;
        $pm->finish;
    }
    $pm->wait_all_children;
}
