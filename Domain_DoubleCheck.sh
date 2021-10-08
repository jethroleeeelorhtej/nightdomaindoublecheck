#!/bin/bash
clear
readonly opApi='Your API'
readonly pdApi='Your API'
readonly now=`date +%Y%m%d_%H%M%S`
readonly yesterday=`date +%Y%m%d --date="-1 day"`
var="Your directory"
log="Your Log directory"

cat $var/dnsdomain.txt |sort |uniq > $log/dnsdomainlist.txt

echo -e "\E[1;5;33m 撈取全域名中．．． \E[0m "
curl -d "Your API參數" -s "${opApi}" > $var/PDNS_All_Domain.txt
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -e "\E[1;5;33m 撈取anti目標域名中．．． \E[0m "
curl "${pdApi}" 2&>1 > $var/antiHijackTargetDomain.txt
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"

# 整理DNS error域名資訊
for domain in `cat $log/dnsdomainlist.txt`; do
    cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$domain\"" |jq -c [.domain_name,.site_group,.status_id,.create_time,.note_gm,.note_id] |sed -e 's/^\[//g;s/\]$//g'|sed 's/^\"//g;s/\"$//g'|awk -F \"\,\" '{print $1, $2, $3, $4, $5, $6}' >> $log/dnsdomainall_${now}.txt
    echo -ne "$domain \033[33m資料撈取完畢\033[0m\n"
done

# 搜尋關鍵字
echo -ne "=================== DNS error Double Check is start ==================\n"
cat $log/dnsdomainall_${now}.txt |grep -w "$yesterday檢查網址DNS劫持" > $log/dnsgrepdomain_${now}.txt

