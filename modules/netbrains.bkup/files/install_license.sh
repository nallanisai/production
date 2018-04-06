#!/bin/bash
function returnresult()
{
   if [ $1 = "0" ];then
        return 0
   else
        return 1
   fi
}

function fadir()
{
local this_dir=`pwd`
local child_dir="$1"
dirname "$child_dir"
cd $this_dir
}

looptag=true
oldIFS=$IFS
while $looptag ;do 
#judge OS version,must be CentOS7.x
osversion=$(rpm -q centos-release|cut -d "-" -f3)
ostype=centos
if [ -z "$osversion" ]; then 
osversion=$(cat /etc/redhat-release|cut -d " " -f7|cut -d "." -f1)
ostype=redhat
fi
#osversion=7
if [ $osversion -lt 7 ]; then  
echo "The version of the operating system must be 7.0 or above. The installation will be aborted."
looptag=false
returnresult 1 
break 
fi 

#judge OS architecture,must be 64bit
uname -a|grep x86_64
if [ ! $? == 0 ];then
echo "The operating system must be 64-bit. The installation will be aborted."
looptag=false
returnresult 1 
break
fi

currentpath=`pwd`
#use yum install first;if not work,use yum localinstall 
#CentOS7 install
if [ $ostype = "centos" ];then
rpm -qa|grep lsof-4.87 >/dev/null 2>&1
if [ $? -ne 0 ]; then
yum -y install lsof-4.87 >/dev/null 2>&1
if [ $? -ne 0 ]; then
yum -y localinstall $currentpath/preinstallcomponents/CentOS7/lsof-4.87-4.el7.x86_64.rpm >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "fail to install lsof"
	looptag=false
    returnresult 1 
break
fi
fi
echo "succeed to install lsof"
fi
else
#RedHat7 install
rpm -qa|grep lsof-4.87 >/dev/null 2>&1
if [ $? -ne 0 ]; then
yum -y install lsof-4.87 >/dev/null 2>&1
if [ $? -ne 0 ]; then
yum -y localinstall $currentpath/preinstallcomponents/RedHat7/lsof-4.87-4.el7.x86_64.rpm >/dev/null 2>&1
if [ $? -ne 0 ]; then
	echo "fail to install lsof"
	looptag=false
    returnresult 1 
break
fi
fi
echo "succeed to install lsof"
fi
fi

if [ ! -d "/etc/netbrain" ]; then
   mkdir "/etc/netbrain"
fi
#if [ ! -f "/etc/netbrain/install_elasticsearch.conf" ]; then
#echo "The \"/etc/netbrain/install_elasticsearch.conf\" already exists."
\cp -rf ./install.conf /etc/netbrain/install_elasticsearch.conf
if [ $? -ne 0 ]; then
echo "Failed to copy install.conf, the installation will be aborted."
looptag=false
returnresult 1 
break
fi
#fi

#read parameters in /etc/netbrain/install_elasticsearch.conf
while IFS='' read -r line || [[ -n "$line" ]];do 
  read -r key value <<< "$line"
  if [[ ! $line =~ ^# && $line ]]; then
	  declare -A array
	  array[$key]="$value"
  fi
done < "/etc/netbrain/install_elasticsearch.conf"
for keyname in "${!array[@]}";do
		case $keyname in
			"ESSystemUser") systemuser=${array[$keyname]} ;;
			"ESSystemGroup") systemgroup=${array[$keyname]} ;;		
			"InstallPath") installpath=${array[$keyname]} ;;
			"ServiceName") servicename=${array[$keyname]} ;;
			"ClusterName") clustername=${array[$keyname]} ;;
			"NodeName") nodename=${array[$keyname]} ;;
			"User") user=${array[$keyname]} ;;
			"Password") password=${array[$keyname]} ;;
			"DataPath") datapath=${array[$keyname]} ;;
			"LogPath") logpath=${array[$keyname]} ;;
			"BindIp") bindip=${array[$keyname]} ;;
			"Port") port=${array[$keyname]} ;;
			"CPULimit") cpulimit=${array[$keyname]} ;;
			"MemoryLimit") memorylimit=${array[$keyname]} ;;			
