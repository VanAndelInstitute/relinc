#' Get a list of FDA approved drugs
#'
#' Attempts to identify the list of FDA drugs in L1000
#'
#' Queries the clue rep_drugs_indications endpoint to identify drugs with
#' known indications and then cross references with list of FDA approved
#' drugs from the orange book.  Some fuzzy matching is required, so  result
#' may be imperfect
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
Relincr$set("public", "approved_drugs", function() {
    if(!is.object(private$sl))
        private$start_slinky()

    perts <- clue(private$sl, "rep_drug_indications",
                  fields = c("pert_iname"),
                  where_clause = list("pert_iname" = list("like" = "")))
    perts <- unique(perts$pert_iname)
    perts <- perts[which(perts %in% metadata(private$sl)$pert_iname)]

    ob <- system.file("extdata",
                      "orange_book_products.txt.gz",
                      package = "relinc")

    orange_book <- read.delim(ob,
                              sep = "~",
                              as.is = TRUE)
    orange_book_pre <- tolower(gsub("(.*?)([A-Z]+).*",
                                    "\\1\\2",
                                    orange_book$Ingredient))
    perts_pre <- gsub("(.*?)([a-z]+).*",
                      "\\1\\2",
                      perts)
    perts[which(perts_pre %in% orange_book_pre)]
})
