# MorphoSource Docker Deployment

It's possible to deploy MorphoSource either as a local development environment or as a single-server instance using Docker containers and Docker Compose. This readme will detail the various options available to do so.

### Prerequisities

In order to deploy MorphoSource you'll need Docker and Docker Compose installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

You'll also need to set up `credentials.env`, and can optionally customize configuration options in `docker-compose.env`. Read on for details.

### Credentials

In the `vendor/docker` directory, there is a `credentials.env-example` file. Copy this file and rename it `credentials.env`. Your `vendor/docker/credentials.env` should look like this: 

```
# Postgres DB user and pass
POSTGRES_USER=
POSTGRES_PASSWORD=

# Fedora user and pass
FCREPO_USERNAME=
FCREPO_PASSWORD=

# Initial MorphoSource user, will be granted admin access
MS_INIT_USR=
MS_INIT_PW=

# Recaptcha keys, necessary for downloading
RECAPTCHA_SITE_KEY=
RECAPTCHA_SECRET_KEY=
```

All of these fields should be completed to provide basic authentication credentials for your instance. Since the Docker instance will be creating a Postgres database, a Fedora/FCRepo repository, and the MorphoSource web application, the various usernames and passwords can be anything you choose. The `MS_INIT_USR` should be in the format of an email address, but even a fake email like `admin@email.com` can work. 

You'll also need to create Recaptcha keys for your server hostname if you wish to download files from the repository instance. Julie can provide Recaptcha keys for "localhost" dev environments to MorphoSource team members. We are working to make this optional and not mandatory for MorphoSource in the near future, but for the moment it is required.

### Environment Variables

Optional configuration options can be found in `vendor/docker/docker-compose.env`. The fields most relevant are those that allow you to customize the setup of the MorphoSource instance at the top of the file:

```
# Site settings
HOST_NAME=localhost
SITE_TITLE="3D Data Repository"

# For custom logo image, place image in public/ and label with leading slash, e.g. "/image.png"
LOGO_IMAGE=

# Number of Resque background workers
COUNT=2
```

* `HOST_NAME` - Defines the server/site host name (`www.morphosource.org`)
* `SITE_TITLE` - Short title for the repository instance, with double quotes if using spaces (`MorphoSource`)
* `LOGO_IMAGE` - Custom logo image for server. Best to place the image in /public and list with leading slash (`/image.png`)
* `COUNT` - This is the number of background Resque job workers. If increased, media contributions and other record creation and update will process more quickly, but perhaps unsurprisingly, this requires more powerful server hardware.

### Usage

The basic deployment profile will set up the MorphoSource web application to be accessible at port 3000, e.g. http://localhost:3000 if `HOST_NAME` is left to the default `localhost` value. You can also modify `docker-compose.yml` to open up ports to directly access the Solr and FCRepo admin consoles at ports 8983 and 8080 respectively by uncommenting the relevant lines.

```
docker-compose up -d # Start containers
docker-compose down  # Stop and remove containers
```

There is also a deployment profile that uses an Apache reverse proxy to expose services using URL endpoints, which most closely matches the production deployment used by MorphoSource.org. In this profile, the main web app is accessed at http://<host_name>, Solr is accessed at http://<host_name>/solr, and Fedora is accessed at http://<host_name>/fcrepo. By default, the main web app is also still accessible at http://<host_name>:3000, and you should probably comment this out in `docker-compose.yml` if using the Apache profile. The Apache server can also be used to deploy MorphoSource with HTTPS/SSL, if you have certificates pre-configured for your host server (see below). Note: This profile is not currently functional for Macs using Apple Silicon, and is best suited for Linux deployments.

```
docker-compose --profile apache up -d # Start containers
docker-compose --profile apache down  # Stop and remove containers
```

There is also a test profile used to run automated tests when doing development on the MorphoSource application. If you're doing development on MorphoSource using Docker, there is a separate documentation file with specific guides and tips for this purpose.

Finally, accessing the interactive Rails console (for technical site administration) is straightforward:

```
docker exec -it app /bin/bash
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

#### Volumes

While a number of volumes will be created, most will not be synced with locations on your file system. This lists only synced locations.

* `.:/app/samvera/hyrax-webapp` - MorphoSource_SF application (this repo)
* `./vendor/docker/fcrepo/fedora.xml:/var/lib/jetty/webapps/fedora.xml` - Fedora config XML
* `./solr/conf:/core_config/conf` - Solr config files

If using the Apache profile, there will be one or two additional synced volumes (1 for HTTP, 2 for HTTPS).

* `./vendor/docker/apache/vhost.conf:/vhosts/vhost.conf:ro` - Apache virtual host
* `./vendor/docker/apache/certs:/certs` - Optional SSL certs, must be named server.crt and server.key

#### Configuring HTTPS/SSL

To configure HTTPS with the Apache profile, there are a few configuration steps that must be followed. This assumes that you already have SSL certificate and private key files pre-configured for your host.

1. Copy your SSL cert files to the following location. Please note they must be renamed to `server.crt` and `server.key`

```
cp path\to\your\certfile path\to\MorphoSource_SF\vendor\docker\apache\certs\server.crt
cp path\to\your\keyfile  path\to\MorphoSource_SF\vendor\docker\apache\certs\server.key
```

2. In `docker-compose.yml` for the `apache` service, uncomment the certs volume and change the virtual host config file reference from `vhost.conf` to `ssl-vhost.conf`. Your service definition should look like the following example.

```
 apache:
    image: 'bitnami/apache:latest'
    container_name: apache
    user: root
    ports:
      - '80:80'
      - '443:443'
    env_file:
      - ./vendor/docker/docker-compose.env
    profiles:
      - apache
    volumes:
    - ./vendor/docker/apache/ssl-vhost.conf:/vhosts/vhost.conf:ro
    - ./vendor/docker/apache/certs:/certs
    networks:
      - morphosource
```

## Built With

* [MorphoSource 2.2.0](https://github.com/MorphoSource/MorphoSource_SF)
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
