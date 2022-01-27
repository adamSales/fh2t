hdi <- function(x, ci = 0.95, verbose = TRUE) {


  x_sorted <- unname(sort.int(x, method = "quick")) # removes NA/NaN, but not Inf
  window_size <- ceiling(ci * length(x_sorted)) # See https://github.com/easystats/bayestestR/issues/39

  if (window_size < 2) {
    if (verbose) {
      warning("`ci` is too small or x does not contain enough data points, returning NAs.")
    }
    return(data.frame(
      "CI" = ci,
      "CI_low" = NA,
      "CI_high" = NA
    ))
  }

  nCIs <- length(x_sorted) - window_size

  if (nCIs < 1) {
    if (verbose) {
      warning("`ci` is too large or x does not contain enough data points, returning NAs.")
    }
    return(data.frame(
      "CI" = ci,
      "CI_low" = NA,
      "CI_high" = NA
    ))
  }

  ci.width <- sapply(1:nCIs, function(.x) x_sorted[.x + window_size] - x_sorted[.x])

  # find minimum of width differences, check for multiple minima
  min_i <- which(ci.width == min(ci.width))
  n_candies <- length(min_i)

  if (n_candies > 1) {
    if (any(diff(sort(min_i)) != 1)) {
      if (verbose) {
        warning("Identical densities found along different segments of the distribution, choosing rightmost.", call. = FALSE)
      }
      min_i <- max(min_i)
    } else {
      min_i <- floor(mean(min_i))
    }
  }

  data.frame(
    "CI" = ci,
    "CI_low" = x_sorted[min_i],
    "CI_high" = x_sorted[min_i + window_size]
  )
}


