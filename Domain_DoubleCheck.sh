#!/bin/bash
clear
readonly opApi='Your API'
readonly prdApi='Your API'
readonly now=`date +%Y%m%d_%H%M%S`
readonly nowtime=`date +%Y-%m-%d\ %H:%M:%S`
readonly yesterday=`date +%Y%m%d --date="-1 day"`
var="Your directory"
data="Your directory"
log="Your Log directory"

cat $var/DNSerrordomainlist.txt |sort |uniq > $log/dnsdomainlist.txt

echo -e "\E[1;5;33m 撈取全域名中．．． \E[0m "
curl -d "Your API參數" -s "${opApi}" > $var/PDNS_All_Domain.txt
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -e "\E[1;5;33m 撈取anti目標域名中．．． \E[0m "
curl "${prdApi}" 2&>1 > $var/antiHijackTargetDomain.txt
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo "##############################"
read -p "輸入要搜尋備註中寫的日期(例如20211006) ：" wordkey
echo -ne "\n"
echo -ne "\n"

# 整理DNS error域名資訊
echo -e "\E[1;5;33m 整理DNS error域名資訊中．．． \E[0m "
for domain in `cat $log/dnsdomainlist.txt`; do
    #cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$domain\"" |jq -c [.domain_name,.site_group,.status_id,.status_ids,.create_time,.note_gm,.note_id] |sed -e 's/^\[//g;s/\]$//g'|sed 's/^\"//g;s/\"$//g'|awk -F \"\,\" '{print $1, $2, $3, $4, $5, $6, $7}' >> $log/dnsdomainall_${now}.txt
    dnssitegroup2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$domain\"" |jq -c [.site_group] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    dnsstatusid2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$domain\"" |jq -c [.status_id] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    dnsstatusids2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$domain\"" |jq -c [.status_ids] | sed -e 's/^\[//g;s/\]$//g' | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    dnscreatetime2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$domain\"" |jq -c [.create_time] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    dnsnotegm2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$domain\"" |jq -c [.note_gm] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    dnsnoteid2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$domain\"" |jq -c [.note_id] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    echo -ne " $domain $dnssitegroup2 $dnsstatusid2 $dnsstatusids2 $dnscreatetime2 $dnsnotegm2 $dnsnoteid2 \n" >> $log/dnsdomainall_${now}.txt
    echo -ne "$domain \033[33m資料撈取完畢\033[0m\n"
done
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"


# 搜尋關鍵字
echo -ne "=================== DNS error Double Check is start ==================\n"
cat $log/dnsdomainall_${now}.txt |grep -w "$wordkey檢查網址DNS劫持" > $log/dnsgrepdomain_${now}.txt

