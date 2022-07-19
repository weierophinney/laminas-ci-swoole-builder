# Build Swoole/OpenSwoole for Laminas-CI

This repository contains tools for pre-building the Swoole and OpenSwoole extensions for the [Laminas CI](https://github.com/laminas/laminas-continous-integration-action).

The [Makefile](Makefile) can be used to do the following:

- Build Docker containers for different PHP versions that are ready for building extensions.
- Use the above Docker containers to build and package each of the Swoole and OpenSwoole extensions, for individual PHP versions or for all PHP versions currently supported.

## Packages

Packages should be uploaded as release artifacts to tagged releases.
Releases should be tagged each time a new PHP version is added, or a version for Swoole or OpenSwoole is changed.
