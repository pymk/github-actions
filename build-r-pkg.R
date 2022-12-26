if (!requireNamespace("devtools", quietly = TRUE)) install.packages("devtools")
if (!requireNamespace("yaml", quietly = TRUE)) install.packages("yaml")

# Setup ------------------------------------------------------------------------
pkg_name <- "NAME_OF_YOUR_R_PACKAGE"

# Create the src/contrib directory ---------------------------------------------
tiny_cran <- getwd()

contrib_dir <- file.path(tiny_cran, "src", "contrib")
if (!dir.exists(contrib_dir)) {
  dir.create(contrib_dir, recursive = TRUE)
}

# Binary paths -----------------------------------------------------------------
# Create bin directory
r_version <- paste(unlist(getRversion())[1:2], collapse = ".")

bin_paths <- list(
  # Windows
  win_binary = file.path("bin", "windows", "contrib", r_version),
  # macOS (X86)
  mac_binary = file.path("bin", "macosx", "contrib", r_version),
  # macOS (ARM)
  # See: https://cran.r-project.org/bin/macosx/
  mac_binary_big_sur = file.path("bin", "macosx", "big-sur-arm64", "contrib", r_version),
  mac_binary_el_capitan = file.path("bin", "macosx", "el-capitan", "contrib", r_version)
)

bin_paths <- lapply(bin_paths, function(x) file.path(tiny_cran, x))
lapply(bin_paths, function(path) {
  dir.create(path, recursive = TRUE)
})

# Repository name --------------------------------------------------------------
read_description <- yaml::read_yaml("DESCRIPTION")

if (length(read_description$Repository) == 0) {
  desc_line <- paste0("Repository: ", pkg_name)
  cat(desc_line, file = "DESCRIPTION", append = TRUE, sep = "\n")
}

# Copy -------------------------------------------------------------------------
devtools::build(".", path = ".")

tar_path <- list.files(pattern = "tar.gz")

if (length(tar_path) != 1) {
  stop("Missing or multiple tar.gz files found")
}

# Copy it to the src/contrib sub-directory
file.copy(
  from = file.path(tar_path),
  to = file.path(contrib_dir, tar_path),
  overwrite = TRUE
)

lapply(bin_paths, function(path) {
  file.copy(from = file.path(tar_path), to = file.path(path, tar_path), overwrite = TRUE)
})

# Write packages for each sub-directory ----------------------------------------
tools::write_PACKAGES(contrib_dir, type = "source")

lapply(bin_paths, function(path) {
  tools::write_PACKAGES(path)
})

# Delete the tar.gz file
file.remove(tar_path)
