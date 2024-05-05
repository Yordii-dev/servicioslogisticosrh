## STEP 1 - Transfer environment file from PC:

scp C:\Users\ELIZABETH\Documents\arequepay-backend-main\arequepay-backend\environment_vars.txt root@srv431103.hstgr.cloud:\root

other option : 

git clone [REPOSITORY] and use the environment_vars.txt file

## SETP 2 - Include file path to ~/.bashrc in VPS:

- Edit file

nano ~/.bashrc

- Add the following:

source /root/environment_vars.txt

- Save ~/.bashrc:

source ~/.bashrc