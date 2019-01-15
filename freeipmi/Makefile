COREOS_VERSION=1745.7.0
FREEIPMI_VERSION=1.6.2

IMAGE="jcr.io/infra/freeipmi-injector:$(COREOS_VERSION)-$(FREEIPMI_VERSION)"

build:
	docker build -t $(IMAGE) .

push:
	docker push $(IMAGE)
