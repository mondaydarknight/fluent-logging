# fluentd-logging
The logging aggregator service (Fluentd) collects logs from application service and ship to the destination.

## Getting started
Set up a local environemnt with Docker.
```console
# Go to docker directory and copy the environment sample to the dot file.
$ cd docker
$ cp .env.sample .env
# Run the `docker-compose` to start Fluentd aggregator container.
$ docker-compose up -d
```

After making changes in a config files, run the following command to restart the Fluentd aggregator.
```console
$ docker-compose restart
```
