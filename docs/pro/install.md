# Install AnyCable-Go Pro

AnyCable-Go Pro is distributed in two forms: a Docker image and pre-built binaries.

**NOTE:** All distribution methods, currently, relies on GitHub **personal access tokens**. We can either grant an access to the packages/projects to your users or generate a token for you. You MUST enable the following permissions: `read:packages` to download Docker images and/or `repo` (full access) to download binary releases.

## Docker

We use [GitHub Container Registry][ghcr] to host images.

See the [official documentation][ghcr-auth] on how to authenticate Docker to pull images from GHCR.

Once authenticated, you can pull images using the following identifier: `ghcr.io/anycable/anycable-go-pro`. For example:

```yml
# docker-compose.yml
services:
  ws:
    image: ghcr.io/anycable/anycable-go-pro:1.5
    ports:
      - '8080:8080'
    environment:
      ANYCABLE_HOST: "0.0.0.0"
```

## Pre-built binaries

We use a dedicated GitHub repo to host pre-built binaries via GitHub Releases: [github.com/anycable/anycable-go-pro-releases][releases-repo].

We recommend using [`fetch`][fetch] to download releases via command line:

```sh
fetch --repo=https://github.com/anycable/anycable-go-pro-releases --tag="v1.4.0" --release-asset="anycable-go-linux-amd64" --github-oauth-token="<access-token>" /tmp
```

## Heroku

### Using buildpacks

Our [heroku buildpack][buildpack] supports downloading binaries from the private GitHub releases repo.
You need to provide the following configuration parameters:

- `HEROKU_ANYCABLE_GO_REPO=https://github.com/anycable/anycable-go-pro-releases`
- `HEROKU_ANYCABLE_GO_GITHUB_TOKEN=<access-token>`

Currently, you also need to specify the version as well: `HEROKU_ANYCABLE_GO_VERSION=1.3.0`.

Make sure you're not using cached `anycable-go` binary by purging the Heroku cache: `heroku builds:cache:purge -a <your-app-name>`. See [documentation](https://help.heroku.com/18PI5RSY/how-do-i-clear-the-build-cache) for more details.

### Using Docker images

You can use Heroku _Container Registry and Runtime_ feature to deploy AnyCable-Go as a standalone service (i.e., when using [RPC-less setup with Hotwire](../guides/hotwire.md) or [HTTP RPC](../ruby/http_rpc.md)).

The basic steps are: pull an AnyCable-Go PRO image from our private registry, push it to your Heroku registry and deploy. See [the official documentation](https://devcenter.heroku.com/articles/container-registry-and-runtime).

[ghcr]: https://ghcr.io
[ghcr-auth]: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry
[releases-repo]: https://github.com/anycable/anycable-go-pro-releases/
[fetch]: https://github.com/gruntwork-io/fetch
[buildpack]: https://github.com/anycable/heroku-anycable-go
