# DotFiles

All .DotFiles you want to keep track of, should be stored in the `src/` folder.

## Initiating .DotFiles in your system from source

This is non-reversible, so you will be prompted for each .DotFile.

`make init`

## Updating .DotFiles from your system

You should not update the files in `src/` directly.
Rather update the files directly in your system (`~`) and when you're happy, run:

`make update`

## Adding a new .DotFile

Just copy it from your system to the `src/` folder and commit.

`cp ~/.newFile src`

## Troubleshooting

1. If you run into "Permission denied" errors when running scripts, run `make chmod`
