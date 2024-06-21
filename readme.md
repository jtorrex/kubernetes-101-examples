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

## Creating an HTTP Ingress

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

