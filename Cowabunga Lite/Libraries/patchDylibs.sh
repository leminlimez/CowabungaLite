install_name_tool -id @executable_path/../Frameworks/libimobiledevice-1.0.6.dylib libimobiledevice-1.0.6.dylib
install_name_tool -id @executable_path/../Frameworks/libusbmuxd-2.0.6.dylib libusbmuxd-2.0.6.dylib
install_name_tool -id @executable_path/../Frameworks/libimobiledevice-glue-1.0.0.dylib libimobiledevice-glue-1.0.0.dylib
install_name_tool -id @executable_path/../Frameworks/libplist-2.0.3.dylib libplist-2.0.3.dylib
install_name_tool -change /usr/local/lib/libimobiledevice-1.0.6.dylib @executable_path/../Frameworks/libimobiledevice-1.0.6.dylib libimobiledevice-1.0.6.dylib
install_name_tool -change /usr/local/lib/libimobiledevice-1.0.6.dylib @executable_path/../Frameworks/libimobiledevice-1.0.6.dylib libusbmuxd-2.0.6.dylib
install_name_tool -change /usr/local/lib/libimobiledevice-1.0.6.dylib @executable_path/../Frameworks/libimobiledevice-1.0.6.dylib libimobiledevice-glue-1.0.0.dylib
install_name_tool -change /usr/local/lib/libimobiledevice-1.0.6.dylib @executable_path/../Frameworks/libimobiledevice-1.0.6.dylib libplist-2.0.3.dylib
install_name_tool -change /usr/local/lib/libusbmuxd-2.0.6.dylib @executable_path/../Frameworks/libusbmuxd-2.0.6.dylib libimobiledevice-1.0.6.dylib
install_name_tool -change /usr/local/lib/libusbmuxd-2.0.6.dylib @executable_path/../Frameworks/libusbmuxd-2.0.6.dylib libusbmuxd-2.0.6.dylib
install_name_tool -change /usr/local/lib/libusbmuxd-2.0.6.dylib @executable_path/../Frameworks/libusbmuxd-2.0.6.dylib libimobiledevice-glue-1.0.0.dylib
install_name_tool -change /usr/local/lib/libusbmuxd-2.0.6.dylib @executable_path/../Frameworks/libusbmuxd-2.0.6.dylib libplist-2.0.3.dylib
install_name_tool -change /usr/local/lib/libimobiledevice-glue-1.0.0.dylib @executable_path/../Frameworks/libimobiledevice-glue-1.0.0.dylib libimobiledevice-1.0.6.dylib
install_name_tool -change /usr/local/lib/libimobiledevice-glue-1.0.0.dylib @executable_path/../Frameworks/libimobiledevice-glue-1.0.0.dylib libusbmuxd-2.0.6.dylib
install_name_tool -change /usr/local/lib/libimobiledevice-glue-1.0.0.dylib @executable_path/../Frameworks/libimobiledevice-glue-1.0.0.dylib libimobiledevice-glue-1.0.0.dylib
install_name_tool -change /usr/local/lib/libimobiledevice-glue-1.0.0.dylib @executable_path/../Frameworks/libimobiledevice-glue-1.0.0.dylib libplist-2.0.3.dylib
install_name_tool -change /usr/local/lib/libplist-2.0.3.dylib @executable_path/../Frameworks/libplist-2.0.3.dylib libimobiledevice-1.0.6.dylib
install_name_tool -change /usr/local/lib/libplist-2.0.3.dylib @executable_path/../Frameworks/libplist-2.0.3.dylib libusbmuxd-2.0.6.dylib
install_name_tool -change /usr/local/lib/libplist-2.0.3.dylib @executable_path/../Frameworks/libplist-2.0.3.dylib libimobiledevice-glue-1.0.0.dylib
install_name_tool -change /usr/local/lib/libplist-2.0.3.dylib @executable_path/../Frameworks/libplist-2.0.3.dylib libplist-2.0.3.dylib
