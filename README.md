# SFF Extract and Demultiplex
A simple script that ties together several other applications to extract a fastq file from an SFF file (with [sff2fastq](https://github.com/indraniel/sff2fastq)) and then demultiplexes that fastq file based on barcodes (with [fastx_barcode_splitter.pl](http://hannonlab.cshl.edu/fastx_toolkit/commandline.html)) and optionally trims the sequences.  
A [Fastqc](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) HTML report will be generated per barcode.
You can also use a fasta or fastq, the SFF extraction will be skipped.  
This repository also includes a Galaxy tool XML.
## Usage
```
wrapper.sh <input> <output_html> <output_dir> <[eol|bol]> <mismatches> <partial> <input_name> (<barcode_id> <barcode_mid> <barcode_trim_start> <barcode_trim_end>)+
```

## Dependencies
[sff2fastq](https://github.com/indraniel/sff2fastq)
[Fastqc](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
[fastx_barcode_splitter.pl](http://hannonlab.cshl.edu/fastx_toolkit/commandline.html)

These files must be put in the repository directory, check the wrapper.sh script to see how exactly.

## Note
This repository exists mostly for legacy/archival reasons, there are probably better ways of doing this now.