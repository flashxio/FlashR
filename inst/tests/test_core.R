

test_that("read/write a dense matrix", {
		  fm.mat <- fm.runif.matrix(100, 20)
		  mat <- fm.conv.FM2R(fm.mat)
		  expect_true(fm.write.obj(fm.mat, "test.mat"))
		  fm.mat1 <- fm.read.obj("test.mat")
		  expect_equal(fm.matrix.layout(fm.mat1), "col")
		  expect_equal(mat, fm.conv.FM2R(fm.mat1))
})

test_that("read/write a transposed dense matrix", {
		  fm.mat <- fm.runif.matrix(100, 20)
		  expect_true(fm.write.obj(t(fm.mat), "test.mat"))
		  fm.mat1 <- fm.read.obj("test.mat")
		  expect_equal(fm.matrix.layout(fm.mat1), "row")
		  expect_equal(fm.conv.FM2R(t(fm.mat)), fm.conv.FM2R(fm.mat1))
})

test_that("read/write a dense submatrix", {
		  fm.mat <- fm.runif.matrix(100, 20)
		  expect_true(fm.write.obj(fm.get.cols(fm.mat, 3:12), "test.mat"))
		  fm.mat1 <- fm.read.obj("test.mat")
		  expect_equal(fm.matrix.layout(fm.mat1), "col")
		  expect_equal(fm.conv.FM2R(fm.mat[,3:12]), fm.conv.FM2R(fm.mat1))
})

test_that("read/write a transposed dense submatrix", {
		  fm.mat <- fm.runif.matrix(100, 20)
		  expect_true(fm.write.obj(t(fm.get.cols(fm.mat, 3:12)), "test.mat"))
		  fm.mat1 <- fm.read.obj("test.mat")
		  expect_equal(fm.matrix.layout(fm.mat1), "row")
		  expect_equal(fm.conv.FM2R(t(fm.mat[,3:12])), fm.conv.FM2R(fm.mat1))
})

for (type in type.set) {
test_that("which.max", {
		  fm.mat <- get.mat(type, nrow=100, ncol=10)
		  agg.which.max <- fm.create.agg.op(fm.bo.which.max, NULL, "which.max")
		  res1 <- fm.conv.FM2R(fm.agg.mat(fm.mat, 1, agg.which.max))
		  res2 <- apply(fm.conv.FM2R(fm.mat), 1, function(x) which.max(x))
		  expect_equal(res1, res2)
})

test_that("which.min", {
		  fm.mat <- get.mat(type, nrow=100, ncol=10)
		  agg.which.min <- fm.create.agg.op(fm.bo.which.min, NULL, "which.min")
		  res1 <- fm.conv.FM2R(fm.agg.mat(fm.mat, 1, agg.which.min))
		  res2 <- apply(fm.conv.FM2R(fm.mat), 1, function(x) which.min(x))
		  expect_equal(res1, res2)
})
}

test_that("test groupby rows", {
		  m <- fm.runif.matrix(100, 10)
		  v <- floor(fm.runif(100))
		  labels <- fm.as.factor(as.integer(v), max(v) + 1)
		  agg.sum <- fm.create.agg.op(fm.bo.add, fm.bo.add, "sum")
		  res <- fm.groupby(m, 2, labels, agg.sum)
		  res2 <- fm.agg.mat(m, 2, agg.sum)
		  expect_equal(as.vector(res), as.vector(res2))

		  v <- floor(fm.runif(100, min=0, max=2))
		  labels <- fm.as.factor(as.integer(v), max(v) + 1)
		  agg.sum <- fm.create.agg.op(fm.bo.add, fm.bo.add, "sum")
		  res <- fm.groupby(m, 2, labels, agg.sum)
		  rmat <- fm.conv.FM2R(m)
		  rlabels <- fm.conv.FM2R(v)
		  rres <- matrix(nrow=2, ncol=10)
		  rres[1,] <- colSums(rmat[rlabels == 0,])
		  rres[2,] <- colSums(rmat[rlabels == 1,])
		  expect_equal(fm.conv.FM2R(res), rres)
})

