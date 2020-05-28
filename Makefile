.phony: build

VERSION := `cat VERSION`


build:
	@echo "assigning version" $(VERSION)
	VERSION=$(VERSION) envsubst < "job_imports.yml.tmpl" > "job_imports.yml"

tag:
	git tag $(VERSION)
	git push origin --tags
