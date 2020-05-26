# Kubernetes deployment

## Dependencies

### Get a Kubernetes Cluster

Get a Kubernetes cluster in some cloud service

### Install Kompose

Compose translates docker-compose files to Kubernetes resources

Linux
```
curl -L https://github.com/kubernetes/kompose/releases/download/v1.20.0/kompose-linux-amd64 -o kompose
```

macOS
```
curl -L https://github.com/kubernetes/kompose/releases/download/v1.20.0/kompose-darwin-amd64 -o kompose
```

```
chmod +x kompose
sudo mv ./kompose /usr/local/bin/kompose
```

Note: In Kompose 1.21.0 deployments are not being created, and only listens to local https port 6443 without the "--server" flag

## Deployment

Run kubectl proxy
```
kubectl proxy --port=8080
```

Deploy
```
kompose up --push-image=false
```

## Delete deployment

```
kompose down
```