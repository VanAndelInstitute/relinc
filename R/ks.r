#' Calculate ks scores for genes
#'
#' Rank-of-ranks score for each gene across all instances
#'
#' Calculates the rank-of-ranks score for each gene across all instance
#' for given perturbation and perturbation type. Genes are first ranked within
#' each instance, and these ranks are ranked across all instances.  The KS
#' statistic is then calculated for each gene in this vector of ranks
#'
#' @param name The pert_iname of desired perturbation
#' @param type The pert_type of desired perturbation, default is `trt_cp``
#' @return Vector of scores, one per gene
#'
#' @examples
#' \dontrun{
#'
#' x <- Relincr$new()
#' x$ks_pert("amoxicillin")
#' }
#' @format NULL
#' @name ks_pert
NULL
#' @import slinky
Relincr$set("public", "ks_pert", function(name, type="trt_cp") {
    dat <- self$fetch_by_pert(name, type)

    ranks <- apply(-dat, 2, rank)
    ranks <- as.vector(ranks)
    names(ranks) <- rep(rownames(dat), ncol(dat))
    ranks <- ranks[order(ranks)]
    res <- foreach(g=rownames(dat), .combine=c) %do% {
        self$ks(names(ranks), g)
    }
    names(res) <- rownames(dat)
    res
})


#' Calculate ks scores for random sample
#'
#' Rank-of-ranks score for each gene across all instances within a random
#' sample of instances
#'
#' Calculates the rank-of-ranks score for each gene across all instances
#' within a random sample of instances. Useful for bootstrapping significance
#' of gene scores.
#'
#' @param n The size of random sample desired
#' @param type The pert_type of desired perturbation, default is `trt_cp``
#' @return Vector of scores, one per gene
#'
#' @examples
#' \dontrun{
#'
#' x <- Relincr$new()
#' x$ks_rand(10)
#' }
#' @format NULL
#' @name ks_rand
NULL
#' @import slinky
Relincr$set("public", "ks_rand", function(n, type="trt_cp") {
    dat <- self$fetch_rand(n, type)

    ranks <- apply(-dat, 2, rank)
    ranks <- as.vector(ranks)
    names(ranks) <- rep(rownames(dat), ncol(dat))
    ranks <- ranks[order(ranks)]
    res <- foreach(g=rownames(dat), .combine=c) %do% {
        self$ks(names(ranks), g)
    }
    names(res) <- rownames(dat)
    res
})


#' Calculate ks score for vector
#'
#' The Kolmogorov-Smirnov statistic for bias in selected values in ordered
#' vector,
#'
#' @param x Vector of ordered values
#' @param m The value of interest
#' @return Score, quantifying the extent to which occurrences of m are
#' biased towards early values.
#'
#' @examples
#' \dontrun{
#'
#' x <- Relincr$new()
#' x$ks(c("a", "b", "a", "b", "a", "a", "a", "a", "b") "b")
#' }
#' @format NULL
#' @name ks
NULL
#' @import slinky
Relincr$set("public", "ks", function(x, m) {
    ix <- which(x == m)
    pen <- -1/(length(x) - sum(x == m))
    inc <- 1 / sum(x == m)
    sc <- rep(pen, length(x))
    sc[ix] <- inc
    sc <- cumsum(sc)
    if(-min(sc) > max(sc)) {
        return(min(sc))
    } else {
        return(max(sc))
    }
})


#' Boostrap zscore
#'
#' Take random samples from appropriate instance space and calculate KS scores
#'
#' This function identifies all instances in the dataset of a given pert_type
#' and then takes s random samples of these instances each of size `n`
#' instances. It then calculates the rank of ranks ks score for each sample,
#' and returns all the ks scores as a dataframe which may then be used to
#' estimate p-values of observed ks scores.
#'
#' @param s the number of samples to take, default is 1000
#' @param n the number of instances in each sample, default is 10
#' @param type the pert_type to sample from, default is trt_cp
#' @return data.frame of ks scores, 1 row per gene and 1 column per sample
#'
#' @examples
#' \dontrun{
#'
#' x <- Relincr$new()
#' x$bootstrap_ks(10, 10)
#' }
#' @format NULL
#' @name bootstrap_ks
NULL
#' @import slinky
#' @importFrom dplyr bind_cols
Relincr$set("public", "bootstrap_ks", function(s = 10,
                                              n = 10,
                                              type = "trt_cp") {
    res <- foreach(i = 1:s,
                   .errorhandling = "stop",
                   .packages = c("relinc")) %dopar% {
                       tryCatch({
                           if(i %% 100 == 0) {
                               private$logger(log = paste(" bootstrap iteration", i, "of", s))
                           }
                           self$ks_rand(n, type)
                       },
                       warning = function(w) {
                           private$logger("WARNING", log = paste(w))
                       },
                       error = function(e) {
                           private$logger("ERROR", log = paste(e))
                       }
                       )
                   }
    names(res) <- 1:s
    do.call(bind_cols, res)
})

