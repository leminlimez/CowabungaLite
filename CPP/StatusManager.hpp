#include <string>
#include "StatusSetter.hpp"
#include "StatusSetter16_3.hpp"

class StatusManager
{
public:
    static StatusManager &getInstance();

    void setFileLocation(const std::string &location);
    std::string getFileLocation() const;

    bool isBatteryHidden();
    void hideBattery(bool hidden);

private:
    StatusManager();
    StatusSetter &getSetter();

    StatusSetter *setter = nullptr;
    std::string fileLocation;
};