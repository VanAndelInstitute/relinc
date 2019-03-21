#' @import slinky
Relincr$set("private", "start_slinky", function() {
    if(is.na(private$sl)) {
        gctx <- paste0(private$CONFIG$LINCS_PATH,
               "GSE92742_Broad_LINCS_Level3_INF_mlr12k_n1319138x12328.gctx")
        info <- paste0(private$CONFIG$LINCS_PATH, "/",
               "GSE92742_Broad_LINCS_inst_info.txt.gz")
        gctx <- gsub("//", "/", gctx)
        info <- gsub("//", "/", info)

        private$sl <- Slinky(self$CONFIG$CLUE_KEY, gctx, info)
    }
})

