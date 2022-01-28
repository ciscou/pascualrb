#!/bin/bash

cd tests

for i in *.pas
do
  ruby -w ../pascualc.rb $i > $(basename $i .pas).asm
  ruby -w ../pascual.rb $(basename $i .pas).asm > $(basename $i .pas).txt
done

cd ..
