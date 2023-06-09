#include <string>

class FileLocationSingleton {
public:
    static FileLocationSingleton& getInstance() {
        static FileLocationSingleton instance;
        return instance;
    }

    void setFileLocation(const std::string& location) {
        fileLocation = location;
    }

    std::string getFileLocation() const {
        return fileLocation;
    }

private:
    FileLocationSingleton() {}
    FileLocationSingleton(const FileLocationSingleton&) = delete;
    FileLocationSingleton& operator=(const FileLocationSingleton&) = delete;

    std::string fileLocation;
};
