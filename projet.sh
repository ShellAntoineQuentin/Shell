#!/bin/bash
#Projet Shell : Groupe ELSAESSER Quentin && LEFEVRE Antoine
max=$#
nbPara=$#

#Test au lancement du programme
test "$max" -eq 0 && echo "Il faut au moins un paramètre." && exit 1
test ! -d ${!max} && echo "Le dernier paramètre doit être un dossier." && exit 2
test "$max" -gt 5 && echo "Veuillez saisir au maximum 3 options et un répertoire." && exit 3

#Sauvegarde le nom du repertoire de base, utile pour les fonctions comme la taille des fichiers etc
saveRepertoire=${!max}
saveTaille=`echo ${#saveRepertoire}`
saveFin=`echo "$saveRepertoire" | cut -c "$saveTaille"`
test "$saveFin" != "/" && saveRepertoire=`echo "$saveRepertoire"/`

#Sauvegarde des options autre que −R et -d pour le cas d'une egalite lors du tri
saveOption=""

#Pour l'option croissant ou decroissant
ordreDecroissant=0

#Pour stocker la chaine triee
chaineTriee=""

#Cree la chaine sans l'option -R
creeChaine () {
	total=""
	rep="$1"
	
	#Enleve le / a la fin du dossier en parametre s'il a ete mis par l'utilisateur
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
				#Enleve le dossier en parametre et le /
				var=`echo $i | sed 's/'"$rep"'\///'`
				total="$total""$var;"
			fi
		fi
	done
	echo $total
}

#Cree la chaine pour l'option -R
creeChaineRecursive () {
	total=""
	rep="$1"
	
	#Enleve le / a la fin du dossier en parametre s'il a ete mis par l'utilisateur
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
				#Enleve le dossier en parametre et le /
				var=`echo $i | sed 's/'"$rep"'\///'`
				total="$total""$var;"
			fi
		fi
	done
	echo $total
}

#Compte le nombre de fois ou il y a un ; -> pour savoir combien de fichier on a
function nombreFichier () {
    t=`echo "$1" | grep -o ";" | wc -l`
    echo "$t" | sed -e 's/[  ]*//g'
}

#Compte le nombre de fois ou il y a un / -> pour savoir combien de / on doit enlever pour avoir le nom du fichier
function nombreSousRep () {
	t=`echo "$1" | grep -o "/" | wc -l`
	t=`expr $t + 1`
	echo "$t" | sed -e 's/[  ]*//g'
}

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

