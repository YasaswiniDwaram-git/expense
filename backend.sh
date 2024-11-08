#!/bin/bash
USERID=$(id -u)
R="\e[31m"
G="\e[32m"
N="\e[0m]"
Y="\e[33m]"

LOGS_FOLDER="/var/log/shell-scriptings"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIME_STAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIME_STAMP.log"
mkdir -p $LOGS_FOLDER

CHECK_ROOT(){
if [ $USERID -ne 0 ]
then
    echo "$R please run script with root access $N" |& tee -a $LOG_FILE
    exit 1
else 
    echo "welcome admin , anything for you today? " &>>$LOG_FILE
fi
}

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is....$R FAILED $N" |& tee -a $LOG_FILE
        exit 1
    else 
        echo -e "$2 is....$G success $N" |& tee -a $LOG_FILE
    fi
}

echo "script started executing at : $TIME_STAMP " | tee -a $LOG_FILE

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "DISABLING DEFAULT NODE JS"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "ENABLING NODE JS - V20 "

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "INSTALLING NODE JS"

id expense
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE
    VALIDATE $? "creating system user -expense"
else 
    echo -e "user already present , hence $Y SKIPPIN $N "
fi



