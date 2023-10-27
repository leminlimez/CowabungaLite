#include "StatusSetter16_3.hpp"
#include "StatusManager.hpp"

enum class StatusBarItem : int
{
    TimeStatusBarItem = 0,
    DateStatusBarItem = 1,
    QuietModeStatusBarItem = 2,
    AirplaneModeStatusBarItem = 3,
    CellularSignalStrengthStatusBarItem = 4,
    SecondaryCellularSignalStrengthStatusBarItem = 5,
    CellularServiceStatusBarItem = 6,
    SecondaryCellularServiceStatusBarItem = 7,
    // 8
    CellularDataNetworkStatusBarItem = 9,
    SecondaryCellularDataNetworkStatusBarItem = 10,
    // 11
    MainBatteryStatusBarItem = 12,
    ProminentlyShowBatteryDetailStatusBarItem = 13,
    // 14
    // 15
    BluetoothStatusBarItem = 16,
    TTYStatusBarItem = 17,
    AlarmStatusBarItem = 18,
    // 19
    // 20
    LocationStatusBarItem = 21,
    RotationLockStatusBarItem = 22,
    CameraUseStatusBarItem = 23,
    AirPlayStatusBarItem = 24,
    AssistantStatusBarItem = 25,
    CarPlayStatusBarItem = 26,
    StudentStatusBarItem = 27,
    MicrophoneUseStatusBarItem = 28,
    VPNStatusBarItem = 29,
    // 30
    // 31
    // 32
    // 33
    // 34
    // 35
    // 36
    // 37
    LiquidDetectionStatusBarItem = 38,
    VoiceControlStatusBarItem = 39,
    // 40
    // 41
    // 42
    // 43
    Extra1StatusBarItem = 44,
};

enum class BatteryState : unsigned int
{
    BatteryStateUnplugged = 0
};

struct StatusBarRawData
{
    bool itemIsEnabled[45];
    char padding1;
    char padding2;
    char timeString[64];
    char shortTimeString[64];
    char dateString[256];
    int gsmSignalStrengthRaw;
    int secondaryGsmSignalStrengthRaw;
    int gsmSignalStrengthBars;
    int secondaryGsmSignalStrengthBars;
    char serviceString[100];
    char secondaryServiceString[100];
    char serviceCrossfadeString[100];
    char secondaryServiceCrossfadeString[100];
    char serviceImages[2][100];
    char operatorDirectory[1024];
    unsigned int serviceContentType;
    unsigned int secondaryServiceContentType;
    unsigned int cellLowDataModeActive : 1;
    unsigned int secondaryCellLowDataModeActive : 1;
    int wifiSignalStrengthRaw;
    int wifiSignalStrengthBars;
    unsigned int wifiLowDataModeActive : 1;
    unsigned int dataNetworkType;
    unsigned int secondaryDataNetworkType;
    int batteryCapacity;
    unsigned int batteryState;
    char batteryDetailString[150];
    int bluetoothBatteryCapacity;
    int thermalColor;
    unsigned int thermalSunlightMode : 1;
    unsigned int slowActivity : 1;
    unsigned int syncActivity : 1;
    char activityDisplayId[256];
    unsigned int bluetoothConnected : 1;
    unsigned int displayRawGSMSignal : 1;
    unsigned int displayRawWifiSignal : 1;
    unsigned int locationIconType : 1;
    unsigned int voiceControlIconType : 2;
    unsigned int quietModeInactive : 1;
    unsigned int tetheringConnectionCount;
    unsigned int batterySaverModeActive : 1;
    unsigned int deviceIsRTL : 1;
    unsigned int lock : 1;
    char breadcrumbTitle[256];
    char breadcrumbSecondaryTitle[256];
    char personName[100];
    unsigned int electronicTollCollectionAvailable : 1;
    unsigned int radarAvailable : 1;
    unsigned int wifiLinkWarning : 1;
    unsigned int wifiSearching : 1;
    double backgroundActivityDisplayStartDate;
    unsigned int shouldShowEmergencyOnlyStatus : 1;
    unsigned int secondaryCellularConfigured : 1;
    char primaryServiceBadgeString[100];
    char secondaryServiceBadgeString[100];
    char quietModeImage[256];
    unsigned int extra1 : 1;
};

