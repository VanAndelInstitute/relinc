
#' Create Relincr objects
#'
#' `Relincr$new` constructs the object and returns it
#'
#' Initializes slinky object and redis connections in preparation for
#' analysis.  Looks for configuration details first in "config.rds" in
#' working directory (which can be generated by `relinc::config()`). If not
#' found, checks for environment variables: `RELINC_REDIS_HOST`,
#' `RELINC_REDIS_PORT`, `RELINC_LINCS_DIR`, `RELINC_CLUE_KEY`. This may be
#' particularly useful if you are using this package in an AWS lambda or batch
#' job). Finally, if neither the above are found and `interactive = TRUE`,
#' it will prompt the user for the information. Note that by default,
#' `interactive = FALSE`.
#'
#' @param interactive Should user be prompted for missing config info?
#'                    If false (default), will exit gracefully if neither
#'                    config.rds nor environment variables are set. If
#'                    TRUE, will prompt user for input.
#' @return An object of type `Relincr`
#'
#' @section Usage:
#' Relincr$new(interactive = FALSE)
#'
#' @examples
#' \dontrun{
#' x <- Relincr$new()
#' }
#' @format NULL
#' @name Relincr
#' @importFrom R6 R6Class
#' @export
NULL

Relincr <- R6::R6Class(
    "Relincr",
    public = list(
        initialize = function(interactive = TRUE) {
            private$CONFIG <- .check_config()
        },
        add = function() {
            return(self$a + self$b)
        }
    ),
    private = list(
        CONFIG = NA,
        sl = NA,
        redis_con = NA
    )
)

Relincr$set("private", "logger", function(level='INFO',
                                          log,
                                          file="log.txt") {
    log <- paste0(timestamp(prefix = paste0(level, " : "),
                            suffix = " : ",
                            quiet = TRUE), log)
    write(log, file, append = TRUE)
    invisible(self)
})


#' Create configuration file
#'
#' Prompts user for config information and saves it to config.rds
#'
#' @return List of config vars, but also called for side effect of
#'         creating config file.
#'
#' @examples
#' \dontrun{
#' config()
#' }
#' @format NULL
#' @export
config <- function() {
    CONFIG <- list()
    CONFIG$REDIS_HOST <- readline("Redis host: ")
    CONFIG$REDIS_PORT <- readline("Redis port: ")
    CONFIG$LINCS_DIR <- readline("Directory with LINCS data files: ")
    CONFIG$CLUE_KEY <- readline("Clue API Key: ")
    save_config <- ""
    while(!save_config %in% c("y", "Y", "n", "N")) {
        save_config <- readline("Save config info for next session (Y/N)? ")
    }
    if(save_config %in% c("y", "Y"))
        saveRDS(CONFIG, "config.rds")
    CONFIG
}
