# This file contains some implementations from the mvtnorm package.

fm.rmvnorm <- function (n, mean = rep(0, nrow(sigma)), sigma = diag(length(mean)),
						method = c("eigen", "svd", "chol"), pre0.9_9994 = FALSE,
						in.mem=TRUE, name="")
{
	orig.test.na <- fm.env$fm.test.na
	fm.set.test.na(FALSE)
	if (!isSymmetric(sigma, tol = sqrt(.Machine$double.eps),
					 check.attributes = FALSE)) {
		stop("sigma must be a symmetric matrix")
	}
	if (length(mean) != nrow(sigma))
		stop("mean and sigma have non-conforming size")
	method <- match.arg(method)
	R <- if (method == "eigen") {
		ev <- eigen(sigma, symmetric = TRUE)
		if (!all(ev$values >= -sqrt(.Machine$double.eps) * abs(ev$values[1]))) {
			warning("sigma is numerically not positive definite")
		}
		t(ev$vectors %*% (t(ev$vectors) * sqrt(ev$values)))
	}
	else if (method == "svd") {
		s. <- svd(sigma)
		if (!all(s.$d >= -sqrt(.Machine$double.eps) * abs(s.$d[1]))) {
			warning("sigma is numerically not positive definite")
		}
		t(s.$v %*% (t(s.$u) * sqrt(s.$d)))
	}
	else if (method == "chol") {
		R <- chol(sigma, pivot = TRUE)
		R[, order(attr(R, "pivot"))]
	}

	retval <- fm.rnorm.matrix(nrow = n, ncol=ncol(sigma), in.mem=in.mem,
							  name=name) %*% R
	# , byrow = !pre0.9_9994
	retval <- sweep(retval, 2, mean, "+")
	colnames(retval) <- names(mean)
	fm.set.test.na(orig.test.na)
	fm.materialize(retval)
}
