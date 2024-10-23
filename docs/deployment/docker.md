# Docker Deployment

## Ruby RPC server

Deployment using Docker could be tricky since we rely on several gems with native extensions (`grpc`,`google-protobuf`).

Here is the list of useful resources:

- Segmentation faults with alpine ([anycable-rails#70](https://github.com/anycable/anycable-rails/issues/70) and [anycable#47](https://github.com/anycable/anycable/issues/47))
- [Example Dockerfile (alpine)](https://github.com/anycable/anycable/blob/master/etc/Dockerfile.alpine)

## AnyCable-Go

Official docker images are available at [DockerHub](https://hub.docker.com/r/anycable/anycable-go/).
