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
	docker build . -t aaa:v0.0.1
	docker tag aaa:v0.0.1 registry.localhost:5000/aaa:v0.0.1
	docker push registry.localhost:5000/aaa:v0.0.1
	docker rmi aaa:v0.0.1
	docker pull registry.localhost:5000/aaa:v0.0.1
	kubectl apply -f ./deployment.yaml
	sleep 2
	kubectl get pods -A


define get-host-alias-ip
	kubectl config use-context $2 > /dev/null && \
	kubectl get nodes $2-agent-0 -o custom-columns='IP:status.addresses[0].address' --no-headers && \
	kubectl config use-context $1 > /dev/null
endef
