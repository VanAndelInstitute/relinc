context("Class instantiation")
test_that("Object can be created", {
  skip_if_devel()
  with_mock(
        redis_available = function(host, port) {TRUE},
        hiredis = function(host, port){TRUE},
        expect_is(Relincr$new(),  "Relincr"))
})

# add more tests here, or more tests in additional r scripts
# in this directory
