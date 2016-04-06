# WDRR
WD40 Repeat Recognition (WDRR): Identification of WD40 repeats by secondary structure-aided profile-profile alignment

This repo hosts the source codes for the WDRR web server and local version. For more information, refer to the original publication: [Identification of WD40 repeats by secondary structure-aided profile–profile alignment](http://www.sciencedirect.com/science/article/pii/S0022519316001661)

WDRR needs nr90 BLAST database to run properly. Download nr90 [here](https://www.dropbox.com/s/rmfrqsz7su3m8ry/blastdb.zip?dl=0) and put all "nr90*" files into the blastdb folder.

WDRR was written in Perl and the web server was written in PHP. No SQL database needed. To set up the web server, put the wdrr folder into your PHP root directory and it should be accessible. To run WDRR locally, use the following command:
```sh
perl bin/wdrr-2015.pl -i your-single-sequence.fasta -d blastdb/nr90 -h 1 -o your-output-file.wdr
```
Other arguments:
```
  ============================================================================
          WDRR - a tool for Recognizing WD40-repeat proteins
            (c) 2010-2016 Zhang's Lab of Protein Bioinformatics @ CAU
  ============================================================================
  v1.0 (Last modified on Tue Dec 29 01:01:52 2015)
  Author: Chuan WANG(grittyy@cau.edu.cn)

  Cmd = bin/wdrr-2015.pl --help
  Usage: WDRR -i <seqfile> [-t <temfile>][-m <method>][-g <n> -x <n> ]
              [-d <blastdb>][-e <n>][-j <n>][-a <n>][-M <n>][-h <n>][-p <n>]
              [-o <outfile>]

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

```