#搜尋關鍵字出來的域名，與DNS error二檢網址清單比對
for dnsname in `cat $log/dnsdomainlist.txt`; do
    listcheck=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |awk '{print $1}'`
    dnssitegroup=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |awk '{print $2}'`
    dnsstatusid=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |awk '{print $3}'`
    dnsstatusids=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |awk '{print $4}'`
    dnscreatetime=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$domain\"" |jq -c [.create_time] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    dnsnotegm=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$dnsname\"" |jq -c [.note_gm] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    dnsnoteid=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$dnsname\"" |jq -c [.note_id] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    timecheck=`date +%s -d "${nowtime}"`
    timecheck2=`date +%s -d "${dnscreatetime}"`
    timecompare=`echo "(${timecheck} - ${timecheck2}) / 86400" |bc`
    dnsantiHijackTarget=`cat $data/antiHijackTargetDomain.txt |grep -w $dnsname`
    dnsantiHijack=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |grep -w "${wordkey}檢查網址DNS劫持\[全域\]" |awk '{print $8}' |grep -w "抗劫持"`
    dnsantiBlockTarget=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |awk '{print $7}' |grep -w "抗封鎖目標網址"`
    dnsantiBlock=`cat $log/dnsgrepdomain_${now}.txt |grep -w $dnsname |grep -w "${wordkey}檢查網址DNS劫持\[全域\]" |awk '{print $8}' |grep -w "抗封鎖"`
    if [ "$dnsname" == "$listcheck" ] && [ ${timecompare} -gt "14" ]; then
        echo -ne "$dnssitegroup $dnsname  \033[32mPDNS有備註且網址不是NEW\033[0m $dnsstatusids \033[32m$dnsnotegm\033[0m $dnsnoteid \n"
        echo -ne "$dnssitegroup $dnsname  \n" >> $log/listok_${now}.txt
    elif [ "$dnsname" == "$listcheck" ] && [ ${timecompare} -lt "14" ]; then
        echo -ne "$dnssitegroup $dnsname  \033[34mPDNS有備註但網址為NEW\033[0m $dnsstatusids \033[32m$dnsnotegm\033[0m $dnsnoteid \n"
        echo -ne "$dnssitegroup $dnsname  \n" >> $log/listerror_${now}.txt
    else
        echo -ne "$dnssitegroup $dnsname \033[31mPDNS沒有備註\033[0m\n"
        echo -ne "$dnssitegroup $dnsname  \n" >> $log/listerror_${now}.txt
    fi

    if [ -n "${dnsantiHijackTarget}" ] || [ -n "${dnsantiHijack}" ] || [ -n "${dnsantiBlockTarget}" ] || [ -n "${dnsantiBlock}" ]; then
        echo -ne "$dnssitegroup $dnsname \033[31m網址為DNS劫持，要撤下抗劫持抗封鎖相關功能\033[0m\n"
        echo -ne "$dnssitegroup $dnsname \033[31m網址為DNS劫持，要撤下抗劫持抗封鎖相關功能\033[0m\n" >> $log/rollback_${now}.txt
    else
        echo -ne "$dnssitegroup $dnsname \n" >> $log/dontrollback_${now}.txt
    fi
done

echo -ne "=================== DNS error Double Check is done ==================\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"

# 整理MB block域名資訊
echo -e "\E[1;5;33m 整理MB Block域名資訊中．．． \E[0m "
for MBdomain in `cat $var/MobileBlockdomainlist.txt`; do
    #cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$MBdomain\"" |jq -c [.domain_name,.site_group,.status_id,.status_ids,.note_gm,.note_id] |sed -e 's/^\[//g;s/\]$//g'|sed 's/^\"//g;s/\"$//g'|awk -F \"\,\" '{print $1, $2, $3, $4, $5, $6}' >> $log/MBdomainall_${now}.txt
    MBsitegroup2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$MBdomain\"" |jq -c [.site_group] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    MBstatusid2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$MBdomain\"" |jq -c [.status_id] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    MBstatusids2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$MBdomain\"" |jq -c [.status_ids] | sed -e 's/^\[//g;s/\]$//g' | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    MBnotegm2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$MBdomain\"" |jq -c [.note_gm] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    MBnoteid2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$MBdomain\"" |jq -c [.note_id] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    echo -ne "$MBdomain $MBsitegroup2 $MBstatusid2 $MBstatusids2 $MBnotegm2 $MBnoteid2  \n" >> $log/MBdomainall_${now}.txt
    echo -ne "$MBdomain \033[33m資料撈取完畢\033[0m\n"
done
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"


# 搜尋關鍵字
echo -ne "=================== MB block網址 Double Check is start ==================\n"
cat $log/MBdomainall_${now}.txt |grep -w "$wordkey檢查大陸封鎖" > $log/MBgrepdomain_${now}.txt

