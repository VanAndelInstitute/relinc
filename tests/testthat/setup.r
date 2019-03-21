library(MyR6Lib)

# Put any preflight tasks here.

# don't rerun all tests when we are working on something in particular.
# devel should be set to FALSE for deployment
devel <- FALSE

skip_if_devel <- function() {
  if (devel) {
    skip("Skipping to speed up development")
  }
}