#			"RequireSSL") requiressl=${array[$keyname]} ;;
#			"CertAndKeyPath") certandkeypath=${array[$keyname]} ;;
#			"KeyStore") keystore=${array[$keyname]} ;;
#			"TrustStore") truststore=${array[$keyname]} ;;
#			"KeyFile") keyfile=${array[$keyname]} ;;			
#			"SignedFile") signedfile=${array[$keyname]} ;;
#			"CaFile") cafile=${array[$keyname]} ;;
#			"KeyPassword") keypassword=${array[$keyname]} ;;	
			"SingleNode") singlenode=${array[$keyname]} ;;
			"MasterOnlyNode") masteronlynode=${array[$keyname]} ;;
            "ClusterMembers") clustermembers=${array[$keyname]} ;;			
        esac			
done;

mkdir -p $logpath
logdir=`fadir $logpath`
datadir=`fadir $datapath`
if [ -f "$logpath/elasticsearch_install.log" ]; then
\mv $logpath/elasticsearch_install.log $logpath/elasticsearch_install_bak.log
fi

echo "ESSystemUser value is :$systemuser" >>$logpath/elasticsearch_install.log
echo "ESSystemGroup value is :$systemgroup" >>$logpath/elasticsearch_install.log
echo "InstallPath value is :$installpath" >>$logpath/elasticsearch_install.log
echo "ServiceName value is :$servicename" >>$logpath/elasticsearch_install.log
echo "ClusterName value is :$clustername" >>$logpath/elasticsearch_install.log
echo "NodeName value is :$nodename" >>$logpath/elasticsearch_install.log
echo "User value is :$user" >>$logpath/elasticsearch_install.log
echo "Password value is :******" >>$logpath/elasticsearch_install.log
echo "DataPath value is :$datapath" >>$logpath/elasticsearch_install.log
echo "LogPath value is :$logpath" >>$logpath/elasticsearch_install.log
echo "BindIp value is :$bindip" >>$logpath/elasticsearch_install.log
echo "Port value is :$port" >>$logpath/elasticsearch_install.log
echo "CPULimit value is :$cpulimit" >>$logpath/elasticsearch_install.log
echo "MemoryLimit value is :$memorylimit" >>$logpath/elasticsearch_install.log
#echo "RequireSSL value is :$requiressl" >>$logpath/elasticsearch_install.log
echo "SingleNode value is :$singlenode" >>$logpath/elasticsearch_install.log
echo "MasterOnlyNode value is :$masteronlynode" >>$logpath/elasticsearch_install.log
requiressl=no
i=1
members=""  
while((1==1))  
do  
		mastermember=`echo $clustermembers|awk '{print $1}'`
        split=`echo $clustermembers|cut -d " " -f$i`
        if [ "$split" != "" ]  
        then  
                ((i++))  
                members=$members"\""$split"\", "
				#echo $members
        else    
				members=${members::-2}
				#echo $members
				number=$[$i-1]
				numvalue=$[$number/2+1]
				#echo $numvalue
				break  
        fi  
done
if [ "$singlenode" == "no" ]; then
echo "ClusterMembers value is :$members" >>$logpath/elasticsearch_install.log
echo "MasterMember value is :$mastermember" >>$logpath/elasticsearch_install.log
fi
if [ "$requiressl" == "yes" ]; then
echo "CertAndKeyPath value is :$certandkeypath" >>$logpath/elasticsearch_install.log
echo "KeyStore value is :$keystore" >>$logpath/elasticsearch_install.log
echo "TrustStore value is :$truststore" >>$logpath/elasticsearch_install.log
echo "KeyFile value is :$keyfile" >>$logpath/elasticsearch_install.log
echo "SignedFile value is :$signedfile" >>$logpath/elasticsearch_install.log
echo "CaFile value is :$cafile" >>$logpath/elasticsearch_install.log
echo "KeyPassword value is :******" >>$logpath/elasticsearch_install.log
fi

date1=`stat install.sh|grep Modify|awk '{print $2}'|sed s/-//g`
date2=`date +%Y%m%d`
if [ $date2 -lt $date1 ]; then
echo "The current system time is earlier than the creation time of the installation package. The installation will be aborted. Please modify the system time and try again." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1
rm -rf $logdir
break
fi

cpulimitnum=$(echo "$cpulimit"|cut -d "%" -f1)
if [ $cpulimitnum -lt 25 ]; then
echo "The value of the CPULimit argument cannot be less than 25%. The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1
rm -rf $logdir
break
else
if [ $cpulimitnum -gt 35 ]; then
echo "The current value of the CPULimit argument exceeds the recommended value (35%)." | tee -a $logpath/elasticsearch_install.log
fi
fi