#搜尋關鍵字出來的域名，與DNS error二檢網址清單比對
for dnsname in `cat $log/dnsdomainlist.txt`; do
    listcheck=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |awk '{print $1}'`
    dnssitegroup=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |awk '{print $2}'`
    dnsstatusid=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |awk '{print $3}'`
    dnscreatetime=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |awk '{print $4}'`
    dnsnotegm=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |awk '{print $6}'`
    dnsnoteid=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |awk '{print $7}'`
    timecheck=`date +%s -d "${nowtime}"`
    timecheck2=`date +%s -d "${dnscreatetime}"`
    timecompare=`echo "(${timecheck} - ${timecheck2}) / 86400" |bc`
    dnsantiHijackTarget=`cat $var/antiHijackTargetDomain.txt |grep -w $dnsname`
    dnsantiHijack=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |grep -w "${yesterday}檢查網址DNS劫持\[全域\]" |awk '{print $7}' |grep -w "抗劫持"`
    dnsantiBlockTarget=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |awk '{print $7}' |grep -w "抗封鎖目標網址"`
    dnsantiBlock=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |grep -w "${yesterday}檢查網址DNS劫持\[全域\]" |awk '{print $7}' |grep -w "抗封鎖"`
    if [ "$dnsname" == "$listcheck" ] && [ ${timecompare} -gt "14" ]; then
        echo -ne "$dnssitegroup $dnsname  \033[32mPDNS有備註且網址不是NEW\033[0m $dnsstatusid \033[32m$dnsnotegm\033[0m $dnsnoteid \n"
        echo -ne "$dnssitegroup $dnsname  \n" >> $log/listok_${now}.txt
    elif [ "$dnsname" == "$listcheck" ] && [ ${timecompare} -lt "14" ]; then
        echo -ne "$dnssitegroup $dnsname  \033[34mPDNS有備註但網址為NEW\033[0m $dnsstatusid \033[32m$dnsnotegm\033[0m $dnsnoteid \n"
        echo -ne "$dnssitegroup $dnsname  \n" >> $log/listerror_${now}.txt
    else
        echo -ne "$dnssitegroup $dnsname \033[31mPDNS沒有備註\033[0m\n"
        echo -ne "$dnssitegroup $dnsname  \n" >> $log/listerror_${now}.txt
    fi

    if [ -n "${dnsantiHijackTarget}" ] || [ -n "${dnsantiHijack}" ] || [ -n "${dnsantiBlockTarget}" ] || [ -n "${dnsantiBlock}" ]; then
        echo -ne "$dnssitegroup $dnsname \033[31mDNS error，要撤下相關功能\033[0m\n"
        echo -ne "$dnssitegroup $dnsname \033[31mDNS error，要撤下相關功能\033[0m\n" >> $log/rollback_${now}.txt
    else
        echo -ne "$dnssitegroup $dnsname \n" >> $log/dontrollback_${now}.txt
    fi
done

echo -ne "=================== DNS error Double Check is done ==================\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"

# 整理MB block域名資訊
echo -e "\E[1;5;33m 整理MB block域名資訊中．．． \E[0m "
for MBdomain in `cat $var/MobileBlockdomainlist.txt`; do
    cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$MBdomain\"" |jq -c [.domain_name,.site_group,.status_id,.note_gm,.note_id] |sed -e 's/^\[//g;s/\]$//g'|sed 's/^\"//g;s/\"$//g'|awk -F \"\,\" '{print $1, $2, $3, $4, $5}' >> $log/MBdomainall_${now}.txt
    echo -ne "$MBdomain \033[33m資料撈取完畢\033[0m\n"
done
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"


# 搜尋關鍵字
echo -ne "=================== MB block網址 Double Check is start ==================\n"
cat $log/MBdomainall_${now}.txt |grep -w "$yesterday檢查大陸封鎖" > $log/MBgrepdomain_${now}.txt

#搜尋關鍵字出來的域名，與MB block網址清單比對
for MBname in `cat $var/MobileBlockdomainlist.txt`; do
    MBlistcheck=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $1}'`
    MBsitegroup=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $2}'`
    MBstatusid=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $3}'`
    MBnotegm=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $4}'`
    MBnoteid=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $5}'`
    MBantiHijackTarget=`cat $var/antiHijackTargetDomain.txt |grep -w $MBname`
    MBantiHijack=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $5}' |grep -w "抗劫持"`
    MBantiBlockTarget=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $5}' |grep -w "抗封鎖目標網址"`
    if [ "${MBstatusid}" == "D-移動封鎖自管" ] || [ "${MBstatusid}" == "D-移動封鎖" ] && [ "${MBname}" == "${MBlistcheck}" ]; then
        echo -ne "$MBsitegroup $MBname  \033[32mPDNS狀態已修改\033[0m $MBstatusid \033[32mPDNS備註已加\033[0m $MBnotegm $MBnoteid \n"
        echo -ne "$MBsitegroup $MBname  \n" >> $log/MBlistok_${now}.txt
    else
        echo -ne "$MBsitegroup $MBname \033[31mPDNS沒有改狀態或備註\033[0m\n"
        echo -ne "$MBsitegroup $MBname  \n" >> $log/MBlisterror_${now}.txt
    fi

    if [ -n "${MBantiHijackTarget}" ] || [ -n "${MBantiHijack}" ] || [ -n "${MBantiBlockTarget}" ]; then
        echo -ne "$MBsitegroup $MBname \033[31mMB block，要撤下相關功能\033[0m\n"
        echo -ne "$MBsitegroup $MBname \033[31mMB block，要撤下相關功能\033[0m\n" >> $log/rollback_${now}.txt
    else
        echo -ne "$MBsitegroup $MBname \n" >> $log/dontrollback_${now}.txt
    fi
done

echo -ne "=================== MB block網址 Double Check is done ==================\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"

# 整理NS error域名資訊
echo -e "\E[1;5;33m 整理NS error域名資訊中．．． \E[0m "
for NSdomain in `cat $var/NSerrordomainlist.txt`; do
    cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$NSdomain\"" |jq -c [.domain_name,.site_group,.status_id,.note_gm,.note_id] |sed -e 's/^\[//g;s/\]$//g'|sed 's/^\"//g;s/\"$//g'|awk -F \"\,\" '{print $1, $2, $3, $4, $5}' >> $log/NSdomainall_${now}.txt
    echo -ne "$NSdomain \033[33m資料撈取完畢\033[0m\n"
done
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"