#搜尋關鍵字出來的域名，與MB block網址清單比對
for MBname in `cat $var/MobileBlockdomainlist.txt`; do
    MBlistcheck=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $1}'`
    MBsitegroup=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $2}'`
    MBstatusid=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $3}'`
    MBstatusidscheck=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $4}' |grep -w "移動封鎖"`
    MBnotegm=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$MBname\"" |jq -c [.note_gm] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    MBnoteid=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$MBname\"" |jq -c [.note_id] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    MBantiHijackTarget=`cat $data/antiHijackTargetDomain.txt |grep -w $MBname`
    MBantiHijack=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $6}' |grep -w "抗劫持"`
    MBantiBlockTarget=`cat $log/MBgrepdomain_${now}.txt |grep -w $MBname |awk '{print $6}' |grep -w "抗封鎖目標網址"`
    if [ -n "${MBstatusidscheck}" ] && [ "${MBname}" == "${MBlistcheck}" ]; then
        echo -ne "$MBsitegroup $MBname  \033[32mPDNS狀態已修改\033[0m $MBstatusids \033[32mPDNS備註已加\033[0m $MBnotegm $MBnoteid \n"
        echo -ne "$MBsitegroup $MBname  \n" >> $log/MBlistok_${now}.txt
    else
        echo -ne "$MBsitegroup $MBname \033[31mPDNS沒有改狀態或備註\033[0m\n"
        echo -ne "$MBsitegroup $MBname  \n" >> $log/MBlisterror_${now}.txt
    fi

    if [ -n "${MBantiHijackTarget}" ] || [ -n "${MBantiHijack}" ] || [ -n "${MBantiBlockTarget}" ]; then
        echo -ne "$MBsitegroup $MBname \033[31m網址為移動封鎖，要撤下抗劫持抗封鎖相關功能\033[0m\n"
        echo -ne "$MBsitegroup $MBname \033[31m網址為移動封鎖，要撤下抗劫持抗封鎖相關功能\033[0m\n" >> $log/rollback_${now}.txt
    else
        echo -ne "$MBsitegroup $MBname \n" >> $log/dontrollback_${now}.txt
    fi
done

echo -ne "=================== MB block網址 Double Check is done ==================\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"

# 整理江蘇封鎖域名資訊
echo -e "\E[1;5;33m 整理江蘇封鎖域名資訊中．．． \E[0m "
for JSdomain in `cat $var/JiangsuBlockdomainlist.txt`; do
    #cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$JSdomain\"" |jq -c [.domain_name,.site_group,.status_id,.status_ids,.note_gm,.note_id] |sed -e 's/^\[//g;s/\]$//g'|sed 's/^\"//g;s/\"$//g'|awk -F \"\,\" '{print $1, $2, $3, $4, $5, $6}' >> $log/JSdomainall_${now}.txt
    JSsitegroup2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$JSdomain\"" |jq -c [.site_group] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    JSstatusid2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$JSdomain\"" |jq -c [.status_id] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    JSstatusids2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$JSdomain\"" |jq -c [.status_ids] | sed -e 's/^\[//g;s/\]$//g' | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    JSnotegm2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$JSdomain\"" |jq -c [.note_gm] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    JSnoteid2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$JSdomain\"" |jq -c [.note_id] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    echo -ne "$JSdomain $JSsitegroup2 $JSstatusid2 $JSstatusids2 $JSnotegm2 $JSnoteid2  \n" >> $log/JSdomainall_${now}.txt
    echo -ne "$JSdomain \033[33m資料撈取完畢\033[0m\n"
done
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"

# 搜尋關鍵字
echo -ne "=================== JS封鎖網址 Double Check is start ==================\n"
cat $log/JSdomainall_${now}.txt |grep -w "$wordkey檢查網址http劫持\[江蘇\]" > $log/JSgrepdomain_${now}.txt