#addr=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6|grep -v 192|awk '{print $2}'|tr -d "addr:"`
#testip=`ip a|grep $bindip`
#if [ "$testip" == "" ];then
#echo "The value of the bindip parameter is not modified to the local IP address of this machine. The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
if [ "$bindip" == "127.0.0.1" ];then
echo "Please fill out the actual IP address in install.conf(loopback address 127.0.0.1 is not allowed). The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1
rm -rf $logdir
break
fi

#if [ "$bindip" == "127.0.0.1" -o "$bindip" == "192.168.1.1" ];then
#echo "Please fill out the actual IP address in install.conf(can't be 127.0.0.1 or 192.168.1.1), the installation will be aborted." | tee -a $logpath/elasticsearch_install.log
#looptag=false
#returnresult 1
#rm -rf $logdir
#break
#fi

if [[ ! "$bindip" == "0.0.0.0" ]];then
testip=`ip a|grep $bindip`
# Did not find the specified IP.
if [ "$testip" == "" ];then
echo "Bind IP: $bindip" | tee -a $logpath/elasticsearch_install.log
echo "Please fill out the actual IP address in install.conf. The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1
rm -rf $logdir
break
fi
# Make sure the found IP is the same as the specified IP.
actualIp=$(ip a | grep $bindip | cut -d "/" -f1)
actualIp=$(echo $actualIp | cut -d " " -f2)
if [[ ! "$actualIp" == "$bindip" ]];then
echo "Bind IP: $bindip" | tee -a $logpath/elasticsearch_install.log
echo "Please fill out the actual IP address in install.conf. The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1
rm -rf $logdir
break
fi  
fi

checkinstall=`find / -name elasticsearch.yml`
if [ ! -z "$checkinstall" ]; then  
echo "It detects an elasticsearch has been installed on the machine. The installation will be aborted." 
looptag=false
returnresult 1
break
fi

checkport=$(lsof -i:$port)
if [ ! -z "$checkport" ]; then  
echo "The port number is being used, the installation will be aborted." 
looptag=false
returnresult 1
rm -rf $logdir
break
fi

