IMAGE = mathpl/coreos-container-extractor
TAG = 0.1

build:
	docker build -t mathpl/coreos-container-extractor:$(TAG) .

push: build
	docker push mathpl/coreos-container-extractor:$(TAG)
