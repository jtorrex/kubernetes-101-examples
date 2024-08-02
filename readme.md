# Kubernetes 101

## Installing the basic tools

Firs, we need to install, the packages needed for the lab:

- git
- docker
- kind
- kubectl

This step can vary depending of your Linux distro.

* Installing git

`sudo apt-get install git`

* Installing docker

```
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
docker version
```

* Installing kind

```
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind version
```

* Installing kubectl

```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
kubectl version
```

## Examples repository

Clone the examples repository

```
git clone https://bitbucket.com/sxxx
```

## Creating the cluster

For creating a local cluster using kind execute:

`kind create cluster --config kind/kind.yaml`

After the cluster is created, setup the context for allow kubectl on communicating to the API

```
kubectl cluster-info --context kind-test-cluster
```

## Basic kubectl commands

* Obtain the version of the cluster

```
kubectl version
```

* Verify the nodes of the cluster

```
kubectl get nodes
```

* Verify the namespaces on the cluster

```
kubectl get namespaces
```

* Verify all the pods in the cluster

```
kubectl get pods -A
```

## Creating namespaces

* Create the namespaces defined in the exampels/namespaces.yaml

```
kubectl apply -f examples/namespaces.yaml
```

* Verify the namespaces on the cluster

```
kubectl get namespaces
NAME                 STATUS   AGE
default              Active   100m
kube-node-lease      Active   100m
kube-public          Active   100m
kube-system          Active   100m
local-path-storage   Active   100m
operations           Active   3s
rnd                  Active   3s
support              Active   3s
```

* Now delete the rnd namespace

```
kubectl delete namespace rnd
```

* Verify again the existant namespaces

```
kubectl get namespaces
NAME                 STATUS   AGE
default              Active   100m
kube-node-lease      Active   100m
kube-public          Active   100m
kube-system          Active   100m
local-path-storage   Active   100m
operations           Active   3m29s
support              Active   3m29s
```

* Recreate again the rnd namespace by applying the manifest again

```
kubectl apply -f examples/namespaces.yaml
```

## Creating a Pod

* Create a basic Pod based on the manifest example/kuard-pod.yaml

```
kubectl apply -f examples/kuard-pod.yaml

```

* Verify that the pod is running

```
kubectl get pods

```

* Describe the current Pod running

```
kubectl describe pod kuard

```

* If we ping the Pod, we shouldnt reach it, as it's working in the cluster internal network

```
ping 10.244.3.2
PING 10.244.3.2 (10.244.3.2) 56(84) bytes of data.
^C
--- 10.244.3.2 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms

```

* Lets forward the traffic using kubectl

```
kubectl port-forward pods/kuar 8080:8080
```

* Verify that now you can reach the exposed port of the Pod in the internal cluster network

```
curl http://127.0.0.1:8080
<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">

  <title>KUAR Demo</title>

  <link rel="stylesheet" href="/static/css/bootstrap.min.css">
  <link rel="stylesheet" href="/static/css/styles.css">

```

* You can also check the service exposed by the Pod

