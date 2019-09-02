#!/bin/bash
if [[ $# -ne 2 ]]; then
    echo "Il faut le mot de passe en paramètre \$1"
    echo "Il faut 1 pour crypter le nom ou 2 pour décrypter \$2"
    exit 1
fi

logFile=noms.log
password=$1
echo "">$logFile


for filePath in $(find . \( -name '*.zip' -o -name 'U2F*' \) -type f); do
    # File info
    dir=$(dirname $filePath)
    file=$(basename $filePath)

    if [[ $2 -eq 1 ]]; then
        # Cryptage
        cryptedName=$(echo $file | openssl enc -aes-128-cbc -a -salt -pass pass:$password)
        cryptedName=$(echo "$cryptedName" | sed 's/\//SLASHESCAPED/g') # escape / charactere
        # logs
        echo "" >> $logFile
        echo dir=$dir >> $logFile
        echo file=$file >> $logFile
        echo cryptedName=$cryptedName >> $logFile
        mv $dir/$file $dir/$cryptedName
    elif [[ $2 -eq 2 ]]; then
        # Encrypt
        fileRealName=$(echo "$file" | sed 's/SLASHESCAPED/\//g') # escape SLASHESCAPED charactere
        decryptedName=$(echo "$fileRealName" | openssl enc -aes-128-cbc -a -d -salt -pass pass:$password)
        echo fileRealName=$fileRealName >> $logFile
        echo decryptedName=$decryptedName >> $logFile
        mv $dir/$file $dir/$decryptedName
    else
        echo "\$2 inconnue"
    fi
done