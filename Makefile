.PHONY: install/checks/spell-and-markdown
install/checks/spell-and-markdown:
	yarn

.PHONY: run/checks/spell-and-markdown
run/checks/spell-and-markdown:
	yarn check-trailing-whitespaces
	yarn check-word-lists
	yarn cspell --no-progress '**/**'
	yarn markdownlint '*.md'

.PHONY: run/checks/terraform
run/checks/terraform:
	terraform fmt -check -recursive -diff

.PHONY: run/checks/all
run/checks/all:
	@${MAKE} run/checks/spell-and-markdown
	@${MAKE} run/checks/terraform
