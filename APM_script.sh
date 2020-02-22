#!/bin/bash
#MiniProject_APM

#The APMs file must be in the same folder as the script
spawns (){

	./APM1 $1 &
	pid1=$!
	#Sometime the script needs time to actually assign the value
	echo "PID for APM1 is $pid1"


	./APM2 $1 &
	pid2=$!
	echo "PID for APM2 is $pid2"
	

	./APM3 $1 &
	pid3=$!	
	echo "PID for APM3 is $pid3"
	

	./APM4 $1 &
	pid4=$!	
	echo "PID for APM4 is $pid4"
	

	./APM5 $1 &
	pid5=$!
	echo "PID for APM5 is $pid5"
	

	./APM6 $1 &
	pid6=$!
	echo "PID for APM6 is $pid6"
	
	ifstat -a -d 1 2> /dev/null &	
	pidifs=$!
	echo "PID for Ifstat is $pidifs"

	echo "Apps and processes have started"
}

cleanup() {

	echo "***Killing processes...***"
	kill -9 $pid1
	echo "APM1 PID: $pid1 killed "
	kill -9 $pid2
	echo "APM2 PID: $pid2 killed "
	pkill APM3
	echo "APM3 PID: $pid3 killed "
	kill -9 $pid4
	echo "APM4 PID: $pid4 killed "
	pkill APM5
	echo "APM5 PID: $pid5 killed "
	pkill APM6
	echo "APM6 PID: $pid6 killed "
	pkill ifstat
	echo "Ifstat PID: $pidifs killed "
	exit $?

}

control_c() {

	trap cleanup SIGINT

}

collect_PLM() {

	echo "$i_counter,`ps -aux | grep $pid1 | head -n 1| awk '{print $3","$4}'`" >> APM1_metrics.csv
	echo "$i_counter,`ps -aux | grep $pid2 | head -n 1| awk '{print $3","$4}'`" >> APM2_metrics.csv 
	echo "$i_counter,`ps -aux | grep $pid3 | head -n 1| awk '{print $3","$4}'`" >> APM3_metrics.csv
	echo "$i_counter,`ps -aux | grep $pid4 | head -n 1| awk '{print $3","$4}'`" >> APM4_metrics.csv
	echo "$i_counter,`ps -aux | grep $pid5 | head -n 1| awk '{print $3","$4}'`" >> APM5_metrics.csv
	echo "$i_counter,`ps -aux | grep $pid6 | head -n 1| awk '{print $3","$4}'`" >> APM6_metrics.csv

}

collect_SLM(){
	echo "$i_counter,`ifstat | grep ens33 | awk '{print $7","$9}' | sed 's/K//g'`,`iostat | grep sda | awk '{print $4}'`,`df -h -m | grep centos-root | awk '{print $4}'`" >> system_metrics.csv

}	

#main
PLM_counter=0
SLM_counter=0
i_counter=0
read -p "Please enter your IP address of the bench computer: " ipadd
spawns $ipadd

while true
do
	control_c
	i_counter=$(($i_counter+1))
	sleep 1
	if [[ $(($i_counter % 5)) -eq 0 ]]
	then
		collect_PLM &	
		collect_SLM &
	fi
	
done
