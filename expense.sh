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

CHECK_ROOT

STEP_STATUS(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is....$R FAILED $N" |& tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 is....$G success $N" |& tee -a $LOG_FILE
    fi
}

dnf install mysql-server -y
VALIDATE $? "Installing MySQL server" | tee -a $LOG_FILE
STEP_STATUS $? "Installation successfull , now enabling MYSQL" | tee -a $LOG_FILE

systemctl enable mysqld
VALIDATE $? "Enabled MySQL server"
STEP_STATUS $? "enabling successfull , now will start MYSQL" | tee -a $LOG_FILE

systemctl start mysqld
VALIDATE $? "Started MySQL server"
STEP_STATUS $? "starting successfull , now setting up root password MYSQL" | tee -a $LOG_FILE

mysql -h mysql.yashd.icu -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE

if [ $? -ne 0 ]
then
    echo "root passwd not set up , setting now" | tee -a $LOG_FILE | tee -a $LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1
else
    echo -e "Root password is already set up ...$Y SKIPPING THE STEP $N " | tee -a $LOG_FILE
    echo "now you can use my sql by typing 'mysql'" 
fi 
