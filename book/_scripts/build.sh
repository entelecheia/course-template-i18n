#!/bin/bash
if [ "$1" == "--all" ]; then
  echo "Building the books with all outputs"
  for lang in en ko; do
    echo "Building the book for $lang"
    jupyter-book build "book/$lang" --all
  done
else
  echo "Building the books"
  for lang in en ko; do
    echo "Building the book for $lang"
    jupyter-book build "book/$lang"
  done
fi

# Run post-processing script
./book/_scripts/postprocessing.sh
