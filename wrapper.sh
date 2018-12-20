#!/bin/bash
input="$1"
output="$2"
outDir="$3"
mkdir "$outDir"
EOL="$4"
mismatches="$5"
partial="$6"
name=$(basename "$7")
ext="${name##*.}"
name="${name%.*}"
name="${name// /_}"
prefix="${name}_"
dir="$(cd "$(dirname "$0")" && pwd)"

unzip $dir/fastqc_v0.11.2.zip -d $PWD/ > $PWD/unziplog.log
chmod 755 $PWD/FastQC/fastqc

declare -A trim_start
declare -A trim_end
for ((i=8;i<=$#;i=i+4))
do
	j=$((i+1))
	start_int=$((i+2))
	end_int=$((i+3))
	id="${!i}"
	echo "$id, ${start_int}, ${end_int}"
	trim_start[$id]=${!start_int}
	trim_end[$id]=${!end_int}
  echo -e "$id\t${!j}" >> $outDir/barcodes.txt
  
done
trim_start["unmatched"]=0
trim_end["unmatched"]=0

echo "trim_start = ${trim_start[@]}"
echo "trim_end = ${trim_end[@]}"

workdir=$PWD
cd $outDir
echo "$3"
filetype=`file $input`
result=""
if [[ $filetype == *ASCII* ]]
then
	result=`cat $input | $dir/fastx_barcode_splitter.pl --bcfile $outDir/barcodes.txt --prefix "$prefix" --suffix ".fastq" --$EOL --mismatches $mismatches --partial $partial`
else
	result=`$dir/sff2fastq $input | $dir/fastx_barcode_splitter.pl --bcfile $outDir/barcodes.txt --prefix "$prefix" --suffix ".fastq" --$EOL --mismatches $mismatches --partial $partial`
fi

echo "$result" | tail -n +2 | sed 's/\t/,/g' > output.txt
echo "<html><head><title>$name demultiplex</title></head><body><table border='1'><thead><tr><th>ID</th><th>Count</th><th>FASTQ</th><th>FASTA</th><th>Trimmed FASTA</th><th>FASTQC</th></tr></thead><tbody>" >> $output
while IFS=, read barcode count location
	do
		if [ "total" == "$barcode" ] 
		then 
			echo "<tr><td>$barcode</td><td>$count</td><td></td><td></td><td></td><td></td><td></td><td></td></tr>" >> $output
			break
		fi
		file="${name}_${barcode}"
		mkdir "$outDir/fastqc_$barcode"
		$workdir/FastQC/fastqc "$file.fastq" -o "$outDir" 2> /dev/null
		cat "$file.fastq" | awk 'NR%4==1{printf ">%s\n", substr($0,2)}NR%4==2{print}' > "$file.fasta"
		python $dir/trim.py --input "$file.fasta" --output "${file}_trimmed.fasta" --start "${trim_start[$barcode]}" --end "${trim_end[$barcode]}"
		echo "<tr><td>$barcode</td><td>$count</td><td><a href='$file.fastq'>$file.fastq</a></td><td><a href='$file.fasta'>$file.fasta</a></td><td><a href='${file}_trimmed.fasta'>${file}_trimmed.fasta</a></td><td><a href='${name}_${barcode}_fastqc.html'>Report</a></td></tr>" >> $output
done < output.txt

echo "</tbody></table>" >> $output
cat $dir/results_footer.html >> $output
echo "</body></html>" >> $output
