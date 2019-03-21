#' @import redux
Relincr$set("private", "connect_redis", function() {
    if(is.na(private$redis_con)) {
        if (!redis_available(host = private$CONFIG$REDIS_HOST,
                             port = private$CONFIG$REDIS_PORT)) {
            warning("Could not connect to redis.  Please verify host and port.")
        } else {
            private$redis_con = hiredis(host = private$CONFIG$REDIS_HOST,
                                        port = private$CONFIG$REDIS_PORT)
        }
    }
    invisible(self)
})

Relincr$set("private", "logger", function(level='INFO',
                                          log,
                                          file="log.txt") {
    log <- paste0(timestamp(prefix = paste0(level, " : "),
                            suffix = " : ",
                            quiet = TRUE), log)
    write(log, file, append = TRUE)
    invisible(self)
})