#搜尋關鍵字出來的域名，與JS二檢網址清單比對
for JSname in `cat $var/JiangsuBlockdomainlist.txt`; do
    JSlistcheck=`cat $log/JSgrepdomain_${now}.txt |grep -w $JSname |awk '{print $1}'`
    JSsitegroup=`cat $log/JSgrepdomain_${now}.txt |grep -w $JSname |awk '{print $2}'`
    JSstatusid=`cat $log/JSgrepdomain_${now}.txt |grep -w $JSname |awk '{print $3}'`
    JSstatusids=`cat $log/JSgrepdomain_${now}.txt |grep -w $JSname |awk '{print $4}'`
    JSnotegm=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$JSname\"" |jq -c [.note_gm] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    JSnoteid=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$JSname\"" |jq -c [.note_id] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    JSantiHijackTarget=`cat $data/antiHijackTargetDomain.txt |grep -w $JSname`
    JKantiBlockTarget=`cat $log/JSgrepdomain_${now}.txt |grep -w $JSname |awk '{print $6}' |grep -w "抗封鎖目標網址"`
    if [ "${JSname}" == "${JSlistcheck}" ]; then
        echo -ne "$JSsitegroup $JSname  \033[32mPDNS有備註備註\033[0m $JSnotegm $JSnoteid \n"
        echo -ne "$JSsitegroup $JSname  \n" >> $log/JSlistok_${now}.txt
    else
        echo -ne "$JSsitegroup $JSname \033[31mPDNS沒有加備註\033[0m\n"
        echo -ne "$JSsitegroup $JSname  \n" >> $log/JSlisterror_${now}.txt
    fi

    if [ -n "${JSantiHijackTarget}" ] || [ -n "${JSantiBlockTarget}" ]; then
        echo -ne "$JSsitegroup $JSname \033[31m網址為JS異常，要撤下抗劫持抗封鎖相關功能\033[0m\n"
        echo -ne "$JSsitegroup $JSname \033[31m網址為JS異常，要撤下抗劫持抗封鎖相關功能\033[0m\n" >> $log/rollback_${now}.txt
    else
        echo -ne "$JSsitegroup $JSname \n" >> $log/dontrollback_${now}.txt
    fi
done

echo -ne "=================== JS異常網址 Double Check is done ==================\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"

# 整理NS error域名資訊
echo -e "\E[1;5;33m 整理NS error域名資訊中．．． \E[0m "
for NSdomain in `cat $var/NSerrordomainlist.txt`; do
    #cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$NSdomain\"" |jq -c [.domain_name,.site_group,.status_id,.status_ids,.note_gm,.note_id] |sed -e 's/^\[//g;s/\]$//g'|sed 's/^\"//g;s/\"$//g'|awk -F \"\,\" '{print $1, $2, $3, $4, $5, $6}' >> $log/NSdomainall_${now}.txt
    NSsitegroup2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$NSdomain\"" |jq -c [.site_group] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    NSstatusid2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$NSdomain\"" |jq -c [.status_id] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    NSstatusids2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$NSdomain\"" |jq -c [.status_ids] | sed -e 's/^\[//g;s/\]$//g' | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    NSnotegm2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$NSdomain\"" |jq -c [.note_gm] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    NSnoteid2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$NSdomain\"" |jq -c [.note_id] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    echo -ne "$NSdomain $NSsitegroup2 $NSstatusid2 $NSstatusids2 $NSnotegm2 $NSnoteid2  \n" >> $log/NSdomainall_${now}.txt
    echo -ne "$NSdomain \033[33m資料撈取完畢\033[0m\n"
done
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"

# 搜尋關鍵字
echo -ne "=================== NS error網址 Double Check is start ==================\n"
cat $log/NSdomainall_${now}.txt |grep -w "$wordkey檢查網址上層異常" > $log/NSgrepdomain_${now}.txt

