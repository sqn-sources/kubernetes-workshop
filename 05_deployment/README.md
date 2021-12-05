# Deployment


ReplicaSety mají jednu velkou slabinu - jakmile pomocí nich spravujeme pody, tak už je nemůžeme měnit.

Například pokud nasadíme aplikaci pomocí ReplicaSetu a chceme jí aktualizovat na novou verzi, musíme nejdřív ReplicaSet smazat a znovu vytvořit. Restart způsobí výpadek, dokud nové pody opět nenaběhnou.

Deployment využívá ReplicaSety ke správě podů, ale ummožňuje provádět jejich úprávy kontrolovaným způsobem.


## Vytvoření deploymentu

The following Deployment definition deploys four pods with nginx as their hosted application:

```
kubectl create -f deployment-1.yaml
```

## Výpis deploymentů

```
$ kubectl get deployments
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   2/2     2            2           63s

```

```
[node1 Deployment101]$ kubectl describe deploy
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Mon, 30 Dec 2019 07:10:33 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=nginx
Replicas:               2 desired | 2 updated | 2 total | 0 available | 2 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:        nginx:1.7.9
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      False   MinimumReplicasUnavailable
  Progressing    True    ReplicaSetUpdated
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-6dd86d77d (2/2 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  90s   deployment-controller  Scaled up replica set nginx-deployment-6dd86d77d to 2
```


## Škálování nahoru

```
kubectl scale deployments/nginx-deployment --replicas=4
deployment.extensions/nginx-deployment scaled
```

Po změně bychom měli mít k dispozici 4 repliky:
```
$ kubectl get deployments
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   4/4     4            4           4m

```

Zároveň se naškálování zaznamenalo do event logu

```
$ kubectl describe deployments/nginx-deployment
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Sat, 30 Nov 2019 20:04:34 +0530
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=nginx
Replicas:               4 desired | 4 updated | 4 total | 4 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Containers:
   nginx:
    Image:        nginx:1.7.9
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Progressing    True    NewReplicaSetAvailable
  Available      True    MinimumReplicasAvailable
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-6dd86d77d (4/4 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  6m12s  deployment-controller  Scaled up replica set nginx-deployment-6dd86d77d to 2
  Normal  ScalingReplicaSet  3m6s   deployment-controller  Scaled up replica set nginx-deployment-6dd86d77d to 4
```



```
$ kubectl get pods -o wide
NAME                               READY   STATUS    RESTARTS   AGE     IP           NODE             NOMINATED NODE   READINESS GATES
nginx-deployment-6dd86d77d-b4v7k   1/1     Running   0          4m32s   10.1.0.237   docker-desktop   <none>           <none>
nginx-deployment-6dd86d77d-bnc5m   1/1     Running   0          4m32s   10.1.0.236   docker-desktop   <none>           <none>
nginx-deployment-6dd86d77d-bs6jr   1/1     Running   0          86s     10.1.0.239   docker-desktop   <none>           <none>
nginx-deployment-6dd86d77d-wbdzv   1/1     Running   0          86s     10.1.0.238   docker-desktop   <none>           <none>
Biradars-MacBook-Air-4:~ sangam$ 
```


# Škálování dolů

Abychom se vrátili k původnímu počtu replik:

```
$ kubectl scale deployments/nginx-deployment --replicas=2
deployment.extensions/nginx-deployment scaled
$ kubectl get deployments
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   2/2     2            2           7m23s
```



## Updatování aplikace

Všechny předchozí ukázky šly realizovat i s obyčejným replicasetem, ale síla Deploymentu spočívá v možnosti updatů bez výpadku.

Máme nasazený nginx 1.7.9, aktualizujme ho na novější.

```
$ kubectl get deployments
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
nginx-deployment   2/2     2            2           7m23s
```

```
kubectl set image deployments/nginx-deployment nginx=nginx:1.9.1
deployment.extensions/nginx-deployment image updated
```

# Zkontrolujeme

