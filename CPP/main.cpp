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
    bool isHidden = statusManager.isBatteryHidden();
    std::cout << "Battery is hidden: " << std::boolalpha << isHidden << std::endl;

    statusManager.hideBattery(true);
    std::cout << "Battery hidden" << std::endl;

    // Return 0 to indicate successful program execution
    return 0;
}
