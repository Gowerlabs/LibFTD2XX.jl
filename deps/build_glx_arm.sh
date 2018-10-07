#!/bin/bash

cd downloads
tar -zxvf ./libftd2xx-arm.gz
mv release/build/* ../usr/lib/
rm -rf release