# 搜尋關鍵字
echo -ne "=================== NS error網址 Double Check is start ==================\n"
cat $log/NSdomainall_${now}.txt |grep -w "$yesterday檢查網址上層異常" > $log/NSgrepdomain_${now}.txt

#搜尋關鍵字出來的域名，與NS error網址清單比對
for NSname in `cat $var/NSerrordomainlist.txt`; do
    NSlistcheck=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $1}'`
    NSsitegroup=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $2}'`
    NSstatusid=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $3}'`
    NSnotegm=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $4}'`
    NSnoteid=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $5}'`
    NSantiHijackTarget=`cat $var/antiHijackTargetDomain.txt |grep -w $NSname`
    NSantiHijack=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $5}' |grep -w "抗劫持"`
    NSantiBlockTarget=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $5}' |grep -w "抗封鎖目標網址"`
    NSantiBlock=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $5}' |grep -w "抗封鎖"`
    if [ "${NSstatusid}" == "N-網址上層/解析異常" ] && [ "${NSname}" == "${NSlistcheck}" ]; then
        echo -ne "$NSsitegroup $NSname  \033[32mPDNS狀態已修改\033[0m $NSstatusid \033[32mPDNS備註已加\033[0m $NSnotegm $NSnoteid \n"
        echo -ne "$NSsitegroup $NSname  \n" >> $log/NSlistok_${now}.txt
    else
        echo -ne "$NSsitegroup $NSname \033[31mPDNS沒有改狀態或備註\033[0m\n"
        echo -ne "$NSsitegroup $NSname  \n" >> $log/NSlisterror_${now}.txt
    fi

    if [ -n "${NSantiHijackTarget}" ] || [ -n "${NSantiHijack}" ] || [ -n "${NSantiBlockTarget}" ] || [ -n "${NSantiBlock}" ]; then
        echo -ne "$NSsitegroup $NSname \033[31mNS error，要撤下相關功能\033[0m\n"
        echo -ne "$NSsitegroup $NSname \033[31mNS error，要撤下相關功能\033[0m\n" >> $log/rollback_${now}.txt
    else
        echo -ne "$NSsitegroup $NSname \n" >> $log/dontrollback_${now}.txt
    fi
done

echo -ne "=================== NS error網址 Double Check is done ==================\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"

# 整理ALL block域名資訊
echo -e "\E[1;5;33m 整理ALL block域名資訊中．．． \E[0m "
for ALLdomain in `cat $var/AllBlockdomainlist.txt`; do
    cat $var/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$ALLdomain\"" |jq -c [.domain_name,.site_group,.status_id,.note_gm,.note_id] |sed -e 's/^\[//g;s/\]$//g'|sed 's/^\"//g;s/\"$//g'|awk -F \"\,\" '{print $1, $2, $3, $4, $5}' >> $log/ALLdomainall_${now}.txt
    echo -ne "$ALLdomain \033[33m資料撈取完畢\033[0m\n"
done
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"

# 搜尋關鍵字
echo -ne "=================== ALL block網址 Double Check is start ==================\n"
cat $log/ALLdomainall_${now}.txt |grep -w "$yesterday檢查大陸封鎖" > $log/ALLgrepdomain_${now}.txt

