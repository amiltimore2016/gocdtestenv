# Gocd Docker Composer test environment

A Centos based docker image for [GoCD server](https://www.gocd.org).

# Issues, feedback?

Please make sure to log them at https://github.com/amiltimore2016/gocdtestenv/.

# Usage

In macOS install make

```
brew install make
```

Start docker compose with this:

```
make run
```

This will expose container ports 8153(http) and 8154(https) onto your server.
You can now open `http://localhost:8153` and `https://localhost:8154`

# Available configuration options

## Mounting volumes

The GoCD server will store all configuration, pipeline history database,
artifacts, plugins, and logs into `/godata`. If you'd like to provide secure
credentials like SSH private keys among other things, you can mount  `/home/go`
by editing the docker-compose.yml file and adding a stanza in the volumes section.

```file
volumes:
      - ./godata/home:/home/go
```

> **Note:** Ensure that `/path/to/home-dir` and `/path/to/godata` is accessible by the `go` user in container (`go` user - uid `1000`).

## Installing plugins

All plugins can be installed under `/godata`.

## Loading configuration from existing git repo
To load existing configuration from git repo, just add an ENV variable `CONFIG_GIT_REPO`.
Auth token may be used to access private repo. Branch `master` would be cloned by default.
To load another branch, define an ENV variable `CONFIG_GIT_BRANCH`.
If `/godata/config` already is git repo then CONFIG_GIT_REPO will be ignored.
Cloned repo **must** contain all files from `/godata/config` dir.

```file
environment:
  CONFIG_GIT_REPO:    https://gocduser:<password_or_auth_token>/config.git \
  CONFIG_GIT_BRANCH: branch_with_config \
```
*Checkd out content would overwrite files in `/godata/config/`*.


## Running custom entrypoint scripts

To execute custom script(s) during the container boostrap, but **before** the GoCD server starts just add a volume stanza

```file
volumes:
  - /path/to/your/script.sh:/docker-entrypoint.d/your-script.sh
```

If you have several scripts in a directory that you'd like to execute:

```file
volumes: 
  - /path/to/script-dir:/docker-entrypoint.d
```

## Tweaking JVM options (memory, heap etc)

JVM options can be tweaked using the environment variable `GOCD_SERVER_JVM_OPTS`.

```file
environment:
  GOCD_SERVER_JVM_OPTS: "-Xmx4096mb -Dfoo=bar" 
```

# Under the hood

The GoCD server runs as the `go` user, the location of the various directories is:

| Directory           | Description                                                                      |
|---------------------|----------------------------------------------------------------------------------|
| `/godata/addons`    | the directory where GoCD addons are stored                                       |
| `/godata/artifacts` | the directory where GoCD artifacts are stored                                    |
| `/godata/config`    | the directory where the GoCD configuration is store                              |
| `/godata/db`        | the directory where the GoCD database and configuration change history is stored |
| `/godata/logs`      | the directory where GoCD logs will be written out to                             |
| `/godata/plugins`   | the directory containing GoCD plugins                                            |
| `/home/go`          | the home directory for the GoCD server                                           |

# Determine Server IP and Ports on Host

Once the GoCD server is up, we should be able to determine its ip address and the ports mapped onto the host by doing the following:
The IP address and ports of the GoCD server in a docker container are important to know as they will be used by the GoCD agents to connect to it

Then, the below commands will determine to GoCD server IP, server port and ssl port
```shell
docker inspect --format='{{(index (index .NetworkSettings.IPAddress))}}' server
docker inspect --format='{{(index (index .NetworkSettings.Ports "8153/tcp") 0).HostPort}}' server
docker inspect --format='{{(index (index .NetworkSettings.Ports "8154/tcp") 0).HostPort}}' server
```

# Troubleshooting

## The GoCD server does not come up

- Check if the docker container is running `docker ps -a`
- Check the STDOUT to see if there is any output that indicates failures `docker logs CONTAINER_ID`
- Check the server logs `docker exec -it CONTAINER_ID tail -f /godata/logs/go-server.log` (or check the log file in the volume mount, if you're using one)


