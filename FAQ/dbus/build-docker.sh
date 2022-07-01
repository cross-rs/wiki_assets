#!/bin/bash

docker build -t libdbus:arm64 --file aarch64.Dockerfile .
docker build -t libdbus:armhf --file armhf.Dockerfile .
docker build -t libdbus:i686 --file i686.Dockerfile .
docker build -t libdbus:amd64 --file amd64.Dockerfile .