#Indique, selon l'option, se que l'on doit faire en cas d'egalite
function casEgalite () {
	var="$saveOption"
	tailleVar=${#var}
	if [ "$tailleVar" -lt 3 ]
	then
		#Cas d'egalite non gere, pas assez de parametres"
		echo "OK"
	else
		para1="$1"
		para2="$2"
	
		for i in $(seq 3 "$tailleVar")
		do
			opt=`echo "$var" | cut -c $i`
			if [ "$opt" != "-" ]
			then
				if [ "$opt" == "n" ]
				then
					if [ "$ordreDecroissant" -eq 0 ]
					then
						#Ordre Croissant
						par1="$para1"
						par2="$para2"
						ssRep=`nombreSousRep "$par1"`
						if [ "$ssRep" -gt 1 ]
						then
							par1=`echo "$par1" | cut -d'/' -f$ssRep`
						fi
						ssRep=`nombreSousRep "$par2"`
						if [ "$ssRep" -gt 1 ]
						then
							par2=`echo "$par2" | cut -d'/' -f$ssRep`
						fi
						if [ "$par1" \< "$par2" ]
						then
							echo "OK"
						elif [ "$par2" \< "$par1" ]
						then
							echo "KO"
						fi
					else
						#Ordre Decroissant
						if [ "$par2" \< "$par1" ]
						then
							echo "OK"
						elif [ "$par1" \< "$par2" ]
						then
							echo "KO"
						fi
					fi
				elif [ "$opt" == "s" ]
				then
					taille1=`stat -c "%s" "$para1"`
					taille2=`stat -c "%s" "$para2"`
					if [ "$ordreDecroissant" -eq 0 ]
					then
						#Ordre Croissant
						if [ "$taille2" -lt "$taille1" ]
						then
							echo "OK"
						elif [ "$taille1" -lt "$taille2" ]
						then
							echo "KO"
						fi
					else
						#Ordre Decroissant
						if [ "$taille1" -lt "$taille2" ]
						then
							echo "OK"
						elif [ "$taille2" -lt "$taille1" ]
						then
							echo "KO"
						fi
					fi
				elif [ "$opt" == "m" ]
				then
					val="ligne a supprimer car sans ca fait erreur"
				elif [ "$opt" == "l" ]
				then
					nbLigne1=`wc -l "$para1" | cut -d' ' -f1`
					nbLigne2=`wc -l "$para2" | cut -d' ' -f1`
					if [ "$ordreDecroissant" -eq 0 ]
					then
						#Ordre Croissant
						if [ "$nbLigne2" -lt "$nbLigne1" ]
						then
							echo "OK"
						elif [ "$nbLigne1" -lt "$nbLigne2" ]
						then
							echo "KO"
						fi
					else
						#Ordre Decroissant
						if [ "$nbLigne1" -lt "$nbLigne2" ]
						then
							echo "OK"
						elif [ "$nbLigne2" -lt "$nbLigne1" ]
						then
							echo "KO"
						fi
					fi
				elif [ "$opt" == "e" ]
				then
					val="ligne a supprimer car sans ca fait erreur"
				elif [ "$opt" == "t" ]
				then
					val="ligne a supprimer car sans ca fait erreur"
				elif [ "$opt" == "p" ]
				then
					val="ligne a supprimer car sans ca fait erreur"
				elif [ "$opt" == "g" ]
				then
					val="ligne a supprimer car sans ca fait erreur"
				fi
			fi
		done
	fi
}

function protegeChaine () {
	tmp="$1"
	for i in $(seq 1 ${#tmp})
	do
		c=`echo "$tmp" | cut -c "$i"`
		if [ $c == "/" ]
		then
			newch="$newch"\\"$c"
		else
			newch="$newch""$c"
		fi
	done
	echo "$newch"
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
	while [ "$nbMots" -ge "$indP" ]
	do
		#Indice du second element
		indD=`expr "$indP" + 1`
		motP=`echo "$total" | cut -d';' -f$indP`
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
					if [ "$motD" \< "$motP" ]
					then
						motP="$motD"
						tmp="$tmp2"
					elif [ "$motD" == "$motP" ]
					then
						equal=`casEgalite "$savePara1" "$savePara2"`
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
			indD=`expr "$indD" + 1`
		done

		#On ajoute des \ a cote des / quand il y a des sous dossiers pour ne pas avoir d'erreur sur le sed	
		ssRep=`nombreSousRep "$tmp"`
		if [ "$ssRep" -gt 1 ]
		then
			newch=`protegeChaine "$tmp"`
			#On enleve le fichier de la chaine a triee
			total=`echo "$total" | sed 's/'"$newch"';//'`
		else
			total=`echo "$total" | sed 's/'"$tmp"';//'`	
		fi
		
		#On affiche l'element trie
		echo "$tmp"
		
		indP=1
		nbMots=`expr "$nbMots" - 1`
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
	while [ "$nbMots" -ge "$indP" ]
	do
		#Indice du second element
		indD=`expr "$indP" + 1`
		motP=`echo "$total" | cut -d';' -f$indP`
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
					fi
				else
					#Ordre Decroissant
					if [ "$extMotP" \< "$extMotD" ]
					then
						motP="$motD"
						tmp="$tmp2"
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
	while [ "$nbMots" -ge "$indP" ]
	do
		#Indice du second element
		indD=`expr "$indP" + 1`
		motP=`echo "$total" | cut -d';' -f$indP`
		tmp="$motP"
		
		#Si c'est dans un sous dossier, on prend uniquement le nom du fichier pour la comparaison
		ssRep=`nombreSousRep "$motP"`
		if [ "$ssRep" -gt 1 ]
		then
			nomProprioP=`stat -c "%U" "$motP"`
			motP=`echo "$motP" | cut -d'/' -f$ssRep`
		else
			nomProprioP=`stat -c "%U" "$motP"`
		fi
		
		while [ "$nbMots" -ge "$indD" ]
		do
			motD=`echo "$total" | cut -d';' -f$indD`
			tmp2="$motD"
			
			#Si c'est dans un sous dossier, on prend uniquement le nom du fichier pour la comparaison
			ssRep=`nombreSousRep "$motD"`
			if [ "$ssRep" -gt 1 ]
			then
				nomProprioD=`stat -c "%U" "$motD"`
				motD=`echo "$motD" | cut -d'/' -f$ssRep`
			else
				nomProprioD=`stat -c "%U" "$motD"`
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
					fi
				else
					#Ordre Decroissant
					if [ "$nomProprioP" \< "$nomProprioD" ]
					then
						motP="$motD"
						tmp="$tmp2"
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
	done
}

function triSelonGroupProprio () {
	total="$1"
	
	#Pour afficher la chaine de base a trier
	#echo $total
	
	nbMots=`nombreFichier "$total"`
	#indice du premier element a comparer
	indP=1
	#tmp pour stocker le fichier avec son chemin dans le cas ou l'option −R est choisi afin de l'enlever de la chaine totale
	tmp=""
	tmp2=""
	while [ "$nbMots" -ge "$indP" ]
	do
		#Indice du second element
		indD=`expr "$indP" + 1`
		motP=`echo "$total" | cut -d';' -f$indP`
		tmp="$motP"
		
		#Si c'est dans un sous dossier, on prend uniquement le nom du fichier pour la comparaison
		ssRep=`nombreSousRep "$motP"`
		if [ "$ssRep" -gt 1 ]
		then
			nomGroupProprioP=`stat -c "%G" "$motP"`
			motP=`echo "$motP" | cut -d'/' -f$ssRep`
		else
			nomGroupProprioP=`stat -c "%G" "$motP"`
		fi
		
		while [ "$nbMots" -ge "$indD" ]
		do
			motD=`echo "$total" | cut -d';' -f$indD`
			tmp2="$motD"
			
			#Si c'est dans un sous dossier, on prend uniquement le nom du fichier pour la comparaison
			ssRep=`nombreSousRep $motD`
			if [ "$ssRep" -gt 1 ]
			then
				nomGroupProprioD=`stat -c "%G" "$motD"`
				motD=`echo "$motD" | cut -d'/' -f$ssRep`
			else
				nomGroupProprioD=`stat -c "%G" "$motD"`
			fi
			
			#Comparaison
			if [ "$motD" != "" ]
			then
				if [ "$ordreDecroissant" -eq 0 ]
				then
					#Ordre Croissant
					if [ "$nomGroupProprioD" \< "$nomGroupProprioP" ]
					then
						motP="$motD"
						tmp="$tmp2"
					fi
				else
					#Ordre Decroissant
					if [ "$nomGroupProprioP" \< "$nomGroupProprioD" ]
					then
						motP="$motD"
						tmp="$tmp2"
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
	
	while [ "$nbMots" -ge "$indP" ]
	do
		#Indice du second element
		indD=`expr "$indP" + 1`
		motP=`echo "$total" | cut -d';' -f$indP`
		savePara1="$saveRepertoire""$motP"
		nbLigne1=`wc -l "$savePara1" | cut -d' ' -f1`
		tmp="$motP"
		
		while [ "$nbMots" -ge "$indD" ]
		do
			motD=`echo "$total" | cut -d';' -f$indD`
			savePara2="$saveRepertoire""$motD"
			nbLigne2=`wc -l "$savePara2" | cut -d' ' -f1`
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
	
	while [ "$nbMots" -ge "$indP" ]
	do
		#Indice du second element
		indD=`expr "$indP" + 1`
		motP=`echo "$total" | cut -d';' -f$indP`
		savePara1="$saveRepertoire""$motP"
		date1=expr `date +%s` - `stat -c %Y "$savePara1"`
		tmp="$motP"
		
		while [ "$nbMots" -ge "$indD" ]
		do
			motD=`echo "$total" | cut -d';' -f$indD`
			savePara2="$saveRepertoire""$motD"
			date2=expr `date +%s` - `stat -c %Y "$savePara2"`
			tmp2="$motD"
			
			#Comparaison
			if [ "$motD" != "" ]
			then
				if [ "$ordreDecroissant" -eq 0 ]
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
	done
}


#Verification des parametres entres pour le tri
function parametre (){
	chaine=`creeChaine ${!max}`
	if [ "$nbPara" -eq 1 ]
	then
        echo "tri dans l'ordre croissant sans sous dossier"
        chaineTriee=`triSimple "$chaine"`
	fi
	
	if [ ! -d "$1" ]
	then
		if [ "$1" == "-R" ]
		then
			chaine=`creeChaineRecursive ${!max}`
			chaineTriee=`triSimple "$chaine"`
			echo ""$1" tri avec chemin d'accès"
		elif [ "$1" == "-d" ]
		then
			ordreDecroissant=1
	        chaineTriee=`triSimple "$chaine"`
			echo ""$1" tri ordre decroissant"
		else
			var="$1"
			saveOption="$1"
			
			#Option special pour le -n car il n'est pas reconnu dans mon terminal s'il est seul
			if [ $var == "-n" ]
			then
				echo "n tri selon nom entree"
		        chaineTriee=`triSimple "$chaine"`
			fi

			#Option special pour le -e car il n'est pas reconnu dans mon terminal s'il est seul
			if [ $var == "-e" ]
			then
				echo "e tri selon extension entree"
		        chaineTriee=`triSelonExtension "$chaine"`
			fi
			
			for i in $(seq 1 ${#var})
			do
				opt=`echo "$var" | cut -c $i`
				if [ "$opt" != "-" ]
				then
					if [ "$opt" == "n" ]
					then
				        chaineTriee=`triSimple "$chaine"`
						echo "$opt" "tri selon nom entree"
					elif [ "$opt" == "s" ]
					then
				        chaineTriee=`triSelonTaille "$chaine"`
						echo "$opt" "tri selon taille entree"
					elif [ "$opt" == "m" ]
					then
						chaineTriee=`triSelonDateDernModif "$chaine"`
						echo "$opt" "tri selon date derniere modif"
					elif [ "$opt" == "l" ]
					then
						chaineTriee=`triSelonNbLigne "$chaine"`
						echo "$opt" "tri selon nombre de ligne"
					elif [ "$opt" == "e" ]
					then
						chaineTriee=`triSelonExtension "$chaine"`
						echo "$opt" "tri selon extension entree"
					elif [ "$opt" == "t" ]
					then
						chaineTriee=`triSelonType "$chaine"`
						echo "$opt" "tri selon type fichier"
					elif [ "$opt" == "p" ]
					then
						chaineTriee=`triSelonProprio "$chaine"`
						echo "$opt" "tri selon nom proprietaire fichier"
					elif [ "$opt" == "g" ]
					then
						chaineTriee=`triSelonGroupProprio "$chaine"`
						echo "$opt" "tri selon groupe du proprietaire"
					fi
				fi
			done
		fi
		shift
		max=$#
		parametre $@
	fi
}

#"Main du programme"
#On cree la chaine de base, sans option puis on lance le programme qui va modifier la chaine finale selon les options
parametre $@
#On affiche le resultat
echo "$chaineTriee"
