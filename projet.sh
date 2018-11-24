#!/bin/bash
#Projet Shell : Groupe ELSAESSER Quentin && LEFEVRE Antoine
max=$#
nbPara=$#
test $max -eq 0 && echo "Il faut au moins un paramètre." && exit 1
test ! -d ${!max} && echo "Le dernier paramètre doit être un dossier." && exit 2
test $max -gt 5 && echo "Veuillez saisir au maximum 3 options et un répertoire." && exit 3

ordreDecroissant=0
chaineTriee=""

creeChaine () {
	total=""
	rep=$1
	
	#Enleve le / a la fin s'il a ete mis par l'utilisateur
	taille=`echo ${#rep}`
	fin=`echo "$rep" | cut -c $taille`
	test $fin == "/" && rep=`echo $rep | sed 's/\///'`
	
	#Cree la chaine avec comme separateur un ;
	var=""
	for i in `find $rep -maxdepth 1`
	do
		if test $i != $rep
		then
			if test ! -d $i
			then
				var=`echo $i | sed 's/'"$rep"'\///'`
				total="$total""$var;"
			fi
		fi
	done
	echo $total
}

creeChaineRecursive () {
	total=""
	rep=$1
	
	#Enleve le / a la fin s'il a ete mis par l'utilisateur
	taille=`echo ${#rep}`
	fin=`echo "$rep" | cut -c $taille`
	test $fin == '/' && rep=`echo $rep | sed 's/\///'`
	
	#Cree la chaine avec comme separateur un ;
	var=""
	for i in `find $rep`
	do
		if test $i != $rep
		then
			if test ! -d $i
			then
				var=`echo $i | sed 's/'"$rep"'\///'`
				total="$total""$var;"
			fi
		fi
	done
	echo $total
}

nombreFichier () {
	echo "$1" | grep -o ";" | wc -l
}

nombreSousRep () {
	t=`echo "$1" | grep -o "/" | wc -l`
	t=`expr $t + 1`
	echo "$t"
}

triSimple () {
	total=$1
	echo $total
	nbMots=`nombreFichier $total`
	#indice du premier element a comparer
	indP=1
	#tmp pour stocker le fichier avec son chemin dans le cas ou l'option −R est choisi afin de l'enlever de la chaine totale
	tmp=""
	tmp2=""
	
	while [ "$nbMots" -ge "$indP" ]
	do
		#Indice du second element
		indD=`expr $indP + 1`
		motP=`echo $total | cut -d';' -f$indP`
		tmp="$motP"
		
		#Si c'est dans un sous dossier, on prend uniquement le nom du fichier pour la comparaison
		ssRep=`nombreSousRep $motP`
		if [ "$ssRep" -gt 1 ]
		then
			motP=`echo $motP | cut -d'/' -f$ssRep`
		fi
		
		while [ "$nbMots" -ge "$indD" ]
		do
			motD=`echo $total | cut -d';' -f$indD`
			tmp2="$motD"
			
			#Si c'est dans un sous dossier, on prend uniquement le nom du fichier pour la comparaison
			ssRep=`nombreSousRep $motD`
			if [ "$ssRep" -gt 1 ]
			then
				motD=`echo $motD | cut -d'/' -f$ssRep`
			fi
			
			#Comparaison
			if [ "$motD" != "" ]
			then
				if [ $ordreDecroissant -eq 0 ]
				then
					#Ordre Croissant
					if [ "$motD" \< "$motP" ]
					then
						motP="$motD"
						tmp="$tmp2"
					fi
				else
					#Ordre Decroissant
					if [ "$motP" \< "$motD" ]
					then
						motP="$motD"
						tmp="$tmp2"
					fi
				fi
			fi
			indD=`expr $indD + 1`
		done
		
		ssRep=`nombreSousRep $tmp`
		if [ "$ssRep" -gt 1 ]
		then
			newch=""
			for i in $(seq 1 ${#tmp})
			do
				c=`echo "$tmp" | cut -c $i`
				if [ $c == "/" ]
				then
					newch="$newch"\\"$c"
				else
					newch="$newch""$c"
				fi
			done
			total=`echo $total | sed 's/'"$newch"';//'`
		else
			total=`echo $total | sed 's/'"$tmp"';//'`	
		fi
		echo "$tmp"
		indP=1
		nbMots=`expr $nbMots - 1`
	done
}

#Verification des parametres entres pour le tri
function parametre (){
	if [ $nbPara -eq 1 ]
	then
        echo "tri dans l'ordre croissant sans sous dossier"
        chaineTriee=`triSimple $chaine`
	fi
	
	if [ ! -d "$1" ]
	then
		if [ "$1" == "-R" ]
		then
			chaine=`creeChaineRecursive ${!max}`
			chaineTriee=`triSimple $chaine`
			echo ""$1" tri avec chemin d'accès"
		elif [ "$1" == "-d" ]
		then
			ordreDecroissant=1
	        chaineTriee=`triSimple $chaine`
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
		shift
		max=$#
		parametre $@
	fi
}

chaine=`creeChaine ${!max}`
parametre $@
echo "$chaineTriee"
