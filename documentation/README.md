# Documentation Source

This folder contains editable source documentation for the project.

## Source Files

- `README.md`
- `quick_start.Rmd`
- `data_schema.md`
- `development.md`
- `deployment.md`
- `google_sheets_setup.md`

## Publishing

Published output is generated into `docs/documentation/`.

`quick_start.md` is generated from `quick_start.Rmd` during publishing.

From project root, run:

```r
source("scripts/publish_docs.R")
```

## Appendix

- Source docs: `documentation/`
- Published docs: `docs/`
