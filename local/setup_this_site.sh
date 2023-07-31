#!/bin/bash

read -p "Site alias: " ALIAS
PATH="/Users/ivanuravic/www/$ALIAS"
PUBLIC_PATH="${PATH}/app/public"

PHPINIPATH="$PATH/conf/php/php.ini.hbs"
INITSHPATH=/Users/ivanuravic/www/init.sh

echo ""
echo "Setting xdebug config in $PHPINIPATH ..."
# default:
#   xdebug.mode=debug
#   xdebug.client_port=9003
#   xdebug.start_with_request=trigger
#   xdebug.discover_client_host=yes
# updated:
#   xdebug.mode=debug
#   xdebug.client_port=9003
#   xdebug.max_nesting_level=2048
#   xdebug.idekey=LOCALDEBUG
#   ;xdebug.start_with_request=trigger
#   ;xdebug.discover_client_host=yes
/usr/bin/sed -i '' -e "s/xdebug.start_with_request=trigger/;xdebug.start_with_request=trigger/g" "$PHPINIPATH"
/usr/bin/sed -i '' -e "s/xdebug.discover_client_host=yes/;xdebug.discover_client_host=yes/g" "$PHPINIPATH"
/usr/bin/sed -i '' -e "s/xdebug.client_port=9003/xdebug.client_port=9003\nxdebug.max_nesting_level=2048\nxdebug.idekey=LOCALDEBUG/g" "$PHPINIPATH"

echo ""
XDENTRY="alias xd${ALIAS}.local=\"XDEBUG_CONFIG=\\\\\"start_with_request=yes\\\\\" PHP_IDE_CONFIG=\\\\\"serverName=${ALIAS}.local\\\\\"\""
echo "Setting xd${ALIAS}.local alias in $INITSHPATH ..."
/usr/bin/sed -i '' -e "s/#xdconf/#xdconf\n${XDENTRY}/g" "$INITSHPATH"

echo ""
echo "Setting WP_DEBUG config in wp-config.php ..."
/usr/bin/sed -i '' -e "s/define( 'WP_DEBUG', false );/define( 'WP_DEBUG', true );\nif ( WP_DEBUG ) {\n  define( 'WP_DEBUG_LOG', true );\n  define( 'SCRIPT_DEBUG', true );\n  define( 'WP_DEBUG_DISPLAY', true );\n  @ini_set( 'display_errors', 1 );\n}\nini_set( 'log_errors', 1 );\nini_set( 'error_log', __DIR__ \. '\/wp-content\/debug\.log' );/g" "${PUBLIC_PATH}/wp-config.php"

echo ""
echo "To finish run:"
echo "  $ /Users/ivanuravic/www/0_local_stuff/mysql_enable_port.sh"
echo "  $ source $INITSHPATH"
echo "  - restart this local site"
echo ""
