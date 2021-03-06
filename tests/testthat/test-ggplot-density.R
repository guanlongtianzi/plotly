context("Probability density")

expect_traces <- function(gg, n.traces, name) {
  stopifnot(is.ggplot(gg))
  stopifnot(is.numeric(n.traces))
  save_outputs(gg, paste0("density-", name))
  L <- gg2list(gg)
  all.traces <- L$data
  no.data <- sapply(all.traces, function(tr) {
    is.null(tr[["x"]]) && is.null(tr[["y"]])
  })
  has.data <- all.traces[!no.data]
  expect_equal(length(has.data), n.traces)
  list(traces=has.data, layout=L$layout)
}

# Draw a probability density estimation using geom_density
base <- ggplot(mtcars, aes(wt))

test_that("geom_density() is translated to area chart", {
  info <- expect_traces(base + geom_density(), 1, "simple")
  tr <- info$traces[[1]]
  expect_identical(tr$type, "scatter")
  expect_identical(tr$fill, "tozeroy")
  expect_identical(tr$fillcolor, "rgba(51,51,51,0)")
})

test_that("geom_density() respects fill aesthetic", {
  gg <- base + geom_density(aes(fill=factor(vs)), alpha = 0.3)
  info <- expect_traces(gg, 2, "fill")
  trs <- info$traces
  type <- unique(sapply(trs, "[[", "type"))
  fill <- unique(sapply(trs, "[[", "fill"))
  expect_identical(type, "scatter")
  expect_identical(fill, "tozeroy")
})

test_that("geom_density() respects colour aesthetic", {
  info <- expect_traces(base + geom_density(aes(colour=factor(vs))), 2, "color")
  trs <- info$traces
  type <- unique(sapply(trs, "[[", "type"))
  fill <- unique(sapply(trs, "[[", "fill"))
  expect_identical(type, "scatter")
  expect_identical(fill, "tozeroy")
})

g <- base + 
  geom_histogram(aes(y = ..density..), binwidth = 0.5, fill = "pink") +
  geom_density(fill = "lightblue", alpha = 0.1)
  
test_that("geom_histogram(aes(y = ..density..)) + geom_density() works", {
  info <- expect_traces(g, 2, "color")
  trs <- info$traces
  type <- unique(sapply(trs, "[[", "type"))
  expect_identical(sort(type), c("bar", "scatter"))
})
