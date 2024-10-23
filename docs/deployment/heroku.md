# Heroku Deployment

## Simplified (with HTTP RPC)

Since v1.4, AnyCable supports [RPC over HTTP](../ruby/http_rpc.md) which allows us to use a single Heroku application for both regular and AnyCable RPC HTTP requests.

All you need is to deploy `anycable-go` as a separate Heroku application, configure it to use HTTP RPC and point it to your main application.

> See the [demo](https://github.com/anycable/anycable_rails_demo/pull/32) of preparing the app for a simplified Heroku deployment.

### Deploying AnyCable-Go

Deploy AnyCable-Go by simply clicking the button below:

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://www.heroku.com/deploy?template=https://github.com/anycable/anycable-go)

**NOTE:** To recreate the button-deployed application later, you must create [`heroku.yml`](https://github.com/anycable/anycable-go/blob/master/heroku.yml) and a [Dockerfile](https://github.com/anycable/anycable-go/blob/master/.docker/Dockerfile.heroku) and put them into your repository.

Fill the required information:

- `ANYCABLE_RPC_HOST`: the URL of your web application containing the mount path of the AnyCable HTTP RPC server (e.g., `https://my-app.herokuapp.com/_anycable`).

- `ANYCABLE_SECRET`: A secret that will be used to generate an authentication token for HTTP RPC requests.

Make sure to set the same values in your web application configuration (e.g., for Rails, `http_rpc_mount_path: "/_anycable"` in `config/anycable.yml` and the `ANYCABLE_SECRET` env var).

We recommend enabling [Dyno Metadata](https://devcenter.heroku.com/articles/dyno-metadata) to activate the [Heroku configuration preset](../anycable-go/configuration.md#presets). Otherwise, don't forget to set `ANYCABLE_HOST=0.0.0.0` in the application configuration.

Other configuration parameters depend on the features you use.

### Deploying AnyCable-Go PRO

Heroku supports only public Docker registries when deploying using the `heroku.yml` config. To deploy AnyCable-Go PRO, you can use Heroku _Container Registry and Runtime_: pull an AnyCable-Go PRO image from our private registry, push it to your Heroku registry and deploy. See [the official documentation](https://devcenter.heroku.com/articles/container-registry-and-runtime).

### Configuring web application

At the web application (Rails) side, you must also configure:

- `config.action_cable.url`: the URL of your AnyCable-Go application (e.g., `wss://anycable-go.herokuapp.com/cable`).

- `config.session_store :cookie_store, key: "_<my-app>_sid", domain: :all` to share the session between the web and AnyCable-Go applications. **NOTE:** Sharing cookies across domains doesn't work with `*.herokuapp.com` domains; you must use custom domains (or put a CDN in front of your applications to server both from the same hostname).

## Full mode (with gRPC)

Deploying applications using AnyCable with gRPC on Heroku is a little bit tricky due to the following limitations:

- **Missing HTTP/2 support.** AnyCable relies on HTTP/2 ('cause it uses [gRPC](https://grpc.io)).
- **The only `web` service.** It is not possible to have two HTTP services within one application (only `web` service is open the world).

The only way (for now) to run AnyCable applications on Heroku is to have two separate applications sharing some resources: the first one is a typical web application responsible for general HTTP and the second contains AnyCable WebSocket and RPC servers.

For convenience, we recommend adding a WebSocket app instance to the same [pipeline](https://devcenter.heroku.com/articles/pipelines) as the original one. You can create a pipeline via Web UI or using a CLI:

```sh
heroku pipelines:create -a example-pipeline
```

### Preparing the source code

> See also the [demo](https://github.com/anycable/anycable_rails_demo/pull/4) of preparing the app for Heroku deployment.

We have to use the same `Procfile` for both applications ('cause we're using the same repo) but run different commands for the `web` service. We can use an environment variable to toggle the application behaviour, for example:

```sh
# Procfile
web: [[ "$ANYCABLE_DEPLOYMENT" == "true" ]] && bundle exec anycable --server-command="anycable-go" ||  bundle exec rails server -p $PORT -b 0.0.0.0
```

If you have a `release` command in your `Procfile`, we recommend to ignore it for AnyCable deployment as well and let the main app take care of it. For example:

```sh
release: [[ "$ANYCABLE_DEPLOYMENT" == "true" ]] && echo "Skip release script" || bundle exec rails db:migrate
```

### Preparing Heroku apps

Here is the step-by-step guide on how to deploy AnyCable application on Heroku from scratch using [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli#download-and-install).

First, we need to create an app for the _main_ application (skip this step if you already have a Heroku app):

```sh
# Create a new heroku application
heroku create example-app

# Add to the pipeline
heroku pipelines:add example-pipeline -a example-app

# Add necessary add-ons
# NOTE: we need at least Redis
heroku addons:create heroku-postgresql
heroku addons:create heroku-redis

# Deploy application
git push heroku master

# Run migrations or other postdeployment scripts
heroku run "rake db:migrate"
```

See also the [official Heroku guide](https://devcenter.heroku.com/articles/getting-started-with-rails6#create-a-new-rails-app-or-upgrade-an-existing-one) for setting up Rails applications.

Secondly, create a new Heroku application for the same repository to host the WebSocket server:

```sh
# Create a new application and name the git remote as "anycable"
heroku create example-app-anycable --remote anycable

# Add this application to the pipeline (if you have one)
heroku pipelines:add example-pipeline -a example-app-anycable
```

Now we need to add `anycable-go` to this new app. There is a buildpack, [anycable/heroku-anycable-go](https://github.com/anycable/heroku-anycable-go), for that:

```sh
# Add anycable-go buildpack
heroku buildpacks:add https://github.com/anycable/heroku-anycable-go -a example-app-anycable
```

Also, to run RPC server ensure that you have a Ruby buildpack installed as well:

```sh
# Add ruby buildpack
heroku buildpacks:add heroku/ruby -a example-app-anycable
```

Now, **the most important** part: linking one application to another.

First, we need to link the shared Heroku resources (databases, caches, other add-ons).

Let's get a list of the main app add-ons:

```sh
# Get the list of the first app add-ons
$ heroku addons -a example-app
```

Find the ones you want to share with the AnyCable app and _attach_ them to it:

```sh
# Attach add-ons to the second app
heroku addons:attach postgresql-closed-12345 -a example-app-anycable
heroku addons:attach redis-regular-12345 -a example-app-anycable
```

**NOTE:** Make sure you have a Redis instance shared and the database as well. You might also want to share other add-ons depending on your configuration.

### Configuring the apps

Finally, we need to add the configuration variables to both apps.

For AnyCable app:

```sh
# Make our heroku/web script run `bundle exec anycable`
heroku config:set ANYCABLE_DEPLOYMENT=true -a example-app-anycable

# Configure anycable-go to listen at 0.0.0.0 (to make it accessible to Heroku router)
heroku config:set ANYCABLE_HOST=0.0.0.0 -a example-app-anycable

# Don't forget to add RAILS_ENV if using Rails
heroku config:set RAILS_ENV=production -a example-app-anycable
```

You may also want to explicitly specify AnyCable-Go version (the latest release is used by default):

```sh
heroku config:set HEROKU_ANYCABLE_GO_VERSION
```

**IMPORTANT:** You also need to copy all (or most) the application-specific variables from
`example-app` to `example-app-anycable` to make sure that applications have the same environment.
For example, you **must** use the same `SECRET_KEY_BASE` if you're going to use cookies for authentication or
utilize some other encryption-related functionality in your channels code.

Here is an example Rake task to sync env vars between two applications on Heroku: [heroku.rake][].

We recommend using Rails credentials (or alternative secure store implementation, e.g., [chamber](https://github.com/thekompanee/chamber)) to store the application configuration. This way you won't need to think about manual and even automated env syncing.

Next, we need to _tell_ the main app where to point Action Cable clients.
If you configured AnyCable via `rails g anycable:setup`, you have something like this in your `production.rb`:

```ruby
# config/environments/production.rb
config.after_initialize do
  config.action_cable.url = ActionCable.server.config.url = ENV.fetch("CABLE_URL") if AnyCable::Rails.enabled?
end
```

And set the `CABLE_URL` var to point to the AnyCable endpoint in the AnyCable app:

```sh
# with the default Heroku domain
heroku config:set CABLE_URL="wss://example-app-anycable.herokuapp.com/cable"

# or with a custom domain
heroku config:set CABLE_URL="ws://anycable.example.com/cable"
```

**NOTE:** with default `.herokuapp.com` domains you won't be able to use cookies for authentication. Read more in [troubleshooting](../troubleshooting.md#my-websocket-connection-fails-with-quotauth-failedquot-error).

### Pushing code

To keep the applications in sync, you need to deploy them simultaneously. The easiest way to do that is to configure [automatic deploys](https://devcenter.heroku.com/articles/github-integration#automatic-deploys).

If you prefer the manual `git push` approach, don't forget to push code to the AnyCable app every time you push the code to the main app:

```sh
git push anycable master
```

## Using with review apps

Creating a separate AnyCable app for every Heroku review app seems to be an unnecessary overhead.

You can avoid this by using one of the following techniques.

### Use AnyCable Rack server

[AnyCable Rack](https://github.com/anycable/anycable-rack-server) server could be mounted into a Rack/Rails app and run from the same process and handle WebSocket clients at the same HTTP endpoint as the app.

On the other hand, it has the same architecture involving the RPC server, and thus provides the same experience as another, standalone, AnyCable implementations.

### Use Action Cable

You can use the _standard_ Action Cable in review apps with [enforced runtime compatibility checks](../rails/compatibility.md#runtime-checks).

In your `cable.yml` use the following code to conditionally load the adapter:

```yml
production:
  adapter: <%= ENV.fetch('CABLE_ADAPTER', 'any_cable') %>
```

And set `"CABLE_ADAPTER": "redis"` (or any other built-in adapter, e.g. `"CABLE_ADAPTER": "async"`) in your `app.json`.

## Choosing the right formation

How do to choose the right dyno type and the number of AnyCable dynos? Let's consider the full mode (with gRPC server).

Since we run both RPC and WebSocket servers within the same dyno, we need to think about the resources usage carefully.

The following formula could be used to estimate the necessary formation configuration:

$$
N = \frac{\mu\frac{C}{1000}}{\phi(D - R)}
$$

$\mu$ — MiB required to serve 1k connections by AnyCable-Go (currently, it equals to 50MiB for most use-cases)

$\phi$ — fill factor ($0 \le \phi \le 1$): what portion of all the available RAM we want to use (to leave a room for load spikes)

$C$ — the expected number of simultaneous connections at peak times

$D$ — RAM available for the dyno type (512MiB for 1X and 1GiB for 2x)

$R$ — the size of the RPC (Rails) application.

For a hypothetical app with $R = 350$, $C = 6000$ and $\phi = 0.8$:

$$
N = \frac{50\frac{6000}{1000}}{0.8(512 - 350)} = \frac{300}{130} = 2.31
$$

Thus, the theoretical number for required 1X dynos is 3.
For 2X dynos it’s just 1 (the formula above gives 0.56).

We recommend to analyze the application size and try to reduce it (e.g., drop unused gems, disable parts of the application for the AnyCable process) in order to leave more RAM for WebSocket connections.

For HTTP RPC mode, the formula is the same, but with $R=0$.

### Preboot and load balancing

The formula above doesn’t take into account load balancing with [Preboot](https://devcenter.heroku.com/articles/preboot), which could result in a non-uniform distribution of the connections across the dynos. We noticed the difference up to 2x-3x between the number of connections after deployment with Preboot.

From the [Preboot docs](https://devcenter.heroku.com/articles/preboot#preboot-in-manual-or-automatic-dyno-restarts):

> The new dynos will start receiving requests as soon as it binds to its assigned port. At this point, both the old and new dynos are receiving requests.

Thus, the lag between new dynos startup causes some dynos to receive new connections before others.

If it’s possible, it’s better to perform deployments during off-peak hours to minimize the unbalancing effect of Preboot and avoid having one dyno serving much more connections than others.

### Open files limit

One thing you should also take into account is OS-level limits. One such limit is the open files limit (the total number of allowed file descriptors, including sockets).

For 1X/2X dynos this limit is 10k. That means that the max number of connections  is ~9500 (we need some room for RPC connections, logs, DB connections, etc).

**NOTE:** It’s impossible to change system limits on Heroku.

Thus, the max practical number of connections per dyno is 9k.

## Integration

### Datadog

1. Install [Datadog agent to Heroku](https://docs.datadoghq.com/agent/basic_agent_usage/heroku)
2. Add environment variable for AnyCable to send metrics via StatsD to Datadog

```sh
heroku config:add ANYCABLE_STATSD_HOST=localhost:8125
```

In case, you've changed default port of Datadog agent set your port.

3. Restart the application
4. Open `https://DATADOG_SITE/metric/explorer`. `DATADOG_SITE` is the domain where your Datadog account is registered. [Read more](https://docs.datadoghq.com/getting_started/site/)
5. Type any `anycable_go.*` metric name

## Links

- [Demo application](https://github.com/anycable/anycable_rails_demo/pull/4)
- [Deployed application](http://demo.anycable.io/)

[heroku.rake]: https://github.com/anycable/anycable_rails_demo/blob/demo/heroku/lib/tasks/heroku.rake
