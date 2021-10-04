#!/bin/bash
clear
readonly opApi='Your API'
readonly now=`date +%Y%m%d_%H%M%S`
var="Your Directory"
log="Your Log Directory"
vim $var/domaininput.txt

cat $var/domaininput.txt |sort |uniq > $var/domainlist.txt

echo -e "\E[1;5;33m 撈取全域名中．．． \E[0m "
curl -d "Your API參數" -s "${opApi}" > $var/PDNS_All_Domain.txt

# 整理域名資訊
for domain in `cat $var/domainlist.txt`
do
sitegroup=`cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$domain\"" |jq -r .site_group`
notegm=`cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$domain\"" |jq -r .note_gm`
noteid=`cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$domain\"" |jq -r .note_id`
        echo -ne "$domain \033[33m資料撈取完畢\033[0m\n"
        echo -ne "$domain $sitegroup $notegm $noteid \n" >> $log/domainall_${now}.txt
done

# 搜尋關鍵字
echo "##############################"
read -p "輸入備註中括號前的關鍵字 ：" wordkey
echo -ne "=================== Double Check is start ==================\n"
cat $log/domainall_${now}.txt |grep -w "$wordkey" > $log/grepdomain_${nowt}.txt

#搜尋關鍵字出來的域名，與原本vim之域名比對
M=`cat $var/domainlist.txt |wc -l`
echo -ne "共$M個domain，檢查中請稍後 \n"
for name in `cat $var/domainlist.txt`
do
list1check=`cat $log/grepdomain_${nowt}.txt |grep -w $name |awk '{print $1}'`
sitegroup2=`cat $log/grepdomain_${nowt}.txt |grep -w $name |awk '{print $2}'`
notegm2=`cat $log/grepdomain_${nowt}.txt |grep -w $name |awk '{print $3}'`
noteid2=`cat $log/grepdomain_${nowt}.txt |grep -w $name |awk '{print $4}'`
        if [ "$name" = "$list1check" ]; then
                echo -ne "$name  \033[32m有備註\033[0m $sitegroup2 \033[32m$notegm2\033[0m $noteid2 \n"
                echo -ne "$name  \n" >> $log/list1ok_${now}.txt
        else
                echo -ne "$name \033[31m沒有備註\033[0m\n"
                echo -ne "$name  \n" >> $log/list1error_${nowt}.txt
        fi
done




echo -ne "\033[33m====================\033[0m        done        \033[33m====================\033[0m\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m     沒有備註之網址   若無檔案代表無符合資料  \033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m\n"
cat $log/list1error_${nowt}.txt
echo -ne "\033[33m==========\033[0m LOG請查看 $log/list1error_${now}.txt  \033[33m==========\033[0m\n"
echo -ne "\033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m     沒有備註之網址   若無檔案代表無符合資料  \033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"

