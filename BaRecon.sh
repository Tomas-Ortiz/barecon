#! /bin/bash

#Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"

function helpPanel(){
 title
 echo -e "\nBaRecon is a tool that performs basic reconnaissance on a network block, a domain and all its subdomains, or a single IP address."
 echo -e "\nUsage:"
 echo -e "./BasicRecon.sh -d ${purpleColour}<DOMAIN>${endColour}\tScan a domain and all its subdomains (e.g. example.com)"
 echo -e "./BasicRecon.sh -n ${purpleColour}<CIDR>${endColour}\tScan a network block (e.g. 10.10.10.0/24)"
 echo -e "./BasicRecon.sh -a ${purpleColour}<IP>${endColour}\t\tScan a single IP (e.g. 10.10.10.10)"
 echo -e "./BasicRecon.sh -h\t\tHelp panel"
 warning
}

function title(){ 
 echo -e "\n*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*"
 echo -e ">                                              >"
 echo -e ">                    ${turquoiseColour}BaRecon${endColour}                   >"
 echo -e ">                 By ${yellowColour}Tomas Ortiz${endColour}               >"
 echo -e ">                                              >"
 echo -e "*>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>*"
}

function warning(){
echo -e "\n${yellowColour}[Warning]${endColour} This tool performs active reconnaissance. Ensure you have authorization before performing any analysis.\nMisuse may result in legal action."
}

function checkDependencies(){
  dependencies=(ipcalc whois naabu ping nslookup awk sed cut grep curl dig subfinder)
  
  echo -e "\nChecking required dependencies..."
  
  for program in "${dependencies[@]}"
   do
    if ! command -v $program &> /dev/null
     then
      echo -e "Installing ${turquoiseColour}$program...${endColour}"
      output=$(apt-get install -y $program 2>&1)
      
      if echo "$output" | grep -q -i "Unable to locate package"
       then
        echo -e "${redColour}[Error] $program not installed. Please install it manually.${endColour}"
        exit 1 # Exit with error
       else
        echo -e "${greenColour}[OK] $program installed.${endColour}"
      fi
    fi
  done
  
  echo -e "${greenColour}[OK] All dependencies installed.${endColour}"
}

