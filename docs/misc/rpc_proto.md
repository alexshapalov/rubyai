# AnyCable RPC Protobuf

> Source code is available in [the repo](https://github.com/anycable/anycable/blob/master/protos/rpc.proto).

This is a `.proto` file that should be used to generate AnyCable clients/servers:

```protobuf
syntax = "proto3";

package anycable;

service RPC {
  // Connect is called when a client connection is established to authenticate it
  rpc Connect (ConnectionRequest) returns (ConnectionResponse) {}
  // Command is called when authenticated client sends a message (subscribe, unsubscribe, perform)
  rpc Command (CommandMessage) returns (CommandResponse) {}
  // Disconnect is called when a client connection is closed
  rpc Disconnect (DisconnectRequest) returns (DisconnectResponse) {}
}

// Every response contains a status field with one of the following values
enum Status {
  // RPC called failed unexpectedly
  ERROR = 0;
  // RPC called succeed, action was performed
  SUCCESS = 1;
  // RPC called succeed but actions was rejected by the application (e.g., rejected subscription/connection)
  FAILURE = 2;
}

// Env represents a client connection information passed to RPC server
message Env {
  // Underlying HTTP request URL
  string url = 1;
  // Underlying HTTP request headers
  map<string,string> headers = 2;
  // Connection-level metadata
  map<string,string> cstate = 3;
  // Channel-level metadata (only set for Command calls, contains data for the affected subscription)
  map<string,string> istate = 4;
}

// EnvResponse contains the changes made to the connection or channel state,
// that must be applied to the state
message EnvResponse {
  map<string,string> cstate = 1;
  map<string,string> istate = 2;
}

// ConnectionRequest describes a payload for the Connect call
message ConnectionRequest {
  Env env = 3;
}

// ConnectionResponse describes a response of the Connect call
message ConnectionResponse {
  Status status = 1;
  // Connection identifiers passed as string (in most cases, JSON)
  string identifiers = 2;
  // Messages to be sent to the client
  repeated string transmissions = 3;
  // Error message in case status is ERROR or FAILURE
  string error_msg = 4;
  EnvResponse env = 5;
}

// ConnectionMesssage describes a payload for the Command call
message CommandMessage {
  // Name of the command ("subscribe", "unsubscribe", "message" for Action Cable)
  string command = 1;
  // Subscription identifier (channel id, channel params)
  string identifier = 2;
  // Client's connection identifiers (received in ConnectionResponse)
  string connection_identifiers = 3;
  // Command payload
  string data = 4;
  Env env = 5;
}

// CommandResponse describes a response of the Command call
message CommandResponse {
  Status status = 1;
  // If true, the client must be disconencted
  bool disconnect = 2;
  // If true, the client must be unsubscribed from all streams from this subscription
  bool stop_streams = 3;
  // List of the streams to subscribe the client to
  repeated string streams = 4;
  // Messages to be sent to the client
  repeated string transmissions = 5;
  string error_msg = 6;
  EnvResponse env = 7;
  // List of the stream to unsubscribe the client from
  repeated string stopped_streams = 8;
}

// DisconnectRequest describes a payload for the Disconnect call
message DisconnectRequest {
  string identifiers = 1;
  // List of a client's subscriptions (identifiers).
  // Required to call `unsubscribe` callbacks.
  repeated string subscriptions = 2;
  Env env = 5;
}

// DisconnectResponse describes a response of the Disconnect call
message DisconnectResponse {
  Status status = 1;
  string error_msg = 2;
}
```
