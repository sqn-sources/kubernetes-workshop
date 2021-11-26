# Kubernetes ReplicaSet

- Vytváří a udržuje specifický počet podobných podů (replik).
- Používá labely a selektory k výběru podů.
- Změnou labelu dojde k vyřazení podu z replicasetu.
- Pody zařazené do ReplicaSetu lze škálovat - automaticky (využití CPU) x ručně
- Předchůdce ReplicaSetu se jmenoval ReplicationController.


# Vytvoření ReplicaSetu

```
kubectl apply -f rs-1.yaml
```

```
kubectl get rs
```

```
NAME   DESIRED   CURRENT   READY   AGE
web	4     	4     	4   	2m
```

# Patří pod do replicasetu?

```
kubectl get pods web-xxxx -o yaml | grep -A 5 owner
```

```
ownerReferences:
  - apiVersion: extensions/v1beta1
	blockOwnerDeletion: true
	controller: true
	kind: ReplicaSet
	name: web
```

# Odstranění Podu z ReplicaSetu

Pod z ReplicaSetu odstraníme (ale nesmažeme) změnou labelu:

```
kubectl edit pods web-xyz
```

Po odstranění podu ReplicaSet automaticky vytvoří další nový pod tak, aby udržel specifikovaný počet replik.

# Škálování a autoscaling

Dvě možnosti:

- Upravíme ReplicaSet a změníme počet replik.
```
kubectl edit rs <jmeno>
```

- Nebo napřímo přes kubectl autoscale - použije Horizontal Pod Autoscaler (HPA).

```
kubectl autoscale rs web --max=5
```

# Best Practices

ReplicaSet používá selektory a labely - může se stát, že matchne i pod, který nechceme. Částečným řešením je nikdy nevytvářed pody napřímo, ale vždy rovnou v ReplicaSetu. 

Nasadíme další Pod, tentokrát s httpd:

```
kubectl apply -f orphan.yaml
```

Tento pod nenastartuje, protože je díky labelu přiřazený k ReplicaSetu - je nadbytečný, chceme 4 repliky a máme 5 podů.
```
NAME    	READY   STATUS    	RESTARTS   AGE
orphan  	0/1 	Terminating   0      	1m
web-6n9cj   1/1 	Running   	0      	25m
web-7kqbm   1/1 	Running   	0      	25m
web-9src7   1/1 	Running   	0      	25m
web-fvxzf   1/1 	Running   	0      	25m
```

Co když to uděláme obráceně? Smažeme ReplicaSet
```
kubectl delete -f rs-1.yaml
```
```
kubectl get pods
```

Pod s httpd by měl běžet. Nahodíme k němu ReplicaSet

```
kubectl apply -f rs-1.yaml
```

```
orphan  	1/1 	Running   0      	29s
web-44cjb   1/1 	Running   0      	12s
web-hcr9j   1/1 	Running   0      	12s
web-kc4r9   1/1 	Running   0      	12s
```

Smažeme httpd, ReplicaSet dorovná

```
kubectl delete pods orphan
```

```
NAME    	READY   STATUS          	RESTARTS   AGE
web-44cjb   1/1 	Running         	0      	24s
web-5kjwx   0/1 	ContainerCreating   0      	3s
web-hcr9j   1/1 	Running         	0      	24s
web-kc4r9   1/1 	Running         	0      	24s
```


# Smazání ReplicaSetu

```
kubectl delete rs <jmeno>
```

Příkaz nahoře smaže ReplicaSet a všechny pody které spravuje. Pokud chceme smazat pouze RS a pody zachovat, pak:

```
kubectl delete rs <jmeno> --cascade=false
```

Kdybychom vytvořili nový ReplicaSet, který bude mít stejně nastavený selektor a pod template, tak se pod něj existující pody přiřadí.