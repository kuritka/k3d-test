CLUSTER1 = test-cluster-1
CLUSTER2 = test-cluster-2

run:
	golangci-lint run
	go run app.go
	kubectl get nodes -o wide
	kubectl config current-context
	$(call get-host-alias-ip,k3d-$(CLUSTER1),k3d-$(CLUSTER2))
	$(call get-host-alias-ip,k3d-$(CLUSTER2),k3d-$(CLUSTER1))

build:
	@echo "\n$(YELLOW)build docker and push to registry $(NC)"
	docker build . -t localhost:5000/aaa:v0.0.1
	docker push localhost:5000/aaa:v0.0.1
	docker rmi localhost:5000/aaa:v0.0.1
	docker pull localhost:5000/aaa:v0.0.1
	kubectl apply -f ./deployment.yaml
	$(call deploy-test-apps)
	sleep 15
	kubectl get pods -A
	kubectl describe pod `kubectl get pod -l app=test-app -o jsonpath="{.items[0].metadata.name}"`
	kubectl describe pod `kubectl get pod -l app=frontend-podinfo-app -o jsonpath="{.items[0].metadata.name}"`

define get-host-alias-ip
	kubectl config use-context $2 > /dev/null && \
	kubectl get nodes $2-agent-0 -o custom-columns='IP:status.addresses[0].address' --no-headers && \
	kubectl config use-context $1 > /dev/null
endef

define deploy-test-apps
	helm repo add podinfo https://stefanprodan.github.io/podinfo
	helm upgrade --install frontend -f podinfo/podinfo-values.yaml \
		--set ui.message="BLAH" \
		--set image.repository=stefanprodan/podinfo \
		podinfo/podinfo
endef

xyz:
	$(call deploy-test-apps)