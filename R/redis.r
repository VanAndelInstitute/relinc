#' Write a record to redis
#'
#' Writes a record to the open redis connection
#'
#' When the Relincr object is created, it opens a connection to the redis
#' database specified by the configuration settings.  The specified data is
#' written to the specified key using this connection.
#'
#' @param key The record key
#' @param value The record data
#' @return Silently returns the Relincr object to allow function chaining
#'
#' @examples
#' \dontrun{
#'
#' x <- Relincr$new()
#' x$write_record("key1", "value1")
#' }
#' @format NULL
#' @name write_record
#' @import redux
NULL

Relincr$set("public", "write_record", function(key, value) {
    tryCatch({
        con <- hiredis(host = private$CONFIG$REDIS_HOST,
                       port = private$CONFIG$REDIS_PORT)
        con$SET(key, object_to_string(value))
        rm(con)
    },
    error = function(e) {
        private$logger("ERROR", e)
        # avoid runaway errors swamping network
        Sys.sleep(1)
    })
    invisible(self)
})


#' Read a record from redis
#'
#' Reads the specified keys from the open redis connection
#'
#' When the Relincr object is created, it opens a connection to the redis
#' database specified by the configuration settings.  The specified key is
#' read from this connection.
#'
#' @param key The record key
#' @return Returns the data stored for the specified key
#'
#' @examples
#' \dontrun{
#'
#' x <- Relincr$new()
#' dat <- x$read_record("key1")
#' }
#' @format NULL
#' @name fetch_record
#' @import redux
NULL

Relincr$set("public", "fetch_record", function(key) {
    con <- hiredis(host = private$CONFIG$REDIS_HOST,
                   port = private$CONFIG$REDIS_PORT)
    rec <- con$GET(key)
    rm(con)
    string_to_object(rec)
})


#' Read multiple records from redis
#'
#' Reads the specified keys from the open redis connection
#'
#' When the Relincr object is created, it opens a connection to the redis
#' database specified by the configuration settings.  The specified keys are
#' read from this connection.
#'
#' @param keys The record keys
#' @return Returns the data stored for the specified keys as a data.frame
#'
#' @examples
#' \dontrun{
#'
#' x <- Relincr$new()
#' dat <- x$read_records(c("key1", "key2"))
#' }
#' @format NULL
#' @name fetch_record
#' @import redux
NULL

Relincr$set("public", "fetch_records", function(keys) {
    con <- hiredis(host = private$CONFIG$REDIS_HOST,
                          port = private$CONFIG$REDIS_PORT)
    recs <- con$MGET(keys)
    rm(con)
    ix <- which(!sapply(recs, is.null))
    if(!length(ix)) {
        return(NA)
    }
    recs <- recs[ix]
    dat <- sapply(recs, string_to_object)
    if(!is.null(ncol(dat)))
        colnames(dat) <- keys[ix]
    else
        names(dat) <- keys[ix]
    dat
})


#' Fetch z-scores for a pert
#'
#' Returns all z-scores for given pert and pert_type
#'
#'
#' @param name The pert_iname for desired perturbation
#' @param type The pert_type desired.  Default is `trt_cp`.
#' @return Returns a data.frame containing to z-scores
#'
#' @examples
#' \dontrun{
#'
#' x <- Relincr$new()
#' dat <- x$fetch_by_pert("amoxicillin")
#' }
#' @format NULL
#' @name fetch_by_pert
#' @import slinky
NULL

Relincr$set("public", "fetch_by_pert", function(name, type="trt_cp") {
    if(!is.object(private$sl))
        private$start_slinky()
    ix <- which(metadata(private$sl)$pert_iname == name &
                    metadata(private$sl)$pert_type == type)
    self$fetch_records(metadata(private$sl)$inst_id[ix])
})


#' Fetch random set of z-scores
#'
#' Returns a random set of z-scores of specified size.  Useful for
#' boostrapping
#'
#'
#' @param n How many samples to fetch
#' @param type The pert_type from which to sample. Default is `trt_cp`
#' @return Returns a data.frame containing zscores stored for a random
#' set of samples
#'
#' @examples
#' \dontrun{
#'
#' x <- Relincr$new()
#' dat <- x$fetch_random(10)
#' }
#' @format NULL
#' @name fetch_by_pert
#' @import slinky
NULL
Relincr$set("public", "fetch_rand", function(n, type="trt_cp") {
    if(!is.object(private$sl))
        private$start_slinky()
    nn <- 0
    dat <- NULL
    ix.type <- which(metadata(private$sl)$pert_type == type)
    while(nn < n) {
        ix <- sample(ix.type, n-nn)
        d <- self$fetch_records(metadata(private$sl)$inst_id[ix])
        if(!is.na(d[1])) {
            if(is.null(dat)) {
                dat <- d
            } else {
                dat <- cbind(dat, d)
            }
            nn <- ncol(dat)
        }
    }
    dat
})