#搜尋關鍵字出來的域名，與NS error二檢網址清單比對
for NSname in `cat $var/NSerrordomainlist.txt`; do
    NSlistcheck=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $1}'`
    NSsitegroup=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $2}'`
    NSstatusid=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $3}'`
    NSstatusids=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |awk '{print $4}'`
    NSnotegm=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$NSname\"" |jq -c [.note_gm] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    NSnoteid=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$NSname\"" |jq -c [.note_id] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    NSnoteidcheck=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |grep -w "網址上層異常"`
    NSantiHijackTarget=`cat $data/antiHijackTargetDomain.txt |grep -w $NSname`
    NSantiHijack=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |grep -w "抗劫持"`
    NSantiBlockTarget=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |grep -w "抗封鎖目標網址"`
    NSantiBlock=`cat $log/NSgrepdomain_${now}.txt |grep -w $NSname |grep -w "抗封鎖"`
    if [ -n "${NSnoteidcheck}" ] && [ "${NSname}" == "${NSlistcheck}" ]; then
        echo -ne "$NSsitegroup $NSname  \033[32m網址上層常TAG已新增\033[0m $NSnoteid \033[32mPDNS備註已加\033[0m $NSnotegm \n"
        echo -ne "$NSsitegroup $NSname  \n" >> $log/NSlistok_${now}.txt
    else
        echo -ne "$NSsitegroup $NSname \033[31mPDNS沒有改TAG或備註\033[0m\n"
        echo -ne "$NSsitegroup $NSname  \n" >> $log/NSlisterror_${now}.txt
    fi

    if [ -n "${NSantiHijackTarget}" ] || [ -n "${NSantiHijack}" ] || [ -n "${NSantiBlockTarget}" ] || [ -n "${NSantiBlock}" ]; then
        echo -ne "$NSsitegroup $NSname \033[31m網址為上層異常，要撤下抗劫持抗封鎖相關功能\033[0m\n"
        echo -ne "$NSsitegroup $NSname \033[31m網址為上層異常，要撤下抗劫持抗封鎖相關功能\033[0m\n" >> $log/rollback_${now}.txt
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
echo -e "\E[1;5;33m 整理ALL Block域名資訊中．．． \E[0m "
for ALLdomain in `cat $var/AllBlockdomainlist.txt`; do
    #cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$ALLdomain\"" |jq -c [.domain_name,.site_group,.status_id,.status_ids,.note_gm,.note_id] |sed -e 's/^\[//g;s/\]$//g'|sed 's/^\"//g;s/\"$//g'|awk -F \"\,\" '{print $1, $2, $3, $4, $5, $6}' >> $log/ALLdomainall_${now}.txt
    ALLsitegroup2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$ALLdomain\"" |jq -c [.site_group] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    ALLstatusid2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$ALLdomain\"" |jq -c [.status_id] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    ALLstatusids2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$ALLdomain\"" |jq -c [.status_ids] | sed -e 's/^\[//g;s/\]$//g' | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    ALLnotegm2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$ALLdomain\"" |jq -c [.note_gm] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    ALLnoteid2=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$ALLdomain\"" |jq -c [.note_id] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    echo -ne "$ALLdomain $ALLsitegroup2 $ALLstatusid2 $ALLstatusids2 $ALLnotegm2 $ALLnoteid2  \n" >> $log/ALLdomainall_${now}.txt
    echo -ne "$ALLdomain \033[33m資料撈取完畢\033[0m\n"
done
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"

# 搜尋關鍵字
echo -ne "=================== ALL block網址 Double Check is start ==================\n"
cat $log/ALLdomainall_${now}.txt |grep -w "$wordkey檢查大陸封鎖" > $log/ALLgrepdomain_${now}.txt

