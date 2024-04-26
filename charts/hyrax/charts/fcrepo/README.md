Fedora Commons Helm Chart
=========================

Fedora is the flexible, modular, open source repository platform with native
linked data support.

## Installation

```sh
helm repo add fcrepo https://samvera-labs.github.io/fcrepo-charts
helm install fcrepo
```

### Or from local

```sh
helm dep up chart/fcrepo
helm install fcrepo chart/fcrepo
```

### Release a new version

- Bump the version in the Chart.yaml
- Run `helm package .`
- Run `helm repo index . --url https://samvera-labs.github.io/fcrepo-charts`
- Add files to git and push

## Configuration

By default, this chart deploys with Postgresql as the backend for Fedora.
Without other configuration, it will deploy a new Postgresql instance/database
as a service available to the `fcrepo` deployment.

In practice, users may want to forego installing postgres for two reasons:

_First_, when you are deploying Fedora into a more complex application
environment you may wish to reuse an existing Postgres instance already
maintained with that environment.

In this case, `fcrepo` should be deployed with postgresql explictly disabled, but
externalPostgresql.host or global.postgresql.postgresqlHost set to your upstream value.
externalPostgresql.password and externalPostgresql.username or `global.postgresql.auth.password`
and `global.postgresql.auth.username` can be used as needed depending on your set up. If both
externalPostgresql.password and `global.postgresql.auth.password` are set, then
externalPostgresql.password is used as an override.
This is usually done in the context of a parent chart which provides the postgresql instance, for example:

```yaml
fcrepo:
  enabled: true
  servicePort: 8080
  postgresql:
    enabled: false
  externalPostgresql:
    host: someurl.rds.amazonaws.com
    username: yourUser # Optional, may be defined globally
    password: wouldntyouliketoknow  # Optional, may be defined globally

```

_Second_, because they want to use another backend for Fedora. This use case is broadly unsupported here. In theory, you can get a default (Infinispan) configuration by setting `postgresql.enabled` to `false`. **THIS CONFIGURATION IS NOT SUPPORTED AT THIS TIME**:

```sh
helm install --set postgresql.enabled=false fcrepo-test chart/fcrepo
```

## Storage
If binary storage in S3 is desired, then please specify the following values

```yaml
s3:
  enabled: true
  bucket:
  access_key:
  secret_key:
```

This will enable S3 support, which is only supported in Fcrepo 4.7.5+
