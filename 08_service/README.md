# Service

Předpokládejme, že máme nasazené pody s nginx někde uvnitř clusteru. Teoreticky můžeme s těmito pody komunikovat napřímo prostřednictvím jejich IP adres. Co když ale Pod zemře? Nebo ho smažeme, naškálujeme, aktualizujeme...? Jestliže používáme Deployment, kubernetes vyrobý nový pod někde v clusteru s novou IP adresou.


To představuje problém: Co když nějaká skupina podů (“backend”) poskytuje funkcionalitu jiné skupině podů (“frontend”) uvnitř clusteru? Jak frontendy zjistí, kde se nachází backendy?

Kubernetes Service je abstrakce nad určitou skupinou Podů běžících někde v clusteru. Při vytvoření dostane každá služba unikátní IP adresu (ClusterIP). Tato IP adresa je napevno svázána se službou a dokud ji nesmažeme, tak se nemění. Pods mohou být nakonfigurovány tak, že komunikují oproti nějaké Service, která požadavky dále rozesílá (underlaying česky?) podům.

## Vytvoření Service

Jako všechno v Kubernetes, Service lze vytvořit z YAML nebo JSON souboru obsahujícího definici (jde to i napřímo z CLI, ale nikdo to nedělá).

```
kubectl apply -f nginx-svc.yaml
```

Tato definice vytvoří službu, která směruje na port 80 jakéhokoliv podu s labelem nginx, a vystaví ho nad nějakým novým portem služby

```
kubectl get svc my-nginx
```


```
kubectl describe svc my-nginx
```

Nyní bychom měli být schopni použít např. curl <CLUSTER-IP>:<PORT> z jakéhokoliv nodu v clusteru. Tato IP adresa je kompletně virtuální a nikde jinde mimo cluster neexistuje.

## Přistupování ke službám

Kubernetes podporuje dvě hlavní metody pro přistupování k Service - proměnné prostředí a DNS

### Proměnné prostředí

TODO


### DNS

Jedním z volitelných doplňků Kubernetes clusterů je DNS server, který automaticky přiřazuje dns záznamy službám. Běží v namespace kube-system:

```
kubectl get services kube-dns --namespace=kube-system
```

```
NAME       TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)         AGE
kube-dns   ClusterIP   10.0.0.10    <none>        53/UDP,53/TCP   8m
```

nslookup
```
kubectl run curl --image=radial/busyboxplus:curl -i --tty
```

```
Waiting for pod default/curl-131556218-9fnch to be running, status is Pending, pod ready: false
Hit enter for command prompt
Then, hit enter and run nslookup my-nginx:

[ root@curl-131556218-9fnch:/ ]$ nslookup my-nginx
Server:    10.0.0.10
Address 1: 10.0.0.10

Name:      my-nginx
Address 1: 10.0.162.149
```


## Typy služeb


### CLusterIP

ClusterIP je výchozí typ služby - Kubernetes jí přiřadí interní IP adresu v clusteru  

```
apiVersion: v1
kind: Service
metadata:
  name: external-backend
spec:
  ports:
  - protocol: TCP
    port: 3000
    targetPort: 3000
  clusterIP: 10.96.0.1
```


### NodePort

Služba kterou použijeme, jestliže chceme povolit přístup ke sluzbě z venku. If you’re having four Nginx pods, the NodePort service type is going to use the IP address of any node in the cluster combined with a specific port to route traffic to those pods. The following graph will demonstrate the idea:

You can use the IP address of any node, the service will receive the request and route it to one of the pods.

Definice služby typu NodePort vypadá přibližně takto:

```
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: NodePort
  ports:
    - port: 80
      nodePort: 30000
      targetPort: 80
  selector:
    app: web
```

Ruční volba portu je dobrovolná, pokud port nenastavíme, Kubernetes nějaký přiřadí automaticky (používá se rozsah 30000-32767).

Pořád musíte počítat s tím, že některý konkrétní node vypadne, proto je vhodné před NodePort služby umístit load balancer.

### LoadBalancer

Tento typ služby funguje u cloudových poskytovatelů. Pokud nasadíme službu typu LoadBalancer, cluster kontaktuje cloud providera a load balancer vytvoří. Provoz poté bude forwardován z load balanceru na konkrétní pody. Konkrétní implementace záleží na cloudovém poskytovateli.

```
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  type: LoadBalancer
  loadBalancerIP: 78.11.24.19
  selector:
    app: web
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
```

Jeden z hlavních rozdílů mezi LoadBalancer a NodePort servisou spočívá v tom, že NodePort dává větší flexibilitu v tom jak si můžeme nakonfigurovat load balancing - nejsme svázaní s implementací u cloud providera
