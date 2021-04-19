#!/bin/bash

### INSTALAR yum install l
PATH=/usr/sbin:/usr/local/bin:/usr/bin:/bin
export PATH

ZMPROV="/opt/zimbra/bin/zmprov"

ldapsearch -x -b "dc=EXEMPLO,dc=local" -H "ldap://EXEMPLO.local" -D "CN=USUARIO_AUTENTICACAO,OU=EXEMPLO,OU=EXEMPLO,DC=EXEMPLO,DC=local" -w SENHA_USUARIO_AUTENTICADOR -s sub "(&(objectCategory=person)(cn=*) (objectCategory=user)(whenCreated>=`date +%Y%m%d`000000.0Z))" sAMAccountName givenName sn info | egrep "givenName|sn|info|sAMAccountName"  > Lista_User_AD.log

echo "
sn: teste
givenName: teste
info: teste
sAMAccountName: teste" | tee -a Lista_User_AD.log > /dev/null


sleep 3600

while read DADOS; do

echo "$DADOS" | egrep 'sn: ' > /dev/null
if [ $? -eq 0 ]; then

        if [[ -n "$SNAME" ]]; then

                         EXISTE=`su - zimbra -c "zmprov ga $EMAIL" 2>/dev/null | grep uid |  awk -F':' '{print $2}' | head -n1 | wc -l`

                if [ $EXISTE == "1" ]
                        then
                                echo "USUÁRIO EXISTE" > /dev/null

                else
						#CRIA OS USUÁRIO
                $ZMPROV ca $EMAIL@virtualsistemas.com.br "" displayName "$PNAME $SNAME" givenName "$PNAME" sn "$SNAME"
						
						#COLOCA NA FILA DE DISTRIBUIÇAO
				$ZMPROV adlm $LISTA funcionarios@virtualsistemas.com.br $EMAIL@virtualsistemas.com.br
                $ZMPROV adlm funcionarios@virtualsistemas.com.br $EMAIL@virtualsistemas.com.br

                fi

#SEGUNDO NOME

        fi
SNAME=$(echo $DADOS | awk -F " " '{print $2}')
fi

#PRIMERO NOME

echo "$DADOS" | egrep 'givenName: ' > /dev/null
if [ $? -eq 0 ]; then
PNAME=$(echo $DADOS | awk -F " " '{print $2}')
fi

#LISTA DE DISTRIBUIÇÃO

echo "$DADOS" | egrep 'info: ' > /dev/null
if [ $? -eq 0 ]; then
LISTA=$(echo $DADOS | awk -F " " '{print $2}')
fi

#USUÁRIO

echo "$DADOS" | egrep 'sAMAccountName: ' > /dev/null
if [ $? -eq 0 ]; then
EMAIL=$(echo $DADOS | awk -F " " '{print $2}')
fi

done < Lista_User_AD.log
