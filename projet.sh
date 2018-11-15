#!/bin/bash
#Projet Shell : Groupe ELSAESSER Quentin && LEFEVRE Antoine
max=$#
test $max -eq 0 && echo "Il faut au moins un paramètre." && exit 1
test ! -d ${!max} && echo "Le dernier paramètre doit être un dossier." && exit 2

#Verification des parametres entres pour le tri
function parametre (){
	if [ ! -d "$1" ]
	then
		if [ "$1" == "-R" ]
		then
			echo ""$1" tri avec chemin d'accès"
		elif [ "$1" == "-d" ]
		then
			echo ""$1" tri ordre decroissant"
		else
			var="$1"
			for i in $(seq 1 ${#var})
			do
				opt=`echo "$var" | cut -c $i`
				if [ "$opt" != "-" ]
				then
					if [ "$opt" == "n" ]
					then
						echo ""$opt" tri selon nom entree"
					elif [ "$opt" == "s" ]
					then
						echo ""$opt" tri selon taille entree"
					elif [ "$opt" == "m" ]
					then
						echo ""$opt" tri selon date derniere modif"
					elif [ "$opt" == "l" ]
					then
						echo ""$opt" tri selon nombre de ligne"
					elif [ "$opt" == "e" ]
					then
						echo ""$opt" tri selon extension entree"
					elif [ "$opt" == "t" ]
					then
						echo ""$opt" tri selon type fichier"
					elif [ "$opt" == "p" ]
					then
						echo ""$opt" tri selon nom proprietaire fichier"
					elif [ "$opt" == "g" ]
					then
						echo ""$opt" tri selon groupe du proprietaire"
					fi
				fi
				
			done
		fi
	fi
	if [ ! -d "$1" ]
	then
		shift
		parametre $@
	fi
}
parametre $@

#Compare deux chaine donne en parametre
function compare(){
	test $# -ne 2 && echo "probleme de parametre dans fct compare" && exit 3
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

#cherche $1
