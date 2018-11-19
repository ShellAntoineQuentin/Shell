#!/bin/bash
#Projet Shell : Groupe ELSAESSER Quentin && LEFEVRE Antoine
max=$#
test $max -eq 0 && echo "Il faut au moins un paramètre." && exit 1
test ! -d ${!max} && echo "Le dernier paramètre doit être un dossier." && exit 2
test $max -gt 5 && echo "Veuillez saisir au maximum 3 options et un répertoire." && exit 3

#Affiche les fichiers d'un répertoire donné
cherche () {
total=""
local rep=$1
cpt=0
for i in `find $rep`
do
if [ $i != $rep ]
then
newname=`echo $i | sed "s#"$rep/"##g"`
total="$total""$newname;"
cpt=$(expr $cpt + 1)
fi
done

a=1
while [ "$cpt" -ge "$a" ]
do

    b=$(expr $a + 1)
    var=`echo "$total" | cut -d';' -f$a`
    while [ "$cpt" -ge "$b" ]
    do
        var2=`echo "$total" | cut -d';' -f$b`

        if [ "$var2" != "" ]
        then

            if [ "$var" \> "$var2" ]
            then
                var="$var2"
            fi
        fi
        b=$(expr $b + 1)
    done
    total=`echo "$total" | sed "s/"$var\;"//g"`
    total=";$total"
    echo "$var"
    a=$(expr $a + 1)
done
}

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
    else
        echo "tri dans l'ordre croissant sans sous dossier"
# NE PAS PRENDRE EN COMPTE LES SOUS DOSSIER
        cherche ${!max}
	fi
	if [ ! -d "$1" ]
	then
		shift
		parametre $@
	fi
}
parametre $@





#cherche $1
