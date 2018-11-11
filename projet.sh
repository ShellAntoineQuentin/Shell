#!/bin/bash
test $# != 1 && echo "Pas assez de parametres donnés" && exit 1

#Compare deux chaine donne en parametre
function compare(){
	ch1="$1"
	ch2="$2"
	if (test $ch1 \< $ch2)
	then
		echo "OK"
	else
		echo "KO"
	fi
}


cherche () {
	total=""
	#local tag=$1
	local rep=$1
	#cd ..
	#local name=$3
	#cd $rep
	#if [ -f $name -a $tag = "-f" ]
	#then
	#    echo "trouver fichier /$rep/$name"
	#    exit 1
	#elif [ -d $name -a $tag = "-d" ]
	#then
	#    echo "trouver dossier /$rep/$name"
	#    exit 1
	#fi

	for i in `find $rep`
	do
		if [ $i != $rep ]
		then
	#        local nrep="$rep/$i"
		newname=`echo $i | sed "s#"$rep/"##g"`
		total="$total""$newname;"
	#        cherche $tag $nrep $name
		fi
	done
	echo "$total" | cut -d';' -f1
	var="$total" | cut -d';' -f1
	test=`echo "$total" | sed "s/$var//"`
	echo "$test"
}

cherche $1
