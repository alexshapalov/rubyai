# Kubernetes Deployment

> Check out our [Kuby plugin][kuby-anycable] and read the [Kubing Rails: stressless Kubernetes deployments with Kuby](https://evilmartians.com/chronicles/kubing-rails-stressless-kubernetes-deployments-with-kuby) blog post.

## AnyCable-Go

AnyCable-Go can be easily deployed to your Kubernetes cluster using Helm and [our official Helm chart][anycable-helm].

- Add it as a dependency to your main application:

  ```yaml
  # Chart.yaml for Helm 3
  dependencies:
  - name: anycable-go
    version: 0.2.4
    repository: https://helm.anycable.io/
```

Check the latest Helm chart version at [github.com/anycable/anycable-helm/releases](https://github.com/anycable/anycable-helm/releases).

And execute

```sh
helm dependencies update
```

- And then configure it in your application values within `anycable-go` section:

```yaml
# values.yaml

# Configuration for the external Helm chart "anycable/anycable-go"
anycable-go:
  env:
    # Assuming that Ruby RPC is available in K8s in the same namespace as anycable-rpc service (see next chapter)
    anycableRpcHost: anycable-rpc:50051
  ingress:
    enable: true
    path: /cable

# values/production.yaml
anycable-go:
  env:
    # Assuming that Redis is available in K8s in the same namespace as redis-anycable service
    anycableRedisUrl: redis://:CHANGE-THE-PASSWORD@redis-anycable:6379/0
  ingress:
    acme: # if you're using Let's Encrypt
      hosts:
        - your-app.com
```

Read the [chart’s README][anycable-helm] for more info.

## AnyCable-Go Pro

Installation process for Pro version is almost identical to the non-Pro one. There are the following changes:

- Use Helm chart version `>= 0.5.1`.

- The `image` section of configuration values MUST contain `pullSecrets` section where you place credentials for private docker repository access:

  ```yaml
  # values.yaml
  anycable-go:
    image:
      repository: ghcr.io/anycable/anycable-go-pro
      tag: edge
      pullSecrets:
        enabled: true
        registry: "ghcr.io"
        username: "username"
        password: "github-token-here"
  ```

You can get a list of available `anycable-go-pro` image versions using the following command:

```sh
curl -X GET -H "Authorization: Bearer $(echo "github-token-here" | base64)" https://ghcr.io/v2/anycable/anycable-go-pro/tags/list
```

Read the [chart’s README][anycable-helm] for more info.

## RPC server

To run Ruby counterpart of AnyCable which will handle connection authentication and execute your business logic we need to create a separate deployment and a corresponding service for it.

- [**Deployment**](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/) that will spin up a required number of pods and handle rolling restarts on deploys

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: anycable-rpc
  labels:
    component: anycable-rpc
spec:
  replicas: 1
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1
      maxSurge: 0
  selector:
    matchLabels:
      component: anycable-rpc
  template:
    metadata:
      labels:
        component: anycable-rpc
    spec:
      containers:
        - name: anycable-rpc
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          imagePullPolicy: IfNotPresent
          command:
            - bundle
            - exec
            - anycable
            # you should define these parameters in the values.yml file, we give them here directly for readability
            - --rpc-host=0.0.0.0:50051
          env:
            - name: ANYCABLE_REDIS_URL
              valueFrom:
                secretKeyRef:
                  name: "anycable-go-secrets"
                  key: anycableRedisUrl
            # And all your application ENV like DATABASE_URL etc
```

- [**Service**](https://kubernetes.io/docs/concepts/services-networking/service/) to connect anycable-go with RPC server.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: anycable-rpc
  labels:
    component: anycable-rpc
spec:
  selector:
    component: anycable-rpc
  type: ClusterIP
  # Uncomment this line if you're using the DNS-based load balancing
  # clusterIP: None
  ports:
    # you should define these parameters in the values.yml file, we give them here directly for readability
    - port: 50051
      targetPort: 50051
      protocol: TCP
```

- (Optional) [**network policy**](https://kubernetes.io/docs/concepts/services-networking/network-policies/) will restrict access to pods running RPC service to only those that run AnyCable-Go daemon in the same namespace.

```yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: anycable-go-and-rpc-connectivity
spec:
  podSelector:
    matchLabels:
      component: anycable-rpc
  ingress:
    - from:
        - podSelector:
            matchLabels:
              component: anycable-go
```

See detailed explanation in the docs and in this example: [Kubernetes network policy recipes: deny traffic from other namespaces](https://github.com/ahmetb/kubernetes-network-policy-recipes/blob/60f5b12f274472901ce79463ce0ba3a8f98b9a48/04-deny-traffic-from-other-namespaces.md)

[anycable-helm]: https://github.com/anycable/anycable-helm/ "Helm charts for installing any cables into a Kubernetes cluster"
[kuby-anycable]: https://github.com/anycable/kuby-anycable