function reconNetBlock(){
 echo -e "\nScanning Network Block, Please Wait..."
 echo -e "==============================================================================================================="
 
 local cidr=$1
 local address=$(echo $cidr | cut -d '/' -f 1)
 getNetBlockDetails $cidr
 getNetworkDetails $network
 
 output_file="BaRecon-$address-$mask.txt"
 > "$output_file"
 
 {
 echo -e "${blueColour}Network${endColour}: $network"
 echo -e "${blueColour}Network owner${endColour}: $networkOwner"
 echo -e "${blueColour}Country${endColour}: $country"
 echo -e "${blueColour}Total hosts${endColour}: $totalHosts"
 echo -e "${blueColour}First IP${endColour}: $firstIP"
 echo -e "${blueColour}Last IP${endColour}: $lastIP"

 echo -e "==============================================================================================================="
 echo -e "\n\nScanning Hosts, Please Wait..."
 echo -e "==============================================================================================================="
 
 for (( i=firstIP_lastOctet; i <= $lastIP_lastOctet; i++ ))
 do
  currentIP="$IP_prefix.$i"
  
  getNetworkDetails $currentIP
  getHostnames $currentIP

  echo -e "${blueColour}IP${endColour}: $currentIP"
  echo -e "${blueColour}Hostnames${endColour}:\n$hostnames"
  echo -e "${blueColour}Ping response${endColour}: $pingResponse"
  echo -e "${blueColour}Open ports${endColour}: $ports" 
  
  httpResponses=''
  
  for port in "${port_list[@]}"
   do
    httpResponse=$(curl -k -m 7 -I https://$currentIP:$port 2>/dev/null || curl -k -m 7 -I http://$currentIP:$port 2>/dev/null)
    
    if [ -n "$httpResponse" ]
    then
     echo -e "${blueColour}HTTP Response ${endColour}(Port $port):\n$httpResponse"
    fi
   done

  echo -e "==============================================================================================================="
 done
 } | tee -a "$output_file"
 
 echo -e "\n:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
 echo -e "Results saved in file ${blueColour}$output_file${endColour}"
 echo -e ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
}

function reconIP(){
 echo -e "\nScanning IP, Please Wait..."
 echo -e "==============================================================================================================="
 
 local ip=$1
 getNetworkDetails $ip
 getHostnames $ip
 
 output_file="BaRecon-$ip.txt"
 > "$output_file"
 
 {
 echo -e "\n${blueColour}IP${endColour}: $ip"
 echo -e "${blueColour}Network owner${endColour}: $networkOwner"
 echo -e "${blueColour}Country${endColour}: $country"
 echo -e "${blueColour}Hostnames${endColour}:\n$hostnames"
 echo -e "${blueColour}Ping response${endColour}: $pingResponse"
 echo -e "${blueColour}Open ports${endColour}: $ports"
 
  for port in "${port_list[@]}"
   do
    httpResponse=$(curl -k -m 7 -I https://$ip:$port 2>/dev/null || curl -k -m 7 -I http://$ip:$port 2>/dev/null)
    [ -n "$httpResponse" ] && echo -e "${blueColour}HTTP Response ${endColour}(Port $port):\n$httpResponse"
  done
 } | tee -a "$output_file"
 
 echo -e "\n:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
 echo -e "Results saved in file ${blueColour}$output_file${endColour}"
 echo -e ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
}

function reconDomainAndSubdomains(){
 echo -e "\nScanning Subdomains, Please Wait..."
 echo -e "==============================================================================================================="
 
 local domain=$1
 local subdomains=$(subfinder -d $domain 2>/dev/null | grep "\.$domain" | sort | uniq)

 if [ -z "$subdomains" ]
  then
   subdomains="-"
  else
   IFS=$'\n' read -rd '' -a subdomains_list <<< "$subdomains"
 fi
 
  output_file="BaRecon-$domain.txt"
  > "$output_file"
 
 for subdomain in "${subdomains_list[@]}"
  do
  getIP $subdomain
  getNetworkDetails $ip
   
  {
  echo -e "${blueColour}Host${endColour}: $subdomain"
  echo -e "${blueColour}IP${endColour}: $ip"
  echo -e "${blueColour}Network owner${endColour}: $networkOwner"
  echo -e "${blueColour}Country${endColour}: $country"
  echo -e "${blueColour}Ping response${endColour}: $pingResponse"
  echo -e "${blueColour}Open ports${endColour}: $ports"
  
  for port in "${port_list[@]}"
   do
    httpResponse=$(curl -k -m 7 -I https://$subdomain:$port 2>/dev/null || curl -k -m 7 -I http://$subdomain:$port 2>/dev/null)
    [ -n "$httpResponse" ] && echo -e "${blueColour}HTTP Response ${endColour}(Port $port):\n$httpResponse"
  done
  
  echo -e "==============================================================================================================="
  } | tee -a "$output_file"
 done
 
 echo -e "\n:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
 echo -e "Results saved in file ${blueColour}$output_file${endColour}"
 echo -e ":::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
}

function getNetworkDetails(){
 local ipAdd=$1
 networkOwner=$(whois $ipAdd 2>/dev/null | grep -i -m 1 -E '^(owner|OrgName|descr):' | awk -F': ' '{gsub(/^ +/, "", $2); print $2}')
 country=$(whois $ipAdd 2>/dev/null | grep -i -m 1 '^country:' | awk -F': ' '{gsub(/^ +/, "", $2); print $2}')
 pingResponse=$(ping -c 1 -W 1 $ipAdd >/dev/null 2>&1 && echo "Ok" || echo "Error")
 ports=$(naabu -host $ipAdd -rate 100 2>/dev/null | awk -F: '{print $2}' | sort -n | tr '\n' ', ' | sed 's/,$//')
 
 [ -z "$networkOwner" ] && networkOwner="-"
 [ -z "$country" ] && country="-"
 
 if [ -z "$ports" ]
  then
   ports="-"
  else
   IFS=',' read -ra port_list <<< "$ports"
 fi
}

function getHostnames(){
 local ipAdd=$1
 hostnames=$(nslookup $ipAdd | awk -F'=' '{gsub(/^ +/, "", $2); print $2}' | sed 's/\.$//' )
 [ -z "$hostnames" ] && hostnames="-"
}

function getIP(){
 local host=$1
 ip=$(dig +short A $host | grep -Eo '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
 [ -z "$ip" ] && ip="-"
}

function getNetBlockDetails(){
 local cidr=$1
 network=$(ipcalc -n -b $cidr | awk '/Network/ {print $2}')
 totalHosts=$(ipcalc -n -b $cidr | awk '/Hosts/ {print $2}')
 firstIP=$(ipcalc -n -b $cidr | awk '/HostMin/ {print $2}')
 lastIP=$(ipcalc -n -b $cidr | awk '/HostMax/ {print $2}')
 IP_prefix=$(ipcalc -n -b $cidr | awk '/Network/ {print $2}' | cut -d'/' -f1 | cut -d'.' -f1-3)
 firstIP_lastOctet=$(ipcalc -n -b $cidr | awk '/HostMin/ {print $2}' | cut -d'.' -f4)
 lastIP_lastOctet=$(ipcalc -n -b $cidr | awk '/HostMax/ {print $2}' | cut -d'.' -f4)
 
 [ -z "$network" ] && network="-"
 [ -z "$totalHosts" ] && totalHosts="-"
 [ -z "$firstIP" ] && firstIP="-"
 [ -z "$lastIP" ] && lastIP="-"
}

# $# = total arguments
if [ $# -eq 0 ]
 then
  title
  echo -e "\n${redColour}Error: No Arguments provided.${endColour}"
  exit 1 # Exit with error
fi

# Check root permissions
if [ "$(id -u)" == "0" ]
then
while getopts ":d:n:a:h" option
do
 case ${option} in
  d)
    domain=$OPTARG
    
    title
    warning
    checkDependencies
    reconDomainAndSubdomains $domain
    ;;
  n)
    cidr=$OPTARG
    
    if [[ $cidr =~ / ]]
    then
     mask=$(echo $cidr | cut -d'/' -f2)
    else
     title
     echo -e "\n${redColour}Error: The mask is required.${endColour}"
     exit 1 # Exit with error
    fi
    
    if [ $mask -lt 8 ] || [ $mask -gt 32 ]
    then
     title
     echo -e "\n${redColour}Error: Mask not allowed, must be between /8 and /32.${endColour}"
     exit 1 # Exit with error
    fi
    
    title
    warning
    checkDependencies
    
    if [ $mask -eq 32 ]
    then
     ip=$(echo $cidr | cut -d'/' -f1)
     reconIP $ip
    else
     reconNetBlock $cidr
    fi
    ;;
  a)
    ip=$OPTARG 
    title
    warning
    checkDependencies
    reconIP $ip
    ;;
  h)
    helpPanel
    exit 0 # Exit after showing the help panel
    ;;
  *)
    echo -e "\n${redColour}Invalid option${endColour}: -$OPTARG" >&2
    helpPanel
    exit 1 # Exit with error
    ;;
 esac
done
else
 title
 echo -e "\n${redColour}Error: You need root permissions.${endColour}"
 exit 1 # Exit with error
fi


