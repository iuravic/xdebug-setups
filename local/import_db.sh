#!/bin/bash

# Global vars.
MYLOCALSITESPATH=/Users/ivanuravic/www
DBNAME=local

# Full bin paths needed when running this inside Local context.
MYSQL_BIN="/Applications/Local.app/Contents/Resources/extraResources/lightning-services/mysql-8.0.16+6/bin/darwin/bin/mysql"
WP_BIN="/Applications/Local.app/Contents/Resources/extraResources/bin/wp-cli/posix/wp"
SED_BIN="/usr/bin/sed"
CAT_BIN="/bin/cat"
RM_BIN="/bin/rm"
CHMOD_BIN="/bin/chmod"
CURL_BIN="/usr/bin/curl"

echo ">>>>>"
echo "Import SQL to local"
echo ">>>>>"
read -p "Site alias (e.g. domain from /Users/ivanuravic/www/domain/app): " ALIAS
read -p "Domain of local site -- leave blank for {ALIAS}.local: " DOMAINLOCAL
if [ -z "$DOMAINLOCAL" ]; then
  DOMAINLOCAL="${ALIAS}.local"
fi
read -p "Path to sql file: " SQL
read -p "Domain used in SQL file (e.g. domain.newspackstaging.com): " DOMAINSQL
read -p "DB_CHARSET used in backup: " DBCHARSET
read -p "All tables in local DB will be deleted. Continue, y/n?: " CONFIRM
if [ 'y' != "$CONFIRM" ]; then
  echo 'Exiting.'
  exit
fi

# Set vars.
TEMPDIR=$(dirname "${SQL}")
PUBLICPATH="${MYLOCALSITESPATH}/${ALIAS}/app/public"

# ===== Import...

echo "Downloading VIP's search-replace-osx to ${TEMPDIR} ..."
eval "${CURL_BIN} -Ls https://github.com/Automattic/go-search-replace/releases/download/0.0.6/go-search-replace_darwin_amd64.gz -o ${TEMPDIR}/sr.gz && /usr/bin/gzip -f -d ${TEMPDIR}/sr.gz && ${CHMOD_BIN} 755 ${TEMPDIR}/sr && /bin/mv ${TEMPDIR}/sr ${TEMPDIR}/search-replace-osx"
SR="${TEMPDIR}/search-replace-osx"

echo "Search-replacing domains in SQL file..."
echo "- from //${DOMAINSQL} to //${DOMAINLOCAL}"
eval "${CAT_BIN} ${SQL} | ${SR} //${DOMAINSQL} //${DOMAINLOCAL} > ${SQL}_REPLACED1"
echo "- from //www.${DOMAINSQL} to //${DOMAINLOCAL}"
eval "${CAT_BIN} ${SQL}_REPLACED1 | ${SR} //www.${DOMAINSQL} //${DOMAINLOCAL} > ${SQL}_REPLACED2"

echo "Deleting all existing DB tables..."
GET_ALL_TABLES_CMD="${MYSQL_BIN} local -e \" SET global group_concat_max_len=15000; SELECT GROUP_CONCAT(table_name) AS statement FROM information_schema.tables WHERE table_schema='${DBNAME}'; \" "
ALL_TABLES_CSV=$(eval "$GET_ALL_TABLES_CMD" | ${SED_BIN} -n '2p')
if [ ! -z "$ALL_TABLES_CSV" ] && [ NULL != "$ALL_TABLES_CSV" ]; then
  ALL_TABLES_CSV_TICKS='`'$(eval "echo $ALL_TABLES_CSV | $SED_BIN 's/,/\\\`,\\\`/g'")'`'
  eval "${MYSQL_BIN} ${DBNAME} -e ' DROP TABLES ${ALL_TABLES_CSV_TICKS}; ' "
fi

echo "Prepend ALLOW_INVALID_DATES to _REPLACED2..."
eval "sed -i '' -e \"1{h;s/.*/SET SQL_MODE='ALLOW_INVALID_DATES';/;p;g;}\" ${SQL}_REPLACED2"

echo "Importing DB..."
eval "${MYSQL_BIN} --default-character-set=${DBCHARSET} ${DBNAME} < ${SQL}_REPLACED2"

eval "${RM_BIN} -rf ${SQL}_REPLACED2 ${SQL}_REPLACED1 ${SR}"
eval "${WP_BIN} --path=${PUBLICPATH} cache flush"

echo "Done, follow ups:"
echo " - setup plugins and themes"
