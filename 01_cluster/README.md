# Přistupování ke  Kubernetes API

Kubectl je command line interface pro spouštění příkazů proti Kubernetes clusterům.  `kubectl` hledá konfigurační soubor s názvem `config` v adresáři `$HOME/.kube`. Toto chování lze upravit nastavením proměnné prostředí `$KUBECONFIG`, nebo používáním  `--kubeconfig` flagu.

## Kontrola nastavení kubectl
```
kubectl config view
```

```
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: ...
  name: aks1
contexts:
- context:
    cluster: aks1
    user: clusterUser_CP-K8S-POC_aks1
  name: aks1
current-context: aks1
kind: Config
preferences: {}
users:
- name: clusterUser_CP-K8S-POC_aks1
  user:
    client-certificate-data: REDACTED
    client-key-data: REDACTED
    token: REDACTED
```

## Nastavení contextu
Jeden config můžeme použít pro přístup k několika clusterům přepnutím contextu

`kubectl config get-contexts`   
`kubectl config current-context`   
`kubectl config use-context <nazev>`  

## Interakce s nody a clusterem

```
kubectl get nodes                                                     # List nodes
kubectl cordon my-node                                                # Mark my-node as unschedulable
kubectl drain my-node                                                 # Drain my-node in preparation for maintenance
kubectl uncordon my-node                                              # Mark my-node as schedulable
kubectl top node my-node                                              # Show metrics for a given node
kubectl cluster-info                                                  # Display addresses of the master and services
```

###Proxy na Kubernetes API
Nejdřív si vypsat cluster info  
`kubectl cluster-info`  
Nastartování proxy serveru  
`kubectl proxy --port=8080`   
Poté múžeme  
 `curl http://localhost:8080/api/`


#Namespace
Namespace poskytuje mechanismus pro izolaci skupiny prostředků uvnitř clusteru. Jména resourců musí být unikátní v rámci jednoho namespace, ale mohou se opakovat napříč několika namespacy. Namespace-based scoping lze používat pouze pro některé objekty (Deployment, Services, Ingress,... ) ale už ne pro cluster-wide objekty (StorageClass, Node, PersistentVolume, ...).

##Vypsání namespaců

```kubectl get namespaces```
```
NAME              STATUS   AGE
default           Active   1d
kube-node-lease   Active   1d
kube-public       Active   1d
kube-system       Active   1d
```
##Tvorba nového namespace

`kubectl create namespace <jmeno>`

##Přepínání mezi namespacy
Pro jednotlivé příkazy  
`kubectl run nginx --image=nginx --namespace=<jmeno>`  
`kubectl get pods --namespace=<jmeno>`  
Trvale  
`kubectl config set-context --current --namespace=<jmeno>`