# Nasazení Wordpressu pomocí Helmu

https://github.com/bitnami/charts/tree/master/bitnami/wordpress/


## Odstraníme existující repozitáře, pokud nějaké máme

```
helm repo list
NAME   	URL
brigade	https://brigadecore.github.io/charts
```

```
helm repo remove brigade
"brigade" has been removed from your repositories
```

## Zkontrolujeme

```
helm repo list
Error: no repositories to show
```

## Přidáme Helm Repo s wordpressem

```
helm repo add bitnami https://charts.bitnami.com/bitnami
"bitnami" has been added to your repositories
```

```
[Captains-Bay]🚩 >  helm repo list
NAME   	URL
stable 	https://kubernetes-charts.storage.googleapis.com
bitnami	https://charts.bitnami.com/bitnami
```

```bash
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm install my-release bitnami/<chart>           # Helm 3
```

To update an exisiting _stable_ deployment with a chart hosted in the bitnami repository you can execute

```bash
$ helm repo add bitnami https://charts.bitnami.com/bitnami
$ helm upgrade my-release bitnami/<chart>
```

## Deploy

```
helm install mycollabnixblog -f values.yaml stable/wordpress
```

## Accessing  WordPress site from outside the cluster

helm install my-release -f values.yaml bitnami/wordpress


