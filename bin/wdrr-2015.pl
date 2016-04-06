#!/usr/bin/perl

#-------------------------------------------------------------------------------
#------------------------ Title, Version & Usage --------------------------------
#-------------------------------------------------------------------------------
my $version = sprintf "v1.0 (Last modified on %s)",scalar localtime((stat($0))[9]);
my $title = <<TITLE;

  ============================================================================
          WDRR - a tool for Recognizing WD40-repeat proteins
            (c) 2010-2016 Zhang's Lab of Protein Bioinformatics @ CAU
  ============================================================================
  $version
  Author: Chuan WANG(grittyy\@cau.edu.cn)

TITLE

my $usage = <<USAGE;
  Usage: WDRR -i <seqfile> [-t <temfile>][-m <method>][-g <n> -x <n> ]
              [-d <blastdb>][-e <n>][-j <n>][-a <n>][-M <n>][-h <n>][-p <n>]
              [-o <outfile>]

USAGE

my $help = "  Type \'--help\' for more details.\n\n";

my $usage1 = <<USAGE1;
  WDRR arguments:

    -i <seqfile> : File contains a FASTA formatted query protein sequence
    -t <temfile> : File contains a FASTA formatted template protein sequence
                   (default = template/WD40-str.fasta)
    -m <method>  : Scoring function options:
                   (default = bdp)
                      b62     = BLOSUM62 scoring matrix
                      dp      = dot product of raw frequencies
                      bdp     = BLOSUM62 + dot product of raw frequencies
    -g <n>       : Gap opening penalty for affine gap penalty type
                   (default = 10)
    -x <n>       : Gap extending penalty for affine gap penalty type
                   (default = 1)
    -d <blastdb> : Path to the database against which PSI-BLAST searches
                   (default = /home/pub/blastdb/nr90)
    -e <n>       : E-value & threshold for inclusion in profiles by PSI-BLAST
                   (default = 0.001)
    -j <n>       : Maximum iterations to generate profiles by PSI-BLAST
                   (default = 5)
    -a <0/1>     : Output alignments
                   (default = 0)
    -M <0/1>     : Output multiple alignments of repeats
                   (default = 1)
    -h <0/1>     : Output each segment hits
                   (default = 0)
    -p <n>       : Cutoff value of p-value
                   (default = 0.05)
    -cpu <n>     : Num. of threads used by PSI-BLAST
                   (default = 1)
    -o <outfile> : Output file
    -html <file> : Generate result file in html format

  For further information, please see the instructions in README file or
  contact the author of this script by mailing to grittyy\@cau.edu.cn.

USAGE1




#-------------------------------------------------------------------------------
#--------------------------- Modules & Variables -------------------------------
#-------------------------------------------------------------------------------
use FindBin;
use lib "$FindBin::Bin";
use strict;
use warnings;
use GapAlign;
#use Time::HiRes 'time';
use Cwd;
use File::Spec;
use File::Basename;
#use Parallel::ForkManager;

# Start time
my $starttime=time();

# Output prior
$|=1;

# Version information
print $title;

my $cmdline = "$0 ".join(' ',@ARGV);

print "  Cmd = $cmdline\n";


#-------------------------------------------------------------------------------
# Read @ARGV and check arguments

# Check arguments
if ($#ARGV<0 || $#ARGV%2==0) {
  print $usage;
  if ($#ARGV >=0) {
    if ($ARGV[0] =~ /^(--help)|(-[h?])|(\/?[h?])$/) {
      die $usage1;
    } else {
      die "  [Error] Invalid arguments! (@ARGV)\n\n";
    }
  } else {
    die $help;
  }
}

my %input = @ARGV;
foreach  (keys %input) {
  if (/-[gxjeaMhp]/ && $input{$_} !~ /-?\d+(\.\d+)?/) {
    die "$usage  [Error] Invalid argument! ($_ $input{$_})\n\n";
  }
}


# ------------------------------------------------------------------------------
# Global constants and variables

# Path of this script
my $path = dirname(File::Spec->rel2abs(__FILE__));

# Default arguments
my %trained = ('b62'     => [9, 1],
               'dp'      => [2, 0.1],
               'bdp'     => [50, 3],
              );

### Z-score EVD
my %mean = ('b62-WD40-pfam' => -7.379597034,
            'bdp-WD40-pfam' => 108.3449772,
            'bdp-WD40-smart' => 108.3449772,
            'dp-WD40-pfam'  => 2.331558685,
            'b62-WD40-str'   => -5.921578908,
            'bdp-WD40-str'   => 114.658845,
            'dp-WD40-str'    => 2.405039323
            );
my %stdev =('b62-WD40-pfam' => 9.468015158,
            'bdp-WD40-pfam' => 42.84260593,
            'bdp-WD40-smart' => 42.84260593,
            'dp-WD40-pfam'  => 0.619496066,
            'b62-WD40-str'   => 9.784520731,
            'bdp-WD40-str'   => 41.30816302,
            'dp-WD40-str'    => 0.616637308
            );

my %arg = ('-m'   => 'bdp',
           '-d'   => "/home/pub/blastdb/nr90",
           '-s'   => 0,
           '-e'   => 0.001,
           '-j'   => 3,
           '-a'   => 0,
           '-M'   => 1,
           '-h'   => 0,
           '-c'   => 0,
           '-p'   => 0.05,
           '-t'   => "$path/template/WD40-str.fasta",
           '-cpu' => 3,
          );

foreach  (keys %input) {
  $arg{$_} = $input{$_};
}

if ($arg{'-m'} !~ /^(b62)|(b?dp)$/) {
  die "$usage  [Error] Invalid method specified! (-m $input{$_})\n\n";
}
if ($arg{'-m'} =~ /^(b62)|(b?dp)$/ && !$arg{'-g'}) {
  ($arg{'-g'}, $arg{'-x'}) = @{$trained{$arg{'-m'}}};
}
# Input sequence file error
if (!$arg{'-i'}) {
  print $usage;
  printf "%-80s\n\n","  [Error] No input sequence file!";
  exit(0);
} elsif (!-s $arg{'-i'} > 0) {
  print $usage;
  printf "%-80s\n\n","  [Error] Input sequence file ($arg{'-i'}) is not found!";
  exit(0);
}
# Specified template file error
if (!$arg{'-t'}) {
  print $usage;
  printf "%-80s\n\n","  [Error] No template file specified!";
  exit(0);
} elsif (!-s $arg{'-t'} > 0) {
  print $usage;
  printf "%-80s\n\n","  [Error] Template file ($arg{'-t'}) is not found!";
  exit(0);
}

# The traceback matrices are indexed by (direction, row, column).
my @direction = (1, 2, 3);
my $stop = 0;

# Directions in the traceback:
my ($fromS, $fromGx, $fromGy) = @direction;

# Minus infinity
my $minInf = -2111111111;     # Representable in 32 bits 2's compl.

# Codes for the traceback
my ($arrows, $opened) = (1, 2);

