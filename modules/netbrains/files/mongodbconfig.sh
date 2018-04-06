#!/bin/bash
function returnresult()
{
   if [ $1 = "0" ];then
        return 0
   else
        return 1
   fi
}

looptag=true
while $looptag ;do 
#judge OS version,must be CentOS7.x
#cat /etc/redhat-release = Red Hat Enterprise Linux Server release 7.0 (Maipo)
#rpm -q centos-release = centos-release-7-2.1511.el7.centos.2.10.x86_64
osversion=$(rpm -q centos-release|cut -d "-" -f3)
if [ -z "$osversion" ]; then 
osversion=$(cat /etc/redhat-release|cut -d " " -f7|cut -d "." -f1)
fi
#osversion=7
if [ $osversion -lt 7 ]; then  
echo "The version of operation system must be 7.0 or above, the installation will abort"
looptag=false
returnresult 1 
break 
fi 

#judge OS architecture,must be 64bit
uname -a
uname -a|grep x86_64
if [ ! $? == 0 ];then
echo "The architecture of operation system must be 64bit, the installation will abort"
looptag=false
returnresult 1 
break
fi

#if [ `whoami` = "root" ];then
# echo "You are root user"
#else
# echo "You are not root user, the installation will abort"
# looptag=false
#returnresult 1 
#break
#fi

while IFS='' read -r line || [[ -n "$line" ]];do 
  read -r key value <<< "$line"
  if [[ ! $line =~ ^# && $line ]]; then
      #echo "Key:$key -Value:$value"
	  declare -A array
	  array[$key]="$value"
  fi
done < "/etc/install_mongodb.conf"
for keyname in "${!array[@]}";do
		case $keyname in 
			"DBServiceName") dbservicename=${array[$keyname]} ;;
			"DBSystemUser") dbsystemuser=${array[$keyname]} ;;
			"DBSystemGroup") dbsystemgroup=${array[$keyname]} ;;
			"ConfPath") confpath=${array[$keyname]} ;;
			#"DBPath") dbpath=${array[$keyname]} ;;
			"DataPath") datapath=${array[$keyname]} ;;
			"LogPath") logpath=${array[$keyname]} ;;
			"BindIp") bindip=${array[$keyname]} ;;
			"DBPort") dbport=${array[$keyname]} ;;
			"ReplicaSetName") replicasetname=${array[$keyname]} ;;
			"CPULimit") cpulimit=${array[$keyname]} ;;
			"MemoryLimit") memorylimit=${array[$keyname]} ;;
			"RequireSSL") requiressl=${array[$keyname]} ;;	
			"CertPath") certpath=${array[$keyname]} ;;
			"KeyPath") keypath=${array[$keyname]} ;;
			"DBUser") dbuser=${array[$keyname]} ;;
			"DBPassword") dbpassword=${array[$keyname]} ;;
			"SingleNode") singlenode=${array[$keyname]} ;;	
			"ReplicaSetMembers") replicasetmembers=${array[$keyname]} ;;
        esac			
		#echo "key  : $keyname"
        #echo "value: ${array[$keyname]}"
done;
dbpath=/bin

echo "DBServiceName value is :$dbservicename"
echo "DBSystemUser value is :$dbsystemuser"
echo "DBSystemGroup value is :$dbsystemgroup"
echo "ConfPath value is :$confpath"
#echo "DBPath value is :$dbpath"
echo "DataPath value is :$datapath"
echo "LogPath value is :$logpath"
echo "BindIp value is :$bindip"
echo "DBPort value is :$dbport"
echo "ReplicaSetName value is :$replicasetname"
echo "CPULimit value is :$cpulimit"
echo "MemoryLimit value is :$memorylimit"
echo "RequireSSL value is :$requiressl"
echo "CertPath value is :$certpath"
echo "KeyPath value is :$keypath"
echo "DBUser value is :$dbuser"
echo "DBPassword value is :******"
echo "SingleNode value is :$singlenode"
if [ "$singlenode" == "no" ]; then
echo "ReplicaSetMembers value is :$replicasetmembers"
fi

if [ "$bindip" == "0.0.0.0" ]; then
  bindip="127.0.0.1"
