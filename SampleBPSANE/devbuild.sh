#!/bin/sh
AIR_SDK_PATH="/Developer/SDKs/air_3.0_sdk/bin"

unzip -o as/bin/bpsane.swc
rm catalog.xml
cp native/Device-Debug/libbpsane-arm.so ./native.so
eval $AIR_SDK_PATH/adt -package -target ane bpsdemo.ane extension.xml -swc as/bin/bpsane.swc -platform QNX-ARM -C . library.swf native.so 
rm native.so
rm library.swf
cp bpsdemo.ane app/bpsdemo.ane