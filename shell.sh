#!/bin/bash
echo "Script to search internal network!!!"
echo "Enter IP :"
read ip
#ip="142.250.193.78" # google ip for testing
echo "Enter Number Of Threads:"
read Threads
#Threads=2 #testing
count=0
subnet="${ip##*/}"
ip="${ip%/*}"
echo [["$subnet"=="$ip"]]
singlescan(){
tmip="$1"
ping -c 1 -W 1 "$tmip" &>/dev/null && echo "$tmip UP"
}
threader(){
while(($(jobs -rp | wc -l) >= "$Threads"));do
sleep 0.1
done

}
subneter(){
sub="$1"
host=$((32-$sub))
host=$((2**$host - 2))
echo " no of hosts is :$host"

IFS=. read -r i1 i2 i3 i4 <<<"$ip"
ip_int=$(( (i1<<24) + (i2<<16) + (i3<<8) + i4 ))
start=1
end="$host"
for ((i=start;i<=end;i++));do
  threader
  {
  val=$((ip_int + i))
  tempip="$(( (val>>24)&255 )).$(( (val>>16)&255 )).$(( (val>>8)&255 )).$((val&255))"
  singlescan "$tempip"
  } &
done

}

if [[ "$subnet" =~ ^[0-9]+$ ]];then
echo "IP subnet Encountered $subnet"
echo " Calling ==>subneter"
subneter "$subnet"
elif [[ "$subnet" == "$ip" ]];then
echo "No Ip Subnet Encountered"
echo "Calling ==> singleipscan"
singlescan "$ip"
elif [["$ip" =~ ^['a'-'z']+$ ]];then
echo "Domain Encountered"
#time ping -c 1 google.com
fi
