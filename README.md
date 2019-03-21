# MyR6Lib

The goal of MyR6Lib is to provide a basic skeleton for an R6 based R 
package. Having code organized in a package is a Good Practice as it 
facilitates test-based development, and it encourages you to stay organized 
and well documented.  Then when you inevitably want to share your 
code later as part of manuscript submission, your code will be in a format 
people are familiar with, with documentation in the usual places, and you 
will look like you have your act together.

BUT getting a new package set up with the object oriented class template 
you want as well as testing and roxygen based documentation and all the 
bits and pieces to pass `R CMD check --as-cran` always takes 
me a few hours and some intensive googling because I can never quite remember 
exactly all the steps and syntax because I don't do it QUITE often enough.

So this template will lower the activation energy.

This template has the following features:

* Based on R6 classes

* Includes templates for roxygen2 based documentation (which is a littly 
  tricky to set up given that roxygen2 does not really support R6 or RC 
  classes). 

* Templated testthat tests included.

* Passes R CMD check and R CMD BiocCheck out of the box as nearly as 
  possible (still get note about extra files in the repo that you would 
  remove prior to submission to Bioconductor or CRAN if you get to that 
  point)

## Installation

You could just fork the repo, but probably cleaner to just do this:

``` bash
git clone https://github.com/vanandelinstitute/MyR6Lib
git mv MyR6Lib YourPackageName
cd YourPackageName
rm -rf .git
git init
git add .
git commit -am "initial"
```

Then create the remote repo for your new package and set the remote in the
usual way.

``` bash
git remote add origin https://github.com/youruserid/yourNewRepoName
git push origin master
```



## To Do

Make more templates with different R oject styles (e.g. S4 and RC)

