DOCKER_COMPOSE=docker-compose


passfile:
	echo secret | htpasswd -ci -B ./godata/config/password_file admin


run: passfile
	$(DOCKER_COMPOSE) up



