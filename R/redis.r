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
        private$redis_con$SET(key, object_to_string(value))
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
    string_to_object(private$redis_con$GET(key))
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
    recs <- private$redis_con$MGET(keys)
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