struct StatusBarOverrideData
{
    bool overrideItemIsEnabled[45];
    char padding1;
    unsigned int overrideTimeString : 1;
    unsigned int overrideDateString : 1;
    unsigned int overrideGsmSignalStrengthRaw : 1;
    unsigned int overrideSecondaryGsmSignalStrengthRaw : 1;
    unsigned int overrideGsmSignalStrengthBars : 1;
    unsigned int overrideSecondaryGsmSignalStrengthBars : 1;
    unsigned int overrideServiceString : 1;
    unsigned int overrideSecondaryServiceString : 1;
    unsigned int overrideServiceImages : 2;
    unsigned int overrideOperatorDirectory : 1;
    unsigned int overrideServiceContentType : 1;
    unsigned int overrideSecondaryServiceContentType : 1;
    unsigned int overrideWifiSignalStrengthRaw : 1;
    unsigned int overrideWifiSignalStrengthBars : 1;
    unsigned int overrideDataNetworkType : 1;
    unsigned int overrideSecondaryDataNetworkType : 1;
    unsigned int disallowsCellularDataNetworkTypes : 1;
    unsigned int overrideBatteryCapacity : 1;
    unsigned int overrideBatteryState : 1;
    unsigned int overrideBatteryDetailString : 1;
    unsigned int overrideBluetoothBatteryCapacity : 1;
    unsigned int overrideThermalColor : 1;
    unsigned int overrideSlowActivity : 1;
    unsigned int overrideActivityDisplayId : 1;
    unsigned int overrideBluetoothConnected : 1;
    unsigned int overrideBreadcrumb : 1;
    unsigned int overrideLock;
    unsigned int overrideDisplayRawGSMSignal : 1;
    unsigned int overrideDisplayRawWifiSignal : 1;
    unsigned int overridePersonName : 1;
    unsigned int overrideWifiLinkWarning : 1;
    unsigned int overrideSecondaryCellularConfigured : 1;
    unsigned int overridePrimaryServiceBadgeString : 1;
    unsigned int overrideSecondaryServiceBadgeString : 1;
    unsigned int overrideQuietModeImage : 1;
    unsigned int overrideExtra1 : 1;
    StatusBarRawData values;
};

void applyChanges(StatusBarOverrideData *overrides)
{
    std::string location = StatusManager::getInstance().getFileLocation();

    std::ofstream outfile(location, std::ofstream::binary);
    if (!outfile)
        return;

    char padding[256] = {'\0'};

    outfile.write(reinterpret_cast<char *>(overrides), sizeof(StatusBarOverrideData));
    outfile.write(padding, sizeof(padding));
}

StatusBarOverrideData *getOverrides()
{
    std::string location = StatusManager::getInstance().getFileLocation();

    std::ifstream infile(location, std::ifstream::binary);
    if (!infile)
    {
        StatusBarOverrideData *overrides = new StatusBarOverrideData();
        return overrides;
    }

    StatusBarOverrideData *overrides = new StatusBarOverrideData();
    infile.read(reinterpret_cast<char *>(overrides), sizeof(StatusBarOverrideData));
    return overrides;
}

bool StatusSetter16_3::isCarrierOverridden() {
    StatusBarOverrideData *overrides = getOverrides();
    return overrides->overrideServiceString == 1;
}

std::string StatusSetter16_3::getCarrierOverride() {
    StatusBarOverrideData *overrides = getOverrides();
    std::string carrier = std::string(overrides->values.serviceString);
    return carrier;
}

void StatusSetter16_3::setCarrier(std::string text) {
    StatusBarOverrideData *overrides = getOverrides();
    overrides->overrideServiceString = 1;
    strcpy(overrides->values.serviceString, text.c_str());
    strcpy(overrides->values.serviceCrossfadeString, text.c_str());
    applyChanges(overrides);
}

void StatusSetter16_3::unsetCarrier() {
    StatusBarOverrideData *overrides = getOverrides();
    overrides->overrideServiceString = 0;
    applyChanges(overrides);
}

bool StatusSetter16_3::isBatteryHidden()
{
    StatusBarOverrideData *overrides = getOverrides();
    return overrides->overrideItemIsEnabled[static_cast<int>(StatusBarItem::MainBatteryStatusBarItem)] == 1;
}

void StatusSetter16_3::hideBattery(bool hidden)
{
    StatusBarOverrideData *overrides = getOverrides();
    if (hidden)
    {
        overrides->overrideItemIsEnabled[static_cast<int>(StatusBarItem::MainBatteryStatusBarItem)] = 1;
        overrides->values.itemIsEnabled[static_cast<int>(StatusBarItem::MainBatteryStatusBarItem)] = 0;
    }
    else
    {
        overrides->overrideItemIsEnabled[static_cast<int>(StatusBarItem::MainBatteryStatusBarItem)] = 0;
    }

    applyChanges(overrides);
}