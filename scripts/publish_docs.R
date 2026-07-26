# Publish project documentation into docs/ for GitHub publication.
# Source of truth: documentation/

source_dir <- "documentation"
target_dir <- file.path("docs", "documentation")

if (!dir.exists(source_dir)) {
  stop("Source folder not found: ", source_dir)
}

dir.create(target_dir, recursive = TRUE, showWarnings = FALSE)

clean_target_dir <- function() {
  old_markdown <- list.files(target_dir, pattern = "\\.md$", full.names = TRUE)
  if (length(old_markdown) > 0) {
    unlink(old_markdown, force = TRUE)
  }

  old_asset_dirs <- list.dirs(target_dir, recursive = FALSE, full.names = TRUE)
  old_asset_dirs <- old_asset_dirs[grepl("_files$", old_asset_dirs)]
  if (length(old_asset_dirs) > 0) {
    unlink(old_asset_dirs, recursive = TRUE, force = TRUE)
  }
}

copy_markdown_files <- function() {
  md_files <- list.files(source_dir, pattern = "\\.md$", full.names = TRUE)
  if (length(md_files) == 0) {
    return(invisible(NULL))
  }

  for (file in md_files) {
    out <- file.path(target_dir, basename(file))
    file.copy(file, out, overwrite = TRUE)
    message("Copied: ", file, " -> ", out)
  }
}

render_rmd_to_markdown <- function() {
  rmd_files <- list.files(source_dir, pattern = "\\.Rmd$", full.names = TRUE)
  if (length(rmd_files) == 0) {
    return(invisible(NULL))
  }

  if (!requireNamespace("rmarkdown", quietly = TRUE)) {
    warning("Package 'rmarkdown' is not installed. Skipping Rmd rendering.")
    return(invisible(NULL))
  }

  for (file in rmd_files) {
    output_name <- sub("\\.Rmd$", ".md", basename(file))
    temp_dir <- tempfile("publish-docs-")
    dir.create(temp_dir, recursive = TRUE, showWarnings = FALSE)

    rmarkdown::render(
      input = file,
      output_format = "github_document",
      output_file = output_name,
      output_dir = temp_dir,
      quiet = TRUE,
      envir = new.env(parent = globalenv())
    )

    rendered <- file.path(temp_dir, output_name)
    target <- file.path(target_dir, output_name)
    file.copy(rendered, target, overwrite = TRUE)
    message("Rendered: ", file, " -> ", target)

    rendered_assets <- file.path(temp_dir, sub("\\.md$", "_files", output_name))
    target_assets <- file.path(target_dir, sub("\\.md$", "_files", output_name))
    if (dir.exists(rendered_assets)) {
      if (dir.exists(target_assets)) {
        unlink(target_assets, recursive = TRUE, force = TRUE)
      }
      file.copy(rendered_assets, target_assets, recursive = TRUE)
      message("Copied assets: ", rendered_assets, " -> ", target_assets)
    }
  }
}

clean_target_dir()
copy_markdown_files()
render_rmd_to_markdown()

message("Documentation publication complete: ", target_dir)
