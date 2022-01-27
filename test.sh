#!/bin/bash

cd tests

for i in *.pas
do
  ruby -w ../pascual.rb $i > $(basename $i .pas).txt
done

cd ..