#搜尋關鍵字出來的域名，與ALL Block二檢網址清單比對
for ALLname in `cat $var/AllBlockdomainlist.txt`; do
    ALLlistcheck=`cat $log/ALLgrepdomain_${now}.txt |grep -w $ALLname |awk '{print $1}'`
    ALLsitegroup=`cat $log/ALLgrepdomain_${now}.txt |grep -w $ALLname |awk '{print $2}'`
    ALLstatusid=`cat $log/ALLgrepdomain_${now}.txt |grep -w $ALLname |awk '{print $3}'`
    ALLstatusids=`cat $log/ALLgrepdomain_${now}.txt |grep -w $ALLname |awk '{print $4}'`
    ALLstatusidscheck=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$ALLname\"" |jq -c [.status_ids] | sed -e 's/^\[//g;s/\]$//g' | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g' |grep -w "封鎖"`
    ALLnotegm=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$ALLname\"" |jq -c [.note_gm] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    ALLnoteid=`cat $data/PDNS_All_Domain.txt |grep -w "\"domain_name\":\"$ALLname\"" |jq -c [.note_id] | sed -e 's/^\[//g;s/\]$//g' | sed 's/^\"//g;s/\"$//g'`
    ALLantiHijackTarget=`cat $data/antiHijackTargetDomain.txt |grep -w $ALLname`
    ALLantiHijack=`cat $log/ALLgrepdomain_${now}.txt |grep -w $ALLname |awk '{print $6}' |grep -w "抗劫持"`
    ALLantiBlockTarget=`cat $log/ALLgrepdomain_${now}.txt |grep -w $ALLname |awk '{print $6}' |grep -w "抗封鎖目標網址"`
    if [ -n "${ALLstatusidscheck}" ] && [ "${ALLname}" == "${ALLlistcheck}" ]; then
        echo -ne "$ALLsitegroup $ALLname  \033[32mPDNS狀態已修改\033[0m $ALLstatusids \033[32mPDNS備註已加\033[0m $ALLnotegm $ALLnoteid \n"
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


echo -ne "\033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m  DNS error網址檢查清單，PDNS沒有備註或是網址為NEW   若無檔案代表皆正常     \033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m\n"
cat $log/listerror_${now}.txt
echo -ne "\033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m  DNS error網址檢查清單，PDNS沒有備註或是網址為NEW   若無檔案代表皆正常     \033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m  MB Block網址檢查清單，PDNS沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m\n"
cat $log/MBlisterror_${now}.txt
echo -ne "\033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m  MB Block網址檢查清單，PDNS沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m  JS檢查清單，PDNS沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m\n"
cat $log/JSlisterror_${now}.txt
echo -ne "\033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m  JS檢查清單，PDNS沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m\n"
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
echo -ne "\033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m  ALL Block網址檢查清單，PDNS沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m\n"
cat $log/ALLlisterror_${now}.txt
echo -ne "\033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m  ALL Block網址檢查清單，PDNS沒改狀態或備註之網址   若無檔案代表皆正常  \033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m  需撤下抗劫持目標 or 抗劫持 or 抗封鎖目標 or 抗封鎖 之網址  若無檔案代表皆正常  \033[33m↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓\033[0m\n"
cat $log/rollback_${now}.txt
echo -ne "\033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m  需撤下抗劫持目標 or 抗劫持 or 抗封鎖目標 or 抗封鎖 之網址  若無檔案代表皆正常  \033[33m↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑\033[0m\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\n"
echo -ne "\033[33m==========\033[0m DNS error網址PDNS沒備註或是網址為NEW清單請查看 $log/listerror_${now}.txt  若無檔案代表皆正常  \033[33m==========\033[0m\n"
echo -ne "\033[33m==========\033[0m MB Block網址PDNS沒改狀態或備註清單請查看 $log/MBlisterror_${now}.txt  若無檔案代表皆正常  \033[33m==========\033[0m\n"
echo -ne "\033[33m==========\033[0m JS移動網址PDNS沒改備註清單請查看 $log/JSlisterror_${now}.txt  若無檔案代表皆正常  \033[33m==========\033[0m\n"
echo -ne "\033[33m==========\033[0m NS error網址PDNS沒改TAG或備註清單請查看 $log/NSlisterror_${now}.txt  若無檔案代表皆正常  \033[33m==========\033[0m\n"
echo -ne "\033[33m==========\033[0m ALL Block網址PDNS沒改狀態或備註清單請查看 $log/ALLlisterror_${now}.txt  若無檔案代表皆正常  \033[33m==========\033[0m\n"
echo -ne "\033[33m==========\033[0m 需撤下抗劫持抗封鎖相關功能清單請查看 $log/rollback_${now}.txt  若無檔案代表皆正常  \033[33m==========\033[0m\n"