# Declaration of global variables
my (@seq, @acc, @len, @segment, @position, @rposition, @lamda, @pfl, @ss, @cf);
my (@score, @id, @gaps, @alen, @xaligned, @yaligned, @xssaligned, @yssaligned);
my (@xcf, @ycf, @wdstart, @wdend, @tstart, @tend, @sspred, @ssp);

# Select EVD params
my $met = $arg{'-t'};
$met =~ s/.*\///;
$met =~ s/\..*//;
$met = "$arg{'-m'}-$met";  

# Calculation of Z-score && P-value
my %zscore;
my %pvalue;
my $mean = $mean{$met};
my $dev  = $stdev{$met};



# ------------------------------------------------------------------------------
# ------------------------------ Main program ----------------------------------
# ------------------------------------------------------------------------------

# Read sequences and print information of this alignment attempt
($seq[0], $acc[0], $len[0]) = &readseq($arg{'-i'});
($seq[1], $acc[1], $len[1]) = &readseq($arg{'-t'});
my $info = "  Query = $acc[0] (Len=$len[0])\n".
           "  Tmplt = $acc[1] (Len=$len[1])\n".
           "  Method = $arg{'-m'}  Gap-open = $arg{'-g'}  Gap-extend = $arg{'-x'}\n".
           "  Database = $arg{'-d'}  E-value = $arg{'-e'}  Iteration = $arg{'-j'}\n\n";
print $info;

# Read profile, ss for each sequence
($pfl[0], $ss[0], $cf[0]) = &readpfl($arg{'-i'}, $acc[0], $seq[0]);
($pfl[1], $ss[1], $cf[1]) = &readtempfl("$arg{'-t'}.pfl", "$arg{'-t'}.ss2");

### Determine beta regions and divide into 4-beta windows with loop tails
my ($wstart, $wend) = &sscut($ss[0], $len[0]);

### Output all the alignments for further consideration
if ($arg{'-o'}) {
  open OUTFILE,">$arg{'-o'}" || die "Cannot open output file: $arg{'-o'}!";
  print OUTFILE $title, $info;
}

### Align every window with the template and each gets a score
print "  Aligning segments...\n\n";

for (my $i=0; $i<scalar(@$wstart); $i++) {
  
  # Shrink tandem segments so that they do not overlap
  $$wstart[$i] = $wdend[$i-4]+1 if ($i>3 && $$wstart[$i]<$wdend[$i-4]+1);
  
  # Call the alignment and traceback functions, get matices, score and alignment
  ($score[$i], $xaligned[$i], $yaligned[$i], $xssaligned[$i], $yssaligned[$i], $xcf[$i], $ycf[$i])
    = &Align($arg{'-m'}, $seq[0], $seq[1], $$wstart[$i], $$wend[$i]);
  $score[$i] = -5 if (!$score[$i]);
  
  # Calculate SS score for PSIPRED
  $sspred[$i] = &scoress($xssaligned[$i], $yssaligned[$i], $xcf[$i], $ycf[$i]);
  
  # calculate identity and gaps
  ($id[$i], $gaps[$i]) = (0, 0);
  $alen[$i] = length $xaligned[$i];
  if ($alen[$i] > 0) {
    for (0..$alen[$i]-1) {
      $id[$i]++
        if (substr($xaligned[$i],$_,1) eq substr($yaligned[$i],$_,1));
      $gaps[$i]++
        if (substr($xaligned[$i],$_,1) eq '-' || substr($yaligned[$i],$_,1) eq '-');
    }
    my $xaln = $xaligned[$i];
    my $yaln = $yaligned[$i];
    $xaln =~ s/[^A-Z]//g;
    $yaln =~ s/[^A-Z]//g;
    $wdstart[$i] = rindex(substr($seq[0], 0, $$wend[$i]+1), $xaln)+1;
    $wdend[$i] = $wdstart[$i] + length($xaln) -1;
    $tstart[$i] = rindex($seq[1], $xaln)+1;
    $tend[$i] = $tstart[$i] + length($yaln) -1;
  } else {
    $wdstart[$i] = $$wstart[$i];
    $wdend[$i] = $$wend[$i];
  }

  $zscore{$i} = ($score[$i]-$mean)/$dev;
  $pvalue{$i} = 1-exp(-exp(-$zscore{$i}*3.1415926/sqrt(6)+.5772156649));
  $zscore{$i} = sprintf "%.2f", $zscore{$i};
  $pvalue{$i} = $pvalue{$i}=~/e/ ? sprintf "%1.1e", $pvalue{$i} : sprintf "%.5f", $pvalue{$i};
  chop $pvalue{$i} if (length($pvalue{$i})>7);

  # print score, identity, gaps and alignment to screen and file $arg{'-o'} if specified $arg{'-a'}
  if (($arg{'-h'} || $arg{'-a'}) && $alen[$i]>0) {
    my $hitline = sprintf ">Seg%3d %4d-%-4d  Z-score = %5.2f  Score = %6.2f".
        "  P-value = %s  Identities = %4.1f%%  SS-score = %5.2f\n",
        $i+1, $$wstart[$i], $$wend[$i], $zscore{$i}, $score[$i], $pvalue{$i}, $id[$i]*100/$len[1], $sspred[$i];
    print $hitline;
    print OUTFILE $hitline if ($arg{'-o'});
  }
  if ($arg{'-a'} && $alen[$i]>0) {
    my $alnblock = sprintf "  Q_SS:     %s\n Query:%4s %s %-4s\n Tmplt:%4s %s %-4s\n  T_SS:     %s\n\n",
      $xssaligned[$i], $wdstart[$i], $xaligned[$i], $wdend[$i], $tstart[$i], $yaligned[$i], $tend[$i], $yssaligned[$i];
    print $alnblock;
    print OUTFILE $alnblock if ($arg{'-o'});
  }
}


### Find optimal combination of segments
my @sorted = sort {$zscore{$b} <=> $zscore{$a}} keys %zscore;
my @combined;
for (my $i=0; $i<@sorted; $i++) {
  my $overlap = 0;
  for (my $j=0; $j<@combined; $j++) {
    if (abs($combined[$j]-$sorted[$i])<4 &&
      $wdstart[$combined[$j]]<$wdend[$sorted[$i]]-2 && $wdstart[$sorted[$i]]<$wdend[$combined[$j]]-2) {
      $overlap = 1;
      last;
    }
  }
  
  #if ($overlap eq 0 && $pvalue{$sorted[$i]}<$arg{'-p'} && $sspred[$sorted[$i]] > 39) {
  if ($overlap eq 0 && $pvalue{$sorted[$i]}<$arg{'-p'}) {
    push @combined, $sorted[$i];
  }
}
@combined = sort {$a <=> $b} @combined;

### Query sequence with labelled SS and repeats
my $content = '';
my $qseq = "                       10        20        30        40        50        60        70        80\n               ....*....|....*....|....*....|....*....|....*....|....*....|....*....|....*....|\n";
my $qseqhtml = $qseq;
my $seqwd = ' ' x $len[0];
for (my $i=$#combined; $i>=0; $i--) {
  substr $seqwd, $wdstart[$combined[$i]]-1, $wdend[$combined[$i]]-$wdstart[$combined[$i]]+1, "(".("_" x ($wdend[$combined[$i]]-$wdstart[$combined[$i]]-1)).")";
  substr $seqwd, ($wdstart[$combined[$i]]+$wdend[$combined[$i]])*.5-2, 4, sprintf("WD%2s", $i+1);
}

