sudo apt update -y && apt upgrade -y && apt install -y unzip
export AWS_ACCESS_KEY_ID=<YOUR ACCESS_KEY_ID>
export AWS_SECRET_ACCESS_KEY=<YOUR SECRET_ACCESS_KEY>
export AWS_DEFAULT_REGION=<YOUR REGION>

# install eksctl
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# install awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin
kubectl version --client


# install du cluster / La Key Pair a ete cree avant la creation de l instance ec2
eksctl create cluster --name=easy --ssh-access --ssh-public-key devops --nodes=1 --nodes-max 5 --asg-access

# retrieve credentials
eksctl utils write-kubeconfig --name=easy --kubeconfig=$HOME/easy
export KUBECONFIG=$HOME/easy

# install k8s autocomplete
sudo echo 'source <(kubectl completion bash)' >> ${HOME}/.bashrc && source ${HOME}/.bashrc

# test cluster
kubectl create namespace my-namespace
# Create a manifest 
nano sample-service.yml
kubectl apply -f sample-service.yml
kubectl get all -n my-namespace
POD=$(kubectl get -n my-namespace pod -l app=my-app -o jsonpath="{.items[0].metadata.name}")
kubectl -n my-namespace exec -it $POD  -n my-namespace -- /bin/bash
curl  my-service.my-namespace.svc.cluster.local


#########################################
# Here, the manifest sample-service.yml #
#########################################
'
apiVersion: v1
kind: Service
metadata:
  name: my-service
  namespace: my-namespace
  labels:
    app: my-app
spec:
  selector:
    app: my-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
  namespace: my-namespace
  labels:
    app: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: beta.kubernetes.io/arch
                operator: In
                values:
                - amd64
                - arm64
      containers:
      - name: nginx
        image: nginx:1.19.2
        ports:
        - containerPort: 80
'