#!/bin/sh

RESOURCE="$1"
CONTEXT="$2"

mv "lib/ex338/"$RESOURCE"/store.ex" "lib/ex338/"$CONTEXT".ex"
mv "lib/ex338/"$RESOURCE"" "lib/ex338/"$CONTEXT""
mv "lib/ex338/"$RESOURCE".ex" "lib/ex338/"$CONTEXT"/"$RESOURCE".ex"

mv "test/ex338/"$RESOURCE"/store_test.exs" "test/ex338/"$CONTEXT"_test.exs"
mv "test/ex338/"$RESOURCE"" "test/ex338/"$CONTEXT""
mv "test/ex338/"$RESOURCE"_test.exs" "test/ex338/"$CONTEXT"/"$RESOURCE"_test.exs"
