#!/bin/bash
#Projet Shell : Groupe ELSAESSER Quentin && LEFEVRE Antoine

max=$#
nbPara=$#

#Test au lancement du programme
test $max -eq 0 && echo "Il faut au moins un paramètre." && exit 1
test ! -d ${!max} && echo "Le dernier paramètre doit être un dossier." && exit 2
test $max -gt 5 && echo "Veuillez saisir au maximum 3 options et un répertoire." && exit 3

#Sauvegarde le nom du repertoire de base, utile pour les fonctions comme la taille des fichiers etc
saveRepertoire=${!max}
#Ajoute le / a la fin du nom du repertoire s'il n'y est pas
saveTaille=`echo ${#saveRepertoire}`
saveFin=`echo "$saveRepertoire" | cut -c "$saveTaille"`
test "$saveFin" != "/" && saveRepertoire=`echo "$saveRepertoire"/`

#Sauvegarde des options autre que −R et -d pour le cas d'une egalite lors du tri
saveOption=""

#Pour l'option croissant ou decroissant
ordreDecroissant=0

#Pour stocker la chaine triee
chaineTriee=""

#Protege les caracteres speciaux dans une chaine
function protegeChaine () {
	rep="$1"
	for i in $(seq 1 ${#rep})
	do
		c=`echo "$rep" | cut -c "$i"`
		if [ $c == "/" ]
		then
			newch="$newch"\\"$c"
		elif [ $c == "." ]
		then
			newch="$newch"\\"$c"
		else
			newch="$newch""$c"
		fi
	done
	echo "$newch"
}

#Compte le nombre de fois ou il y a un ; -> pour savoir combien de fichier on a
function nombreFichier () {
    t=`echo "$1" | grep -o ";" | wc -l`
	#Ligne pour le MacOS
    #echo "$t" | sed -e 's/[  ]*//g'
    echo "$t"
}

#Compte le nombre de fois ou il y a un / -> pour savoir combien de / on doit enlever pour avoir le nom du fichier
function nombreSousRep () {
	t=`echo "$1" | grep -o "/" | wc -l`
	t=`expr $t + 1`
	#Ligne pour le MacOS
	#echo "$t" | sed -e 's/[  ]*//g'
	echo "$t"
}

#Retourne un entier selon le type de la source
function numTypeFichier(){
	fichier="$1"

	if test -d "$fichier" 
	then
		echo 1
	elif test -f "$fichier"
	then
		echo 2
	elif test -h "$fichier"
	then
		echo 3
	elif test -b "$fichier"
	then
		echo 4
	elif test -c "$fichier"
	then
		echo 5
	elif test -p "$fichier"
	then
		echo 6
	elif test -S "$fichier"
	then
		echo 7
	fi
}

#Cree la chaine sans l'option -R
function creeChaine () {
	total=""
	rep="$1"
	
	taille=`echo ${#rep}`
	fin=`echo "$rep" | cut -c "$taille"`
	
	#Modifier le sed pour n'enlever que le dernier /
	test "$fin" == "/" && rep=`echo "$rep" | sed 's/[\/]$//'`

	repProtege=`protegeChaine "$rep"`
	
	#Cree la chaine avec comme separateur un ;
	var=""
	for i in `find "$rep" -maxdepth 1`
	do
		if test $i != $rep
		then
			#On enleve de la chaine le repertoire donnee en parametre
			var=`echo $i | sed 's/'"$repProtege"'\///'`
			total="$total""$var;"
		fi
	done
	echo $total
}

#Cree la chaine avec l'option -R
function creeChaineRecursive () {
	total=""
	rep="$1"
	
	taille=`echo ${#rep}`
	fin=`echo "$rep" | cut -c "$taille"`
	
	#Modifier le sed pour n'enlever que le dernier /
	test "$fin" == "/" && rep=`echo "$rep" | sed 's/[\/]$//'`

	repProtege=`protegeChaine "$rep"`
	
	#Cree la chaine avec comme separateur un ;
	var=""
	for i in `find "$rep"`
	do
		if test $i != $rep
		then
			#On enleve de la chaine le repertoire donnee en parametre
			var=`echo $i | sed 's/'"$repProtege"'\///'`
			total="$total""$var;"
		fi
	done
	echo $total
}

#Indique, selon l'option, se que l'on doit faire en cas d'egalite
function casEgalite () {
	#Ajout de \ pour proteger car le -n ne s'affiche pas (lié au bash je suppose)
	var=\\"$saveOption"
	tailleVar=${#var}
	if [ $tailleVar -lt 4 ]
	then
		#Cas d'egalite non gere, pas assez de parametres"
		echo "OK"
	else
		para1="$1"
		para2="$2"
		
		for i in $(seq 4 "$tailleVar")
		do
			opt=`echo "$var" | cut -c "$i"`
			if [ "$opt" != "-" ]
			then
				if [ "$opt" == "n" ]
				then
					par1="$para1"
					ssRep=`nombreSousRep "$par1"`
					if [ "$ssRep" -gt 1 ]
					then
						par1=`echo "$par1" | cut -d'/' -f$ssRep`
					fi
					par2="$para2"
					ssRep=`nombreSousRep "$par2"`
					if [ "$ssRep" -gt 1 ]
					then
						par2=`echo "$par2" | cut -d'/' -f$ssRep`
					fi									
					
					if [ $ordreDecroissant -eq 0 ]
					then
						#Ordre Croissant
						if [ "$par2" \< "$par1" ]
						then
							echo "KO"
							break
						fi
					else
						#Ordre Decroissant
						if [ "$par1" \< "$par2" ]
						then
							echo "KO"
							break
						fi
					fi
				elif [ "$opt" == "s" ]
				then
					taille1=`stat -c "%s" "$para1"`
					taille2=`stat -c "%s" "$para2"`
					if [ $ordreDecroissant -eq 0 ]
					then
						#Ordre Croissant
						if [ "$taille2" -lt "$taille1" ]
						then
							echo "KO"
							break
						fi
					else
						#Ordre Decroissant
						if [ "$taille1" -lt "$taille2" ]
						then
							echo "KO"
							break
						fi
					fi
				elif [ "$opt" == "m" ]
				then
					dateAct=`date +%s`
					dateP1=`stat -c %Y "$para1"`
					dateP2=`stat -c %Y "$para2"`
					date1=`expr "$dateAct" - "$dateP1"`
					date2=`expr "$dateAct" - "$dateP2"`					
					if [ $ordreDecroissant -eq 0 ]
					then
						#Ordre Croissant
						if [ "$date2" -lt "$date1" ]
						then
							echo "KO"
							break
						fi
					else
						#Ordre Decroissant
						if [ "$date1" -lt "$date2" ]
						then
							echo "KO"
							break
						fi
					fi
				elif [ "$opt" == "l" ]
				then
					if test -d "$para1"
					then
						nbLigne1=0
					else
						nbLigne1=`wc -l "$para1" | cut -d' ' -f1`
					fi
					if test -d "$para2"
					then
						nbLigne2=0
					else
						nbLigne2=`wc -l "$para2" | cut -d' ' -f1`
					fi
					
					if [ "$ordreDecroissant" -eq 0 ]
					then
						#Ordre Croissant
						if [ "$nbLigne2" -lt "$nbLigne1" ]
						then
							echo "KO"
							break
						fi
					else
						#Ordre Decroissant
						if [ "$nbLigne1" -lt "$nbLigne2" ]
						then
							echo "KO"
							break
						fi
					fi
				elif [ "$opt" == "e" ]
				then
					#Recupere l'extension
					if [[ "$para1" =~ "." ]]
					then
						ext1=`echo "$para1" | sed 's/.*\.//'`
					else
						ext1=""
					fi

					if [[ "$para2" =~ "." ]]
					then
						ext2=`echo "$para2" | sed 's/.*\.//'`
					else
						ext2=""
					fi
					
					if [ $ordreDecroissant -eq 0 ]
					then
						#Ordre Croissant
						if [ "$ext2" \< "$ext1" ]
						then
							echo "KO"
							break
						fi
					else
						#Ordre Decroissant
						if [ "$ext1" \< "$ext2" ]
						then
							echo "KO"
							break
						fi
					fi
				elif [ "$opt" == "t" ]
				then
					type1=`numTypeFichier "$para1"`
					type2=`numTypeFichier "$para2"`
					
					if [ $ordreDecroissant -eq 0 ]
					then
						#Ordre Croissant
						if [ "$type2" -lt "$type1" ]
						then
							echo "KO"
							break
						fi
					else
						#Ordre Decroissant
						if [ "$type1" -lt "$type2" ]
						then
							echo "KO"
							break
						fi
					fi
				elif [ "$opt" == "p" ]
				then
					prop1=`stat -c "%U" "$para1"`
					prop2=`stat -c "%U" "$para2"`
					
					if [ $ordreDecroissant -eq 0 ]
					then
						#Ordre Croissant
						if [ "$prop2" \< "$prop1" ]
						then
							echo "KO"
							break
						fi
					else
						#Ordre Decroissant
						if [ "$prop1" \< "$prop2" ]
						then
							echo "KO"
							break
						fi
					fi

				elif [ "$opt" == "g" ]
				then
					prop1=`stat -c "%G" "$para1"`
					prop2=`stat -c "%G" "$para2"`
					
					if [ $ordreDecroissant -eq 0 ]
					then
						#Ordre Croissant
						if [ "$prop2" \< "$prop1" ]
						then
							echo "KO"
							break
						fi
					else
						#Ordre Decroissant
						if [ "$prop1" \< "$prop2" ]
						then
							echo "KO"
							break
						fi
					fi
				fi
			fi
		done
	fi
}

function triSimple () {
	total="$1"
	
	#Pour afficher la chaine de base a trier
	#echo $total
	
	nbMots=`nombreFichier "$total"`
	#indice du premier element a comparer
	indP=1
	#tmp pour stocker le fichier avec son chemin dans le cas ou l'option −R est choisi afin de l'enlever de la chaine totale
	tmp=""
	tmp2=""
	savePara1=""
	savePara2=""
	newch=""
	
	while [ "$nbMots" -ge "$indP" ]
	do
		#Indice du second element
		indD=`expr "$indP" + 1`
		motP=`echo "$total" | cut -d';' -f$indP`
		savePara1="$saveRepertoire""$motP"
		tmp="$motP"
		
		#Si c'est dans un sous dossier, on prend uniquement le nom du fichier pour la comparaison
		ssRep=`nombreSousRep "$motP"`
		if [ "$ssRep" -gt 1 ]
		then
			motP=`echo "$motP" | cut -d'/' -f$ssRep`
		fi
		
		while [ "$nbMots" -ge "$indD" ]
		do
			motD=`echo "$total" | cut -d';' -f$indD`
			savePara2="$saveRepertoire""$motD"
			tmp2="$motD"
			
			#Si c'est dans un sous dossier, on prend uniquement le nom du fichier pour la comparaison
			ssRep=`nombreSousRep $motD`
			if [ "$ssRep" -gt 1 ]
			then
				motD=`echo "$motD" | cut -d'/' -f$ssRep`
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
					elif [ "$motD" == "$motP" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							savePara1="$saveRepertoire""$motP"
						fi
					fi
				else
					#Ordre Decroissant
					if [ "$motP" \< "$motD" ]
					then
						motP="$motD"
						tmp="$tmp2"
					elif [ "$motD" == "$motP" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							savePara1="$saveRepertoire""$motP"
						fi
					fi
				fi
			fi
			indD=`expr "$indD" + 1`
		done

		#On ajoute des \ a cote des / quand il y a des sous dossiers pour ne pas avoir d'erreur sur le sed	
		ssRep=`nombreSousRep "$tmp"`
		if [ "$ssRep" -gt 1 ]
		then
			newch=`protegeChaine "$tmp"`
			total=`echo "$total" | sed 's/'"$newch"';//'`
		else
			total=`echo "$total" | sed 's/'"$tmp"';//'`	
		fi

		#On affiche l'element trie
		echo "$tmp"
		
		indP=1
		nbMots=`expr "$nbMots" - 1`
		newch=""
	done
}

function triSelonTaille () {
	total="$1"
	
	#Pour afficher la chaine de base a trier
	#echo $total
	
	nbMots=`nombreFichier "$total"`
	#indice du premier element a comparer
	indP=1
	#tmp pour stocker le fichier avec son chemin dans le cas ou l'option −R est choisi afin de l'enlever de la chaine totale
	tmp=""
	tmp2=""
	taille1=0
	taille2=0
	savePara1=""
	savePara2=""
	newch=""
	
	while [ "$nbMots" -ge "$indP" ]
	do
		#Indice du second element
		indD=`expr "$indP" + 1`
		motP=`echo "$total" | cut -d';' -f$indP`
		savePara1="$saveRepertoire""$motP"
		taille1=`stat -c "%s" "$savePara1"`
		tmp="$motP"
		
		while [ "$nbMots" -ge "$indD" ]
		do
			motD=`echo "$total" | cut -d';' -f$indD`
			savePara2="$saveRepertoire""$motD"
			taille2=`stat -c "%s" "$savePara2"`
			tmp2="$motD"
			
			#Comparaison
			if [ "$motD" != "" ]
			then
				if [ "$ordreDecroissant" -eq 0 ]
				then
					#Ordre Croissant
					if [ "$taille2" -lt "$taille1" ]
					then
						motP="$motD"
						tmp="$tmp2"
						taille1="$taille2"
						savePara1="$saveRepertoire""$motP"
					elif [ "$taille2" -eq "$taille1" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`				
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							taille1="$taille2"
							savePara1="$saveRepertoire""$motP"
						fi
					fi
				else
					#Ordre Decroissant
					if [ "$taille1" -lt "$taille2" ]
					then
						motP="$motD"
						tmp="$tmp2"
						taille1="$taille2"
						savePara1="$saveRepertoire""$motP"
					elif [ "$taille2" -eq "$taille1" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							taille1="$taille2"
							savePara1="$saveRepertoire""$motP"
						fi
					fi
				fi
			fi
			indD=`expr "$indD" + 1`
		done
		
		#On ajoute des \ a cote des / quand il y a des sous dossiers pour ne pas avoir d'erreur sur le sed
		ssRep=`nombreSousRep "$tmp"`
		if [ "$ssRep" -gt 1 ]
		then
			newch=`protegeChaine "$tmp"`
			total=`echo "$total" | sed 's/'"$newch"';//'`
		else
			total=`echo "$total" | sed 's/'"$tmp"';//'`	
		fi
		
		#On affiche l'element trie
		echo "$tmp"
		
		indP=1
		nbMots=`expr "$nbMots" - 1`
		newch=""
	done
}

function triSelonDateDernModif () {
	total="$1"
	
	#Pour afficher la chaine de base a trier
	#echo $total
	
	nbMots=`nombreFichier "$total"`
	#indice du premier element a comparer
	indP=1
	#tmp pour stocker le fichier avec son chemin dans le cas ou l'option −R est choisi afin de l'enlever de la chaine totale
	tmp=""
	tmp2=""
	date1=0
	date2=0
	savePara1=""
	savePara2=""
	newch=""

	dateAct=`date +%s`
	
	while [ "$nbMots" -ge "$indP" ]
	do
		#Indice du second element
		indD=`expr "$indP" + 1`
		motP=`echo "$total" | cut -d';' -f$indP`
		savePara1="$saveRepertoire""$motP"
		dateP1=`stat -c %Y "$savePara1"`
		date1=`expr "$dateAct" - "$dateP1"`
		tmp="$motP"
		
		while [ "$nbMots" -ge "$indD" ]
		do
			motD=`echo "$total" | cut -d';' -f$indD`
			savePara2="$saveRepertoire""$motD"
			dateP2=`stat -c %Y "$savePara2"`
			date2=`expr "$dateAct" - "$dateP2"`
			tmp2="$motD"
			
			#Comparaison
			if [ "$motD" != "" ]
			then
				if [ "$ordreDecroissant" -eq 1 ]
				then
					#Ordre Croissant
					if [ "$date2" -lt "$date1" ]
					then
						motP="$motD"
						tmp="$tmp2"
						date1="$date2"
						savePara1="$saveRepertoire""$motP"
					elif [ "$date2" -eq "$date1" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`				
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							date1="$date2"
							savePara1="$saveRepertoire""$motP"
						fi
					fi
				else
					#Ordre Decroissant
					if [ "$date1" -lt "$date2" ]
					then
						motP="$motD"
						tmp="$tmp2"
						date1="$date2"
						savePara1="$saveRepertoire""$motP"
					elif [ "$date2" -eq "$date1" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							date1="$date2"
							savePara1="$saveRepertoire""$motP"
						fi
					fi
				fi
			fi
			indD=`expr "$indD" + 1`
		done
		
		#On ajoute des \ a cote des / quand il y a des sous dossiers pour ne pas avoir d'erreur sur le sed
		ssRep=`nombreSousRep "$tmp"`
		if [ "$ssRep" -gt 1 ]
		then
			newch=`protegeChaine "$tmp"`
			total=`echo "$total" | sed 's/'"$newch"';//'`
		else
			total=`echo "$total" | sed 's/'"$tmp"';//'`	
		fi
		
		#On affiche l'element trie
		echo "$tmp"
		
		indP=1
		nbMots=`expr "$nbMots" - 1`
		newch=""
	done
}

function triSelonNbLigne () {
	total="$1"
	
	#Pour afficher la chaine de base a trier
	#echo $total
	
	nbMots=`nombreFichier "$total"`
	#indice du premier element a comparer
	indP=1
	#tmp pour stocker le fichier avec son chemin dans le cas ou l'option −R est choisi afin de l'enlever de la chaine totale
	tmp=""
	tmp2=""
	nbLigne1=0
	nbLigne2=0
	savePara1=""
	savePara2=""
	newch=""
	
	while [ "$nbMots" -ge "$indP" ]
	do
		#Indice du second element
		indD=`expr "$indP" + 1`
		motP=`echo "$total" | cut -d';' -f$indP`
		savePara1="$saveRepertoire""$motP"
		if test -d "$savePara1"
		then
			nbLigne1=0
		else
			nbLigne1=`wc -l "$savePara1" | cut -d' ' -f1`
		fi
		tmp="$motP"
		
		while [ "$nbMots" -ge "$indD" ]
		do
			motD=`echo "$total" | cut -d';' -f$indD`
			savePara2="$saveRepertoire""$motD"
			if test -d "$savePara2"
			then
				nbLigne2=0
			else
				nbLigne2=`wc -l "$savePara2" | cut -d' ' -f1`
			fi
			tmp2="$motD"
			
			#Comparaison
			if [ "$motD" != "" ]
			then
				if [ "$ordreDecroissant" -eq 0 ]
				then
					#Ordre Croissant
					if [ "$nbLigne2" -lt "$nbLigne1" ]
					then
						motP="$motD"
						tmp="$tmp2"
						nbLigne1="$nbLigne2"
						savePara1="$saveRepertoire""$motP"
					elif [ "$nbLigne2" -eq "$nbLigne1" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`		
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							nbLigne1="$nbLigne2"
							savePara1="$saveRepertoire""$motP"
						fi
					fi
				else
					#Ordre Decroissant
					if [ "$nbLigne1" -lt "$nbLigne2" ]
					then
						motP="$motD"
						tmp="$tmp2"
						nbLigne1="$nbLigne2"
					elif [ "$nbLigne2" -eq "$nbLigne1" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							nbLigne1="$nbLigne2"
						fi
					fi
				fi
			fi
			indD=`expr "$indD" + 1`
		done
		
		#On ajoute des \ a cote des / quand il y a des sous dossiers pour ne pas avoir d'erreur sur le sed
		ssRep=`nombreSousRep "$tmp"`
		if [ "$ssRep" -gt 1 ]
		then
			newch=`protegeChaine "$tmp"`
			total=`echo "$total" | sed 's/'"$newch"';//'`
		else
			total=`echo "$total" | sed 's/'"$tmp"';//'`	
		fi

		#On affiche l'element trie
		echo "$tmp"

		indP=1
		nbMots=`expr "$nbMots" - 1`
		newch=""
	done
}

function triSelonExtension () {
	total="$1"
	
	#Pour afficher la chaine de base a trier
	#echo $total
	
	nbMots=`nombreFichier "$total"`
	#indice du premier element a comparer
	indP=1
	#tmp pour stocker le fichier avec son chemin dans le cas ou l'option −R est choisi afin de l'enlever de la chaine totale
	tmp=""
	tmp2=""
	savePara1=""
	savePara2=""
	newch=""
	
	while [ "$nbMots" -ge "$indP" ]
	do
		#Indice du second element
		indD=`expr "$indP" + 1`
		motP=`echo "$total" | cut -d';' -f$indP`
		savePara1="$saveRepertoire""$motP"
		tmp="$motP"
		
		#Si c'est dans un sous dossier, on prend uniquement le nom du fichier pour la comparaison
		ssRep=`nombreSousRep "$motP"`
		if [ "$ssRep" -gt 1 ]
		then
			motP=`echo "$motP" | cut -d'/' -f$ssRep`
		fi
		
		while [ "$nbMots" -ge "$indD" ]
		do
			motD=`echo "$total" | cut -d';' -f$indD`
			savePara2="$saveRepertoire""$motD"
			tmp2="$motD"
			
			#Si c'est dans un sous dossier, on prend uniquement le nom du fichier pour la comparaison
			ssRep=`nombreSousRep $motD`
			if [ "$ssRep" -gt 1 ]
			then
				motD=`echo "$motD" | cut -d'/' -f$ssRep`
			fi
			
			#Comparaison
			if [ "$motD" != "" ]
			then
				if [[ "$motD" =~ "." ]]
					then
						extMotD=`echo "$motD" | sed 's/.*\.//'`
					else
						extMotD=""
					fi
					if [[ "$motP" =~ "." ]]
					then
						extMotP=`echo "$motP" | sed 's/.*\.//'`
					else
						extMotP=""
					fi
				if [ "$ordreDecroissant" -eq 0 ]
				then
					#Ordre Croissant
					if [ "$extMotD" \< "$extMotP" ]
					then
						motP="$motD"
						tmp="$tmp2"
						extMotP="$extMotD"
						savePara1="$saveRepertoire""$motP"
					elif [ "$extMotD" == "$extMotP" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`		
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							extMotP="$extMotD"
							savePara1="$saveRepertoire""$motP"
						fi
					fi
				else
					#Ordre Decroissant
					if [ "$extMotP" \< "$extMotD" ]
					then
						motP="$motD"
						tmp="$tmp2"
						extMotP="$extMotD"
						savePara1="$saveRepertoire""$motP"
					elif [ "$extMotD" == "$extMotP" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`		
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							extMotP="$extMotD"
							savePara1="$saveRepertoire""$motP"
						fi
					fi
				fi
			fi
			indD=`expr "$indD" + 1`
		done

		#On ajoute des \ a cote des / quand il y a des sous dossiers pour ne pas avoir d'erreur sur le sed	
		ssRep=`nombreSousRep "$tmp"`
		if [ "$ssRep" -gt 1 ]
		then
			newch=`protegeChaine "$tmp"`
			total=`echo "$total" | sed 's/'"$newch"';//'`
		else
			total=`echo "$total" | sed 's/'"$tmp"';//'`	
		fi
		
		#On affiche l'element trie
		echo "$tmp"
		
		indP=1
		nbMots=`expr "$nbMots" - 1`
		newch=""
	done
}

function triSelonType () {
	total="$1"
	#Pour afficher la chaine de base a trier
	#echo $total
	
	nbMots=`nombreFichier "$total"`
	#indice du premier element a comparer
	indP=1
	#tmp pour stocker le fichier avec son chemin dans le cas ou l'option −R est choisi afin de l'enlever de la chaine totale
	tmp=""
	tmp2=""
	type1=0
	type2=0
	savePara1=""
	savePara2=""
	newch=""
	
	while [ "$nbMots" -ge "$indP" ]
	do
		#Indice du second element
		indD=`expr "$indP" + 1`
		motP=`echo "$total" | cut -d';' -f$indP`
		savePara1="$saveRepertoire""$motP"
		type1=`numTypeFichier "$savePara1"`
		tmp="$motP"
		
		while [ "$nbMots" -ge "$indD" ]
		do
			motD=`echo "$total" | cut -d';' -f$indD`
			savePara2="$saveRepertoire""$motD"
			type2=`numTypeFichier "$savePara2"`
			tmp2="$motD"
			
			#Comparaison
			if [ "$motD" != "" ]
			then
				if [ "$ordreDecroissant" -eq 0 ]
				then
					#Ordre Croissant
					if [ "$type2" -lt "$type1" ]
					then
						motP="$motD"
						tmp="$tmp2"
						type1="$type2"
						savePara1="$saveRepertoire""$motP"
					elif [ "$type2" -eq "$type1" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`				
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							type1="$type2"
							savePara1="$saveRepertoire""$motP"
						fi
					fi
				else
					#Ordre Decroissant
					if [ "$type1" -lt "$type2" ]
					then
						motP="$motD"
						tmp="$tmp2"
						type1="$type2"
						savePara1="$saveRepertoire""$motP"
					elif [ "$type2" -eq "$type1" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							type1="$type2"
							savePara1="$saveRepertoire""$motP"
						fi
					fi
				fi
			fi
			indD=`expr "$indD" + 1`
		done
		
		#On ajoute des \ a cote des / quand il y a des sous dossiers pour ne pas avoir d'erreur sur le sed
		ssRep=`nombreSousRep "$tmp"`
		if [ "$ssRep" -gt 1 ]
		then
			newch=`protegeChaine "$tmp"`
			total=`echo "$total" | sed 's/'"$newch"';//'`
		else
			total=`echo "$total" | sed 's/'"$tmp"';//'`	
		fi
		
		#On affiche l'element trie
		echo "$tmp"
		
		indP=1
		nbMots=`expr "$nbMots" - 1`
		newch=""
	done
}

function triSelonProprio () {
	total="$1"
	
	#Pour afficher la chaine de base a trier
	#echo $total
	
	nbMots=`nombreFichier "$total"`
	#indice du premier element a comparer
	indP=1
	#tmp pour stocker le fichier avec son chemin dans le cas ou l'option −R est choisi afin de l'enlever de la chaine totale
	tmp=""
	tmp2=""
	savePara1=""
	savePara2=""
	newch=""
	
	while [ "$nbMots" -ge "$indP" ]
	do
		#Indice du second element
		indD=`expr "$indP" + 1`
		motP=`echo "$total" | cut -d';' -f$indP`
		savePara1="$saveRepertoire""$motP"
		nomProprioP=`stat -c "%U" "$savePara1"`
		tmp="$motP"
		
		#Si c'est dans un sous dossier, on prend uniquement le nom du fichier pour la comparaison
		ssRep=`nombreSousRep "$motP"`
		if [ "$ssRep" -gt 1 ]
		then
			motP=`echo "$motP" | cut -d'/' -f$ssRep`
		fi
		
		while [ "$nbMots" -ge "$indD" ]
		do
			motD=`echo "$total" | cut -d';' -f$indD`
			savePara2="$saveRepertoire""$motD"
			nomProprioD=`stat -c "%U" "$savePara2"`
			tmp2="$motD"
			
			#Si c'est dans un sous dossier, on prend uniquement le nom du fichier pour la comparaison
			ssRep=`nombreSousRep "$motD"`
			if [ "$ssRep" -gt 1 ]
			then
				motD=`echo "$motD" | cut -d'/' -f$ssRep`
			fi
			
			#Comparaison
			if [ "$motD" != "" ]
			then
				if [ "$ordreDecroissant" -eq 0 ]
				then
					#Ordre Croissant
					if [ "$nomProprioD" \< "$nomProprioP" ]
					then
						motP="$motD"
						tmp="$tmp2"
						savePara1="$saveRepertoire""$motP"
						nomProprioP="$nomProprioD"
					elif [ "$nomProprioD" == "$nomProprioP" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`				
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							nomProprioP="$nomProprioD"
							savePara1="$saveRepertoire""$motP"
						fi
					fi
				else
					#Ordre Decroissant
					if [ "$nomProprioP" \< "$nomProprioD" ]
					then
						motP="$motD"
						tmp="$tmp2"
						savePara1="$saveRepertoire""$motP"
						nomProprioP="$nomProprioD"
					elif [ "$nomProprioD" == "$nomProprioP" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`				
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							nomProprioP="$nomProprioD"
							savePara1="$saveRepertoire""$motP"
						fi
					fi
				fi
			fi
			indD=`expr "$indD" + 1`
		done

		#On ajoute des \ a cote des / quand il y a des sous dossiers pour ne pas avoir d'erreur sur le sed	
		ssRep=`nombreSousRep "$tmp"`
		if [ "$ssRep" -gt 1 ]
		then
			newch=`protegeChaine "$tmp"`
			total=`echo "$total" | sed 's/'"$newch"';//'`
		else
			total=`echo "$total" | sed 's/'"$tmp"';//'`	
		fi
		
		#On affiche l'element trie
		echo "$tmp"
		
		indP=1
		nbMots=`expr "$nbMots" - 1`
		newch=""
	done
}

function triSelonGroupe () {
	total="$1"
	
	#Pour afficher la chaine de base a trier
	#echo $total
	
	nbMots=`nombreFichier "$total"`
	#indice du premier element a comparer
	indP=1
	#tmp pour stocker le fichier avec son chemin dans le cas ou l'option −R est choisi afin de l'enlever de la chaine totale
	tmp=""
	tmp2=""
	savePara1=""
	savePara2=""
	newch=""
	
	while [ "$nbMots" -ge "$indP" ]
	do
		#Indice du second element
		indD=`expr "$indP" + 1`
		motP=`echo "$total" | cut -d';' -f$indP`
		savePara1="$saveRepertoire""$motP"
		nomProprioP=`stat -c "%G" "$savePara1"`
		tmp="$motP"
		
		#Si c'est dans un sous dossier, on prend uniquement le nom du fichier pour la comparaison
		ssRep=`nombreSousRep "$motP"`
		if [ "$ssRep" -gt 1 ]
		then
			motP=`echo "$motP" | cut -d'/' -f$ssRep`
		fi
		
		while [ "$nbMots" -ge "$indD" ]
		do
			motD=`echo "$total" | cut -d';' -f$indD`
			savePara2="$saveRepertoire""$motD"
			nomProprioD=`stat -c "%G" "$savePara2"`
			tmp2="$motD"
			
			#Si c'est dans un sous dossier, on prend uniquement le nom du fichier pour la comparaison
			ssRep=`nombreSousRep "$motD"`
			if [ "$ssRep" -gt 1 ]
			then
				motD=`echo "$motD" | cut -d'/' -f$ssRep`
			fi
			
			#Comparaison
			if [ "$motD" != "" ]
			then
				if [ "$ordreDecroissant" -eq 0 ]
				then
					#Ordre Croissant
					if [ "$nomProprioD" \< "$nomProprioP" ]
					then
						motP="$motD"
						tmp="$tmp2"
						savePara1="$saveRepertoire""$motP"
						nomProprioP="$nomProprioD"
					elif [ "$nomProprioD" == "$nomProprioP" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`				
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							nomProprioP="$nomProprioD"
							savePara1="$saveRepertoire""$motP"
						fi
					fi
				else
					#Ordre Decroissant
					if [ "$nomProprioP" \< "$nomProprioD" ]
					then
						motP="$motD"
						tmp="$tmp2"
						savePara1="$saveRepertoire""$motP"
						nomProprioP="$nomProprioD"
					elif [ "$nomProprioD" == "$nomProprioP" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`				
						if [ "$equal" == "KO" ]
						then
							motP="$motD"
							tmp="$tmp2"
							nomProprioP="$nomProprioD"
							savePara1="$saveRepertoire""$motP"
						fi
					fi
				fi
			fi
			indD=`expr "$indD" + 1`
		done

		#On ajoute des \ a cote des / quand il y a des sous dossiers pour ne pas avoir d'erreur sur le sed	
		ssRep=`nombreSousRep "$tmp"`
		if [ "$ssRep" -gt 1 ]
		then
			newch=`protegeChaine "$tmp"`
			total=`echo "$total" | sed 's/'"$newch"';//'`
		else
			total=`echo "$total" | sed 's/'"$tmp"';//'`	
		fi
		
		#On affiche l'element trie
		echo "$tmp"
		
		indP=1
		nbMots=`expr "$nbMots" - 1`
		newch=""
	done
}

#Verification des parametres entres pour le tri
function parametre () {
	if [ "$nbPara" -eq 1 ]
	then
        echo "tri dans l'ordre croissant sans sous dossier"
        chaineTriee=`triSimple "$chaine"`
	else
		if test -d "$1"
		then
			if [ "$saveOption" == "" ]
			then
				echo "Tri simple par nom de fichier"
				chaineTriee=`triSimple "$chaine"`
			fi
		else
			numPara=`expr "$nbPara" - "$max"`
			if [ "$1" == "-R" ]
			then
				if [ $numPara -eq 0 ]
				then
					echo "−R Tri avec chemin d'acces"
					chaine=`creeChaineRecursive ${!max}`
				else
					echo "Erreur : −R doit être le premier parametre"
					exit 4
				fi
			elif [ "$1" == "-d" ]
			then
				if [ $numPara -lt 2 ]
				then
					echo "−d Tri ordre decroissant"
					ordreDecroissant=1
				else
					echo "Erreur : −d doit être le premier ou le deuxieme parametre"
					exit 5
				fi
			else
				var=\\"$1"
				saveOption="$1"
				estOpt=`echo "$var" | cut -c 2`
				if [ "$estOpt" != '-' ]
				then
					echo "Dernier parametre n'est pas une option valable, doit commencer par un -"
					exit 6
				fi
				for i in $(seq 3 ${#var})
				do
					opt=`echo "$var" | cut -c "$i"`
					
					if [ "$opt" == "n" ]
					then
						echo "$opt" " : tri selon le nom des entrees"
						chaineTriee=`triSimple "$chaine"`
						break
					elif [ "$opt" == "s" ]
					then
						echo "$opt" " : tri selon la taille des entrees"
						chaineTriee=`triSelonTaille "$chaine"`
						break
					elif [ "$opt" == "m" ]
					then
						echo "$opt" " : tri selon la date de derniere modification"
						chaineTriee=`triSelonDateDernModif "$chaine"`
						break
					elif [ "$opt" == "l" ]
					then
						echo "$opt" " : tri selon le nombre de lignes"
						chaineTriee=`triSelonNbLigne "$chaine"`
						break
					elif [ "$opt" == "e" ]
					then
						echo "$opt" " : tri selon l'extention des entrées"
						chaineTriee=`triSelonExtension "$chaine"`
						break
					elif [ "$opt" == "t" ]
					then
						echo "$opt" " : tri selon le type du fichier"
						chaineTriee=`triSelonType "$chaine"`
						break
					elif [ "$opt" == "p" ]
					then
						echo "$opt" " : tri selon le nom du proprietaire"
						chaineTriee=`triSelonProprio "$chaine"`
						break
					elif [ "$opt" == "g" ]
					then
						echo "$opt" " : tri selon le groupe du proprietaire"
						chaineTriee=`triSelonGroupe "$chaine"`
						break
					else
						echo "$opt" " : pas option reconnu, aucune action sur cette option"
					fi
				done
			fi

			shift
			max=$#
			parametre $@		
		fi
	fi
}

#"Main du programme"
#On cree la chaine de base, sans option puis on lance le programme qui va modifier la chaine finale selon les options
chaine=`creeChaine ${!max}`
parametre $@
echo "$chaineTriee"
