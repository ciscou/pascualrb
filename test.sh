#!/bin/bash

cd tests

for i in *.pas
do
  ruby ../pascual.rb $i > $(basename $i .pas).txt
done

cd ..
