pull-scripts:
	./scripts/pull-scripts

TARGETS := prepare patch charts clean template

validate:
	@./scripts/pull-ci-scripts
	@./bin/partner-charts-ci validate

$(TARGETS):
	@./scripts/pull-scripts
	@./bin/charts-build-scripts $@

.PHONY: $(TARGETS) validate
