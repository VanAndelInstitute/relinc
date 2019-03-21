
#' Create MyR6Class objects
#'
#' `MyR6Class$new` constructs the object and returns it
#'
#' A longer description goes here.
#'
#' @param a A number
#' @param b Another number
#'
#' @return An object of type `MyR6Class`
#'
#' @section Usage:
#' MyR6Class$new(a, b)
#'
#' @examples
#' x <- MyR6Class$new(1,2)
#'
#' @format NULL
#' @name MyR6Class
#' @importFrom R6 R6Class
#' @export

# We document on NULL because roxygen2 does not
# currently support R6 classes (or RC classes, for that matter)
NULL

MyR6Class <- R6::R6Class(
    "MyR6Class",
        public = list(
        a = NA,
        b = NA,
        initialize = function(a, b) {
            self$a <- a
            self$b <- b
        },
        add = function() {
            return(self$a + self$b)
        }
    )
)

