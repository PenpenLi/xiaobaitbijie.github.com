package=./publish/$1
echo $package
scp $package  root@120.77.183.51:~
ssh root@120.77.183.51 unzip -o $1  -d hotupdate/chaoshanniuniu
ssh root@120.77.183.51
