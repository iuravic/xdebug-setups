## Custom Docker setup with Xdebug

Full setup:
- `$ export DOCKER_BUILDKIT=0`
- `$ export COMPOSE_DOCKER_CLI_BUILD=0`
- `$ docker compose up `

#### 1/2 configure and create a new site.
- `./configure_wp_site.sh`

#### 2/2 ssh to php container and set up WP site
- `$ docker exec -it xdphp bash`
	> `$ cd /var/www`
	> `sudo chown nonroot wp_cli_install_site.sh && chmod +x wp_cli_install_site.sh`
	> `./wp_cli_install_site.sh`
- `$ docker-compose down && docker-compose up --force-recreate`
