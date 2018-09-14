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

4.1.x - 6.0.x

### Supported OS versions for packages

Builds packages for:

* CentOS 7 x86_64 (for now)

## Usage

```bash
# build RPMs for for all supported modules
make rpms VARNISH_VERSION=6.0.1-1

# or for a particular module:
make rpms VARNISH_VERSION=6.0.1-1 MODULE=vmod-curl

# Start Varnish with simple NginX backend in the Docker Compose environment:
make test

# Help for make commands:
make help
```

Resulting RPM packages can be found in `./modules/dist` folder.