```
$ kubectl describe pods
Name:               nginx-deployment-6dd86d77d-b4v7k
Namespace:          default
Priority:           0
PriorityClassName:  <none>
Node:               docker-desktop/192.168.65.3
Start Time:         Sat, 30 Nov 2019 20:04:34 +0530
Labels:             app=nginx
                    pod-template-hash=6dd86d77d
Annotations:        <none>
Status:             Running
IP:                 10.1.0.237
Controlled By:      ReplicaSet/nginx-deployment-6dd86d77d
Containers:
  nginx:
    Container ID:   docker://2c739cf9fe4dac53a4cc5c6097207da0c5edc2183f1f36f9f3e5c7057f85da43
    Image:          nginx:1.7.9
    Image ID:       docker-pullable://nginx@sha256:e3456c851a152494c3e4ff5fcc26f240206abac0c9d794affb40e0714846c451
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sat, 30 Nov 2019 20:05:28 +0530
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-ds5tg (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  default-token-ds5tg:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-ds5tg
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age   From                     Message
  ----    ------     ----  ----                     -------
  Normal  Scheduled  16m   default-scheduler        Successfully assigned default/nginx-deployment-6dd86d77d-b4v7k to docker-desktop
  Normal  Pulling    16m   kubelet, docker-desktop  Pulling image "nginx:1.7.9"
  Normal  Pulled     15m   kubelet, docker-desktop  Successfully pulled image "nginx:1.7.9"
  Normal  Created    15m   kubelet, docker-desktop  Created container nginx
  Normal  Started    15m   kubelet, docker-desktop  Started container nginx


Name:               nginx-deployment-6dd86d77d-bnc5m
Namespace:          default
Priority:           0
PriorityClassName:  <none>
Node:               docker-desktop/192.168.65.3
Start Time:         Sat, 30 Nov 2019 20:04:34 +0530
Labels:             app=nginx
                    pod-template-hash=6dd86d77d
Annotations:        <none>
Status:             Running
IP:                 10.1.0.236
Controlled By:      ReplicaSet/nginx-deployment-6dd86d77d
Containers:
  nginx:
    Container ID:   docker://12ab35cbf4fdf78997b106b5eb27135f2fc37c890e723fee44ac820ba1b1fd75
    Image:          nginx:1.7.9
    Image ID:       docker-pullable://nginx@sha256:e3456c851a152494c3e4ff5fcc26f240206abac0c9d794affb40e0714846c451
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sat, 30 Nov 2019 20:05:23 +0530
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-ds5tg (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  default-token-ds5tg:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-ds5tg
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age   From                     Message
  ----    ------     ----  ----                     -------
  Normal  Scheduled  16m   default-scheduler        Successfully assigned default/nginx-deployment-6dd86d77d-bnc5m to docker-desktop
  Normal  Pulling    16m   kubelet, docker-desktop  Pulling image "nginx:1.7.9"
  Normal  Pulled     15m   kubelet, docker-desktop  Successfully pulled image "nginx:1.7.9"
  Normal  Created    15m   kubelet, docker-desktop  Created container nginx
  Normal  Started    15m   kubelet, docker-desktop  Started container nginx


Name:               nginx-deployment-784b7cc96d-kxc68
Namespace:          default
Priority:           0
PriorityClassName:  <none>
Node:               docker-desktop/192.168.65.3
Start Time:         Sat, 30 Nov 2019 20:20:04 +0530
Labels:             app=nginx
                    pod-template-hash=784b7cc96d
Annotations:        <none>
Status:             Pending
IP:                 
Controlled By:      ReplicaSet/nginx-deployment-784b7cc96d
Containers:
  nginx:
    Container ID:   
    Image:          nginx:1.9.1
    Image ID:       
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Waiting
      Reason:       ContainerCreating
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-ds5tg (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             False 
  ContainersReady   False 
  PodScheduled      True 
Volumes:
  default-token-ds5tg:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-ds5tg
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age   From                     Message
  ----    ------     ----  ----                     -------
  Normal  Scheduled  36s   default-scheduler        Successfully assigned default/nginx-deployment-784b7cc96d-kxc68 to docker-desktop
  Normal  Pulling    35s   kubelet, docker-desktop  Pulling image "nginx:1.9.1"
```

## Rollback 

```
$ kubectl rollout undo deployments/nginx-deployment
deployment.extensions/nginx-deployment rolled back

$ kubectl rollout status deployments/nginx-deployment 
deployment "nginx-deployment" successfully rolled out

```

Použila se RollingUpdate strategie
```
kubectl describe deployments | grep Strategy
StrategyType:           RollingUpdate
RollingUpdateStrategy:  25% max unavailable, 25% max surge
```


## Úklid

Deployment můžete smazat pomocí příkazu:
```
kubectl delete deployment nginx-deployment
```
