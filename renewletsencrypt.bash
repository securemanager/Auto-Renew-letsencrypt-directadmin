#!/bin/sh
echo" ______________________________________________________________________________"
echo"/  ____            _       _     ____                                          \"
echo"| / ___|  ___ _ __(_)_ __ | |_  |  _ \ ___ _ __   _____      __                |"
echo"| \___ \ / __| '__| | '_ \| __| | |_) / _ \ '_ \ / _ \ \ /\ / /                |"
echo"|  ___) | (__| |  | | |_) | |_  |  _ <  __/ | | |  __/\ V  V /                 |"
echo"| |____/ \___|_|  |_| .__/ \__| |_| \_\___|_| |_|\___| \_/\_/                  |"
echo"|                   |_|                                                        |"
echo"|  _         _         _____                             _     _____           |"
echo"| | |    ___| |_ ___  | ____|_ __   ___ _ __ _   _ _ __ | |_  |  ___|__  _ __  |"
echo"| | |   / _ \ __/ __| |  _| | '_ \ / __| '__| | | | '_ \| __| | |_ / _ \| '__| |"
echo"| | |__|  __/ |_\__ \ | |___| | | | (__| |  | |_| | |_) | |_  |  _| (_) | |    |"
echo"| |_____\___|\__|___/ |_____|_| |_|\___|_|   \__, | .__/ \__| |_|  \___/|_|    |"
echo"|                                            |___/|_|                          |"
echo"|  ____  _               _            _           _                            |"
echo"| |  _ \(_)_ __ ___  ___| |_ __ _  __| |_ __ ___ (_)_ __                       |"
echo"| | | | | | '__/ _ \/ __| __/ _` |/ _` | '_ ` _ \| | '_ \                      |"
echo"| | |_| | | | |  __/ (__| || (_| | (_| | | | | | | | | | |                     |"
echo"| |____/|_|_|  \___|\___|\__\__,_|\__,_|_| |_| |_|_|_| |_|                     |"
echo"\                                                                              /"
echo" ------------------------------------------------------------------------------"
echo"        \   ^__^"
echo"         \  (oo)\_______"
echo"            (__)\       )\/\"
echo"               ||----w |"
echo"                ||     ||"
echo "

echo "  ____            _       _     _            "
echo " / ___|  ___ _ __(_)_ __ | |_  | |__  _   _  "
echo " \___ \ / __| '__| | '_ \| __| | '_ \| | | | "
echo "  ___) | (__| |  | | |_) | |_  | |_) | |_| | "
echo " |____/ \___|_|  |_| .__/ \__| |_.__/ \__, | "
echo "                  |_|                |___/  "
echo "  ____     _        _     _               ____                           "
echo " / __ \   / \   ___| |__ | | ____ _ _ __ / ___|  ___  ___ _   _ _ __ ___ "
echo "/ / _` | / _ \ / __| '_ \| |/ / _` | '_ \\___ \ / _ \/ __| | | | '__/ _ \"
echo"| | (_| |/ ___ \\__ \ | | |   < (_| | | | |___) |  __/ (__| |_| | | |  __/"
echo "\ \__,_/_/   \_\___/_| |_|_|\_\__,_|_| |_|____/ \___|\___|\__,_|_|  \___|"
echo  "\____/                                                                  "



VERSION=1.3
WELLKNOWN_PATH="/var/www/html/.well-known/acme-challenge"
TIMESTAMP=`date +%s`
CURL=/usr/local/bin/curl
if [ ! -x ${CURL} ]; then
        CURL=/usr/bin/curl
fi

if ! /usr/local/directadmin/directadmin c | grep '^letsencrypt=1$'; then
	exit 1
else
	LETSENCRYPT_LIST_SELECTED="`/usr/local/directadmin/directadmin c | grep '^letsencrypt_list_selected=' | cut -d= -f2 | tr ':' ' '`"
fi

challenge_check() {
        if [ ! -d ${WELLKNOWN_PATH} ]; then
                mkdir -p ${WELLKNOWN_PATH}
        fi
        touch ${WELLKNOWN_PATH}/letsencrypt_${TIMESTAMP}
        #Checking if http://www.domain.com/.well-known/acme-challenge/letsencrypt_${TIMESTAMP} is available
		if ! ${CURL} ${CURL_OPTIONS} -k -I -L -X GET http://${1}/.well-known/acme-challenge/letsencrypt_${TIMESTAMP} 2>/dev/null | grep -m1 -q 'HTTP.*200'; then
                echo 1
        else
                echo 0
        fi
        rm -f ${WELLKNOWN_PATH}/letsencrypt_${TIMESTAMP}
}

for u in `ls /usr/local/directadmin/data/users`; do
{
	  for d in `cat /usr/local/directadmin/data/users/$u/domains.list`; do
	  {
			if [ ! -e /usr/local/directadmin/data/users/$u/domains/$d.cert ] && [ -s /usr/local/directadmin/data/users/$u/domains/$d.conf ]; then
				DOMAIN_LIST="${d}"
				CHALLENGE_TEST=`challenge_check $d`
				if [ ${CHALLENGE_TEST} -ne 1 ]; then
					for A in ${LETSENCRYPT_LIST_SELECTED}; do
					{
						H=${A}.${d}
						CHALLENGE_TEST=`challenge_check ${H}`
						if [ ${CHALLENGE_TEST} -ne 1 ]; then
							DOMAIN_LIST="${DOMAIN_LIST},${H}"
						fi
					};
					done;
					CHALLENGE_TEST=`challenge_check $d`
					if echo "${DOMAIN_LIST}" | grep -m1 -q ','; then
						/usr/local/directadmin/scripts/letsencrypt.sh request ${DOMAIN_LIST} 4096
					else
						/usr/local/directadmin/scripts/letsencrypt.sh request_single ${d} 4096
					fi
				fi
			fi
			if [ -e /usr/local/directadmin/data/users/$u/domains/$d.cert ]; then
				REWRITE=false
				if ! grep -m1 -q '^ssl=ON' /usr/local/directadmin/data/users/$u/domains/$d.conf; then
					perl -pi -e 's|^ssl\=.*|ssl=ON|g' /usr/local/directadmin/data/users/$u/domains/$d.conf								
					REWRITE=true
				fi
				if ! grep -m1 -q '^ssl=ON' /usr/local/directadmin/data/users/$u/domains/$d.conf; then
					echo 'ssl=ON' >> /usr/local/directadmin/data/users/$u/domains/$d.conf
				fi
				if ! grep -m1 -q '^SSLCACertificateFile=' /usr/local/directadmin/data/users/$u/domains/$d.conf && ! grep -m1 -q '^SSLCertificateFile=' /usr/local/directadmin/data/users/$u/domains/$d.conf && ! grep -m1 -q '^SSLCertificateKeyFile=' /usr/local/directadmin/data/users/$u/domains/$d.conf; then
					perl -pi -e "s|^UseCanonicalName=|SSLCACertificateFile=/usr/local/directadmin/data/users/$u/domains/$d.cacert\nSSLCertificateFile=/usr/local/directadmin/data/users/$u/domains/$d.cert\nSSLCertificateKeyFile=/usr/local/directadmin/data/users/$u/domains/$d.key\nUseCanonicalName=|g" /usr/local/directadmin/data/users/$u/domains/$d.conf
					REWRITE=true
				fi
				if ${REWRITE}; then
					echo "action=rewrite&value=httpd&user=$u" >> /usr/local/directadmin/data/task.queue
				fi
			fi
	  }
	  done;
}
done;
exit 0
