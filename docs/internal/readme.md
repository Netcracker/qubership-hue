**This guide should be read after [architecture.md](/docs/public/architecture.md) and [installation.md](/docs/public/installation.md)**

## Repository structure

* `chart` - helm charts for Qubership Hue.
* `docker` - files for Qubership Hue image building and python script for creating database during deploy.
* `docs` - Qubership Hue documentation.
* `/` - other files in the root folder those are required.

## How to start

Qubership Hue uses [hue community image](https://hub.docker.com/r/gethue/hue/tags) as a base image. The Qubership Hue image updates some python libraries to reduce vulnerabilities and installs some ssl related linux packages

Qubership Hue helm chart is based on [community chart](https://github.com/cloudera/hue/tree/master/tools/kubernetes/helm/hue) with some minor changes, like the custom labels for Qubership release requirements.

Qubership Hue also has a preinstall job that is used for database creation, see [createdb.py](/hue_docker/createdb.py) and [pg_preinstall_hooks](/helm/hue/templates/pg_preinstall_hooks)

**Note** Qubership Hue also includes [qubership trino image](https://github.com/Netcracker/qubership-trino). Qubership Hue can deploy trino with itself or can work with a separate trino installation.


### Deploy to k8s

See [installation.md](/docs/public/installation.md)

### How to debug and troubleshoot

For troubleshouting it might be useful to carefully check installation parameters. If it does not help, it might help to see hue source code at https://github.com/cloudera/hue/tree/master .

## Upgrade strategy

1) Update Qubership Hue docker image in [Dockerfile](/hue_docker/Dockerfile)
2) Check python lib versions in [requirements.txt](/hue_docker/requrements.txt) compared to community image. If in community image the versions are higher, remove these libraries from requirements.txt.
3) Check vulnerabilities. If possible to fix vulnerabilities in python libraries by increasing their patch version, add these libraries with updated versions to requirements.txt.
4) Update helm charts based on https://github.com/cloudera/hue/tree/master/tools/kubernetes/helm/hue while keeping custom changes
5) Check that hue can be deployed and can connect to all dependent services.
6) Update documentation if needed.

## Useful links:

* https://github.com/cloudera/hue - hue github page
* https://github.com/cloudera/hue/tree/master/tools/kubernetes/helm/hue - hue helm charts location
* https://hub.docker.com/r/gethue/hue/tags - community hue docker image
* https://docs.gethue.com/ - hue documentation
* https://docs.gethue.com/administrator/configuration/connectors/ hue connectors configuration