test_that("test groupby cols", {
		  m <- fm.runif.matrix(100, 10)
		  v <- floor(fm.runif(10))
		  labels <- fm.as.factor(as.integer(v), max(v) + 1)
		  agg.sum <- fm.create.agg.op(fm.bo.add, fm.bo.add, "sum")
		  res <- fm.groupby(m, 1, labels, agg.sum)
		  res2 <- fm.agg.mat(m, 1, agg.sum)
		  expect_equal(as.vector(res), as.vector(res2))

		  v <- floor(fm.runif(10, min=0, max=2))
		  labels <- fm.as.factor(as.integer(v), max(v) + 1)
		  agg.sum <- fm.create.agg.op(fm.bo.add, fm.bo.add, "sum")
		  res <- fm.groupby(m, 1, labels, agg.sum)
		  rmat <- fm.conv.FM2R(m)
		  rlabels <- fm.conv.FM2R(v)
		  rres <- matrix(nrow=100, ncol=2)
		  rres[,1] <- rowSums(rmat[,rlabels == 0])
		  rres[,2] <- rowSums(rmat[,rlabels == 1])
		  expect_equal(fm.conv.FM2R(res), rres)
})


test_that("test mapply2", {
		  # fm op fm
		  m <- fm.runif.matrix(100, 10)
		  m2 <- fm.runif.matrix(100, 10)
		  res <- fm.mapply2(m, m2, "+", TRUE)
		  rres <- fm.conv.FM2R(m) + fm.conv.FM2R(m2)
		  expect_equal(fm.conv.FM2R(res), rres)

		  # fmV op fmV
		  v <- fm.runif(1000)
		  v2 <- fm.runif(1000)
		  res <- fm.mapply2(v, v2, "+", TRUE)
		  rres <- fm.conv.FM2R(v) + fm.conv.FM2R(v2)
		  expect_equal(fm.conv.FM2R(res), rres)

		  # fm op fmV
		  vcol <- fm.runif(nrow(m))
		  res <- fm.mapply2(m, vcol, "+", TRUE)
		  rres <- fm.conv.FM2R(m) + fm.conv.FM2R(vcol)
		  expect_equal(fm.conv.FM2R(res), rres)

		  # fm op matrix
		  mtmp <- matrix(runif(length(m)), nrow(m), ncol(m))
		  res <- fm.mapply2(m, mtmp, "+", TRUE)
		  rres <- fm.conv.FM2R(m) + mtmp
		  expect_equal(fm.conv.FM2R(res), rres)

		  # matrix op fm
		  res <- fm.mapply2(mtmp, m, "+", TRUE)
		  rres <- mtmp + fm.conv.FM2R(m)
		  expect_equal(fm.conv.FM2R(res), rres)

		  # fm op ANY
		  vcol <- runif(nrow(m))
		  res <- fm.mapply2(m, vcol, "+", TRUE)
		  rres <- fm.conv.FM2R(m) + vcol
		  expect_equal(fm.conv.FM2R(res), rres)

		  res <- fm.mapply2(m, 1, "+", TRUE)
		  rres <- fm.conv.FM2R(m) + 1
		  expect_equal(fm.conv.FM2R(res), rres)

		  # ANY op fm
		  res <- fm.mapply2(1, m, "+", TRUE)
		  rres <- 1 + fm.conv.FM2R(m)
		  expect_equal(fm.conv.FM2R(res), rres)

		  # fmV op ANY
		  vtmp <- runif(length(v))
		  res <- fm.mapply2(v, vtmp, "+", TRUE)
		  rres <- fm.conv.FM2R(v) + vtmp
		  expect_equal(fm.conv.FM2R(res), rres)

		  res <- fm.mapply2(v, 1, "+", TRUE)
		  rres <- fm.conv.FM2R(v) + 1
		  expect_equal(fm.conv.FM2R(res), rres)

		  # ANY op fmV
		  res <- fm.mapply2(vtmp, v, "+", TRUE)
		  rres <- vtmp + fm.conv.FM2R(v)
		  expect_equal(fm.conv.FM2R(res), rres)

		  res <- fm.mapply2(1, v, "+", TRUE)
		  rres <- 1 + fm.conv.FM2R(v)
		  expect_equal(fm.conv.FM2R(res), rres)
})
