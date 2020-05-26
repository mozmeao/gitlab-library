.phony: build

VERSION := `cat VERSION`


build:
	@echo "assiging version" $(VERSION)
	envsubst < "job_imports.yml.tmpl" > "job_imports.yml"

tag:
	git tag $(VERSION)
	git checkout v1.0
	git merge master
	git push origin --tags
