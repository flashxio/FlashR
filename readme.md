FlashR is an R package that accelerate the existing R matrix functions to process
tera-scale datasets at the lightning speed.
FlashR overrides many R matrix functions in the R "base" package so that users
can execute many existing R code in FlashR with no or little modification.
FlashR parallelizes all matrix operations automatically and scales to large datasets
by storing matrices on solid-state drives (SSDs).
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

The [programming tutorial](https://github.com/icoming/FlashX/wiki/FlashR-programming-tutorial)
shows all of the features in FlashR.

Please visit http://flashx.io/ for more documentation.
