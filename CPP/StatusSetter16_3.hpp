#pragma once

#include "StatusSetter.hpp"

class StatusSetter16_3 : public StatusSetter {
public:
    bool isBatteryHidden() override;
    void hideBattery(bool hidden) override;
};