fi

  #judge if mongodbconfig.sh has been execute successfully
  if [ "$requiressl" == "yes" ]; then
  $(which echo) "exit"|$dbpath/mongo --host 127.0.0.1:$dbport -u "$dbuser" -p "$dbpassword" --authenticationDatabase admin --ssl --sslAllowInvalidCertificates > /dev/null 2>&1
  else
  $(which echo) "exit"|$dbpath/mongo --host 127.0.0.1:$dbport -u "$dbuser" -p "$dbpassword" --authenticationDatabase admin > /dev/null 2>&1
  fi
  if [ $? == 0 ];then
  echo "mongodbconfig.sh has been execute successfully"
  looptag=false
  returnresult 0 
  break
  fi
  #config replicaset for three,five,seven or more nodes
  if [ "$bindip" == "0.0.0.0" ]; then
    bindip="127.0.0.1"
  fi
  
  if [ "$requiressl" == "yes" ]; then
  $(which echo) "exit"|$dbpath/mongo "$bindip:$dbport" --ssl --sslAllowInvalidCertificates
  else
  $(which echo) "exit"|$dbpath/mongo "$bindip:$dbport"
  fi
  if [ $? == 0 ];then
  echo "successfully connected to mongodb node :$bindip:$dbport"
  #must sleep some seconds
  sleep 20
  if [ "$singlenode" == "no" ]; then
	if [ -f "/etc/initreplica.js" ]; then  
	rm -rf /etc/initreplica.js
	fi 

	echo "var cfg = { _id: '$replicasetname'," >> "/etc/initreplica.js"
	echo "members: [" >> "/etc/initreplica.js"
	#echo " { _id: 0, host: '$bindip:$dbport', priority: 1000}," >> "/etc/initreplica.js"
	#i=1
	i=0
	for   rsmember  in   $replicasetmembers    
	do      
	rsip=$(echo $rsmember|cut -d ":" -f1)
	rsport=$(echo $rsmember|cut -d ":" -f2)
	#if [ "$rsip:$rsport" = "$bindip:$dbport" ];then
	#continue
	#fi
	echo " { _id: $i, host: '$rsip:$rsport', priority: $(expr 1000 - 30 \* $i)}," >> "/etc/initreplica.js"
	i=$(expr $i + 1)
	done
	echo $i
    #change the last }, to be , arbiterOnly: true} ,means the last to be arbiter
    arbiterstr=$(sed -n '$p' "/etc/initreplica.js" | sed 's/\(.*\)},/\1, arbiterOnly: true}/')
    echo $arbiterstr
    sed -i '$d' "/etc/initreplica.js" 
    echo $arbiterstr >> "/etc/initreplica.js"
    
    echo "]" >> "/etc/initreplica.js"
    echo "};" >> "/etc/initreplica.js"
    echo "var error = rs.initiate(cfg);" >> "/etc/initreplica.js"
    echo "printjson(error);" >> "/etc/initreplica.js"	
	if [ ! -f "/etc/netbrainrssuccess" ]; then
    if [ "$requiressl" == "yes" ]; then	
	$dbpath/mongo 127.0.0.1:$dbport/admin --ssl --sslAllowInvalidCertificates "/etc/initreplica.js"
	else
	$dbpath/mongo 127.0.0.1:$dbport/admin "/etc/initreplica.js"
	fi
	if [ $? == 0 ];then
    echo "successfully initiated replicaset $replicasetname of mongodb"
	echo "successfully initiated replicaset $replicasetname of mongodb" > /etc/netbrainrssuccess
    fi
	fi	
  else
  if [ ! -f "/etc/netbrainrssuccess" ]; then
  if [ "$requiressl" == "yes" ]; then  
  $(which echo) "rs.initiate()"|$dbpath/mongo "127.0.0.1:$dbport" --ssl --sslAllowInvalidCertificates
  else
  $(which echo) "rs.initiate()"|$dbpath/mongo "127.0.0.1:$dbport"
  fi
  if [ $? == 0 ];then
    echo "successfully initiated single node replicaset $replicasetname of mongodb"
	echo "successfully initiated replicaset $replicasetname of mongodb" > /etc/netbrainrssuccess
  fi
  fi
  fi
  else 
  echo "failed to connect mongodb node:$bindip:$dbport"
  looptag=false
  returnresult 1 
break
  fi
##restart mongodb service to make replicaset work
#systemctl restart $dbservicename > /dev/null 2>&1
##must sleep some seconds
sleep 10  
#add username and password (both username and password must not be empty) for replicaset or only this node
if [ ! -z "$dbuser" -a ! -z "$dbpassword" ] ; then
    #must sleep some seconds
    sleep 20
