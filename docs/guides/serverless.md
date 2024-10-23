# Using AnyCable to power serverless JavaScript applications

AnyCable is a great companion for your serverless JavaScript (and TypeScript) applications needing real-time features. It can be used as a real-time server with no strings attached: no vendor lock-in, no microservices spaghetti, no unexpected PaaS bills. Keep your logic in one place (your JS application) and let AnyCable handle the low-level stuff.

## Overview

To use AnyCable with a serverless JS application, you need to:

- Deploy AnyCable server to a platform of your choice (see [below](#deploying-anycable)).
- Configure AnyCable API handler in your JS application.
- Use [AnyCable Client SDK][anycable-client] to communicate with the AnyCable server from your client.

<picture class="captioned-figure">
     <source srcset="/assets/serverless-dark.png" media="(prefers-color-scheme: dark)">
     <img align="center" alt="AnyCable + Node.js serverless architecture" style="max-width:80%" title="AnyCable + Node.js serverless architecture" src="/assets/serverless-light.png">
</picture>

AnyCable will handle WebSocket/SSE connections and translate incoming commands into API calls to your serverless functions, where you can manage subscriptions and respond to commands.

Broadcasting real-time updates is as easy as performing POST requests to AnyCable.

Luckily, you don't need to write all this code from scratch. Our JS SDK makes it easy to integrate AnyCable with your serverless application.

### Standalone real-time server

You can run AnyCable in a standalone mode by using [signed pub/sub streams](../anycable-go/signed_streams.md) and [JWT authentication](../anycable-go/jwt_identification.md). In this case, all real-time actions are pre-authorized and no API handlers are required.

> Check out this Next.js demo chat application running fully within Stackblitz and backed by AnyCable pub/sub streams: [![Open in StackBlitz](https://developer.stackblitz.com/img/open_in_stackblitz.svg)](https://stackblitz.com/edit/anycable-pubsub?file=README.md)

## AnyCable Serverless SDK

[AnyCable Serverless SDK][anycable-serverless-js] is a Node.js package that provides a set of helpers to integrate AnyCable into your JavaScript backend application.

> Check out our demo Next.js application to see the complete example: [vercel-anycable-demo][]

AnyCable Serverless SDK contains the following components:

- JWT authentication and signed streams.
- Broadcasting.
- Channels.

### JWT authentication

AnyCable support [JWT-based authentication](../anycable-go/jwt_identification.md). With the SDK, you can generate tokens as follows:

```js
import { identificator } from "@anycable/serverless-js";

const jwtSecret = "very-secret";
const jwtTTL = "1h";

export const identifier = identificator(jwtSecret, jwtTTL);

// Then, somewhere in your code, generate a token and provide it to the client
const userId = authenticatedUser.id;
const token = await identifier.generateToken({ userId });
```

### Signed streams

SDK provides functionality to generate [signed stream names](/anycable-go/signed_streams). For that, you can create a _signer_ instance with the corresponding secret:

```js
import { signer } from "@anycable/serverless-js";

const streamsSecret = process.env.ANYCABLE_STREAMS_SECRET;

const sign = signer(secret);

const signedStreamName = sign("room/13");
```

Then, you can use the generated stream name with your client (using [AnyCable JS client SDK](https://github.com/anycable/anycable-client)):

```js
import { createCable } from "@anycable/web";

const cable = createCable(WEBSOCKET_URL);
const stream = await fetchStreamForRoom("13");

const channel = cable.streamFromSigned(stream);
channel.on("message", (msg) => {
  // handle notification
})
```

### Broadcasting

SDK provides utilities to publish messages to AnyCable streams via HTTP:

```js
import { broadcaster } from "@anycable/serverless-js";

// Broadcasting configuration
const broadcastURL =
  process.env.ANYCABLE_BROADCAST_URL || "http://127.0.0.1:8090/_broadcast";
const broadcastKey = process.env.ANYCABLE_BROADCAST_KEY || "";

// Create a broadcasting function to send broadcast messages via HTTP API
export const broadcastTo = broadcaster(broadcastURL, broadcastKey);

// Now, you can use the initialized broadcaster to publish messages
broadcastTo("chat/42", message);
```

Learn more about [broadcasting](../anycable-go/broadcasting.md).

### Channels

Channels help to encapsulate your real-time logic and enhance typical pub/sub capabilities with the ability to handle incoming client commands.

For example, a channel representing a chat room may be defined as follows:

```js
import { Channel } from "@anycable/serverless-js";

export default class ChatChannel extends {
  // The `subscribed` method is called when the client subscribes to the channel
  // You can use it to authorize the subscription and set up streaming
  async subscribed(handle, params) {
    // Subscribe requests may contain additional parameters.
    // Here, we require the `roomId` parameter.
    if (!params?.roomId) {
      handle.reject();
      return;
    }

    // We set up a subscription; now, the client will receive real-time updates
    // sent to the `room:${params.roomId}` stream.
    handle.streamFrom(`room:${params.roomId}`);
  }

  // This method is called by the client
  async sendMessage(handle, params, data) {
    const { body } = data;

    if (!body) {
      throw new Error("Body is required");
    }

    const message = {
      id: Math.random().toString(36).substr(2, 9),
      body,
      createdAt: new Date().toISOString(),
    };

    // Broadcast the message to all subscribers (see below)
    await broadcastTo(`room:${params.roomId}`, message);
  }
}
```

Channels are registered within an _application_ instance, which can also be used to authenticate connections (if JWT is not being used):

```js
import { Application } from "@anycable/serverless-js";

import ChatChannel from "./channels/chat";

// Application instance handles connection lifecycle events
class CableApplication extends Application {
  async connect(handle) {
    // You can access the original WebSocket request data via `handle.env`
    const url = handle.env.url;
    const params = new URL(url).searchParams;

    if (params.has("token")) {
      const payload = await verifyToken(params.get("token")!);

      if (payload) {
        const { userId } = payload;

        // Here, we associate user-specific data with the connection
        handle.identifiedBy({ userId });
      }
      return;
    }

    // Reject connection if not authenticated
    handle.reject();
  }

  async disconnect(handle: ConnectionHandle<CableIdentifiers>) {
    // Here you can perform any cleanup work
    console.log(`User ${handle.identifiers?.userId} disconnected`);
  }
}

// Create an instance of the class to use in HTTP handlers (see the next section)
const app = new CableApplication();

// Register channel
app.register("chat", ChatChannel);
```

To connect your channels to an AnyCable server, you MUST add AnyCable API endpoint to your HTTP server (or serverless function). The SDK provides HTTP handlers for that.

Here is an example setup for Next.js via [Vercel serverless functions](https://vercel.com/docs/functions/serverless-functions):

```js
// api/anycable/route.ts
import { NextResponse } from "next/server";
import { handler, Status } from "@anycable/serverless-js";

// Your cable application instance
import app from "../../cable";

export async function POST(request: Request) {
  try {
    const response = await handler(request, app);
    return NextResponse.json(response, {
      status: 200,
    });
  } catch (e) {
    console.error(e);
    return NextResponse.json({
      status: Status.ERROR,
      error_msg: "Server error",
    });
  }
}
```

You can use our [AnyCable Client SDK][anycable-client] on the client side. The corresponding code may look like this:

```js
import { createCable, Channel } from "@anycable/web";

//Set up a connection
export const cable = createCable();

//Define a client-side class for the channel
export class ChatChannel extends Channel {
  static identifier = "chat";

  sendMessage(message: SentMessage) {
    this.perform("sendMessage", message);
  }
}

// create a channel instance
const channel = new ChatChannel({ roomId });
// subscribe to the server-side channel
cable.subscribe(channel);

channel.on("message", (message) => {
  console.log("New message", message);
});

// perform remote commands
channel.sendMessage({ body: "Hello, world!" });
```

**NOTE:** Both serverless and client SDKs support TypeScript so that you can leverage the power of static typing in your real-time application.

## Deploying AnyCable

> The quickest way to get AnyCable is to use our managed (and free) solution: [plus.anycable.io](https://plus.anycable.io)

AnyCable can be deployed anywhere from modern clouds to good old bare-metal servers. Check out the [deployment guide](../deployment.md) for more details. We recommend using [Fly][], as you can deploy AnyCable in a few minutes with just a single command:

```sh
fly launch --image anycable/anycable-go:1.5 --generate-name --ha=false \
  --internal-port 8080 --env PORT=8080 \
  --env ANYCABLE_SECERT=<YOUR_SECRET> \
  --env ANYCABLE_PRESETS=fly,broker \
  --env ANYCABLE_RPC_HOST=https://<YOUR_JS_APP_HOSTNAME>/api/anycable
```

## Running AnyCable locally

There are plenty of ways of installing `anycable-go` binary on your machine (see [../anycable-go/getting_started.md]). For your convenience, we also provide an NPM package that can be used to install and run `anycable-go`:

```sh
npm install --save-dev @anycable/anycable-go
pnpm install --save-dev @anycable/anycable-go
yarn add --dev @anycable/anycable-go

# and run as follows
npx anycable-go
```

**NOTE:** The version of the NPM package is the same as the version of the AnyCable-Go binary (which is downloaded automatically on the first run).

[vercel-anycable-demo]: https://github.com/anycable/vercel-anycable-demo
[Fly]: https://fly.io
[anycable-serverless-js]: https://github.com/anycable/anycable-serverless-js
[anycable-client]: https://github.com/anycable/anycable-client
