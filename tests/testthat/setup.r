library(relinc)

# Put any preflight tasks here.

# don't do this at home...always use your own key
demo_key <- httr::content(httr::GET("https://api.clue.io/temp_api_key"),
                          as = "parsed")$user_key

Sys.setenv("RELINC_REDIS_HOST"="localhost")
Sys.setenv("RELINC_REDIS_PORT"="6379")
Sys.setenv("RELINC_LINCS_DIR"="~/")
Sys.setenv("RELINC_CLUE_KEY"=demo_key)

# don't rerun all tests when we are working on something in particular.
# devel should be set to FALSE for deployment
devel <- FALSE

skip_if_devel <- function() {
  if (devel) {
    skip("Skipping to speed up development")
  }
}
