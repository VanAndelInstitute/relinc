#' Calculate and store robust z-scores
#'
#' Calculates and scores all instances for given pert
#'
#' Uses Slinky to query and load instances for given pert and
#' same plate controls, and then calculate robust z-scores.  These
#' are then stored in the redis instance associated with the object.
#' Presently only uses the L1000 genes (i.e. inferred genes are
#' excluded).  TO DO: create option to include inferred genes.
#'
#' @param pert The pert_iname of desired perturbation
#' @return Silently returns the Relincr object to allow function chaining,
#'         and has the side effect of storing data in redis
#'
#' @examples
#' \dontrun{
#'
#' x <- Relincr$new()
#' x$zscore_and_store("LMNA")
#' }
#' @format NULL
#' @name zscore_and_store
NULL

#' @import slinky
Relincr$set("public", "zscore_and_store", function(pert) {
    if(!is.object(private$sl))
        private$start_slinky()

    scores <- rzs(private$sl, pert, inferred = FALSE, verbose = FALSE)
    foreach(s = colnames(scores)) %do% {
        st <- self$write_record(s, scores[ , s])
    }
})

#' Calculate and store zscores for all drugs
#'
#' Convenience wrapper for all drugs
#'
#' Calls score_and_store for all drugs in the dataset, using (almost)
#' all available cores on the host machine to speed things up. TO DO:
#' add option to pass a cluster object in explicitly to allow
#' parallelization on multiple nodes
#'
#' @return Silently returns the Relincr object to allow function chaining,
#'         and has the side effect of storing data in redis
#'
#' @examples
#' \dontrun{
#'
#' x <- Relincr$new()
#' x$score_all_drugs()
#' }
#' @format NULL
#' @name zscore_all_drugs
NULL
#' @import slinky
Relincr$set("public", "zscore_all_drugs", function() {
    drugs <- self$approved_drugs()
    .init_cluster()
    res <- foreach(d = drugs,
                   .errorhandling = "stop",
                   .packages = c("relinc")) %dopar% {
                       tryCatch({
                           .throttle(2000)
                           self$zscore_and_store(d)
                           private$logger(log = paste0(d, " processed and written to redis"))
                       },
                       warning = function(w) {
                           private$logger("WARNING", log = paste(d, w))
                       },
                       error = function(e) {
                           private$logger("ERROR", log = paste(d, e))
                       }
                       )
                   }
})

#' Calculate and store zscores for all genes
#'
#' Convenience wrapper for all genes
#'
#' Calls score_and_store for all gene perturbagens  in the dataset, using
#' available cores on the host machine to speed things up. TO DO:
#' add option to pass a cluster object in explicitly to allow
#' parallelization on multiple nodes
#'
#' @return Silently returns the Relincr object to allow function chaining,
#'         and has the side effect of storing data in redis
#'
#' @examples
#' \dontrun{
#'
#' x <- Relincr$new()
#' x$score_all_drugs()
#' }
#' @format NULL
#' @name zscore_and_store
NULL
#' @import slinky
Relincr$set("public", "zscore_all_genes", function() {
    if(!is.object(private$sl))
        private$start_slinky()

    ix.sh <- which(metadata(private$sl)$pert_type == "trt_sh")
    genes <- unique(metadata(private$sl)$pert_iname[ix.sh])
    .init_cluster()
    res <- foreach(g = genes,
                   .errorhandling = "stop",
                   .packages = c("relinc")) %dopar% {
                       tryCatch({
                           .throttle(2000)
                           self$zscore_and_store(g)
                           private$logger(log = paste0(g, " processed and written to redis"))
                       },
                       warning = function(w) {
                           private$logger("WARNING", log = paste(g, w))
                       },
                       error = function(e) {
                           private$logger("ERROR", log = paste(g, e))
                       }
                       )
                   }
})

