#include <string>
#include <iostream>
#include "StatusManager.hpp"

int main()
{
    // Create an instance of the StatusManager
    StatusManager& statusManager = StatusManager::getInstance();

    // Set the file location
    std::string fileLocation = "statusBarOverrides";
    statusManager.setFileLocation(fileLocation);

    // Call other functions or perform operations using the StatusManager

    // Example usage:
    // statusManager.setCarrier("Beans");

    bool isHidden = statusManager.isCarrierOverridden();
    std::cout << "Carrier is overridden: " << std::boolalpha << isHidden << std::endl;

    // statusManager.hideBattery(true);
    std::string carrier = statusManager.getCarrierOverride();
    std::cout << "Carrier is: " << carrier << std::endl;

    // Return 0 to indicate successful program execution
    return 0;
}
