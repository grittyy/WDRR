# WDRR
WD40 Repeat Recognition (WDRR): Identification of WD40 repeats by secondary structure-aided profile-profile alignment

## Intro
This repo hosts the source codes for the WDRR web server and local version. The results for sequences from the WDSP paper are included in this repo. For more information, refer to the original publication: [Identification of WD40 repeats by secondary structure-aided profile–profile alignment](http://dx.doi.org/10.1016/j.jtbi.2016.03.025)

## Get started
### Requirements
- WDRR was written in Perl and the web server was written in PHP. No SQL database needed.
- WDRR was tested under CentOS 6 64-bit. It should also work under most Linux/Unix systems.
- WDRR needs nr90 BLAST database to run properly. Download nr90 [here (Dropbox)](https://www.dropbox.com/s/rmfrqsz7su3m8ry/blastdb.zip?dl=0) or [here (baiduyun)](http://pan.baidu.com/s/1pLFyLa7) and put all "nr90*" files into the blastdb folder.

### To set up the web server
Put the wdrr folder into your PHP root directory and it should be accessible. (You probably need to change the path to the blastdb/nr90 within bin/wdrr.pl)

### To run WDRR locally
Use the following command:
```sh
perl bin/wdrr-2015.pl -i your-single-sequence.fasta -d blastdb/nr90 -h 1 -o your-output-file.wdr
```
A script `batch-wdrr.pl` is also included as an example for running WDRR for a lot of protein sequences on a compurter cluster based on SLURM. It basically runs for each sequence as a single job, and runs 20 jobs in parallel.

## Other arguments:
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
