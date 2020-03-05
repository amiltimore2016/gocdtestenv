DOCKER_COMPOSE=docker-compose


passfile:	
	echo secret | htpasswd -ci -B godata/passwd admin


run: passfile
	$(DOCKER_COMPOSE) up



