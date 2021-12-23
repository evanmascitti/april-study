R_SCRIPT = Rscript --no-save --no-restore --no-site-file --verbose

FIGURES = $(wildcard ./figures/*.pdf)
DATA = ./data/all-results.rds  ./data/tidy-win-pcts.rds 


all: ./April-study-final-report.pdf ./April-study-final-report.html

# render as pdf
./April-study-final-report.pdf: ./April-study-final-report.Rmd $(FIGURES) ./src/R/win-pct-plots.R $(DATA) ./library.bib ./packages.bib
	$(R_SCRIPT) -e 'rmarkdown::render(input = "$<", output_file = "$@")'

# render as html
./April-study-final-report.html: ./April-study-final-report.Rmd $(FIGURES) ./src/R/win-pct-plots.R $(DATA) ./library.bib ./packages.bib
	$(R_SCRIPT) -e 'rmarkdown::render(input = "$<", output_format = "bookdown::html_document2")'

# download and save all results
./data/all-results.rds: ./src/R/win-losses-gathering.R
	$(R_SCRIPT) $< $@  | tee ./script-outputs/$(notdir $<).out

# further process results 
./data/tidy-win-pcts.rds: ./src/R/win-losses-cleaning.R ./data/all-results.rds 
	$(R_SCRIPT) $< $@  | tee ./script-outputs/$(notdir $<).out


# I don't want to modularize the figure building script into separate 
# scripts for each figure....so I built some conditional logic into 
# the .Rmd....this will re-build the figures only if the figure-building
# script has changed since the last time the .Rmd was rendered.

# build figures 	

# ./figures/*.pdf &: ./src/R/win-pct-plots.R $(DATA)
# 	$(R_SCRIPT) $<
	
# ./figures/monbthly-r-squared-plots


#./figures/monthly-r-squared-plots.pdf: ./src/R/win-pct-plots.R $(DATA)
#	$(R_SCRIPT) $<
#./figures/monthly-win-pct-facets.pdf: ./src/R/win-pct-plots.R $(DATA)
#	$(R_SCRIPT) $<
#./figures/phils-since-1970-daily-win-pcts.pdf: ./src/R/win-pct-plots.R $(DATA)
#	$(R_SCRIPT) $<
#./figures/phils-since-1970-monthly-win-pcts.pdf: ./src/R/win-pct-plots.R $(DATA)
#	$(R_SCRIPT) $<
#./figures/phils-since-1978-monthly-win-pcts.pdf: ./src/R/win-pct-plots.R $(DATA)
#	$(R_SCRIPT) $<
#


