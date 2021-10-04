#!/bin/bash
clear
readonly opApi='Your API'
readonly now=`date +%Y%m%d_%H%M%S`
readonly yesterday=`date +%Y%m%d --date="-1 day"`
var="Your directory"
log="Your Log directory"

cat $var/dnsdomain.txt |sort |uniq > $log/dnsdomainlist.txt

echo -e "\E[1;5;33m 撈取全P域名中．．． \E[0m "
curl -d "Your API參數" -s "${opApi}" > $var/PDNS_All_Domain.txt

# 整理DNS error域名資訊
for domain in `cat $log/dnsdomainlist.txt`; do
    sitegroup=`cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$domain\"" |jq -r .site_group`
    notegm=`cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$domain\"" |jq -r .note_gm`
    noteid=`cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$domain\"" |jq -r .note_id`
    echo -ne "$domain \033[33m資料撈取完畢\033[0m\n"
    echo -ne "$domain $sitegroup $notegm $noteid \n" >> $log/dnsdomainall_${now}.txt
done

# 搜尋關鍵字
echo -ne "=================== DNS error Double Check is start ==================\n"
cat $log/dnsdomainall_${now}.txt |grep -w "$yesterday檢查網址DNS劫持" > $log/dnsgrepdomain_${now}.txt

#搜尋關鍵字出來的域名，與DNS error二檢網址清單比對
for name in `cat $log/dnsdomainlist.txt`; do
    listcheck=`cat $log/dnsgrepdomain_${now}.txt |grep -w $name |awk '{print $1}'`
    sitegroup2=`cat $log/dnsgrepdomain_${now}.txt |grep -w $name |awk '{print $2}'`
    notegm2=`cat $log/dnsgrepdomain_${now}.txt |grep -w $name |awk '{print $3}'`
    noteid2=`cat $log/dnsgrepdomain_${now}.txt |grep -w $name |awk '{print $4}'`
    if [ "$name" == "$listcheck" ]; then
        echo -ne "$name  \033[32m有備註\033[0m $sitegroup2 \033[32m$notegm2\033[0m $noteid2 \n"
        echo -ne "$name  \n" >> $log/listok_${now}.txt
    else
        echo -ne "$name \033[31m沒有備註\033[0m\n"
        echo -ne "$name  \n" >> $log/listerror_${now}.txt
    fi
done

echo -ne "=================== DNS error Double Check is done ==================\n"

# 整理MB block域名資訊
for MBdomain in `cat $var/MobileBlockdomainlist.txt`; do
    MBsitegroup=`cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$MBdomain\"" |jq -r .site_group`
    MBstatusid=`cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$MBdomain\"" |jq -r .status_id`
    MBnotegm=`cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$MBdomain\"" |jq -r .note_gm`
    MBnoteid=`cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$MBdomain\"" |jq -r .note_id`
    echo -ne "$MBdomain \033[33m資料撈取完畢\033[0m\n"
    echo -ne "$MBdomain $MBsitegroup $MBstatusid $MBnotegm $MBnoteid \n" >> $log/MBdomainall_${now}.txt
done

# 搜尋關鍵字
echo -ne "=================== MB block網址 Double Check is start ==================\n"
cat $log/MBdomainall_${now}.txt |grep -w "$yesterday檢查大陸封鎖" > $log/MBgrepdomain_${now}.txt

#搜尋關鍵字出來的域名，與MB block網址清單比對
for MBname in `cat $var/MobileBlockdomainlist.txt`; do
    MBlistcheck=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $1}'`
    MBsitegroup2=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $2}'`
    MBstatusid2=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $3}'`
    MBnotegm2=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $4}'`
    MBnoteid2=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $5}'`
    if [ "${MBstatusid2}" == "D-移動封鎖自管" ] || [ "${MBstatusid2}" == "D-移動封鎖" ] && [ "${MBname}" == "${MBlistcheck}" ]; then
        echo -ne "$MBname  \033[32m狀態已修改\033[0m $MBstatusid2 $MBsitegroup2 \033[32m備註已加\033[0m $MBnotegm2 $MBnoteid2 \n"
        echo -ne "$MBname  \n" >> $log/MBlistok_${now}.txt
    else
        echo -ne "$MBname \033[31m沒有改狀態或備註\033[0m\n"
        echo -ne "$MBname  \n" >> $log/MBlisterror_${now}.txt
    fi
done

echo -ne "=================== MB block網址 Double Check is done ==================\n"


# 整理NS error域名資訊
for NSdomain in `cat $var/NSerrordomainlist.txt`; do
    NSsitegroup=`cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$NSdomain\"" |jq -r .site_group`
    NSstatusid=`cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$NSdomain\"" |jq -r .status_id`
    NSnotegm=`cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$NSdomain\"" |jq -r .note_gm`
    NSnoteid=`cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$NSdomain\"" |jq -r .note_id`
    echo -ne "$NSdomain \033[33m資料撈取完畢\033[0m\n"
    echo -ne "$NSdomain $NSsitegroup $NSstatusid $NSnotegm $NSnoteid \n" >> $log/NSdomainall_${now}.txt
done

# 搜尋關鍵字
echo -ne "=================== NS error網址 Double Check is start ==================\n"
cat $log/NSdomainall_${now}.txt |grep -w "$yesterday檢查網址上層異常" > $log/NSgrepdomain_${now}.txt

#搜尋關鍵字出來的域名，與NS error網址清單比對
for NSname in `cat $var/NSerrordomainlist.txt`; do
    NSlistcheck=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $1}'`
    NSsitegroup2=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $2}'`
    NSstatusid2=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $3}'`
    NSnotegm2=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $4}'`
    NSnoteid2=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $5}'`
    if [ "${NSstatusid2}" == "N-網址上層/解析異常" ] && [ "${NSname}" == "${NSlistcheck}" ]; then
        echo -ne "$NSname  \033[32m狀態已修改\033[0m $NSstatusid2 $NSsitegroup2 \033[32m備註已加\033[0m $NSnotegm2 $NSnoteid2 \n"
        echo -ne "$NSname  \n" >> $log/NSlistok_${now}.txt
    else
        echo -ne "$NSname \033[31m沒有改狀態或備註\033[0m\n"
        echo -ne "$NSname  \n" >> $log/NSlisterror_${now}.txt
    fi
done

echo -ne "=================== NS error網址 Double Check is done ==================\n"






echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m  DNS error沒有備註之網址   若無檔案代表皆正常     \033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m\n"
cat $log/listerror_${now}.txt
echo -ne "\033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m  DNS error沒有備註之網址   若無檔案代表皆正常     \033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m  MB block沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m\n"
cat $log/MBlisterror_${now}.txt
echo -ne "\033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m  MB block沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m  NS error沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m\n"
cat $log/NSlisterror_${now}.txt
echo -ne "\033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m  NS error沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\033[33m==========\033[0m DNS error沒備註清單請查看 $log/listerror_${now}.txt             若無檔案代表皆正常  \033[33m==========\033[0m\n"
echo -ne "\033[33m==========\033[0m MB block沒改狀態或備註清單請查看 $log/MBlisterror_${now}.txt  若無檔案代表皆正常  \033[33m==========\033[0m\n"
echo -ne "\033[33m==========\033[0m NS error沒改狀態或備註清單請查看 $log/NSlisterror_${now}.txt  若無檔案代表皆正常  \033[33m==========\033[0m\n"

