CLUSTER1 = test-cluster-1
CLUSTER2 = test-cluster-2

run:
	golangci-lint run
	go run app.go
	$(call get-host-alias-ip,k3d-$(CLUSTER1),k3d-$(CLUSTER2))
	$(call get-host-alias-ip,k3d-$(CLUSTER2),k3d-$(CLUSTER1))


define get-host-alias-ip
	kubectl config use-context $2 > /dev/null && \
	kubectl get nodes $2-agent-0 -o custom-columns='IP:status.addresses[0].address' --no-headers && \
	kubectl config use-context $1 > /dev/null
endef
