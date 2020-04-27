help:
	@echo "The following commands are available:"
	@echo "    roxygenize        Build roxygen2 documentation"
	@echo "    check             install dependencies and check if package can be loaded"
	@echo "    install           install package and dependencies"
	@echo "    docs              build docs with pkgdown"
	@echo "    deploy_docs       build docs and commit them to the git repository (-> github pages)"
	@echo "    clean             clean repository (docs, man and all dev files)"
	@echo "    conda						 build anaconda package"

.PHONY: install_deps
install_deps:
	Rscript -e 'install.packages("remotes", repos="https://cran.rstudio.com")'
	Rscript -e 'remotes::install_cran(c("devtools", "roxygen2", "covr"), repos="https://cran.rstudio.com")'
	Rscript -e 'deps <- remotes::dev_package_deps(dependencies = NA); remotes::install_deps(dependencies = TRUE, upgrade="never"); if (!all(deps$$package %in% installed.packages())) { message("missing: ", paste(setdiff(deps$$package, installed.packages()), collapse=", ")); q(status = 1, save = "no")}'

.PHONY: roxygenize
roxygenize: # | install_deps
	Rscript -e "library(methods); library(devtools); document()"

.PHONY: install
install: | check
	R CMD INSTALL .

.PHONY: docs
docs: roxygenize
	Rscript -e 'pkgdown::build_site()'

.PHONY: deploy_docs
deploy_docs: docs
	cd docs && git add -A . && git commit -m "update docs" && git push origin gh-pages

.PHONY: test
test: | roxygenize docs
	_R_CHECK_TESTS_NLINES_=0 Rscript -e 'devtools::check()'

.PHONY: clean
clean:
	rm -rfv docs/*
	rm -rfv builds
	rm -rfv man/*.*
	rm -rfv vignettes/*.html
	find . -type f -name "*~" -exec rm '{}' \;
	find . -type f -name ".Rhistory" -exec rm '{}' \;

.PHONY: conda
conda:
	conda build .
