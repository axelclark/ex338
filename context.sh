#!/bin/sh

RESOURCE="$1"
CONTEXT="$2"

mv "lib/ex338/"$RESOURCE"/"* "lib/ex338/"$CONTEXT"/"
rm -d "lib/ex338/"$RESOURCE"/"
mv "lib/ex338/"$RESOURCE".ex" "lib/ex338/"$CONTEXT"/"$RESOURCE".ex"

mv "test/ex338/"$RESOURCE"/"* "test/ex338/"$CONTEXT"/"
rm -d "test/ex338/"$RESOURCE"/"
mv "test/ex338/"$RESOURCE"_test.exs" "test/ex338/"$CONTEXT"/"$RESOURCE"_test.exs"
