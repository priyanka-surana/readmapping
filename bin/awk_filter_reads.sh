awk 'BEGIN{OFS="\t"}{if($1 ~ /^\@/) {print($0)} else {$2=and($2,compl(2048)); print(substr($0,2))}}'
