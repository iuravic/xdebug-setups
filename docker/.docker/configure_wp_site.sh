#!/bin/bash

echo '-- 1/2 Configure new WP site nginx/conf.d, run from local ---'
read -p "new WP site domain: " DOMAIN
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


# ###


SSL_DIR="$SCRIPT_DIR"/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout "$SSL_DIR/$DOMAIN".key -out "$SSL_DIR/$DOMAIN".crt -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=$DOMAIN"
echo "+ created https cert"


CONFD_DIR="$SCRIPT_DIR"/nginx/conf.d
cd $CONFD_DIR
eval NGINX_CONF=' php -r " \$conf = file_get_contents( \"${CONFD_DIR}/0_site.conf_template\" ); \$conf = str_replace( \"{DOMAIN}\", \"${DOMAIN}\", \$conf ); echo \$conf; "' > "${CONFD_DIR}/${DOMAIN}.conf"
echo "+ created ${CONFD_DIR}/${DOMAIN}.conf"


echo 'root pass:'
sudo cp /etc/hosts /etc/hosts_BKP
sudo sed -ie "s/# ### docker hostnames ###/# ### docker hostnames ###\n127.0.0.1 ${DOMAIN}/g" /etc/hosts
echo "+ inserted hostname to /etc/hosts"


NGINX_DOCKERFILE_DIR="$SCRIPT_DIR"/nginx
cp $NGINX_DOCKERFILE_DIR/a8cnginx.Dockerfile $NGINX_DOCKERFILE_DIR/a8cnginx.Dockerfile_BKP
sed -ie "s/# ### script add openssl ###/# ### script add openssl ###\nRUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout \/etc\/nginx\/ssl\/selfsigned\/${DOMAIN}.key -out \/etc\/nginx\/ssl\/selfsigned\/${DOMAIN}.crt -subj '\/C=GB\/ST=London\/L=London\/O=Global Security\/OU=IT Department\/CN=${DOMAIN}'/g" $NGINX_DOCKERFILE_DIR/a8cnginx.Dockerfile
echo "+ added openssl cert creation to $NGINX_DOCKERFILE_DIR/a8cnginx.Dockerfile"


PHP_DOCKERFILE_DIR="$SCRIPT_DIR"/php
cp $PHP_DOCKERFILE_DIR/a8cphp.Dockerfile $PHP_DOCKERFILE_DIR/a8cphp.Dockerfile_BKP
# This entry is needed, much escaping: RUN echo 'alias xdreno="XDEBUG_CONFIG=\"start_with_request=yes\" PHP_IDE_CONFIG=\"serverName=reno.test\""' >> /home/nonroot/.bashrc
sed -ie "s/# ### script add xd aliases ###/# ### script add xd aliases ###\nRUN echo 'alias xd${DOMAIN}=\"XDEBUG_CONFIG=\\\\\"start_with_request=yes\\\\\" PHP_IDE_CONFIG=\\\\\"serverName=${DOMAIN}\\\\\"\"' >> \/home\/nonroot\/.bashrc/g" $PHP_DOCKERFILE_DIR/a8cphp.Dockerfile
echo "+ added XD CLI alias to $PHP_DOCKERFILE_DIR/a8cphp.Dockerfile"


WWW_DIR=$SCRIPT_DIR/../www/${DOMAIN}/public
mkdir -p $WWW_DIR
echo "+ created www dir $WWW_DIR"


DOCKERCOMPOSE_FILE_DIR="$SCRIPT_DIR"/..
cp $DOCKERCOMPOSE_FILE_DIR/docker-compose.yml $DOCKERCOMPOSE_FILE_DIR/docker-compose.yml_BKP
# sed -ie "s/# ### script add www volumes ###/# ### script add www volumes ###\n            - .\/www\/${DOMAIN}:\/var\/www\/${DOMAIN}/g" $DOCKERCOMPOSE_FILE_DIR/docker-compose.yml
# echo "+ added volumes to $DOCKERCOMPOSE_FILE_DIR/docker-compose.yml"
sed -ie "s/# ### script add nginx conf ###/# ### script add nginx conf ###\n            - .\/.docker\/nginx\/conf.d\/${DOMAIN}.conf:\/etc\/nginx\/conf.d\/${DOMAIN}.conf/g" $DOCKERCOMPOSE_FILE_DIR/docker-compose.yml
echo "+ added nginx conf to $DOCKERCOMPOSE_FILE_DIR/docker-compose.yml"


echo ""
echo "Finish up with:"
echo "  $ docker exec -it a8cphp bash"
echo "    > $ cd /var/www && sudo chown nonroot wp_cli_install_site.sh && chmod +x wp_cli_install_site.sh && ./wp_cli_install_site.sh"
echo "  $ docker-compose down && docker-compose up --force-recreate"
echo "    ( and occasionally for XDebug CLI run  $ docker-compose up --build --force-recreate --no-deps a8cphp , then do ,  docker-compose down && docker-compose up --force-recreate )"