if [[ $user == *[{}\[\]:\",\'\|@^\&\<\>%\\]* ]]; then
echo "The username should not contain: {}[]:\",'|<>@&^%\\ " | tee -a $logpath/elasticsearch_install.log 
looptag=false
returnresult 1
rm -rf $logdir
break 
fi
if ( echo "$user" | grep -q ' ' ); then
echo "The username should not contain a space." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
rm -rf $logdir
break
fi
if [[ $password == *[{}\[\]:\",\'\|@^\&\<\>%\\]* ]]; then
echo "The password should not contain: {}[]:\",'|<>@&^%\\ " | tee -a $logpath/elasticsearch_install.log 
looptag=false
returnresult 1 
rm -rf $logdir
break
fi
if ( echo "$password" | grep -q ' ' ); then
echo "The password should not contain a space." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
rm -rf $logdir
break
fi
if [[ ${#user} -gt 64  ||  ${#password} -gt 64 ]]; then
echo "The length of the username or password should not exceed 64 characters." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1
rm -rf $logdir
break 
fi

if [[ $systemuser == *[{}\[\]:\",\'\|@^\&\<\>%\\]* ]]; then
echo "The essystemuser should not contain: {}[]:\",'|<>@&^%\\ " | tee -a $logpath/elasticsearch_install.log 
looptag=false
returnresult 1
rm -rf $logdir
break 
fi
if ( echo "$systemuser" | grep -q ' ' ); then
echo "The essystemuser should not contain a space." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
rm -rf $logdir
break
fi
if [[ "$systemuser" == "root" ]]; then
echo "The essystemuser can't be root." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
rm -rf $logdir
break
fi
if [[ $systemgroup == *[{}\[\]:\",\'\|@^\&\<\>%\\]* ]]; then
echo "The essystemgroup should not contain: {}[]:\",'|<>@&^%\\ " | tee -a $logpath/elasticsearch_install.log 
looptag=false
returnresult 1 
rm -rf $logdir
break
fi
if ( echo "$systemgroup" | grep -q ' ' ); then
echo "The essystemgroup should not contain a space." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
rm -rf $logdir
break
fi
if [[ "$systemgroup" == "root" ]]; then
echo "The essystemgroup can't be root." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
rm -rf $logdir
break
fi
if [[ ${#systemuser} -gt 64  ||  ${#systemgroup} -gt 64 ]]; then
echo "The length of the essystemuser or essystemgroup should not exceed 64 characters." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1
rm -rf $logdir
break 
fi

if [ "$user" == "" ] || [ "$password" == "" ] || [ "$systemuser" == "" ] || [ "$systemgroup" == "" ]; then
echo "The user/password/essystemuser/essystemgroup should not be empty." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1
rm -rf $logdir
break 
fi

#if requiressl equal to yes,check *.pem
if [ "$requiressl" == "yes" ]; then 
if [ ! -f "$certandkeypath/$keystore" ]; then  
echo "$keystore can't be found. The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
rm -rf $logdir
break
fi
if [ ! -f "$certandkeypath/$truststore" ]; then  
echo "$truststore can't be found. The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
rm -rf $logdir
break
fi
if [ ! -f "$certandkeypath/$keyfile" ]; then  
echo "$keyfile can't be found. The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
rm -rf $logdir
break
fi
if [ ! -f "$certandkeypath/$signedfile" ]; then  
echo "$signedfile can't be found. The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1
rm -rf $logdir
break
fi
if [ ! -f "$certandkeypath/$cafile" ]; then  
echo "$cafile can't be found. The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
rm -rf $logdir
break
fi
if [ ! -n "$keypassword" ]; then  
echo "RequiredSSL is enabled, so the KeyPassword can't be empty. The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
rm -rf $logdir
break
fi
fi

if [ "$singlenode" == "no" ]; then
if [ "$mastermember" == "$bindip" ]; then
if [ "$masteronlynode" == "yes" ]; then  
echo "$bindip can't be master only node, the installation will be aborted." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
rm -rf $logdir
break
fi
fi
fi

#groupadd -r $systemgroup 2>>$logpath/elasticsearch_install.log
#testgroup1=$?
#testgroup2=`cat $logpath/elasticsearch_install.log | grep "group '$systemgroup' already exists"`
#if [ $testgroup1 -eq 0 ] || [ -n "$testgroup2" ]; then
#echo "Successfully created the system group \"$systemgroup\"."
#else
#echo "Failed to create the system group \"$systemgroup\", the installation will be aborted."
#looptag=false
#returnresult 1 
#rm -rf $logdir
#break
#fi

#useradd -g $systemgroup $systemuser 2>>$logpath/elasticsearch_install.log
#testuser1=$?
#testuser2=`cat $logpath/elasticsearch_install.log | grep "user '$systemuser' already exists"`
#if [ $testuser1 -eq 0 ] || [ -n "$testuser2" ]; then
#echo "Successfully created the system user \"$systemuser\"."
#else
#echo "Failed to create the system user \"$systemuser\", the installation will be aborted."
#looptag=false
#returnresult 1 
#rm -rf $logdir
#break
#fi

mkdir -p $datapath
mkdir -p $logpath

if [ "$masteronlynode" == "yes" ] && [ "$singlenode" == "no" ]; then
echo "$bindip is master only node" | tee -a $logpath/elasticsearch_install.log
else
topdir_log=$logpath
while [ ! -d $topdir_log ]; do
   topdir_log=$(dirname $topdir_log)
done
freespaceinMB_log=$(df -h -m $topdir_log | awk '/^\/dev/{print $4}')
if [ -z "$freespaceinMB_log" ]; then
freespaceinMB_log=$(df -h -m $topdir_log | awk '/^tmpfs/{print $4}')
fi

topdir_data=$datapath
while [ ! -d $topdir_data ]; do
   topdir_data=$(dirname $topdir_data)
done
freespaceinMB_data=$(df -h -m $topdir_data | awk '/^\/dev/{print $4}')
if [ -z "$freespaceinMB_data" ]; then
freespaceinMB_data=$(df -h -m $topdir_data | awk '/^tmpfs/{print $4}')
fi
#if [ "$topdir_log" == "$topdir_data" ]; then
#if [ "$freespaceinMB_log" -lt "10240" ]; then
#echo "The free space of data and log folder is less than 100GB. It may result in insufficient disk space after a period of use, the installation will be aborted."
#looptag=false
#returnresult 1 
#break
#fi
#else
if [ "$freespaceinMB_log" -lt "10240" ]; then
echo "Warning: The specified directory has less than 10GB free space, which may result in abnormal use after the Index Server runs for a period time." | tee -a $logpath/elasticsearch_install.log
fi
if [ "$freespaceinMB_data" -lt "51200" ]; then
echo "Warning: The specified directory has less than 50GB free space, which may result in abnormal use after the Index Server runs for a period time." | tee -a $logpath/elasticsearch_install.log
fi
fi
#fi

binpath=$installpath/bin
configpath=$installpath/config
pluginspath=$installpath/plugins

./jdk.sh
testjdk=`cat $logpath/elasticsearch_install.log | grep Failed`
if [ -n "$testjdk" ]; then
echo "Failed to install JDK. The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
break
else
testwording=`cat $logpath/elasticsearch_install.log | grep -E "JDK does not exist|need installation jdk1.8.0_121"`
if [ -n "$testwording" ]; then
echo "Successfully installed jdk1.8.0_121." | tee -a $logpath/elasticsearch_install.log
else
testversion=`cat $logpath/elasticsearch_install.log | grep "jdk_version" | awk 'NR==1{ gsub(/"/,""); print $2 }'`
echo "The current version of JDK is $testversion." | tee -a $logpath/elasticsearch_install.log
fi
fi

echo "It may take a few minutes to install the $servicename. Please wait." | tee -a $logpath/elasticsearch_install.log
./installelasticsearch.sh >>$logpath/elasticsearch_install.log
testinstall=`cat $logpath/elasticsearch_install.log | grep Failed`
if [ -n "$testinstall" ]; then
echo "Failed to install the $servicename. The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
break
else
sed -i '/\%/d' $logpath/elasticsearch_install.log
echo "Successfully installed the $servicename." | tee -a $logpath/elasticsearch_install.log
fi

./elasticsearchconfig.sh >>$logpath/elasticsearch_install.log
testconfig=`cat $logpath/elasticsearch_install.log | grep Failed`
if [ -n "$testconfig" ]; then
echo "Failed to modify the configurations of the $servicename. The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
break
else
echo "Successfully modified the configurations of the $servicename." | tee -a $logpath/elasticsearch_install.log
fi

echo "Starting the service of the $servicename. Please wait..." | tee -a $logpath/elasticsearch_install.log
./userpassword.sh >>$logpath/elasticsearch_install.log
sed -i '/JAVA_HOME/d' $logpath/elasticsearch_install.log
testservice=`cat $logpath/elasticsearch_install.log | grep Failed`
#testerror=`cat $logpath/elasticsearch_install.log | grep noooooooooooooooo`
#if [ -n "$testservice" ]||[ -n "$testerror" ]; then
if [ -n "$testservice" ]; then
echo "Failed to initialize the username and password in the $servicename. The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
testpassword=`cat $logpath/$clustername.log | grep "Password verification failed"`
if [ -n "$testpassword" ]; then
echo "Failed to start the service of the $servicename because the KeyPassword verification failed." | tee -a $logpath/elasticsearch_install.log
#break
fi
looptag=false
returnresult 1 
break
else
testsuccess=`cat $logpath/elasticsearch_install.log | grep "Done with success"`
if [ -n "$testsuccess" ]; then
echo "Successfully initialized the username and password in the $servicename." | tee -a $logpath/elasticsearch_install.log
else
echo "Failed to initialize the username and password in the $servicename. The installation will be aborted." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 1 
break
fi
fi

if [ "$requiressl" == "no" ]; then
testport=`curl -s -XGET --user $user:$password http://$bindip:$port | grep cluster_name`
i="1"
while [[ -z $testport ]]
 do
 echo "It is the No.$i times to attempt to connect to the $servicename, please wait..." | tee -a $logpath/elasticsearch_install.log
 sleep 30s
 testport=`curl -s -XGET --user $user:$password http://$bindip:$port | grep cluster_name`
 let "i++"
 done
#echo "Successfully set up the $servicename."
else
testport=`curl -k -s -XGET --user $user:$password https://$bindip:$port | grep cluster_name`
i="1"
while [[ -z $testport ]]
 do
 echo "It is the No.$i times to attempt to connect to the $servicename, please wait..." | tee -a $logpath/elasticsearch_install.log
 sleep 30s
 testport=`curl -k -s -XGET --user $user:$password https://$bindip:$port | grep cluster_name`
 let "i++"
 done
#echo "Successfully set up the $servicename."
fi

echo "Successfully connected to the $servicename. The setup was finished." | tee -a $logpath/elasticsearch_install.log
looptag=false
returnresult 0 
break
done;
IFS=$oldIFS	