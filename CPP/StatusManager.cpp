#include "StatusManager.hpp"

StatusManager::StatusManager()
{
}

StatusManager &StatusManager::getInstance()
{
    static StatusManager instance;
    return instance;
}

void StatusManager::setFileLocation(const std::string &location)
{
    fileLocation = location;
}

std::string StatusManager::getFileLocation() const
{
    return fileLocation;
}

StatusSetter &StatusManager::getSetter()
{
    if (!setter)
    {
        setter = new StatusSetter16_3();
    }
    return *setter;
}

bool StatusManager::isCarrierOverridden()
{
    return getSetter().isCarrierOverridden();
}

std::string StatusManager::getCarrierOverride()
{
    return getSetter().getCarrierOverride();
}

void StatusManager::setCarrier(std::string text) {
    return getSetter().setCarrier(text);
}

void StatusManager::unsetCarrier() {
    getSetter().unsetCarrier();
}

bool StatusManager::isBatteryHidden()
{
    return getSetter().isBatteryHidden();
}

void StatusManager::hideBattery(bool hidden)
{
    getSetter().hideBattery(hidden);
}