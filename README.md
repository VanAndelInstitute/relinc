# relinc

Find drugs that target genes based on LINCS L1000 data.

## Installation

Requires a running redis database with at least 30GB of RAM, as well as 
the level 3 phase I data from LINCS.

``` r
devtools::install_github("vanandelinstitute/relinc")
library(relinc)
rl <- Relincr()
```

## Usage

See worked example [here](https://vanandelinstitute.github.io/relinc/guided-analysis.html). 


**NOTE:** Supporting files are in the `./docs` directory of this repo.
