context("Class instantiation")
test_that("Object can be created", {
  skip_if_devel()
  myObj <- MyR6Class$new(1, 2)
  expect_is(myObj,  "MyR6Class")
})

# add more tests here, or more tests in additional r scripts
# in this directory
