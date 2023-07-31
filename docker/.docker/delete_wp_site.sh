#!/bin/bash

echo '-- Delete WP site, run from local ---'
read -p "delete WP site domain: " DOMAIN
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# ###

# rm ssl
SSL_DIR="$SCRIPT_DIR"/ssl
rm "$SSL_DIR/$DOMAIN".crt "$SSL_DIR/$DOMAIN".key
echo "+ deleted https cert and key"


# rm nginx/conf.d
CONFD_DIR="$SCRIPT_DIR"/nginx/conf.d
rm "${CONFD_DIR}/${DOMAIN}.conf"
echo "+ deleted ${CONFD_DIR}/${DOMAIN}.conf"


# clean /etc/hosts
echo 'root pass:'
sudo sed -i '' "/127.0.0.1 ${DOMAIN}/d" /etc/hosts
echo "+ deleted hostname from /etc/hosts"


# edit a8cnginx.Dockerfile
NGINX_DOCKERFILE_DIR="$SCRIPT_DIR"/nginx
sed -i '' "/CN=${DOMAIN}'/d" $NGINX_DOCKERFILE_DIR/a8cnginx.Dockerfile
echo "+ removed openssl cert from $NGINX_DOCKERFILE_DIR/a8cnginx.Dockerfile"


# edit a8cphp.Dockerfile
PHP_DOCKERFILE_DIR="$SCRIPT_DIR"/php
sed -i '' "/alias xd${DOMAIN}=/d" $PHP_DOCKERFILE_DIR/a8cphp.Dockerfile
echo "+ removed XD CLI alias from $PHP_DOCKERFILE_DIR/a8cphp.Dockerfile"


# rm www
WWW_DIR=$SCRIPT_DIR/../www/${DOMAIN}
rm -rf $WWW_DIR
rm -rf $WWW_DIR
echo "+ deleted www dir $WWW_DIR"


# edit docker-compose.yml
DOCKERCOMPOSE_FILE_DIR="$SCRIPT_DIR"/..
sed -i '' "/- .\/www\/${DOMAIN}:\/var\/www\/${DOMAIN}/d" $DOCKERCOMPOSE_FILE_DIR/docker-compose.yml
echo "+ removed volumes from $DOCKERCOMPOSE_FILE_DIR/docker-compose.yml"
sed -i '' "/- .\/.docker\/nginx\/conf.d\/${DOMAIN}.conf:/d" $DOCKERCOMPOSE_FILE_DIR/docker-compose.yml
echo "+ removed nginx conf from $DOCKERCOMPOSE_FILE_DIR/docker-compose.yml"


echo ""
echo "Finish up with:"
echo "  - deleting the database"
