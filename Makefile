##
# (c) 2021 - Cloud Ops Works LLC - https://cloudops.works/
#            On GitHub: https://github.com/cloudopsworks
#            Distributed Under Apache v2.0 License
#
OS := $(shell uname)
NAMESPACE := "NAMESPACE"
VERFOUND := $(shell [ -f VERSION ] && echo 1 || echo 0)
RELEASE_VERSION :=
TARGET :=
CHART :=

.PHONY: VERSION
.PHONY: version
.PHONY: module.tf
.PHONY: init
.PHONY: init-template

module.tf:
	@if [ ! -f $(TARGET)-module.tf ] ; then \
		echo "Module $(TARGET)-module.tf not found... copying from template" ; \
		cp template-module.tf_template $(TARGET)-module.tf ; \
		touch values/$(TARGET)-values.yaml ; \
	else echo "Module $(TARGET)-module.tf found... all OK" ; \
	fi
# ifeq "" "$(T)"
# 	$(info )
# ifeq ($(OS),Darwin)
# else ifeq ($(OS),Linux)
# else
# 	echo "platfrom $(OS) not supported to release from"
# 	exit -1
# endif
# else
# 	$(info )
# endif

version: VERSION module.tf
ifeq ($(OS),Darwin)
	sed -i "" -e "s/MODULE_NAME/$(TARGET)/g" $(TARGET)-module.tf
	sed -i "" -e "s/chart_name[ \t]*=.*/chart_name = \"$(CHART)\"/" $(TARGET)-module.tf
	sed -i "" -e "s/chart_version[ \t]*=.*/chart_version = \"$(RELEASE_VERSION)\"/" $(TARGET)-module.tf
	sed -i "" -e "s/release_name[ \t]*=.*/release_name = \"$(TARGET)\"/" $(TARGET)-module.tf
else ifeq ($(OS),Linux)
	sed -i -e "s/MODULE_NAME/$(TARGET)/g" $(TARGET)-module.tf
	sed -i -e "s/chart_name[ \t]*=.*/chart_name = \"$(CHART)\"/" $(TARGET)-module.tf
	sed -i -e "s/chart_version[ \t]*=.*/chart_version = \"$(RELEASE_VERSION)\"/" $(TARGET)-module.tf
	sed -i -e "s/release_name[ \t]*=.*/release_name = \"$(TARGET)\"/" $(TARGET)-module.tf
else
	echo "platfrom $(OS) not supported to release from"
	exit -1
endif

VERSION:
ifeq ($(VERFOUND),1)
	$(info Version File OK)
override RELEASE_VERSION := $(shell cat VERSION | grep VERSION | cut -f 2 -d "=")
override TARGET := $(shell cat VERSION | grep TARGET | cut -f 2 -d "=")
override CHART := $(shell cat VERSION | grep CHART | cut -f 2 -d "=")
else
	$(error Hey $@ File not found)
endif

clean:
	rm -f VERSION

init-template:
	@if [ ! -f terraform.tfvars ] ; then \
		echo "Initial Variables terraform.tfvars not found... copying from template" ; \
		cp terraform.tfvars_template terraform.tfvars ; \
	else echo "Initial Variables terraform.tfvars found... all OK" ; \
	fi

init: init-template
	cp backend.tf_template backend.tf
	cp OWNERS_template OWNERS
