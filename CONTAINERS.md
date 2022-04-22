# MorphoSource Docker Deployment

It's possible to deploy MorphoSource either as a local development environment or as a single-server instance using Docker containers and Docker Compose. This readme will detail the various options available to do so.

## Getting Started

To get up and running with the simplest version of the Docker Compose deployment, install Docker and run

```
docker-compose --env-file docker-compose.env build
docker-compose --env-file docker-compose.env up
```

Building containers may take a while due to installing Ruby gems and precompiling assets. When the containers are fully up and the container db_migrate has successfully finished seeding the database, you will be able to access the various services:

* MorphoSource web application: http://localhost:3000
* Solr: http://localhost:8983
* Fedora: http://localhost:8080

See the Usage section for further details and other Docker-based deployment options.

### Prerequisities

In order to run this container you'll need docker installed.

* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)

### Usage

#### Container Parameters

List the different parameters available to your container

```shell
docker run give.example.org/of/your/container:v0.2.1 parameters
```

One example per permutation 

```shell
docker run give.example.org/of/your/container:v0.2.1
```

Show how to get a shell started in your container too

```shell
docker run give.example.org/of/your/container:v0.2.1 bash
```

#### Environment Variables

* `VARIABLE_ONE` - A Description
* `ANOTHER_VAR` - More Description
* `YOU_GET_THE_IDEA` - And another

#### Volumes

* `/your/file/location` - File location

#### Useful File Locations

* `/some/special/script.sh` - List special scripts
  
* `/magic/dir` - And also directories

## Built With

* List the software v0.1.3
* And the version numbers v2.0.0
* That are in this container v0.3.2

## Find Us

* [GitHub](https://github.com/your/repository)
* [Quay.io](https://quay.io/repository/your/docker-repository)

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the 
[tags on this repository](https://github.com/your/repository/tags). 

## Authors

* **Billie Thompson** - *Initial work* - [PurpleBooth](https://github.com/PurpleBooth)

See also the list of [contributors](https://github.com/your/repository/contributors) who 
participated in this project.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

* Dockerfile and docker-compose.yml modified from [Hyrax's Docker implementation](https://github.com/samvera/hyrax)
* Readme template structure from [Template-README-for-containers.md](https://gist.github.com/PurpleBooth/ea518ae68a49029bae95)