[Kuard Dashboard](http://127.0.0.1:8080)

* Remove the created Pod

```
kubectl delete pod kuard
```

## Adding a Pod healthcheck

* Now, lets deploy the kuard Pod but with HealthChecks

```
kubectl apply -f examples/kuard-pod-health.yaml

```

* When the Pod is running, forward again their 8080 port

```
kubectl port-forward pods/kuar 8080:8080
```

* Access the Dashboard

[Kuard Dashboard](http://127.0.0.1:8080)

* Check the Liveness Probe tab and you should see the probes that the Pod has received from the Liveness check

* If you click the Fail link on that page, kuard will start to fail healthchecks

* Wait long enough and Kubernetes will restart the container

* Events can be checked by running

```
kubectl describe pods kuard
```

* On the events section

```
Events:
  Type     Reason     Age                 From               Message
  ----     ------     ----                ----               -------
  Normal   Scheduled  4m18s               default-scheduler  Successfully assigned default/kuard to test-cluster-worker3
  Normal   Pulling    4m18s               kubelet            Pulling image "gcr.io/kuar-demo/kuard-amd64:blue"
  Normal   Pulled     4m3s                kubelet            Successfully pulled image "gcr.io/kuar-demo/kuard-amd64:blue" in 14.585s (14.585s including waiting). Image size: 11481802 bytes.
  Normal   Created    18s (x2 over 4m3s)  kubelet            Created container kuard
  Normal   Started    18s (x2 over 4m3s)  kubelet            Started container kuard
  Warning  Unhealthy  18s (x3 over 38s)   kubelet            Liveness probe failed: HTTP probe failed with statuscode: 500
  Normal   Killing    18s                 kubelet            Container kuard failed liveness probe, will be restarted
  Normal   Pulled     18s                 kubelet            Container image "gcr.io/kuar-demo/kuard-amd64:blue" already present on machine
```

* Delete the kuard pod

```
kubectl delete pod kuard
```

## Adding resources to Pods

* To request a hardware assignation for each container running inside a Pod, we need to add the resources section in the Pod manifest

```
   resources:
        requests:
          cpu: "500m"
          memory: "128Mi"
        limits:
          cpu: "1000m"
          memory: "256Mi"
```
* This section defines the minimum "request" of resources, and the limit that the containers inside the Pod can consume
* Apply the next manifest to resquest a Pod requesting a concrete ammount of resources

```
kubectl apply -f examples/kuard-pod-resources.yaml
```

* Verify the resources assigned to the Pod

```
kubectl describe pod kuard
-test-cluster
```

## Basic kubectl commands

* Obtain the version of the cluster

```
kubectl version
```

* Verify the nodes of the cluster

```
kubectl get nodes
```

* Verify the namespaces on the cluster

```
kubectl get namespaces
```

* Verify all the pods in the cluster

```
kubectl get pods -A
```

## Creating namespaces

* Create the namespaces defined in the exampels/namespaces.yaml

```
kubectl apply -f examples/namespaces.yaml
```

* Verify the namespaces on the cluster

```
kubectl get namespaces
NAME                 STATUS   AGE
default              Active   100m
kube-node-lease      Active   100m
kube-public          Active   100m
kube-system          Active   100m
local-path-storage   Active   100m
operations           Active   3s
rnd                  Active   3s
support              Active   3s
```

* Now delete the rnd namespace

```
kubectl delete namespace rnd
```

* Verify again the existant namespaces

```
kubectl get namespaces
NAME                 STATUS   AGE
default              Active   100m
kube-node-lease      Active   100m
kube-public          Active   100m
kube-system          Active   100m
local-path-storage   Active   100m
operations           Active   3m29s
support              Active   3m29s
```

* Recreate again the rnd namespace by applying the manifest again

```
kubectl apply -f examples/namespaces.yaml
```

## Creating a Pod

* Create a basic Pod based on the manifest example/kuard-pod.yaml

```
kubectl apply -f examples/kuard-pod.yaml

```

* Verify that the pod is running

```
kubectl get pods

```

* Describe the current Pod running

```
kubectl describe pod kuard

```

* If we ping the Pod, we shouldnt reach it, as it's working in the cluster internal network

```
ping 10.244.3.2
PING 10.244.3.2 (10.244.3.2) 56(84) bytes of data.
^C
--- 10.244.3.2 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms

```

* Lets forward the traffic using kubectl

```
kubectl port-forward pods/kuar 8080:8080
```

* Verify that now you can reach the exposed port of the Pod in the internal cluster network

```
curl http://127.0.0.1:8080
<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">

  <title>KUAR Demo</title>

  <link rel="stylesheet" href="/static/css/bootstrap.min.css">
  <link rel="stylesheet" href="/static/css/styles.css">

```

* You can also check the service exposed by the Pod

[Kuard Dashboard](http://127.0.0.1:8080)

* Remove the created Pod

```
kubectl delete pod kuard
```

## Adding a Pod healthcheck

* Now, lets deploy the kuard Pod but with HealthChecks

```
kubectl apply -f examples/kuard-pod-health.yaml

```

* When the Pod is running, forward again their 8080 port

```
kubectl port-forward pods/kuar 8080:8080
```

* Access the Dashboard

[Kuard Dashboard](http://127.0.0.1:8080)

* Check the Liveness Probe tab and you should see the probes that the Pod has received from the Liveness check

* If you click the Fail link on that page, kuard will start to fail healthchecks

* Wait long enough and Kubernetes will restart the container

* Events can be checked by running

```
kubectl describe pods kuard
```

* On the events section

```
Events:
  Type     Reason     Age                 From               Message
  ----     ------     ----                ----               -------
  Normal   Scheduled  4m18s               default-scheduler  Successfully assigned default/kuard to test-cluster-worker3
  Normal   Pulling    4m18s               kubelet            Pulling image "gcr.io/kuar-demo/kuard-amd64:blue"
  Normal   Pulled     4m3s                kubelet            Successfully pulled image "gcr.io/kuar-demo/kuard-amd64:blue" in 14.585s (14.585s including waiting). Image size: 11481802 bytes.
  Normal   Created    18s (x2 over 4m3s)  kubelet            Created container kuard
  Normal   Started    18s (x2 over 4m3s)  kubelet            Started container kuard
  Warning  Unhealthy  18s (x3 over 38s)   kubelet            Liveness probe failed: HTTP probe failed with statuscode: 500
  Normal   Killing    18s                 kubelet            Container kuard failed liveness probe, will be restarted
  Normal   Pulled     18s                 kubelet            Container image "gcr.io/kuar-demo/kuard-amd64:blue" already present on machine
```

* Delete the kuard pod

```
kubectl delete pod kuard
```

## Adding resources to Pods

* To request a hardware assignation for each container running inside a Pod, we need to add the resources section in the Pod manifest

```
   resources:
        requests:
          cpu: "500m"
          memory: "128Mi"
        limits:
          cpu: "1000m"
          memory: "256Mi"
```
* This section defines the minimum "request" of resources, and the limit that the containers inside the Pod can consume
* Apply the next manifest to resquest a Pod requesting a concrete ammount of resources

```
kubectl apply -f examples/kuard-pod-resources.yaml
```

* Verify the resources assigned to the Pod

```
kubectl get pods kuard -o custom-columns="CPU REQUEST:.spec.containers[*].resources.requests.cpu,MEM REQUEST:.spec.containers[*].resources.requests.memory,CPU LIMITS:.spec.containers[*].resources.limits.cpu,MEM LIMITS:.spec.containers[*].resources.limits.memory"
```

* Now delete the Pod

```
kubectl delete pod kuard
```

## Adding labels and annotations to Pods

* Apply the manifest for create 3 pods labeled differently between them

```
kubetl apply -f examples/kuard-pod-labels.yaml
```

* Verify that the pods are running and print it using LABELS

```
kubectl get pods --show-labels
NAME         READY   STATUS    RESTARTS   AGE     LABELS
kuard-pre    1/1     Running   0          3m27s   app=kuard,environment=pre
kuard-prod   1/1     Running   0          3m27s   app=kuard,environment=prod
kuard-test   1/1     Running   0          3m27s   app=kuard,environment=test

```

* Print the Pods labeled as application kuard using the label selector

```
kubectl get pods --selector "app=kuard"
```

* Print the Pod from the prod environment
```
kubectl get pods --selector "environment=prod"
NAME         READY   STATUS    RESTARTS   AGE
kuard-prod   1/1     Running   0          5m21s
```

* Print the Pod from the test environment
```
kubectl get pods --selector "environment=test"
NAME         READY   STATUS    RESTARTS   AGE
kuard-test   1/1     Running   0          5m30s
```

* Destroy the previous pods using a label selector

```
kubectl delete pods --selector "app=kuard"
```

## Node selector

* Label the first worker node on the cluster

```
kubectl label node test-cluster-worker "gpu=nvidia"
node/test-cluster-worker labeled
```

* Label the second worker node on the cluster

```
kubectl label node test-cluster-worker2 "gpu=amd"
node/test-cluster-worker2 labeled
```

* Apply the next Pod manifest where two Pods are deployed, one assigned to the nvidia node and another to the amd node

```
kubectl apply -f examples/kuard-nodeselector.yaml"
```

* Verify where is placed the fist Pod on the Events section

```
kubectl describe pods kuard-pod-nvidia
```

* Verify where is placed the second Pod on the Events section

```
kubectl describe pods kuard-pod-amd
```

* Now delete the Pods

```
kubectl delete -f examples/kuard-nodeselector.yaml"
```

## Creating a Cluster IP service

* Let's create 3 Kuard pods that are exposed on the 8080 port, and a ClusterIP service

```
kubectl apply -f examples/kuard-service-clusterip.yaml
```

* List the Pods and Services within the cluster

```
kubectl get pods && kubectl get svc
NAME                  READY   STATUS    RESTARTS   AGE
kuard-pod-internal    1/1     Running   0          102s
kuard-pod-published   1/1     Running   0          102s

NAME                TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)   AGE
clusterip-service   ClusterIP   10.96.240.73   <none>        80/TCP    102s
kubernetes          ClusterIP   10.96.0.1      <none>        443/TCP   3h6m
```

* Get the IP of the published Pod

```
kubectl describe pods kuard-pod-published | grep IP
IP:               10.244.2.5
IPs:
  IP:  10.244.2.5
```

* Describe the service created
```
kubectl describe svc clusterip-service
Name:              clusterip-service
Namespace:         default
Labels:            app=public
Annotations:       <none>
Selector:          app=public
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.96.240.73
IPs:               10.96.240.73
Port:              <unset>  80/TCP
TargetPort:        8080/TCP
Endpoints:         10.244.2.5:8080
Session Affinity:  None
Events:            <none>
```

* Note that the endpoint is set to the published Pod IP, but the IP of the service is internal

* Delete the published Pod

```
kubectl delete pod kuard-pod-published
```

* Recreate it applying again the manifest and grep the IP

```
kubectl apply -f kuard-pod-published.yaml

```

```
kubectl describe pods kuard-pod-published | grep IP
IP:               10.244.3.7
IPs:
  IP:  10.244.3.7
```

* Describe again the Service to see that the service tracks the new IP of the recreated POD using the same IP

```
jtorrex@archhpcnow/kubernetes-101-examples/examples ❯ kubectl describe svc clusterip-service
Name:              clusterip-service
Namespace:         default
Labels:            app=public
Annotations:       <none>
Selector:          app=public
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.96.240.73
IPs:               10.96.240.73
Port:              <unset>  80/TCP
TargetPort:        8080/TCP
Endpoints:         10.244.3.7:8080
Session Affinity:  None
Events:            <none>
```

* Delete both the Pods and the Service

```
kubectl delete -f kuard-service-clusterip.yaml
```

## Creating a NodePort service

* Apply the manifest to create a sample Pod and a Service of type NodePort

```
kubectl apply -f kuard-service-nodeport.yaml
```

* Verify the information about the Pod and check in which Node is running

```
kubectl get pods -o wide
NAME                  READY   STATUS    RESTARTS   AGE     IP           NODE                  NOMINATED NODE   READINESS GATES
kuard-pod-published   1/1     Running   0          8m30s   10.244.3.8   test-cluster-worker   <none>           <none>

```

* Verify the information about the NodePort Service created, serviec should be published on the 30080 port of the Node

```
kubectl get svc -o wide
NAME               TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)          AGE     SELECTOR
kubernetes         ClusterIP   10.96.0.1     <none>        443/TCP          4h21m   <none>
nodeport-service   NodePort    10.96.143.1   <none>        8080:30080/TCP   9m5s    app=public

```

* Verify the information about the nodes
```
kubectl get nodes -o wide
NAME                         STATUS   ROLES           AGE     VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION   CONTAINER-RUNTIME
test-cluster-control-plane   Ready    control-plane   4h21m   v1.30.0   172.19.0.5    <none>        Debian GNU/Linux 12 (bookworm)   6.6.33-1-lts     containerd://1.7.15
test-cluster-worker          Ready    <none>          4h20m   v1.30.0   172.19.0.3    <none>        Debian GNU/Linux 12 (bookworm)   6.6.33-1-lts     containerd://1.7.15
test-cluster-worker2         Ready    <none>          4h20m   v1.30.0   172.19.0.4    <none>        Debian GNU/Linux 12 (bookworm)   6.6.33-1-lts     containerd://1.7.15
test-cluster-worker3         Ready    <none>          4h20m   v1.30.0   172.19.0.2    <none>        Debian GNU/Linux 12 (bookworm)   6.6.33-1-lts     containerd://1.7.15

```

* Probe that the Kuard service is available on the all the nodes on the on the selected port of the NodePort service

```
curl http://172.19.0.2:30080
<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">

  <title>KUAR Demo</title>

```

```
curl http://172.19.0.3:30080
<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">

  <title>KUAR Demo</title>

```

```
curl http://172.19.0.4:30080
<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">

  <title>KUAR Demo</title>

```

* Delete the deployment

```
kubectl delete -f kuard-service-nodeport.yaml
pod "kuard-pod-published" deleted
service "nodeport-service" deleted
```
## Creating a LoadBalancer service

* Apply the manifest to create a Deployment of 3 Kuard replicas

```
kubectl apply -f kuard-lb-deployment.yaml
```

* Apply the manifest to crate a Service of type LoadBalancer to publish the service

```
kubectl apply -f kuard-lb-svc.yaml
```

* Verify the information about the Deployment and check in which IPs are running

```
kubectl get pods -o wide
NAME                                            READY   STATUS    RESTARTS        AGE     IP           NODE                   NOMINATED NODE   READINESS GATES
kuard-deployment-76dc59d66c-mxshq               1/1     Running   0               4m18s   10.244.3.6   test-cluster-worker    <none>           <none>
kuard-deployment-76dc59d66c-xmgbf               1/1     Running   0               34m     10.244.2.5   test-cluster-worker3   <none>           <none>
kuard-deployment-76dc59d66c-xwnk7               1/1     Running   0               34m     10.244.1.5   test-cluster-worker2   <none>           <none>
```

* Verify the information about the LoadBalancer Service created, and note the IP assigned to it and the Port that is configured 8080

```
kubectl get svc -o widec,gg,gg
NAME               TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE     SELECTOR
kuard-lb-service   LoadBalancer   10.96.68.254   <pending>     8080:31072/TCP   35m     app=kuard
```

* To verify that the LoadBalancer is running properly, access an internal node of the cluster

```
docker exec -it test-cluster-control-plane /bin/bash
root@test-cluster-control-plane:/#
```

* Now 'curl' the LoadBalancer IP on the Port where the Service is running and check the field 'addrs' that coresponds to the node that is running the Pod

```

root@test-cluster-control-plane:/# curl http://10.96.68.254:8080 | grep addrs
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1466  100  1466    0     0  1002k      0 --:--:-- --:--:-- --:--:-- 1431k
var pageContext = {"hostname":"kuard-deployment-76dc59d66c-xmgbf","addrs":["10.244.2.5"],"version":"v0.8.1-1","versionColor":"hsl(18,100%,50%)","requestDump":"GET / HTTP/1.1\r\nHost: 10.96.68.254:8080\r\nAccept: */*\r\nUser-Agent: curl/7.88.1","requestProto":"HTTP/1.1","requestAddr":"172.19.0.5:20549"}
root@test-cluster-control-plane:/# curl http://10.96.68.254:8080 | grep addrs
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1466  100  1466    0     0   795k      0 --:--:-- --:--:-- --:--:-- 1431k
var pageContext = {"hostname":"kuard-deployment-76dc59d66c-xmgbf","addrs":["10.244.2.5"],"version":"v0.8.1-1","versionColor":"hsl(18,100%,50%)","requestDump":"GET / HTTP/1.1\r\nHost: 10.96.68.254:8080\r\nAccept: */*\r\nUser-Agent: curl/7.88.1","requestProto":"HTTP/1.1","requestAddr":"172.19.0.5:31005"}
root@test-cluster-control-plane:/# curl http://10.96.68.254:8080 | grep addrs
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1466  100  1466    0     0   886k      0 --:--:-- --:--:-- --:--:-- 1431k
var pageContext = {"hostname":"kuard-deployment-76dc59d66c-xwnk7","addrs":["10.244.1.5"],"version":"v0.8.1-1","versionColor":"hsl(18,100%,50%)","requestDump":"GET / HTTP/1.1\r\nHost: 10.96.68.254:8080\r\nAccept: */*\r\nUser-Agent: curl/7.88.1","requestProto":"HTTP/1.1","requestAddr":"172.19.0.5:22786"}

```

* You can note that the traffic is balanced across the nodes as the response is offered from different nodes/IPs

```
10.244.2.5
10.244.1.5
```

* Finally delete the Deployment and the LoadBalancer service


```
kubectl delete -f kuard-lb-deployment.yaml
```

```
kubectl delete -f kuard-lb-svc.yaml
```

## Creating an HTTP Ingress

An Ingress may be configured to give Services externally-reachable URLs, load balance traffic, terminate SSL / TLS, and offer name-based virtual hosting. 

An Ingress controller is responsible for fulfilling the Ingress, usually with a load balancer, though it may also configure your edge router or additional frontends to help handle the traffic.

You must have an Ingress controller to satisfy an Ingress. Only creating an Ingress resource has no effect.

You may need to deploy an Ingress controller such as ingress-nginx. You can choose from a number of Ingress controllers.

* Deploy the NGINX Ingress Controller on the Kind cluster

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

* Verify that the ingress is Deployed properly

```
~ ❯ kubectl get pods -n ingress-nginx
NAME                                       READY   STATUS      RESTARTS   AGE
ingress-nginx-admission-create-zz4fx       0/1     Completed   0          16m
ingress-nginx-admission-patch-ctvj4        0/1     Completed   0          16m
ingress-nginx-controller-d45d995d4-ddch7   1/1     Running     0          16m
```

* Now that the Ingress controler is deployed in the cluster, create these deployments imperatively to run different applications on the cluster

```
kubectl create deployment be-default \
--image=gcr.io/kuar-demo/kuard-amd64:blue \
--replicas=3 \
--port=8080
```

```
kubectl create deployment alpaca \
--image=gcr.io/kuar-demo/kuard-amd64:green \
--replicas=3 \
--port=808
```

```
kubectl create deployment bandicoot \
--image=gcr.io/kuar-demo/kuard-amd64:purple \
--replicas=3 \
--port=8080
```

* Expose each of them to define the different services

```
kubectl expose deployment be-default
kubectl expose deployment alpaca
kubectl expose deployment bandicoot
```

* List the services created

```
kubectl get services -o wide -A
NAMESPACE       NAME                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE   SELECTOR
default         alpaca                               ClusterIP   10.96.214.247   <none>        8080/TCP                     45m   app=alpaca
default         bandicoot                            ClusterIP   10.96.30.123    <none>        8080/TCP                     45m   app=bandicoot
default         be-default                           ClusterIP   10.96.1.4       <none>        8080/TCP                     45m   app=be-default
default         kubernetes                           ClusterIP   10.96.0.1       <none>        443/TCP                      57m   <none>
default         nginx                                ClusterIP   10.96.38.165    <none>        80/TCP                       15m   app=nginx
ingress-nginx   ingress-nginx-controller             NodePort    10.96.71.2      <none>        80:31071/TCP,443:30992/TCP   17m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx
ingress-nginx   ingress-nginx-controller-admission   ClusterIP   10.96.149.234   <none>        443/TCP                      17m   app.kubernetes.io/component=controller,app.kubernetes.io/instance=ingress-nginx,app.kubernetes.io/name=ingress-nginx
kube-system     kube-dns                             ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP,9153/TCP       57m   k8s-app=kube-dns
```

### Simple ingress

* Create a simple Ingress to publish the Alpaca Deployment

```
kubectl apply -f simple-ingress.yaml

```
* Verify that the ingress is properly created

```
kubectl get ingress
NAME             CLASS    HOSTS   ADDRESS   PORTS   AGE
simple-ingress   <none>   *                 80      2m10s
```

* Describe the ingress to view the details about it

```
kubectl describe ingress simple-ingress
Name:             simple-ingress
Labels:           <none>
Namespace:        default
Address:          localhost
Ingress Class:    <none>
Default backend:  alpaca:8080 (10.244.1.3:8080,10.244.2.3:8080,10.244.3.3:8080)
Rules:
  Host        Path  Backends
  ----        ----  --------
  *           *     alpaca:8080 (10.244.1.3:8080,10.244.2.3:8080,10.244.3.3:8080)
Annotations:  <none>
Events:
  Type    Reason  Age                From                      Message
  ----    ------  ----               ----                      -------
  Normal  Sync    12m (x2 over 13m)  nginx-ingress-controller  Scheduled for sync
```

* Add an entry to your /etc/hosts file to route kube.local to 127.0.0.1 to perform local tests over a "domain"

```
echo "127.0.0.1 kube.local" | sudo tee -a /etc/hosts
```

* Forward the port from the Ingress controller service to localhost on port 8080 for testing

```
kubectl port-forward --namespace ingress-nginx svc/ingress-nginx-controller 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

* Curl or navigate to the local http endpoint where the ingress is forwarded to verify that is properly running

[http://alpaca.kube.local:8008]

```
curl http://kube.local:8080
<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">

  <title>KUAR Demo</title>

  <link rel="stylesheet" href="/static/css/bootstrap.min.css">
  <link rel="stylesheet" href="/static/css/styles.css">

  <script>
var pageContext = {"urlBase":"","hostname":"alpaca-7d854b686f-j5v4q","addrs":["10.244.1.3"],"version":"v0.10.0-dirty-green","versionColor":"hsl(3,100%,50%)","requestDump":"GET / HTTP/1.1\r\nHost: kube.local:8080\r\nAccept: */*\r\nUser-Age
```

* Delete the simple Ingress

```
kubectl delete -f simple-ingress.yaml

```

### Ingress based on hostnames

Things start to get interesting when we start to direct traffic based on properties of
the request. The most common example of this is to have the Ingress system look at
the HTTP host header (which is set to the DNS domain in the original URL) and
direct traffic based on that header

* First, add the different hostnames to refer services on /etc/hosts


```
echo "127.0.0.1 alpaca.kube.local" | sudo tee -a /etc/hosts
echo "127.0.0.1 be-default.kube.local" | sudo tee -a /etc/hosts
echo "127.0.0.1 bandicoot.kube.local" | sudo tee -a /etc/hosts
```

* Now create an Ingress that uses Hostames to determine the backend service

```
kubectl apply -f host-ingress.yaml

```
* Verify and describe the ingress created

```
kubectl get ingress && kubectl describe ingress host-ingress
NAME             CLASS    HOSTS                                    ADDRESS     PORTS   AGE
host-ingress     <none>   alpaca.kube.local,bandicoot.kube.local               80      14s

Name:             host-ingress
Labels:           <none>
Namespace:        default
Address:
Ingress Class:    <none>
Default backend:  be-default:8080 (10.244.1.2:8080,10.244.2.2:8080,10.244.3.2:8080)
Rules:
  Host                  Path  Backends
  ----                  ----  --------
  alpaca.kube.local
                        /   alpaca:8080 (10.244.1.3:8080,10.244.2.3:8080,10.244.3.3:8080)
  bandicoot.kube.local
                        /   bandicoot:8080 (10.244.1.4:8080,10.244.2.4:8080,10.244.3.4:8080)
Annotations:            <none>
Events:
  Type    Reason  Age   From                      Message
  ----    ------  ----  ----                      -------
  Normal  Sync    14s   nginx-ingress-controller  Scheduled for sync

```

* Forward the port from the Ingress controller service to localhost on port 8080 for testing

```
kubectl port-forward --namespace ingress-nginx svc/ingress-nginx-controller 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

* Verify the endpoint for the alpaca service on the domain that we defined on the /etc/hosts files (http://alpaca.kube.local)

[http://alpaca.kube.local:8008]

```
curl http://alpaca.kube.local:8080
<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">

  <title>KUAR Demo</title>

  <link rel="stylesheet" href="/static/css/bootstrap.min.css">
  <link rel="stylesheet" href="/static/css/styles.css">

  <script>
var pageContext = {"urlBase":"","hostname":"alpaca-7d854b686f-mwpnp","addrs":["10.244.2.3"],"version":"v0.10.0-dirty-green","versionColor":"hsl(3,100%,50%)","requestDump":"GET / HTTP/1.1\r\nHost: alpaca.kube.local:8080\r\nAccept: */*\r\nUser-Agent: curl/8.9.0\r\nX-Forwarded-For: 127.0.0.1\r\nX-Forwarded-Host: alpaca.kube.local:8080\r\nX-Forwarded-Port: 80\r\nX-Forwarded-Proto: http\r\nX-Forwarded-Scheme: http\r\nX-Real-Ip: 127.0.0.1\r\nX-Request-Id: f9f417df3caca41607803cfc3b

```

* Verify the endpoint for the bandicoot service on the domain that we defined on the /etc/hosts files (http://bandicoot.kube.local)

[http://bandicoot.kube.local:8008]

```
hpcnow/kubernetes-101-examples/examples on 🌱main [!] ❯ curl http://bandicoot.kube.local:8080
<!doctype html>

<html lang="en">
<head>
  <meta charset="utf-8">

  <title>KUAR Demo</title>

  <link rel="stylesheet" href="/static/css/bootstrap.min.css">
  <link rel="stylesheet" href="/static/css/styles.css">

  <script>
var pageContext = {"urlBase":"","hostname":"bandicoot-57678d4f47-ttpn2","addrs":["10.244.3.4"],"version":"v0.10.0-purple","versionColor":"hsl(293,100%,50%)","requestDump":"GET / HTTP/1.1\r\nHost: bandicoot.kube.local:8080\r\nAccept: */*\r\nUser-Agent: curl/8.9.0\r\nX-Forwarded-For: 127.0.0.1\r\nX-Forwarded-Host: bandicoot.kube.local:8080\r\nX-Forwarded-Port: 80\r\nX-Forwarded-Proto: http\r\nX-Forwarded-Scheme: http\r\nX-Real-Ip: 127.0.0.1\r\nX-Request-Id: 48e5cd152138ffa8fe97
```

* Delete the Hosts Ingress

```
kubectl delete -f host-ingress.yaml

```

### Paths Ingress

The next interesting scenario is to direct traffic based on not just the hostname, but
also the path in the HTTP request. We can do this easily by specifying a path in the
paths entry. In this example we direct everything coming into
http://bandicoot.kube.local to the bandicoot service, but we also send http://bandi‐
coot.kube.local/a to the alpaca service. This type of scenario can be used to host
multiple services on different paths of a single domain.

When there are multiple paths on the same host listed in the Ingress system, the
longest prefix matches. So, in this example, traffic starting with /a/ is forwarded to
the alpaca service, while all other traffic (starting with /) is directed to the bandicoot
service.

As requests get proxied to the upstream service, the path remains unmodified. That
means a request to bandicoot.example.com/a/ shows up to the upstream server that
is configured for that request hostname and path. The upstream service needs to be
ready to serve traffic on that subpath. In this case, kuard has special code for testing,
where it responds on the root path (/) along with a predefined set of subpaths (/
a/, /b/, and /c/).

* Now create an Ingress that uses Paths to determine the backend service

```
kubectl apply -f path-ingress.yaml

```
* Ensure to forward the port from the Ingress controller service to localhost on port 8080 for testing

```
kubectl port-forward --namespace ingress-nginx svc/ingress-nginx-controller 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

* Verify that a petition on the default hostname points to the bandicoot service

[http://bandicoot.kube.local:8080]

```
curl http://bandicoot.kube.local:8080 | grep bandicoot
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1734  100  1734    0     0   469k      0 --:--:-- --:--:-- --:--:--  564k
var pageContext = {"urlBase":"","hostname":"bandicoot-57678d4f47-5vgfd","addrs":["10.244.2.4"],"version":"v0.10.0-purple","versionColor":"hsl(293,100%,50%)","requestDump":"GET / HTTP/1.1\r\nHost: bandicoot.kube.local:8080\r\nAccept: */*\r\nUser-Agent: curl/8.9.0\r\nX-Forwarded-For: 127.0.0.1\r\nX-Forwarded-Host: bandicoot.kube.local:8080\r\nX-Forwarded-Port: 80\r\nX-Forwarded-Proto: http\r\nX-Forwarded-Scheme: http\r\nX-Real-Ip: 127.0.0.1\r\nX-Request-Id: 438ec08f1813d6f87929ebc7cc921ca8\r\nX-Scheme: http","requestProto":"HTTP/1.1","requestAddr":"10.244.0.5:48534"}
```

* Verify that a petition on the subpath of the hostaneme points to the **alpaca** service

[http://bandicoot.kube.local:8080/a/]

```
curl http://bandicoot.kube.local:8080/a/ | grep alpaca
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  1738  100  1738    0     0   129k      0 --:--:-- --:--:-- --:--:--  141k
var pageContext = {"urlBase":"/a","hostname":"alpaca-7d854b686f-f65cn","addrs":["10.244.3.3"],"version":"v0.10.0-dirty-green","versionColor":"hsl(3,100%,50%)","requestDump":"GET /a/ HTTP/1.1\r\nHost: bandicoot.kube.local:8080\r\nAccept: */*\r\nUser-Agent: curl/8.9.0\r\nX-Forwarded-For: 127.0.0.1\r\nX-Forwarded-Host: bandicoot.kube.local:8080\r\nX-Forwarded-Port: 80\r\nX-Forwarded-Proto: http\r\nX-Forwarded-Scheme: http\r\nX-Real-Ip: 127.0.0.1\r\nX-Request-Id: 064c678104c2ee834b15ffdbd8ceb507\r\nX-Scheme: http","requestProto":"HTTP/1.1","requestAddr":"10.244.0.5:33042"}

```

* Delete the Paths Ingress

```
kubectl delete -f path-ingress.yaml

```
## Creating a ReplicaSet

## Creating a Deployment

## Apply Recreate Strategy

## Apply RollingUpdate strategy

## Apply Canary strategy

## Apply A/B strategy

## Creating a DaemonSet

## Creating a Job

## Creating a CronJob

## Creating a StatefulSet

## Creating a StorageClass

## Creating a Volume

## Create a PersistentVolumeClaim

## Managing PersistentVolumes

## Managing ConfigMaps

## Managing Secrets

## Managing RBAC

