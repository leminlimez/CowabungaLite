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

bool StatusManager::isBatteryHidden()
{
    return getSetter().isBatteryHidden();
}

void StatusManager::hideBattery(bool hidden)
{
    getSetter().hideBattery(hidden);
}