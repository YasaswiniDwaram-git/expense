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

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE
    VALIDATE $? "creating system user -expense"
else 
    echo -e "user already present , hence $Y SKIPPIN $N "
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating app folder"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOG_FILE
VALIDATE $? "Downloding backend app code"

cd /app &>>$LOG_FILE
rm -rf /app/*     #this helps in removing previous version and deploy new version if available instead of re-write
unzip /tmp/backend.zip
VALIDATE $? "extracting latest backend app to tmp folder"

npm install &>>$LOG_FILE
cp /home/ec2-user/expense/backend-service /etc/systemd/system/backend.service 
#above step , we copied backend.service file from git repo to the new folder backend.service on systemconfig in server

dnf install mysql -y  &>>$LOG_FILE #loading data before running backend file , since we need client to connect to mysql server
VALIDATE $? "installing MYSQL client"

mysql -h mysql.yashd.icu -uroot -pExpenseApp@1 < /app/schema/backend.sql &>>$LOG_FILE
VALIDATE $? "Schema/database loaded"

# /app/schema/backend.sql: This part tells MySQL to read and execute the SQL commands contained in the file located at /app/schema/backend.sql.
# which are idempotent in nature
# CREATE DATABASE IF NOT EXISTS transactions;
# USE transactions;
# CREATE TABLE IF NOT EXISTS transactions (
#   id INT AUTO_INCREMENT PRIMARY KEY,
#  amount INT,
# description VARCHAR(255)
# );
# CREATE USER IF NOT EXISTS 'expense'@'%' IDENTIFIED BY 'ExpenseApp@1';
# GRANT ALL ON transactions.* TO 'expense'@'%';
# FLUSH PRIVILEGES;

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Daemon-reload"

systemctl enable backend &>>$LOG_FILE
VALIDATE $? "enabled backend"

systemctl restart backend &>>$LOG_FILE
VALIDATE $? "restarted backend"





