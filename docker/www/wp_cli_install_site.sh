# ! /usr/bin/env bash

echo '--- 2/2 Install new WP site, run from PHP (first run configure_wp_site.sh from local) ---'
read -p 'WP site domain, e.g. n-dev.test: ' DOMAIN
read -p 'Site slug, DB friendly (no dashes), e.g. ndev: ' SLUG

#

mkdir -p /var/www/${DOMAIN}/public
cd /var/www/${DOMAIN}/public
wp core download --force
wp core config --dbhost=host.docker.internal --dbname=wp_${SLUG} --dbuser=root --dbpass=root
mysql -hhost.docker.internal -uroot -proot -e "create database wp_${SLUG}";
wp core install --url=${DOMAIN} --title="${DOMAIN}" --admin_name=admin --admin_password=pass --admin_email=admin@local.test
chmod 775 /var/www/${DOMAIN}/public/wp-content/uploads/
echo 'Done.'
