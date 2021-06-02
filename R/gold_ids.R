#' Fetch list of gold instances from clue.io api
#'
#' The LINCS program identifies low variability and self-connected signatures
#' as "gold" among all the L1000 signatures. Getting the list of "gold"
#' instances is a little unwieldy, requiring extracting the instances form
#' these signatures. This function performs this extraction.
#'
#' Note that this resulting list is available as part of this package, as
#' \preformatted{
#'   ids <- readRDS(system.file("extdata",
#'                  orange_book_products.txt.gz",
#'                  package = "relinc"))
#' }
#'
#' @return List of ids that are in at least one "gold" signature.
#'
#' @examples
#' \dontrun{
#'
#' x <- Relincr$new()
#' ids <- x$gold_ids()
#' }
#' @format NULL
#' @name gold_ids
#' @import foreach
NULL

Relincr$set("public", "gold_ids", function() {
    count <- 476251

    message("Retrieving gold instance ids from clue.io")

    pb <- txtProgressBar(
        min = 0,
        max = ceiling(count / 1000),
        initial = 0,
        width = 100,
        style = 3
    )

    ids <- foreach(i = 1:ceiling(count / 1000), .combine = c) %do% {
        setTxtProgressBar(pb, i)
        limit <- 1000
        if(i*1000 > count)
            limit <- count %% 1000

        skip <- (i - 1) * 1000

        res <- httr::GET(
            url = "https://api.clue.io/",
            path = paste0("api/sigs/"),
            query = list(
                filter = jsonlite::toJSON(
                    list(
                        fields = c("distil_id"),
                        limit = limit,
                        skip = skip
                    ),
                    auto_unbox = TRUE
                ),
                user_key = private$CONFIG$CLUE_KEY
                # "db1db72b80bcb8ed812a2a7af0198bbb"
            )
        )
        as.character(unlist(content(res)))
    }
    unique(ids)
})

