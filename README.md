# Github Actions

`build-r-pkg.yml`: This Github Actions workflow creates a mini CRAN by building compiled and binary files for Linux, macOS, and Windows operating sytems and checks them into the same repo in proper directories in the same branch.

It does so by using `rocker/verse` Docker image (R version `4.2.2`) to run the `build-r-pkg.R` script.

This Github Actions is run when the files and directories in the `paths` (line 5) are modified.
