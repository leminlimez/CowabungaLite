install_name_tool -id @executable_path/../Resources/idevice_id idevice_id
install_name_tool -id @executable_path/../Resources/ideviceinfo ideviceinfo
install_name_tool -id @executable_path/../Resources/idevicename idevicename
install_name_tool -id @executable_path/../Resources/idevicebackup2 idevicebackup2
install_name_tool -id @executable_path/../Resources/homeScreenAppsNew homeScreenAppsNew
install_name_tool -change /usr/local/lib/libimobiledevice-1.0.6.dylib @executable_path/../Frameworks/libimobiledevice-1.0.6.dylib idevice_id
install_name_tool -change /usr/local/lib/libimobiledevice-1.0.6.dylib @executable_path/../Frameworks/libimobiledevice-1.0.6.dylib ideviceinfo
install_name_tool -change /usr/local/lib/libimobiledevice-1.0.6.dylib @executable_path/../Frameworks/libimobiledevice-1.0.6.dylib idevicename
install_name_tool -change /usr/local/lib/libimobiledevice-1.0.6.dylib @executable_path/../Frameworks/libimobiledevice-1.0.6.dylib idevicebackup2
install_name_tool -change /usr/local/lib/libimobiledevice-1.0.6.dylib @executable_path/../Frameworks/libimobiledevice-1.0.6.dylib homeScreenAppsNew
install_name_tool -change /usr/local/lib/libusbmuxd-2.0.6.dylib @executable_path/../Frameworks/libusbmuxd-2.0.6.dylib idevice_id
install_name_tool -change /usr/local/lib/libusbmuxd-2.0.6.dylib @executable_path/../Frameworks/libusbmuxd-2.0.6.dylib ideviceinfo
install_name_tool -change /usr/local/lib/libusbmuxd-2.0.6.dylib @executable_path/../Frameworks/libusbmuxd-2.0.6.dylib idevicename
install_name_tool -change /usr/local/lib/libusbmuxd-2.0.6.dylib @executable_path/../Frameworks/libusbmuxd-2.0.6.dylib idevicebackup2
install_name_tool -change /usr/local/lib/libusbmuxd-2.0.6.dylib @executable_path/../Frameworks/libusbmuxd-2.0.6.dylib homeScreenAppsNew
install_name_tool -change /usr/local/lib/libimobiledevice-glue-1.0.0.dylib @executable_path/../Frameworks/libimobiledevice-glue-1.0.0.dylib idevice_id
install_name_tool -change /usr/local/lib/libimobiledevice-glue-1.0.0.dylib @executable_path/../Frameworks/libimobiledevice-glue-1.0.0.dylib ideviceinfo
install_name_tool -change /usr/local/lib/libimobiledevice-glue-1.0.0.dylib @executable_path/../Frameworks/libimobiledevice-glue-1.0.0.dylib idevicename
install_name_tool -change /usr/local/lib/libimobiledevice-glue-1.0.0.dylib @executable_path/../Frameworks/libimobiledevice-glue-1.0.0.dylib idevicebackup2
install_name_tool -change /usr/local/lib/libimobiledevice-glue-1.0.0.dylib @executable_path/../Frameworks/libimobiledevice-glue-1.0.0.dylib homeScreenAppsNew
install_name_tool -change /usr/local/lib/libplist-2.0.4.dylib @executable_path/../Frameworks/libplist-2.0.4.dylib idevice_id
install_name_tool -change /usr/local/lib/libplist-2.0.4.dylib @executable_path/../Frameworks/libplist-2.0.4.dylib ideviceinfo
install_name_tool -change /usr/local/lib/libplist-2.0.4.dylib @executable_path/../Frameworks/libplist-2.0.4.dylib idevicename
install_name_tool -change /usr/local/lib/libplist-2.0.4.dylib @executable_path/../Frameworks/libplist-2.0.4.dylib idevicebackup2
install_name_tool -change /usr/local/lib/libplist-2.0.4.dylib @executable_path/../Frameworks/libplist-2.0.4.dylib homeScreenAppsNew
