# Build Swoole/OpenSwoole for Laminas-CI

This repository contains tools for pre-building the Swoole and OpenSwoole extensions for the [Laminas CI](https://github.com/laminas/laminas-continous-integration-action).

The [Makefile](Makefile) can be used to do the following:

- Build Docker containers for different PHP versions that are ready for building extensions.
- Use the above Docker containers to build each of the Swoole and OpenSwoole extensions.
- Package and upload the extensions (currently only to S3).