$seq[0] =~ s/(.{80})/$1\n/g;
my $seqss = substr join('',@{$ss[0]}), 1;
$seqss =~ s/(.{80})/$1\n/g;
my $seqcolor = &colorseq(&highlight($seq[0], $seqss));
$seqwd =~ s/(.{80})/$1\n/g;
my @seqlines = split /\n/, $seq[0];
my @seqclines = split /\n/, $seqcolor;
my @seqwlines = split /\n/, $seqwd;
my @seqslines = split /\n/, $seqss;
for (my $i=0; $i<@seqclines; $i++) {
  my $rpos = ($i+1)*80;
  $rpos = $len[0] if ($rpos > $len[0]);
  $qseq .= sprintf "Query     %4s ".$seqlines[$i]." %-4s\nQuery SS       ".$seqslines[$i]."\nWD40-rpts      ".$seqwlines[$i]."\n\n", $i*80+1, $rpos;
  $qseqhtml .= sprintf "Query     %4s ".$seqclines[$i]." %-4s\nWD40-rpts      ".$seqwlines[$i]."\n\n", $i*80+1, $rpos;
}
print $qseq;
print OUTFILE $qseq if ($arg{'-o'});


if (@combined < 1) {
  print "\nNo WD40-repeats found in QUERY=$acc[0] (Len=$len[0])!\n";
  print OUTFILE "\nNo WD40-repeats found in QUERY=$acc[0] (Len=$len[0])!\n" if ($arg{'-o'});
  $content .= "<strong>No WD40-repeats found in QUERY=$acc[0] (Len=$len[0])!<strong>" if ($arg{'-html'});
} else {
### 2011-07-08 group @combined by distance >= 4-strands(8-segments)
  my @grouped;
  my %gc;
  my $g = 1;
  for (my $i=1; $i<@combined; $i++) {
    $grouped[$i-1] = $g;
    $gc{$g}++;
    $g++ if ($combined[$i] - $combined[$i-1] > 8);
  }
  $grouped[$#combined] = $g;
  $gc{$g}++;
  my @ncombined;
  my @ngrouped;
  for (my $i=0; $i<@combined; $i++) {
    if ($gc{$grouped[$i]} > 3) {
      push @ncombined, $combined[$i];
      push @ngrouped, $grouped[$i];
    }
  }
  #@combined = @ncombined;
  #@grouped = @ngrouped;
###
  printf "\n%d WD40-repeats found in QUERY=$acc[0] (Len=$len[0]):\n", scalar(@combined);
  printf OUTFILE "\n%d WD40-repeats found in QUERY=$acc[0] (Len=$len[0]):\n", scalar(@combined) if ($arg{'-o'});
  $content .= sprintf "<strong>%d WD40-repeats found in QUERY=$acc[0] (Len=$len[0]):</strong><pre>(<font color=red>Red</font> - Z-score>4.0)</pre><pre>", scalar(@combined) if ($arg{'-html'});
  printf "  Rpts  Segment   Boundary  Z-score   Score  P-value  Identities  SS-score\n";
  printf OUTFILE "  Rpts  Segment   Boundary  Z-score   Score  P-value  Identities  SS-score\n" if ($arg{'-o'});
  $content .= sprintf "  Rpts  Segment   Boundary  Z-score   Score  P-value  Identities  SS-score\n" if ($arg{'-html'});
  for (my $i=0; $i<@combined; $i++) {
    my $sig = ' ';
    #$sig = $grouped[$i] if (@grouped>1);
    my $hitline = sprintf " %1sWD%2d:  Seg%3d  %4d-%-4d    %5.2f  %6.2f  %s       %4.1f%%     %5.2f\n",
        $sig, $i+1, $combined[$i]+1, $wdstart[$combined[$i]], $wdend[$combined[$i]],
        $zscore{$combined[$i]}, $score[$combined[$i]], $pvalue{$combined[$i]},
        $id[$combined[$i]]*100/$len[1], $sspred[$combined[$i]];
    print $hitline;
    print OUTFILE $hitline if ($arg{'-o'});
    if ($zscore{$combined[$i]}>=4.037) {
      $hitline = "<font color=red>$hitline</font>";
    }
    $content .= $hitline if ($arg{'-html'});
  }
  $content .= "</pre>" if ($arg{'-html'});
  
  ### 2012-02-07 Display MSA for found repeats
  if ($arg{'-M'}) {
    printf "\nMultiple sequence alignment of %d WD40-repeats:\n\n", scalar(@combined);
    printf OUTFILE "\nMultiple sequence alignment of %d WD40-repeats:\n\n", scalar(@combined)  if ($arg{'-o'});
    $content .= sprintf "<strong>Multiple sequence alignment of %d WD40-repeats:</strong><pre>(<span style=\"background-color:#ddf\">BLUE</span> - beta-strands, <span style=\"background-color:#fdd\">RED</span> - alpha-helices, predicted by PSIPRED)</pre><pre>", scalar(@combined)  if ($arg{'-html'});
    my ($tlen, $fulltmp) = (-1, 0);
    for (my $i=0; $i<@combined; $i++) {
      if (length($yaligned[$combined[$i]])>$tlen) {
        $tlen = length($yaligned[$combined[$i]]);
        $fulltmp = $i;
      }
      $xaligned[$combined[$i]] = reverse $xaligned[$combined[$i]];
      $yaligned[$combined[$i]] = reverse $yaligned[$combined[$i]];
      $xssaligned[$combined[$i]] = reverse $xssaligned[$combined[$i]];
      $yssaligned[$combined[$i]] = reverse $yssaligned[$combined[$i]];
    }
    for (my $p=0; $p<=$tlen; $p++) {
      my @insert;
      for (my $i=0; $i<@combined; $i++) {
        if (length($yaligned[$combined[$i]])>$tlen) {
          $tlen = length($yaligned[$combined[$i]]);
          $fulltmp = $i;
        }
        if ($p>length($yaligned[$combined[$i]])) {
          $yaligned[$combined[$i]] .= '-';
          $yssaligned[$combined[$i]] .= '-';
          $xaligned[$combined[$i]] .= '-';
          $xssaligned[$combined[$i]] .= '-';
        }
        if (substr($yaligned[$combined[$i]],$p,1) eq '-') {
          push @insert, $i;
        }
      }
      if (@insert>0) {
        for (my $i=0; $i<@combined; $i++) {
          next if (&in_array(\@insert, $i));
          substr($yaligned[$combined[$i]],$p,0,'-');
          substr($xaligned[$combined[$i]],$p,0,'-');
          substr($yssaligned[$combined[$i]],$p,0,'-');
          substr($xssaligned[$combined[$i]],$p,0,'-');
        }
      }
    }
    for (my $i=0; $i<@combined; $i++) {
      $xaligned[$combined[$i]] = reverse $xaligned[$combined[$i]];
      $xssaligned[$combined[$i]] = reverse $xssaligned[$combined[$i]];
      $yaligned[$combined[$i]] = reverse $yaligned[$combined[$i]];
      $yssaligned[$combined[$i]] = reverse $yssaligned[$combined[$i]];
    }
    my $msa = '';
    my $msahtml = '';
    for (my $i=0; $i<@combined; $i++) {
      $msa .= sprintf "   WD%2s %4d-%-4d   %s\n", $i+1, $wdstart[$combined[$i]], $wdend[$combined[$i]], $xaligned[$combined[$i]];
      $msahtml .= sprintf "   WD%2s %4d-%-4d   %s\n", $i+1, $wdstart[$combined[$i]], $wdend[$combined[$i]], &colorseq(&highlight($xaligned[$combined[$i]], $xssaligned[$combined[$i]]));
    }
    $msa .= "\n";
    $msahtml .= "\n";
    $msa .= sprintf "   WD40 Template    %s\n", $yaligned[$combined[$fulltmp]];
    $msahtml .= sprintf "   WD40 Template    %s\n", &colorseq(&highlight($yaligned[$combined[$fulltmp]], $yssaligned[$combined[$fulltmp]]));
    $msa .= sprintf "        Tmplt-SS    %s\n", $yssaligned[$combined[$fulltmp]];
    #$msahtml .= sprintf "        Tmplt-SS    %s\n", $yssaligned[$combined[$fulltmp]];
    $msa .= "\n";
    $msahtml .= "\n";
    for (my $i=0; $i<@combined; $i++) {
      $msa .= sprintf "   SS%2s %4d-%-4d   %s\n", $i+1, $wdstart[$combined[$i]], $wdend[$combined[$i]], $xssaligned[$combined[$i]];
      #$msahtml .= sprintf "   SS%2s %4d-%-4d   %s\n", $i+1, $wdstart[$combined[$i]], $wdend[$combined[$i]], $xssaligned[$combined[$i]];
    }
    print $msa;
    print OUTFILE $msa if ($arg{'-o'});
    if ($arg{'-html'}) {
      $content .= $msahtml.'</pre>';
    }
  }
  ###
}


print "\n";
if ($arg{'-o'}) {
  #print "  Alignment also written to file \'$arg{'-o'}\'.\n";
  close OUTFILE;
}

### 2012-02-10 Generate HTML file
if ($arg{'-html'}) {
  open DAT, ">$arg{'-i'}.dat";
  print DAT "0\t0\t0\n";
  for (my $i=0; $i<scalar(@$wstart); $i++) {
    print DAT ($i+1)."\t$zscore{$i}\t0\t$score[$i]\t$sspred[$i]\t$wdstart[$i]-$wdend[$i]\n";
  }
  print DAT (scalar(@$wstart)+1)."\t0\t0\n";
  close DAT;
  my $gplt = 'set terminal png
set output "'.$arg{'-i'}.'.png"
set title "WDRR: Alignment Z-scores of '.scalar(@$wstart).' segments in '.$acc[0].'"
set size 1,0.5
set xlabel"4-beta-strand-segments"
set ylabel"Alignment Z-score"
set y2label"Alignment SS-score"
set ytics
set ytics nomirror
set y2tics
set xtics auto
unset key
';
  #$gplt .= 'plot "'.$arg{'-i'}.'.dat" using 1:2:3 w filledcurves lw 2 lc rgb "grey", 2.766 lt 0 lc 1 lw 2, 4.037 lt 0 lc 2 lw 2';
  $gplt .= 'plot "'.$arg{'-i'}.'.dat" using 1:2 w filledcurves lw 2 lt 8 axis x1y1, 2.766 lt 1 lw 2 w dots axis x1y1, 4.037 lt 2 lw 2 w dots axis x1y1, "'.$arg{'-i'}.'.dat" using 1:5 w lines lw 2 lt 5 axis x1y2';
  #$gplt .= 'plot "'.$arg{'-i'}.'.dat" using 1:2 w lines lw 2 lt 8 axis x1y1, "'.$arg{'-i'}.'.dat" using 1:5 w lines lw 2 lt 4 axis x1y2';

  open GPLT, "| gnuplot";
  print GPLT $gplt;
  close GPLT;
  my $jobdir = dirname(File::Spec->rel2abs($arg{'-i'}));
  $jobdir =~ s/.*\/tmp\//tmp\//;
  $content = "
<strong>Input parameters:</strong>
<pre>$info</pre>
<strong>Query sequence ($acc[0], Len=$len[0]):</strong>
<pre>(<span style=\"background-color:#ddf\">BLUE</span> - beta-strands, <span style=\"background-color:#fdd\">RED</span> - alpha-helices, predicted by PSIPRED)</pre>
<pre>$qseqhtml</pre>
<img src=\"$jobdir/$arg{'-i'}.png\"><br /><br />
".$content;

  open HTML, ">$arg{'-html'}";
  print HTML $content;
  close HTML;
}


# end time
my $endtime = time();
printf "  ==========\n  %.3f seconds.\n\n",$endtime-$starttime;




# ------------------------------------------------------------------------------
# ------------------------------ Subroutines -----------------------------------
# ------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Read input sequence file
# Input: the FASTA file name by $arg{'-i'}
# Output: references to $seq, $acc, $len

sub readseq {
  my $seqfile = shift;
  my $i = 0;
  my $seq = '';
  my ($acc, $len);
  if (-e $seqfile) {
    open SEQ, "<$seqfile";
    while (<SEQ>) {
      $i++ if (/^>/);
      if ($i>1) {
        last;
      }elsif ($i>0) {
        $seq .= $_;
      }
    }
    close SEQ;
    if ($i < 1) {
      printf "\r%-80s\n\n", "  [Error] There's no sequence in file '$seqfile'!";
      exit(0);
    }
  }else{
    printf "\r%-80s\n\n", "  [Error] Sequence file '$seqfile' doesn't exists!";
    exit(0);
  }
  $seq =~ s/^>(.*)\s*$//m;
  $acc = $1;
  $seq = uc $seq;
  $seq =~ s/[^A-Z]//g;
  $len = length $seq;
  $acc =~ s/\s+.*$//;
  $acc =~ s/[^A-Za-z0-9-_.]/_/g;
  return ($seq, $acc, $len);
}


# ------------------------------------------------------------------------------
# Read query profile files to arrays, do PSI-BLAST first if not exists
# Have dependencies on &prep and &readtempfl
# Input: the FASTA file name by $arg{'-i'}, accession by $acc, sequence by $seq
# Output: references to @pfl @ss

sub readpfl {
  my ($seqfile, $acc, $seq) = @_;
  
  # Generate PSI-BLAST and calculate .pfl .ss2 files
  my $pass = &prepQuery($seqfile, $acc, $seq, $arg{'-d'}, $arg{'-j'}, $arg{'-e'});
  
  # Read files to @pfl @ss and return
  #return &readtempfl("$seqfile.tmp/$acc.pfl", "$seqfile.tmp/$acc.ss2");
  return &readtempfl("$seqfile.pfl", "$seqfile.ss2");
}


# ------------------------------------------------------------------------------
# Do PSI-BLAST first if .pfl and .ss2 files are not exists
# Input: the FASTA file name by $arg{'-i'}, accession by $acc, sequence by $seq
# Output: references to @pfl @ss

sub prepQuery {
  my ($seqfile, $acc, $seq, $nrdb, $argj, $arge) = @_;
  my $seqpath   = dirname $seqfile;
  my $basename  = basename $seqfile;
  #mkdir "$seqfile.tmp";
  #my $fastafile = "$seqfile.tmp/$basename.fasta";
  #my $bstfile   = "$seqfile.tmp/$basename.bst";
  #my $pssmfile  = "$seqfile.tmp/$basename.pssm";
  #my $ssfile    = "$seqfile.tmp/$basename.ss2";
  #my $pflfile   = "$seqfile.tmp/$basename.pfl";
  #my $chkfile   = "$seqfile.tmp/$basename.chk";
  my $fastafile = "$seqfile";
  my $bstfile   = "$seqfile.bst";
  my $pssmfile  = "$seqfile.pssm";
  my $ssfile    = "$seqfile.ss2";
  my $pflfile   = "$seqfile.pfl";
  my $chkfile   = "$seqfile.chk";

  my $tmproot   = "psitmp$acc";
  # Write $seq to SSEQ
  #if (!-e $fastafile) {
  #  open SSEQ, ">$fastafile" or die "Cannot open $fastafile!\n";
  #  print SSEQ ">$acc\n$seq\n";
  #  close SSEQ;
  #}
  # Psi-blast to generate .pssm and .bst files
  if (!-e $ssfile || (!-e $bstfile && !-e $pflfile )) {
    print "  Doing PSI-BLAST against $nrdb for QUERY=$acc (Len=".length($seq).")...\n";
    #my $psiblast = "$path/tools/ncbi-blast-2.2.25+";
    #system "$psiblast/bin/psiblast -num_threads $arg{'-cpu'} -db $nrdb -query $fastafile -evalue $arge -inclusion_ethresh $arge -out_pssm $tmproot.chk -num_iterations $argj -out_ascii_pssm $pssmfile -out $bstfile ";
    system "psiblast -query $fastafile -num_threads $arg{'-cpu'} -db $nrdb -evalue $arge -inclusion_ethresh $arge -out_pssm $tmproot.chk -num_iterations $argj -out_ascii_pssm $pssmfile -out $bstfile ";
    die "\n  [Error] Cannot launch PSI-BLAST for $acc!\n" unless (-e $bstfile);
    die "\n  [Error] No hits found by PSI-BLAST for $acc against $nrdb!\n" if (`grep "No hits found" $bstfile`);
  }

  ### do psipred to generate .ss2 file

  if (!-e $ssfile) {
    print "  Predicting PSIPRED secondary structure types...\n";

    my $psipred = "$path/tools/psipred32";
    `$psipred/bin/chkparse $tmproot.chk > $tmproot.mtx`;
    `$psipred/bin/psipred $tmproot.mtx $psipred/data/weights.dat $psipred/data/weights.dat2 $psipred/data/weights.dat3 > $seqpath/$acc.ss`;
    `$psipred/bin/psipass2 $psipred/data/weights_p2.dat 1 1.0 1.0 $ssfile $seqpath/$acc.ss > $seqpath/$acc.horiz`;
    #`cp $tmproot.chk $chkfile`;
    `rm -f $tmproot.* error.log $seqpath/$acc.ss $seqpath/$acc.horiz`;
    die "\n  [Error] Cannot predict SS using PSIPRED for $acc!\n" unless (-e "$ssfile");
  }

  ### Generate .pfl file

  if (!-e $pflfile) {
    print "  Calculating profile for QUERY=$acc (Len=".length($seq).")...\n";
    # Read bst file to calculate
    open BST,"<$bstfile";
    my %am; ## alignment metrix
    my %ev_dim; ## sequence E-value
    my $ROUND;
    while (my $line=<BST>) {
      if ($line=~/Results from round\s+(\d+)/) {
        $ROUND=$1;
      }
    }
    seek BST,0,0;
    my $it = 0;  ## sequence index
    while(my $line=<BST>){
      last if (!$ROUND);
      if($line=~/Results from round\s+$ROUND/){
        while(my $line=<BST>){
          if($line=~/Expect =\s*([^\s,]+)/){
            my $ev=$1;
            $ev="1".$ev if ($ev=~/^e/);
            <BST>=~/Identities =\s*\S+\s+\(([0-9.]+)\%/;
            my $id=$1;
            <BST>;
            if($ev<0.1 && $id < 98){
              $it++;
              $ev_dim{$it}=$ev;
              my $m2=0;
              while(my $line = <BST>){
                if($line=~/Query\:?\s*(\d+)\s+(\S+)\s+(\d+)/){
                  my $i1=$1;  ## query segment start index
                  my $seq1=$2;  ## query segment
                  <BST>;
                  <BST>=~/Sbjct\:?\s*(\d+)\s+(\S+)\s+(\d+)/;
                  my $seq2=$2;   ## subject segment
                  <BST>;
                  ###
                  my $L=length $seq1;   ## length of query segment
                  my $m1=$i1-1;   ## query array start index
                  for(my $i=1;$i<=$L;$i++){
                    my $q1=substr($seq1,$i-1,1);
                    my $q2=substr($seq2,$i-1,1);
                    #$m1++ if($q1 ne '-');
                    if ($q1 ne '-') {
                      $m1++;
                      $m2=0;
                    } else {
                      $m2+=.0001;
                    }
                    $am{"$it,".($m1+$m2)}=$q2;  #with henikoff
                  }
                } elsif ($line =~ /^\s*$/) {
                  last;
                }
              }
            }
          }
        }
      }
    }
    close(BST);

    # with henikoff
    # Henikoff weight $wei{i_seq}
    # nA{A,i_pos}: number of times A appear at the position
    my %nA;
    my %w;
    my $w_all;
    for(my $i=1;$i<=length($seq);$i++){
      foreach my $j (@GapAlign::AA) {
        $nA{"$j,$i"} = 0;
      }
    }
    for(my $i=1;$i<=length($seq);$i++){
      for (my $j=1;$j<=$it;$j++){
        if (defined($am{"$j,$i"})) {
          $nA{$am{"$j,$i"}.",$i"} += &transform($ev_dim{$j});
        }
      }
    }
    
    # henikoff weight w(i)=sum of 1/rs
    for(my $i=1;$i<=$it;$i++){
      for(my $j=1;$j<=length($seq);$j++){
        ####### r: number of different residues in j'th position:
        if (defined($am{"$i,$j"}) && $am{"$i,$j"} ne ' ' && $am{"$i,$j"} ne '-') {
          my $r=0;
          foreach my $A(@GapAlign::AA){
            $r++ if($nA{"$A,$j"}>0);
          }
          $w{$i}+=1.0/($r*$nA{$am{"$i,$j"}.",$j"});
        }
      }
      $w_all+=$w{$i};
    }
    
    # normalization of w(i):
    for(my $i=1;$i<=$it;$i++){
      $w{$i}/=$w_all;
    }
    # Henikoff weight finished

    if (!-e $pflfile) {
      # weighted frequence
      my (%log, %pfl);
      for(my $i=1;$i<=$it;$i++){
          for(my $j=1;$j<=length($seq);$j++){
              $log{"$j,".$am{"$i,$j"}}+=$w{$i} if (defined($am{"$i,$j"}));
          }
      }
      
      #record the profile
      for(my $i=1;$i<=length($seq);$i++) {
          my $norm=0;
          foreach my $A(@GapAlign::AA) {
            if (!defined($log{"$i,$A"})) {
              $log{"$i,$A"}=0;
            }
            $norm+=$log{"$i,$A"};
          }
          $norm = 1 if $norm eq 0;
          foreach my $A(@GapAlign::AA) {
            $pfl{"$i,$A"}=$log{"$i,$A"}/$norm;
          }
      }
      
      # Write to pfl file
      open PFL,">$pflfile";
      print PFL "# profile length: ".length($seq)."\n";
      for(my $i=1;$i<=length($seq);$i++){
          printf PFL "%3d %s",$i,substr($seq,$i-1,1);
          foreach my $A(@GapAlign::AA){
              printf PFL "%10.7f",$pfl{"$i,$A"};
          }
          print PFL "\n";
      }
      close PFL;
    }
  }
  return;
}


# ------------------------------------------------------------------------------
# Read template profile files to arrays
# Input: the FASTA file name by $arg{'-t'}, accession by $acc, sequence by $seq,
#        specified profile $pflfile
# Output: references to @pfl @ss

sub readtempfl {
  my ($pflfile, $ssfile) = @_;
  my (@pfl, @ss, @cf);
  
  # Read files to @pfl @ss
  die "\n  [Error] Cannot open profile ($pflfile)!\n" if (!-e $pflfile);
  open PFL, "<$pflfile";
  while (<PFL>) {
    if (/^\s*\d+/) {
      s/^\s*//;
      my ($pos, $sym, @vec) = split /\s+/;
      $pfl[$pos]=[@vec[0..19]];
    }
  }
  close PFL;
  
  die "\n  [Error] Cannot open .ss2 file ($ssfile)!\n" if (!-e $ssfile);
  open SS, "<$ssfile";
  while (<SS>) {
    if (/^\s*\d+/) {
      s/^\s*//;
      my @row = split;
      $ss[$row[0]] = $row[2];
      $cf[$row[0]] = int 10* (2* &max(@row[3..5]) - ($row[3]+$row[4]+$row[5]) + &min(@row[3..5]));
      $cf[$row[0]] = 9 if ($cf[$row[0]]>9);
    }
  }
  $ss[0] = 'C';
  $cf[0] = 0;
  close SS;
  
  return \@pfl, \@ss, \@cf;  
}


# ------------------------------------------------------------------------------
# Cut a sequence into 4-beta fragments (overlapped)
# Input: the SS @ss array of a sequence
#        the length of the sequence
# Output: the start and end positions of fragments in @start and @end

sub sscut {
  my ($ss, $len) = @_;
  my (@estart, @betas, @helices, @start, @end);
  
  ## count elements
  #my $nn = 0;
  #$estart[0] = 1;
  #for (my $i=1; $i<=$len; $i++) {
  #  if ($i == 1) {
  #    $nn++;
  #    $estart[$nn] = $i;
  #    push @betas, $nn if ($$ss[$i] eq 'E');
  #    push @helices, $nn if ($$ss[$i] eq 'H');
  #  } elsif ($$ss[$i] ne $$ss[$i-1])  {
  #    $nn++;
  #    $estart[$nn] = $i;
  #    push @betas, $nn if ($$ss[$i] eq 'E');
  #    push @helices, $nn if ($$ss[$i] eq 'H');
  #  }
  #}
  #$estart[$nn+1] = $len+1;

  # 20110517 mod - count elements
  my $nn = 0;
  my $mm = 0;
  my $hm = 0;
  $estart[0] = 1;
  for (my $i=1; $i<=$len; $i++) {
    if ($$ss[$i] ne $$ss[$i-1])  {
      if ($$ss[$i-1] eq 'C' || $mm > 2) {
        $nn++;
        ## 2011-08-18 mod - shorten terminal C's with half of the C element
        if ($$ss[$i-1] eq 'C') {
          $hm = int $mm*.5 if ($arg{'-s'} eq 1);   # half of $mm
          $mm -= $hm;
        }
        ##
        $estart[$nn] = $i - $mm;
        ## 2011-08-18 mod - shorten terminal C's with half of the C element
        if ($$ss[$i-1] ne 'C') {
          push @betas, $nn if ($$ss[$i-1] eq 'E');
          push @helices, $nn if ($$ss[$i-1] eq 'H');
          $estart[$nn] -= $hm;  # $hm from last round
          $hm = 0;
        }
        ##
        ## push @betas, $nn if ($$ss[$i-1] eq 'E');
        ## push @helices, $nn if ($$ss[$i-1] eq 'H');
        $mm = 0;
      }
    }
    $mm++;
  }
  if ($$ss[$len] eq 'C' || $mm > 2) {
    $nn++;
    ## 2011-08-18 mod - shorten terminal C's with half of the C element
    if ($$ss[$len] eq 'C') {
      $hm = int $mm*.5 if ($arg{'-s'} eq 1);   # half of $mm
      $mm -= $hm;
    }
    ##
    $estart[$nn] = $len-$mm+1;
    ## 2011-08-18 mod - shorten terminal C's with half of the C element
    if ($$ss[$len] ne 'C') {
      push @betas, $nn if ($$ss[$len] eq 'E');
      push @helices, $nn if ($$ss[$len] eq 'H');
      $estart[$nn] -= $hm;  # $hm from last round
      $hm = 0;
    }
    ##
    ## push @betas, $nn if ($$ss[$len] eq 'E');
    ## push @helices, $nn if ($$ss[$len] eq 'H');
  }
  $estart[$nn+1] = $len+1-$hm;
  ## $estart[$nn+1] = $len+1;
  
  # cut into fragments
  if (@betas < 4) {
    $start[0] = 1;
    $end[0] = $len;
  } else {
    for (my $i=0; $i<@betas-3; $i++) {
      if ($betas[$i] == 1) {
        $start[$i] = 1;
      } else {
        if ($estart[$betas[$i]]>5) {
          $start[$i] = $estart[$betas[$i]-1];
        } else {
          $start[$i] = 1;
        }
      }
      if ($betas[$i+3] >= $nn-1) {
        $end[$i] = $len;
      } else {
        if ($estart[$betas[$i+3]+1]<$len-5) {
          $end[$i] = $estart[$betas[$i+3]+2]-1;
        } else {
          $end[$i] = $len;
        }
      }
    }
  }
  return \@start, \@end;
}


# ------------------------------------------------------------------------------
# The Needleman-Wunsch global alignment algorithm &&
# The Smith-Waterman local alignment algorithm
# Input: the scoring matrix, the sequences $x and $y,
#        the start & end positions of query to align in $start & $end
# Output: references to the matrices S, Gx, Gy, TB,
#         maximal score and the aligned sequences

sub Align {
  my ($method, $x, $y, $start, $end) = @_;
  my ($n, $m) = ($end, length($y));
  # Initialize upper and left-hand borders
  # S represent an aa/aa match;
  # Gx represents insertions in x (gaps in y);
  # Gy represents insertions in y (gaps in x);
  # The traceback now points to the matrix (S, Gx, Gy) from which the
  # maximum was obtained: $fromS=1, $fromGx=2, $fromGy=3
  # TB[$dir][1] is the traceback for S,
  # TB[$dir][2] is the traceback for Gx;
  # TB[$dir][3] is the traceback for Gy
  my (@S, @Gx, @Gy, @TB);
  $S[0][$start-1] = 0;
  $Gx[0][$start-1] = $Gy[0][$start-1] = $minInf;
  # The traceback matrix; also correctly initializes borders
  foreach my $dir (@direction) {
    for (my $j=0; $j<=$m; $j++) {
      for (my $k=1; $k<=3; $k++) {
        $TB[$dir][$k][$j] = [($stop) x ($n+1)];
      }
    }
  }
  for (my $i=$start; $i<=$n; $i++) {
    $Gx[0][$i] = - $arg{'-g'} - $arg{'-x'} * ($i-1);
    #2011-05-20 no penalty for terminal gaps
    #$Gx[0][$i] = 0*$Gx[0][$i];
    $TB[$fromGx][2][0][$i] = $arrows;
    $Gy[0][$i] = $minInf;
    $S[0][$i] = $minInf;
  }
  for (my $j=1; $j<=$m; $j++) {
    $Gy[$j][$start-1] = - $arg{'-g'} - $arg{'-x'} * ($j-1);
    #2011-05-20 no penalty for terminal gaps
    #$Gy[$j][$start-1] = 0*$Gy[$j][$start-1];
    $TB[$fromGy][3][$j][$start-1] = $arrows;
    $Gx[$j][$start-1] = $minInf;
    $S[$j][$start-1] = $minInf;
  }
  # Fill in the matrices S, Gx, Gy, TB
  for (my $i=$start; $i<=$n; $i++) {
    for (my $j=1; $j<=$m; $j++) {
      my $s = $arg{'-c'} + &score($method,
                                  substr($x, $i-1, 1),
                                  substr($y, $j-1, 1),
                                  $i,
                                  $j,
                                  \@lamda,
                                  \@pfl);
      # 2011-05-20 no penalty for H and align a gap for template to the H in query
      if ($ss[0][$i] eq 'H') {
        $S[$j][$i] = $minInf;
        $Gy[$j][$i] = $minInf;
        $Gx[$j][$i] = &max($S[$j][$i-1],
                           $Gx[$j][$i-1],
                           $Gy[$j][$i-1]);
        if ($Gx[$j][$i] == $S[$j][$i-1]) {
          $TB[$fromS][2][$j][$i] = $arrows;
        }
        if ($Gx[$j][$i] == $Gx[$j][$i-1]) {
          $TB[$fromGx][2][$j][$i] = $TB[$fromGx][2][$j][$i-1] + $arrows;
        }
        if ($Gx[$j][$i] == $Gy[$j][$i-1]) {
          $TB[$fromGy][2][$j][$i] = $arrows;
        }
      } else {
        
      ## in the else clause for 'H'
      $S[$j][$i] = &max($S[$j-1][$i-1]+$s,
                        $Gx[$j-1][$i-1]+$s,
                        $Gy[$j-1][$i-1]+$s);
      if ($S[$j][$i] == $S[$j-1][$i-1]+$s) {
        $TB[$fromS][1][$j][$i] = $arrows;
      }
      if ($S[$j][$i] == $Gx[$j-1][$i-1]+$s) {
        $TB[$fromGx][1][$j][$i] = $arrows;
      }
      if ($S[$j][$i] == $Gy[$j-1][$i-1]+$s) {
        $TB[$fromGy][1][$j][$i] = $arrows;
      }
      if ($arg{'-s'} eq -2 && $ss[0][$i] eq $ss[1][$j] && $ss[0][$i] ne 'E') {
        # SSR
        $Gx[$j][$i] = $minInf;
        $Gy[$j][$i] = $minInf;
      } else {
        my ($gox, $goy, $gex, $gey) = (&gapopen($i, $j, 1),
                                       &gapopen($i, $j, 0),
                                       &gapextend($i, $j, 1, $TB[$fromGx][2][$j][$i-1]),
                                       &gapextend($i, $j, 0, $TB[$fromGy][3][$j-1][$i]));
        if ($arg{'-s'} eq -1 && $ss[1][$j] eq $ss[1][$j-1] && $ss[1][$j] eq 'E') {
          # FSSR - Flanking SSR
          $Gx[$j][$i] = $minInf;
          #$Gy[$j][$i] = $minInf;
        } else {
          $Gx[$j][$i] = &max($S[$j][$i-1]-$gox,
                             $Gx[$j][$i-1]-$gex,
                             $Gy[$j][$i-1]-$gox);
          if ($Gx[$j][$i] == $S[$j][$i-1]-$gox) {
            $TB[$fromS][2][$j][$i] = $arrows;
          }
          if ($Gx[$j][$i] == $Gx[$j][$i-1]-$gex) {
            $TB[$fromGx][2][$j][$i] = $TB[$fromGx][2][$j][$i-1] + $arrows;
          }
          if ($Gx[$j][$i] == $Gy[$j][$i-1]-$gox) {
            $TB[$fromGy][2][$j][$i] = $arrows;
          }
        }
        if ($arg{'-s'} eq -1 && $ss[0][$i] eq $ss[0][$i-1] && $ss[0][$i] eq 'E') {
          # FSSR - Flanking SSR
          #$Gx[$j][$i] = $minInf;
          $Gy[$j][$i] = $minInf;
        } else {
          $Gy[$j][$i] = &max($S[$j-1][$i]-$goy,
                             $Gy[$j-1][$i]-$gey,
                             $Gx[$j-1][$i]-$goy);
          if ($Gy[$j][$i] == $S[$j-1][$i]-$goy) {
            $TB[$fromS][3][$j][$i] = $arrows;
          }
          if ($Gy[$j][$i] == $Gy[$j-1][$i]-$gey) {
            $TB[$fromGy][3][$j][$i] = $TB[$fromGy][3][$j-1][$i] + $arrows;
          }
          if ($Gy[$j][$i] == $Gx[$j-1][$i]-$goy) {
            $TB[$fromGx][3][$j][$i] = $arrows;
          }
        }
      }
      
      ## end of the else clause for 'H'
      }
    }
  }
  # Find maximal score in matrices for local alignment
  # Find maximal score of ($m,$n) in matrix (@S, @Gx or @Gy) for globalalignment
  # $vmax is the highest score
  # $kmax is the matrix which contains the $vmax, 1 for @S, 2 for @Gx, 3 for @Gy
  # $imax and $jmax is the column and row of the $vmax in $kmax
  my ($vmax, $kmax, $jmax, $imax) = ($S[$m][$end], 1, $m, $end);
  
  for (my $i=$start; $i<=$end; $i++) {
    $vmax = &max($vmax, $S[$m][$i], $Gx[$m][$i], $Gy[$m][$i]);
  }
  for (my $i=$start; $i<=$end; $i++) {
    if ($vmax == $S[$m][$i]) {
      $imax = $i;
      $kmax = 1;
    }
    if ($vmax == $Gx[$m][$i]) {
      $imax = $i;
      $kmax = 2;
    }
    if ($vmax == $Gy[$m][$i]) {
      $imax = $i;
      $kmax = 3;
    }
  }

  # release mem
  @S  = ();
  @Gx = ();
  @Gy = ();
  return ($vmax, &traceback($x, $y, \@TB, $kmax, $imax, $jmax, $start, $end));
}


# ------------------------------------------------------------------------------
# Traceback subroutine for reconstruct the alignment from the traceback matrices

sub traceback {
  my ($x, $y, $TB, $k, $i, $j, $start, $end) = @_;      # TB by reference
  my ($xAlign, $yAlign, $xSStr, $ySStr, $xSScf, $ySScf) = ("", "", "", "", "", "");
  #print "  Tracing back...\n";
  while ((($j == 1 && $k == 1) || $j > 1) && $i>=$start && ($$TB[$fromS][$k][$j][$i] != 0
         || $$TB[$fromGx][$k][$j][$i] != 0
         || $$TB[$fromGy][$k][$j][$i] != 0)) {
  #while ( $j >= 1 || $i>=$start && ($$TB[$fromS][$k][$j][$i] != 0
  #       || $$TB[$fromGx][$k][$j][$i] != 0
  #       || $$TB[$fromGy][$k][$j][$i] != 0)) {
    my $nextk;
    # Mark as route the path that was actually taken
    if ($$TB[$fromS][$k][$j][$i]) {
      $nextk = 1;               # From S
    } elsif ($$TB[$fromGx][$k][$j][$i]) {
      $nextk = 2;               # From Gx
    } elsif ($$TB[$fromGy][$k][$j][$i]) {
      $nextk = 3;               # From Gy
    }
    if ($k == 1) {              # We're in the S matrix
      $xAlign .= substr($x, $i-1, 1);
      $yAlign .= substr($y, $j-1, 1);
      $xSStr  .= $ss[0][$i];
      $ySStr  .= $ss[1][$j];
      $xSScf  .= $cf[0][$i];
      $ySScf  .= $cf[1][$j];
      $i--; $j--;
    } elsif ($k == 2) {         # We're in the Gx matrix
      $xAlign .= substr($x, $i-1, 1);
      $yAlign .= "-";
      $xSStr  .= $ss[0][$i];
      $ySStr  .= "-";
      $xSScf  .= $cf[0][$i];
      $ySScf  .= "-";
      $i--;
    } elsif ($k == 3) {         # We're in the Gy matrix
      $xAlign .= "-";
      $yAlign .= substr($y, $j-1, 1);
      $xSStr  .= "-";
      $ySStr  .= $ss[1][$j];
      $xSScf  .= "-";
      $ySScf  .= $cf[1][$j];
      $j--;
    }
    $k = $nextk;
  }
  $xAlign = reverse $xAlign;
  $yAlign = reverse $yAlign;
  $xSStr  = reverse $xSStr;
  $ySStr  = reverse $ySStr;
  $xSScf  = reverse $xSScf;
  $ySScf  = reverse $ySScf;
  return ($xAlign, $yAlign ,$xSStr, $ySStr, $xSScf, $ySScf);
}


#-------------------------------------------------------------------------------
# scoress - score PSIPRED SS matches

sub scoress {
  my ($ss0, $ss1, $cf0, $cf1) = @_;
  my @s1 = split //, $ss0;
  my @s2 = split //, $ss1;
  my @c1 = split //, $cf0;
  my @c2 = split //, $cf1;
  my $scoress = 0;
  for (my $i=0; $i<length($ss0); $i++) {
    $c1[$i] =~ s/-/-1/g;
    $c2[$i] =~ s/-/-1/g;
    $scoress += &sspred($s1[$i], $c1[$i]+1, $s2[$i], $c2[$i]+1);
  }
  return $scoress;
}


#-------------------------------------------------------------------------------
# gapopen score function

sub gapopen {
  ## affine gap penalty
  return $arg{'-g'} + $arg{'-x'};
}


#-------------------------------------------------------------------------------
# gapextend score function

sub gapextend {
  ## affine gap penalty
  return $arg{'-x'};
}


#-------------------------------------------------------------------------------
# color sequence function

sub colorseq {
  my $chr = shift;
  my @char = split //, $chr;
  for (my $i=0; $i<@char; $i++) {
    if ($char[$i] =~ /[AGST]/) {
      $char[$i] = "<font color=#404040>$char[$i]</font>";
    } elsif ($char[$i] eq 'C') {
      $char[$i] = "<font color=#a08000>$char[$i]</font>";
    } elsif ($char[$i] =~ /[DE]/) {
      $char[$i] = "<font color=blue>$char[$i]</font>";
    } elsif ($char[$i] =~ /[FWY]/) {
      $char[$i] = "<font color=#00a000>$char[$i]</font>";
    } elsif ($char[$i] =~ /[ILMV]/) {
      $char[$i] = "<font color=green>$char[$i]</font>";
    } elsif ($char[$i] =~ /[KR]/) {
      $char[$i] = "<font color=red>$char[$i]</font>";
    } elsif ($char[$i] eq 'H') {
      $char[$i] = "<font color=#e06000>$char[$i]</font>";
    } elsif ($char[$i] =~ /[NQ]/) {
      $char[$i] = "<font color=#d000a0>$char[$i]</font>";
    #} elsif ($char[$i] eq '-') {
    #  $char[$i] = "<font color=#808080>$char[$i]</font>";
    }
  }
  $chr = join '',@char;
  return $chr;
}


#-------------------------------------------------------------------------------
# highlight - color sequence background according to SS function
# must used before &colorseq

sub highlight {
  my ($seq, $ss) = @_;
  my @residue = split //, $seq;
  my @ss = split //, $ss;
  for (my $i=0; $i<length($seq); $i++) {
    if ($ss[$i] eq 'E') {
      $residue[$i] = "<span style=\"background-color:#ddf;\">$residue[$i]</span>";
    #} elsif ($ss[$i] eq 'C') {
    #  $residue[$i] = "<span style=\"background-color:#ccc;\">$residue[$i]</span>";
    } elsif ($ss[$i] eq 'H') {
      $residue[$i] = "<span style=\"background-color:#fdd;\">$residue[$i]</span>";
    }
  }
  $seq = join '',@residue;
  return $seq;
}

