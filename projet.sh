#!/bin/bash

if [ $# != 1 ]
then
echo "pas de parametres"
exit 1
fi




cherche () {
total=""
#local tag=$1
local rep=$1
cd ..
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
test=`echo "$total" | sed "s/$var//g"`
echo "$test"


}

cherche $1
