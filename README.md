# Varnish VMOD building environment

This is the environment provided for building the Varnish [VMODs](https://varnish-cache.org/vmods/).

Currently provided setups:

* [varnish-modules](https://github.com/varnish/varnish-modules)
* [vmod-curl](https://github.com/varnish/libvmod-curl)
* [vmod-querystring](https://github.com/Dridi/libvmod-querystring)
* [vmod-uuid](https://github.com/otto-de/libvmod-uuid)

## Convention for modules configs

**NOTE** Contribution welcome!

Currently upported modules configurations are placed in `./modules/vmods` folder.
A configuration consists of 3 files:

* `.env` - environment set-up per module
* `version_map.env` - mapping between Varnish version and module version,
* `vmod.spec` - the RPM building standard specification file.

To provide a support for a new module one should:

* create a sub-folder in `./modules/vmods`, named same as the module itself,
* prepare a working `vmod.spec`,
* set the variables in the `.env` file (see curent ones for reference).

## Environment

### Local requirements

* docker
* make

### Supported Varnish versions

4.1.x - 6.1.x

### Supported OS versions for packages

Builds packages for:

* CentOS 7 x86_64 (for now)

## Usage

```shell
# Help for make commands:
make help
```

### Building modules

```shell
# build RPMs for for all supported modules
make rpms VARNISH_VERSION=6.0.1-1

# or for a particular module:
make rpms VARNISH_VERSION=6.0.1-1 MODULE=vmod-curl
```

**NOTE** Resulting RPM packages can be found in `./modules/dist` folder.

### Local integration test

The integration test is a Docker Compose stack containing:

* Varnish (version = `$VARNISH_VERSION`) with all built modules installed,
* [Nginx](https://hub.docker.com/_/nginx/) as the main backend,
* An [echo-server](https://hub.docker.com/r/jmalloc/echo-server/) for testing [vmod-curl](https://github.com/varnish/libvmod-curl).

Due to customize the setup:

* create a `docker-compose.yml` file in the main project directory, copying from the template `template/docker-compose.yml` file (if not created by hand then will be copied automatically during `make start`),
* create `test/config` folder, copy into it and modify `template/default.vcl` and `template/varnish.env` files according to your needs (if not created by hand then will be copied automatically during `make start`)

**NOTE** Automatically generated files can be edited later (they are excluded from the source control).

```shell
# Starts Varnish with modules RPMs in a simple Docker Compose stack together with some backend service:
make start
```

The above will start the Docker Compose stack in the background.

Display logs with following:

```shell
# Open docker compose logs.
make logs

# or Varnish log:
make varnishlog
```

Stop or tear down the stack with following:

```shell
# Stops the test stack without removing the images.
make stop

# or stop and delete the docker compose related images:
make clean
```

### Load test

Ajdust the load test settings in the `.env` file:

```shell
# benchmark settings
# -- defaults:
# METHOD=GET
CONCURRENT=100
NR_OF_REQUESTS=50000
```

Perform Apache Benchmark (load test) against provided Varnish Docker Compose stack:

```shell
# Ensures stack whether it is started, performs benchmark and cleans up the stack after.
make benchmark VARNISH_VERSION=6.0.1-1
```

**NOTE** The benchmark results for particular Varnish version will be stored in the `benchmark` folder.
