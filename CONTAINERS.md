# MorphoSource Docker Deployment

It's possible to deploy MorphoSource either as a local development environment or as a single-server instance using Docker containers and Docker Compose. This readme will detail the various options available to do so.

## Getting Started

To get up and running with the simplest version of the Docker Compose deployment, run

```
docker-compose --env-file docker-compose.env build
docker-compose --env-file docker-compose.env up
```

Building containers may take a while due to installing Ruby gems and precompiling assets. When the containers are fully up and the container db_migrate has successfully finished seeding the database, you will be able to access the various services:

* MorphoSource web application: http://localhost:3000
* Solr: http://localhost:8983
* Fedora: http://localhost:8080

**Warning!** If you follow these steps and do nothing further, deployment will proceed successfully and you will be able to access MorphoSource, but you'll get errors on media pages related to not having a Recaptcha key. Read on for the full prerequisites, how to customize the deployment configuration, and the various deployment options available (including reverse proxy web server and/or HTTPS/SSL).

### Prerequisities

In order to deploy MorphoSource you'll need Docker and Docker Compose installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

You'll also need to create Recaptcha keys for your server hostname. Julie can provide Recaptcha keys for "localhost" dev environments to MorphoSource team members. We are working to make this optional and not mandatory for MorphoSource in the near future, but for the moment it is required.

Finally, see the **Environment Variables** section for required and recommended customizations to `docker-compose.env`.

### Usage

There are two Docker Compose files that can be used to deploy MorphoSource, `docker-compose.yml` and `docker-compose-apache.yml`. The first of these deploys MorphoSource as described in the **Getting Started** section - important MorphoSource stack services have their ports open to the host, and can be accessed from the relevant host ports. The main web app can be accessed at http://<host_name>:3000, Solr at http://<host_name>:8983, Fedora at http://<host_name>:8080, etc. The Apache Docker Compose file adds an Apache reverse proxy web server container to this arrangement and prevents services from exposing their own ports. Instead, the main web app is accessed at http://<host_name>, Solr is accessed at http://<host_name>/solr, and Fedora is accessed at http://<host_name>/fcrepo. This Apache server can also be used to deploy MorphoSource with HTTPS/SSL, if you have certificates pre-configured for your host server (see below for more details on this).

#### Container Parameters

Build and run basic deployment configuration

```
docker-compose --env-file docker-compose.env build
docker-compose --env-file docker-compose.env up
```

Build and run Apache-based deployment configuration

```
docker-compose --env-file docker-compose.env -f docker-compose-apache.yml build
docker-compose --env-file docker-compose.env -f docker-compose-apache.yml up
```

Attach to main app container with a shell and run Rails console
```
docker exec -it morphosource_sf_app_1 /bin/bash
bundle exec rails c
```
#### Containers

* `app` - Main web app container. Should be attached to in order to use Rails console.
* `app_worker` - Very similar to app container, except this container has third-party tools for file metadata characterization and web preview derivative generation downloaded and installed. If trying to diagnose or debug an issue with characterization or derivatives, attach to this container.
* `app_test` - By default, this container will not be created or started. It is used by developers for running automated tests, and can be accessed by using the `test` container profile. This container is identical to app_worker in build.
* `db_migrate` - Identical to app container in build. This container is used to create initial Postgres databases and seed Postgres/Fedora/Solr with necessary initial data, such as the default Hyrax admin set. It also creates the initial MorphoSource admin user. It waits for Postgres/Fedora/Solr to become accessible, carries out setup steps, and then exits. Because of this, it's normal for this to be the only container that has exited even while the rest of the server proceeds on. Further, These setup steps are idempotent, it does not matter how many times this container runs in the case of container restarts. If you update MorphoSource application code, this container will also take care of DB migrations.
* `fcrepo`
* `solr`
* `postgres`
* `memcached`
* `redis`
* `apache`

#### Environment Variables

All relevant and customizable environment variables are included in the file `docker-compose.env`, you should read over this file and familiarize yourself with it. Because this file is not called `.env` (in order to avoid problematic interactions with Rails and other packages), Docker and Docker Compose will not read it by default, and Docker executables must be informed how to locate this environment file with the command line option `--env-file docker-compose.env`.

You have to provide values for the following fields related to Recaptcha keys:

* `RECAPTCHA_SITE_KEY`
* `RECAPTCHA_SECRET_KEY`

You can optionally provide customized values for the following fields, and if you're deploying to a remote server, you should probably customize all of them:

* `HOST_NAME` - Defines the server/site host name (`www.morphosource.org`)
* `SITE_TITLE` - Short title for the repository instance, with double quotes if using spaces (`MorphoSource`)
* `LOGO_IMAGE` - Custom logo image for server. Best to place the image in /public and list with leading slash (`/image.png`)
* Username and password fields for initial MorphoSource admin user, Postgres DB user, and Fedora admin user

#### Volumes

While a number of volumes will be created, most will not be synced with locations on your file system. This lists only synced locations.

* `.:/app/samvera/hyrax-webapp` - MorphoSource_SF application (this repo)
* `./vendor/docker/fcrepo/fedora.xml:/var/lib/jetty/webapps/fedora.xml` - Fedora config XML
* `./solr/config:/core_config/conf` - Solr config files

If using `docker-compose-apache.yml`, there will be one or two additional synced volumes (1 for HTTP, 2 for HTTPS).

* `./vendor/docker/apache/vhost.conf:/vhosts/vhost.conf:ro` - Apache virtual host
* `./vendor/docker/apache/certs:/certs` - Optional SSL certs, must be named server.crt and server.key

#### Configuring HTTPS/SSL

To configure HTTPS with `docker-compose-apache.yml`, there are a few configuration steps that must be followed. This assumes that you already have SSL certificate and private key files pre-configured for your host.

1. Copy your SSL cert files to the following location. Please note they must be renamed to `server.crt` and `server.key`

```
cp path\to\your\certfile path\to\MorphoSource_SF\vendor\docker\apache\certs\server.crt
cp path\to\your\keyfile  path\to\MorphoSource_SF\vendor\docker\apache\certs\server.key
```

2. In `docker-compose-apache.yml` for the `apache` service, uncomment the certs volume and change the virtual host config file reference from `vhost.conf` to `ssl-vhost.conf`. Your service definition should look like the following example.

```
 apache:
    image: 'bitnami/apache:latest'
    user: root
    ports:
      - '80:80'
      - '443:443'
    env_file:
      - docker-compose.env
    volumes:
    - ./vendor/docker/apache/ssl-vhost.conf:/vhosts/vhost.conf:ro
    - ./vendor/docker/apache/certs:/certs
    networks:
      - morphosource
```

## Built With

* [MorphoSource 2.1.0](https://github.com/MorphoSource/MorphoSource_SF)
* [Fedora FCRepo 4.7.5](https://github.com/orgs/samvera/packages/container/package/fcrepo4)
* [Solr 7.7.3](https://hub.docker.com/_/solr)
* [Postgres](https://hub.docker.com/_/postgres)
* [Memcached](https://hub.docker.com/r/bitnami/memcached)
* [Redis](https://hub.docker.com/_/redis)
* [Apache](https://hub.docker.com/r/bitnami/apache)

## Find Us

* [MorphoSource](https://www.morphosource.org)
* [MorphoSource GitHub Organization](https://github.com/MorphoSource)

## Acknowledgments

* Dockerfile and docker-compose.yml modified from [Hyrax's Docker implementation](https://github.com/samvera/hyrax)
* Readme template structure from [Template-README-for-containers.md](https://gist.github.com/PurpleBooth/ea518ae68a49029bae95)
