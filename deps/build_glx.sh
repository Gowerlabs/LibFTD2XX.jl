#!/bin/bash

cd downloads
tar -zxvf ./libftd2xx.gz
mv release/build/* ../usr/lib/
rm -rf release
