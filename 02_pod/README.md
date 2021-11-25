#Kubectl
Kontrola nastavení kubectl  
`kubectl config view`  

Vypsání info o clusteru  
`kubectl cluster-info` 

Přímá interakce s k8s api    
`kubectl proxy --port=8080` a poté curl `http://localhost:8080/api/`

Když máme více clusterů  
`kubectl config get-contexts`  
`kubectl config current-context`  
`kubectl config use-context my-cluster-name`  

#Namespace
`kubectl get namespaces`  
`kubectl create namespace <jmeno>`

Přepnutí kubectl do namespacu  
`kubectl config set-context --current --namespace=<jmeno>`

# Pod
`kubectl run --image=nginx websesrver --port=80`  
`kubectl get pods`  
`kubectl get pods -o wide`  
`kubectl describe po webserver`    

Vystavení portu na localhost  
`kubectl port-forward <nazev-kontejneru> <port-lokalni>:<port-v-clusteru>`  
`kubectl port-forward pods/<nazev-kontejneru> <port-lokalni>:<port-v-clusteru>`  
`kubectl port-forward pods/<nazev-kontejneru> :<port-v-clusteru>`  

`kubectl exec -it webserver -- /bin/bash`

Kubernetes restartuje spadlé pody  
`kubectl exec -it webserver -- /bin/bash -c "kill 1"$`  zabijeme  
`kubectl get pods`  zkontrolujeme ze nabehl

Smazání podu  
`kubectl delete pod webserver`  
`kubectl delete pod <PODNAME> --grace-period=0 --force --namespace <NAMESPACE>`

Pod ze souboru
`kubectl apply -f pods01.yaml`
`kubectl delete -f pods01.yaml`

Editace beziciho podu
`kubectl edit pod <jmeno>`