#use js to get db.isMaster().ismaster 30 times, if get ture 10 times continuously, the replicaset is stable
	if [ -f "/etc/judgersstable.js" ]; then  
	rm -rf /etc/judgersstable.js
	fi 
	echo "var totaltimes = 30;" >> "/etc/judgersstable.js"
	echo "var continuoustimes = 0;" >> "/etc/judgersstable.js"
	echo "var successtag = 1;" >> "/etc/judgersstable.js"
	echo "for (i = 0; i < totaltimes; i++) {" >> "/etc/judgersstable.js"
	echo "var result = db.isMaster().ismaster;" >> "/etc/judgersstable.js"
	echo "if(result == true)" >> "/etc/judgersstable.js"
	echo "{" >> "/etc/judgersstable.js"
	echo "continuoustimes = continuoustimes+1;" >> "/etc/judgersstable.js"
	echo "}" >> "/etc/judgersstable.js"
	echo "else" >> "/etc/judgersstable.js"
	echo "{" >> "/etc/judgersstable.js"
	echo "continuoustimes = 0;" >> "/etc/judgersstable.js"
	echo "continue;" >> "/etc/judgersstable.js"
	echo "}" >> "/etc/judgersstable.js"
	echo "if(continuoustimes == 10)" >> "/etc/judgersstable.js"
	echo "{" >> "/etc/judgersstable.js"
	echo "successtag = 0;" >> "/etc/judgersstable.js"
	echo "printjson(successtag);" >> "/etc/judgersstable.js"
	echo "break;" >> "/etc/judgersstable.js"
	echo "}" >> "/etc/judgersstable.js"
	echo "}" >> "/etc/judgersstable.js"
	if [ "$requiressl" == "yes" ]; then
	fullstring=$($dbpath/mongo 127.0.0.1:$dbport --ssl --sslAllowInvalidCertificates "/etc/judgersstable.js")
	else
    fullstring=$($dbpath/mongo 127.0.0.1:$dbport "/etc/judgersstable.js")	
	fi
	echo "fullstring = $fullstring"
	resultstring=${fullstring: -1}	
	echo "resultstring = $resultstring"
	#if not stable,exit shell
	if [ "$resultstring" == "1" ]; then
    echo "The node of mongodb is not stable, the shell will abort"
	looptag=false
    returnresult 1 
	break
	fi
	
	if [ "$resultstring" == "t" ]; then
    echo "The node of mongodb is not stable, the shell will abort"
	looptag=false
    returnresult 1 
	break
	fi
	echo "Creating MongoDB user, please wait."
	sleep 60
	if [ "$resultstring" == "0" ]; then
	if [ -f "/etc/adduserpassword.js" ]; then  
	rm -rf /etc/adduserpassword.js
	fi
	#echo "var existuser = db.getSiblingDB(\"admin\").getUsers()[0].user;" >> "/etc/adduserpassword.js"
	#echo "printjson(existuser);" >> "/etc/adduserpassword.js"
	#echo "if(existuser != \"$dbuser\"){" >> "/etc/adduserpassword.js"
	echo "var userpassword = {" >> "/etc/adduserpassword.js"
	echo "user: \"$dbuser\"," >> "/etc/adduserpassword.js"
	echo "pwd: \"$dbpassword\"," >> "/etc/adduserpassword.js"
	echo "roles: [ { role: \"root\", db: \"admin\" } ]" >> "/etc/adduserpassword.js"
	echo "};" >> "/etc/adduserpassword.js"
	echo "var error = db.createUser(userpassword);" >> "/etc/adduserpassword.js"
	#echo "var error = db.createUser(userpassword);}" >> "/etc/adduserpassword.js"
	
		
    if [ ! -f "/etc/netbrainuserpwdsuccess" ]; then
    if [ "$requiressl" == "yes" ]; then
	$dbpath/mongo 127.0.0.1:$dbport/admin --ssl --sslAllowInvalidCertificates "/etc/adduserpassword.js"
	else
	$dbpath/mongo 127.0.0.1:$dbport/admin "/etc/adduserpassword.js"
    fi
	if [ $? == 0 ];then
    echo "successfully added username:\"$dbuser\",password:\"******\" for mongodb"
	echo "successfully added username:\"$dbuser\",password:\"******\" for mongodb" > /etc/netbrainuserpwdsuccess
	else
    echo "failed to add username:\"$dbuser\",password:\"******\" for mongodb"
    looptag=false
    returnresult 1 
break
	fi 
	fi
	
#restart mongodb service to make user and password work
systemctl restart $dbservicename > /dev/null 2>&1
#must sleep some seconds
sleep 10
#test user and password work or not
if [ "$requiressl" == "yes" ]; then
$(which echo) "exit"|$dbpath/mongo --host 127.0.0.1:$dbport -u "$dbuser" -p "$dbpassword" --authenticationDatabase admin --ssl --sslAllowInvalidCertificates
else
$(which echo) "exit"|$dbpath/mongo --host 127.0.0.1:$dbport -u "$dbuser" -p "$dbpassword" --authenticationDatabase admin
fi
if [ $? == 0 ];then
echo "successfully logged in mongodb with username:\"$dbuser\",password:\"******\""
else
echo "failed to login mongodb with username:\"$dbuser\",password:\"******\""
fi
fi
fi
looptag=false
returnresult 0 
break  
done;  