#搜尋關鍵字出來的域名，與上層異常二檢網址清單比對
for ALLname in `cat $var/AllBlockdomainlist.txt`; do
    ALLlistcheck=`cat $log/ALLgrepdomain_${now}.txt |grep -w $ALLname |awk '{print $1}'`
    ALLsitegroup=`cat $log/ALLgrepdomain_${now}.txt |grep -w $ALLname |awk '{print $2}'`
    ALLstatusid=`cat $log/ALLgrepdomain_${now}.txt |grep -w $ALLname |awk '{print $3}'`
    ALLnotegm=`cat $log/ALLgrepdomain_${now}.txt |grep -w $ALLname |awk '{print $4}'`
    ALLnoteid=`cat $log/ALLgrepdomain_${now}.txt |grep -w $ALLname |awk '{print $5}'`
    ALLantiHijackTarget=`cat $var/antiHijackTargetDomain.txt |grep -w $ALLname`
    ALLantiHijack=`cat $log/ALLgrepdomain_${now}.txt |grep -w $ALLname |awk '{print $5}' |grep -w "抗劫持"`
    ALLantiBlockTarget=`cat $log/ALLgrepdomain_${now}.txt |grep -w $ALLname |awk '{print $5}' |grep -w "抗封鎖目標網址"`
    if [ "${ALLstatusid}" == "D-封鎖自管" ] || [ "${ALLstatusid}" == "D-封鎖" ] && [ "${ALLname}" == "${ALLlistcheck}" ]; then
        echo -ne "$ALLsitegroup $ALLname  \033[32mPDNS狀態已修改\033[0m $ALLstatusid \033[32mPDNS備註已加\033[0m $ALLnotegm $ALLnoteid \n"
        echo -ne "$ALLsitegroup $ALLname  \n" >> $log/ALLlistok_${now}.txt
    else
        echo -ne "$ALLsitegroup $ALLname \033[31mPDNS沒有改狀態或備註\033[0m\n"
        echo -ne "$ALLsitegroup $ALLname  \n" >> $log/ALLlisterror_${now}.txt
    fi

    if [ -n "${ALLantiHijackTarget}" ] || [ -n "${ALLantiHijack}" ] || [ -n "${ALLantiBlockTarget}" ]; then
        echo -ne "$ALLsitegroup $ALLname \033[31m網址為全域封鎖，要撤下抗劫持抗封鎖相關功能\033[0m\n"
        echo -ne "$ALLsitegroup $ALLname \033[31m網址為全域封鎖，要撤下抗劫持抗封鎖相關功能\033[0m\n" >> $log/rollback_${now}.txt
    else
        echo -ne "$ALLsitegroup $ALLname \n" >> $log/dontrollback_${now}.txt
    fi
done

echo -ne "=================== ALL block網址 Double Check is done ==================\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"





echo -ne "\033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m  DNS error檢查清單，PDNS沒有備註或是網址為NEW   若無檔案代表皆正常     \033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m\n"
cat $log/listerror_${now}.txt
echo -ne "\033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m  DNS error檢查清單，PDNS沒有備註或是網址為NEW   若無檔案代表皆正常     \033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m  MB block網址檢查清單，PDNS沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m\n"
cat $log/MBlisterror_${now}.txt
echo -ne "\033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m  MB block網址檢查清單，PDNS沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m  NS error網址檢查清單，PDNS沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m\n"
cat $log/NSlisterror_${now}.txt
echo -ne "\033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m  NS error網址檢查清單，PDNS沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m  ALL block網址檢查清單，PDNS沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m\n"
cat $log/ALLlisterror_${now}.txt
echo -ne "\033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m  ALL block網址檢查清單，PDNS沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m  需撤下相關功能 之網址  若無檔案代表皆正常  \033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m\n"
cat $log/rollback_${now}.txt
echo -ne "\033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m  需撤下相關功能 之網址  若無檔案代表皆正常  \033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\033[33m==========\033[0m DNS error網址PDNS沒備註或是網址為NEW清單請查看 $log/listerror_${now}.txt  若無檔案代表皆正常  \033[33m==========\033[0m\n"
echo -ne "\033[33m==========\033[0m MB block網址PDNS沒改狀態或備註清單請查看 $log/MBlisterror_${now}.txt  若無檔案代表皆正常  \033[33m==========\033[0m\n"
echo -ne "\033[33m==========\033[0m NS error網址PDNS沒改狀態或備註清單請查看 $log/NSlisterror_${now}.txt  若無檔案代表皆正常  \033[33m==========\033[0m\n"
echo -ne "\033[33m==========\033[0m ALL block網址PDNS沒改狀態或備註清單請查看 $log/ALLlisterror_${now}.txt  若無檔案代表皆正常  \033[33m==========\033[0m\n"
echo -ne "\033[33m==========\033[0m 需撤相關功能清單請查看 $log/rollback_${now}.txt  若無檔案代表皆正常  \033[33m==========\033[0m\n"
