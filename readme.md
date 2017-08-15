FlashR is an R package that extends the existing R matrix functions to process
datasets at a scale of terabytes in parallel and out of core automatically.
FlashR overrides many R matrix functions in the R "base" package so that users
can execute many existing R code in FlashR with no or little modification.
FlashR stores matrices on solid-state drives (SSDs) to scale to large datasets.
It executes many matrix operations together to achieve performance comparable
to optimized C implementations.

## Installation

To install from Github directly, 
```
git clone --recursive https://github.com/flashxio/FlashR.git
cd FlashR
R CMD build .
R CMD INSTALL FlashR_0.1-0.tar.gz
```

To install from the tar file directly,
```
R -e "install.packages("https://github.com/flashxio/FlashR/releases/download/FlashR-latest/FlashR.tar.gz", repos=NULL)"
```
However, the tar file may contain a less up-to-date version.

**Note: FlashR relies on some Linux and R packages.** Please follow the instructions
[here](https://flashxio.github.io/FlashX-doc/FlashX-Quick-Start-Guide.html)
for more details of installing FlashR.

## Documentation

Please visit http://flashx.io/.
