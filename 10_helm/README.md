# Helm

# Co je to Helm?
- Helm je package manager pro Kubernetes, jedná se o k8s ekvivalent pro apt nebo yum. Helm nasazuje tzv. charty, o kterých můžeme přemýšlet jako o zabalené aplikaci.

# Proč používat Helm?
- Application deployment becomes easy, standardized and reusable
- While working with huge application you to deal with number of object of kubernetes (i.e. Deployment, confimap, secrets, namespace, statefulsets, daemonsets..etc) to manage and deploy all in such dynamic environment, it becomes difficult, better to package all in one place and deployed the same.

# Helm instalace

# Linux (Ubuntu):
```
    curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
    sudo apt-get install apt-transport-https --yes
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
   sudo apt-get install helm
```
# Windows (Powershell):

```
   choco install kubernetes-helm
```

# MacOsx (brew):
```
   brew install helm
```


