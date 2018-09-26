
GCLOUD_PROJECT?=
GCLOUD_CONTAINER_REGISTRY?=gcr.io
IBMCLOUD_REGISTRY_NAMESPACE?=signalsciences
CLUSTER?=signalsciences
OS=$(shell uname -s)

# CREATE CLUSTER
gcloud-kube-create-cluster:
	gcloud config set project $(GCLOUD_PROJECT)
	gcloud container clusters create $(CLUSTER) --zone us-central1 --no-enable-autorepair --num-nodes 1

ibmcloud-kube-create-cluster:
	bx cs cluster-create --name $(CLUSTER)

aws-kube-create-cluster:
	kops create cluster --node-count=2 --node-size=t2.medium --zones=us-east-1a --name=$(CLUSTER)

# DELETE CLUSTER
gcloud-kube-delete-cluster:
	gcloud config set project $(GCLOUD_PROJECT)
	gcloud container clusters delete $(CLUSTER)

ibmcloud-kube-delete-cluster:
	bx cs cluster-rm $(CLUSTER)

# ADD SIGSCI TO REGISTRY
gcloud-sigsci-to-registry:
	# https://cloud.google.com/container-registry/docs/pushing-and-pulling
	gcloud auth configure-docker
	docker pull foospidy/sigsci:latest
	docker tag foospidy/sigsci registry.ng.bluemix.net/$(GCLOUD_PROJECT)/sigsci:latest
	docker push gcr.io/$(GCLOUD_PROJECT)/sigsci:latest

ibmcloud-sigsci-to-registry:
	bx cr namespace-add $(IBMCLOUD_REGISTRY_NAMESPACE)
	docker pull foospidy/sigsci:latest
	docker tag foospidy/sigsci registry.ng.bluemix.net/$(IBMCLOUD_REGISTRY_NAMESPACE)/sigsci:latest
	docker push registry.ng.bluemix.net/$(IBMCLOUD_REGISTRY_NAMESPACE)/sigsci:latest

# LIST CLUSTERS
gcloud-list-clusters:
	gcloud container clusters list

ibmcloud-list-clusters:
	bx cs clusters

# DEPLOY DEPLOYMENTS
gcloud-kube-apply-deployment:
	gcloud config set container/cluster $(CLUSTER)
	gcloud container clusters get-credentials $(CLUSTER)
	kubectl apply -f gcloud-deployment.yaml

ibmcloud-kube-apply-deployment:
	eval $$(bx cs cluster-config $(CLUSTER) --export) \
		&& kubectl apply -f ibmcloud-deployment.yaml

# EXPOSE SERVICE
gcloud-kube-expose-service:
	gcloud config set container/cluster $(CLUSTER)
	gcloud container clusters get-credentials $(CLUSTER)
	kubectl expose deployment sigsci-agent-deployment --name=sigsci-agent-service --type=LoadBalancer --port 80 --target-port 8080
	kubectl get service -o wide

ibmcloud-kube-expose-service:
	eval $$(bx cs cluster-config $(CLUSTER) --export) \
		&& kubectl expose deployment sigsci-agent-deployment --name=sigsci-agent-service --type=NodePort --port 80 --target-port 8080 \
		&& kubectl get service -o wide

# UN-EXPOSE SERVICE
gcloud-kube-delete-service:
	gcloud config set container/cluster $(CLUSTER)
	gcloud container clusters get-credentials $(CLUSTER)
	kubectl delete service sigsci-agent-service

ibmcloud-kube-delete-service:
	eval $(bx cs cluster-config $(CLUSTER) --export)
	kubectl delete service sigsci-agent-service

# TOOLS
ibmcloud-install-tools:
	#https://console.bluemix.net/docs/cli/index.html#overview
	curl -sL https://ibm.biz/idt-installer | bash
	bx login
	bx plugin install container-service -r Bluemix
	bx cs init
	bx plugin update container-registry -r Bluemix

gcloud-install-tools:
	@echo See https://cloud.google.com/sdk/install

aws-install-tools:
# https://medium.com/containermind/how-to-create-a-kubernetes-cluster-on-aws-in-few-minutes-89dda10354f4
ifeq ($(OS), Darwin)
	brew install awscli
	brew install kops
else
	pip install awscli --upgrade --user
	curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
	chmod +x kops-linux-amd64
	sudo mv kops-linux-amd64 /usr/local/bin/kops
endif	

gcloud-update-tools:
	gcloud components update

ibmcloud-update-tools:
	bx plugin update container-service -r Bluemix

aws-update-tools:
ifeq ($(OS), Darwin)
	brew upgrade awscli
	brew upgrade kops
else
	pip install awscli --upgrade --user
	curl -LO https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
	chmod +x kops-linux-amd64
	sudo mv kops-linux-amd64 /usr/local/bin/kops
endif

# BUILD
install:
ifeq ($(OS), Darwin)
	brew install shellcheck
else
	# for travis-ci
	apt-get install shellcheck
endif

lint:
	shellcheck sigsci-cloud-kube

clean:
	if [ -f "ibmcloud-deployment.yaml" ]; then rm ibmcloud-deployment.yaml; fi
	if [ -f "gcloud-deployment.yaml" ]; then rm gcloud-deployment.yaml; fi

# OTHER (NOT USED BY SCRIPT)
gcloud-kube-describe-deployment:
	kubectl describe deployment sigsci-agent-deployment

gcloud-kube-get-pods:
	kubectl get pods -l app=sigsci-agent

gcloud-kube-get-service:
	kubectl get service

glcoud-kube-scale-app:
	kubectl scale deployment app --replicas 3

kube-get-pod:
	kubectl get pod -o wide

kube-create-deployment:
	kubectl create -f deployment.yaml

kube-get-deployment:
	kubectl get deployment -o wide

kube-get-service:
	kubectl get service -o wide

kube-get-node:
	kubectl get node -o wide

kube-describe-pod:
	kubectl describe pod sigsci-agent-pod

kube-describe-deployment:
	kubectl describe deployment sigsci-agent-deployment

kube-describe-service:
	kubectl describe service sigsci-agent-service

kube-delete-pod:
	kubectl delete pod sigsci-agent-pod

kube-delete-deployment:
	kubectl delete deployment sigsci-agent-deployment

kube-delete-service:
	kubectl delete service sigsci-agent-service

ibmcloud-cr-namespace-list:
	bx cr namespace-list

ibmcloud-cr-images:
	bx cr images

ibmcloud-cs-cluster-rm:
	bx cs cluster-rm mycluster

ibmcloud-cs-cluster-config:
	bx cs cluster-config mycluster

ibmcloud-cs-workers:
	bx cs workers mycluster