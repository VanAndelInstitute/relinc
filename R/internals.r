# Try to locate configuration values, first from config.rds, then
# from environment variables, and finally by prompting user if interactive.
.check_config <- function(interactive = TRUE) {
    update = FALSE
    if(file.exists("config.rds")) {
        CONFIG <- readRDS("config.rds")
    } else {
        CONFIG <- list(
            REDIS_HOST = Sys.getenv("RELINC_REDIS_HOST"),
            REDIS_PORT = Sys.getenv("RELINC_REDIS_PORT"),
            LINCS_DIR = Sys.getenv("RELINC_LINCS_DIR"),
            CLUE_KEY = Sys.getenv("RELINC_CLUE_KEY")
        )
    }
    if(nchar(CONFIG$REDIS_HOST) < 1) {
        if(interactive)
            CONFIG$REDIS_HOST <- readline("Redis host: ")
        else
            stop("Config file or RELINC_REDIS_HOST env variable required")
        update <- TRUE
    }
    if(nchar(CONFIG$REDIS_PORT) < 1) {
        if(interactive)
            CONFIG$REDIS_PORT <- readline("Redis port: ")
        else
            stop("Config file or RELINC_REDIS_PORT env variable required")
        update <- TRUE
    }
    if(nchar(CONFIG$LINCS_DIR) < 1) {
        if(interactive)
            CONFIG$LINCS_DIR <- readline("Directory with LINCS data files: ")
        else
            stop("Config file or RELINC_LINCS_DIR env variable required")
        update <- TRUE
    }
    if(nchar(CONFIG$CLUE_KEY) < 1) {
        if(interactive)
            CONFIG$CLUE_KEY <- readline("Clue API Key: ")
        else
            stop("Config file or RELINC_CLUE_KEY env variable required")
        update <- TRUE
    }
    if(update & interactive) {
        save_config <- ""
        while(!save_config %in% c("y", "Y", "n", "N")) {
            save_config <- readline("Save config info for next session (Y/N)? ")
        }
        if(save_config %in% c("y", "Y"))
            saveRDS(CONFIG, "config.rds")
    }
    CONFIG
}

#' @import doMC
#' @importFrom parallel detectCores
.init_cluster <- function() {
    registerDoMC(detectCores() - 1)
}

# unix time as character, for .throttle
.epoch_char <- function() {
    as.character(
        as.numeric(Sys.time())
    )
}


# unix time as float, for .throttle
.epoch_float <- function() {
    as.numeric(Sys.time())
}

# file based throttling, prevents more than one
# execution per i milliseconds for any function
# calling throttle.
#' @import flock
.throttle <- function(i = 1000) {
    # make sure we are the only one using the lockfile
    l <- lock(".lock", exclusive = TRUE)

    if(file.exists(".thlock")) {
        last <- as.numeric(readLines(".thlock"))
        current <- .epoch_float()
        if((current - last) < (i/1000)) {
            Sys.sleep((i/1000) - current + last)
        }
    }
    con <- file(".thlock", blocking=TRUE, open="w+")
    writeLines(.epoch_char(), con = con)
    close(con)
    unlock(l)
}
