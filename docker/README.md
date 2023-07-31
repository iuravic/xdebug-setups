
Full setup:
	$ export DOCKER_BUILDKIT=0
	$ export COMPOSE_DOCKER_CLI_BUILD=0
	$ docker compose up 

1/2 Now configure and create a new site.
	./configure_wp_site.sh

2/2 Next ssh to php container
	$ docker exec -it xdphp bash
		> $ cd /var/www
		> sudo chown nonroot wp_cli_install_site.sh && chmod +x wp_cli_install_site.sh
		> ./wp_cli_install_site.sh
	$ docker-compose down && docker-compose up --force-recreate
