# Render Deployment

> Original version of this guide could be found in the PR: [anycable/docs.anycable.io#35](https://github.com/anycable/docs.anycable.io/pull/35).

The easiest way to deploy AnyCable + Rails apps to Render.com is by having three services:

* **Rails app** -- Web Service (public) -- Ruby environment
* **Same rails app running gRPC** - Private Service -- Ruby environment
* **AnyCable-Go server** -- Web Service (public) -- Docker environment

It's likely doable to combine the two Rails app instances (public and grpc) into a single server, but I'll leave that exercise to the reader.

## Assumptions

* You've followed the standard Rails setup and run the excellent installer script (see [Getting started with Rails](../rails/getting_started.md)).
* You are using a custom domain and have DNS control, so you can create a subdomain.
* You are using Devise/Warden for authentication in your Rails app (if you're using something else, I'll leave it to you to figure out what is needed to make AnyCable work with your auth scheme.)
* You are using `redis_session_store` for sessions.

## Rails Web Service

We're going to call our Rails app **"xylophone"** for the remainder of this guide.

Provision the normal public Rails app web service as you usually would on Render. I'm also assuming you've provisioned a Redis server; remember the `REDIS_URL` because we'll need it later.

We're going to assume you set up your custom domain under _Settings_ (e.g. `xylophone.com`)

## gRPC Private Service

The gRPC app is just going to be your same Rails app again, but this time running on a _private_ service, communicating internally with your AnyCable service.

We're going to provision it with the name `xylophone-grpc`.

Under **Environment**, you will likely want to set the following:

* `RAILS_MASTER_KEY` (same as on your public app service)
* `REDIS_URL` (same as on your public app service)

Under **Settings**, set the following:

* Build Command: `bundle install`
* Start Command: `bundle exec anycable --rpc-host 0.0.0.0:50051`

Once your grpc app service is provisioned, it should provide an _internal_ service name like `xylophone-grpc:50051` ... remember this because you'll need it later.

## AnyCable-Go Web Service

AnyCable is going to be deployed as a simple Docker application on Render. The easiest way to do this is create a `anycable-go` directory on your local machine that literally _only_ has a `Dockerfile` in it.

### `Dockerfile`

```dockerfile
FROM anycable/anycable-go:1.2
```

Now push that directory to a git repo so Render will be able to connect to it.

Back to Render dashboard, click New+ and create a `Web Service` (it's going to be publicly available because this is the server that your clients' browser will hit up with websocket requests.) Make sure to connect to your new anycable-go repo with the Dockerfile. Render should auto-detect that it's a Docker app and build it for you. You'll need some settings though...

### Render Settings

Under **Environment**:

* set `ANYCABLE_HOST` to `0.0.0.0`
* set `ANYCABLE_RPC_HOST` to `xylophone-grpc:50051` (the internal service name from before)
* set `REDIS_URL` to the same redis url for your other services (e.g. `redis://red-abc123abc123abc123:6379`)

Under **Settings**:

You shouldn't really need to change much here. Just make sure you've set up your custom domain with a reasonable subdomain, e.g. `ws.xylophone.com`.

## Wiring some things together

Now that you've got all three services running, you need to go back to the public Rails web service and tell it what ActionCable URL to give to clients.

This assumes that your `production.rb` has something like this:

```ruby
config.after_initialize do
  config.action_cable.url = ENV.fetch("CABLE_URL", "/cable") if AnyCable::Rails.enabled?
end
```

If so, all you need to do on Render is change the Rails app **Environment** variables again:

* Set `CABLE_URL` to your new anycable service (e.g. `wss://ws.xylophone.com/cable`)

(_Don't forget the **/cable** at the end!_)

With that, your services should now all be able to talk to each other. However, you may run into some issues:

## cable.yml

If you haven't already, make sure you've setup `cable.yml` properly for production:

```yml
production:
  adapter: any_cable
```

## redis-session-store config

If, like me, you're using the `redis-session-store` gem for session handling, you may need to tweak the config some...

```ruby
Rails.application.config.session_store(
  :redis_session_store,
  key: "_session_#{Rails.env}",
  serializer: :json,
  domain: :all, # <-- THIS IS IMPORTANT
  redis: {
    expire_after: 1.year,
    ttl: 1.year,
    key_prefix: "xylophone:session:",
    url: ENV["REDIS_URL"]
  }
)
```

⚠️ Note the change to `domain: :all`. This ensures that your clients' session cookie key can be shared between your primary domain (`xylophone.com`) and your websocket subdomain (`ws.xylophone.com`)

See also [Authentication](../rails/authentication.md).
