// compile: g++ -o CreateBackup CreateBackup.cpp -lcrypto

#include <iostream>
#include <fstream>
#include <string>
#include <sys/stat.h>
#include <cstdint>
#include <filesystem>
#include <regex>
#include <openssl/sha.h>
#include <random>

std::string removeDomain(const std::string &domain, const std::string &input)
{
    size_t pos = input.find(domain);
    if (pos != std::string::npos)
    {
        pos += domain.length();
        if (input[pos] == '\\' || input[pos] == '/')
        {
            ++pos;
        }
        return input.substr(pos);
    }
    return input;
}

void writeStringWithLength(std::ofstream &output_file, const std::string &str)
{
    uint16_t length = str.size();
    uint16_t bigEndianLength = (length << 8) | (length >> 8);

    output_file.write(reinterpret_cast<const char *>(&bigEndianLength), sizeof(bigEndianLength));
    output_file.write(str.data(), length);
}

void writeHash(std::ofstream &output_file, const std::string &file)
{
    std::ifstream input_file(file, std::ios::binary);
    if (!input_file)
    {
        std::cerr << "Failed to open file: " << file << std::endl;
        return;
    }

    std::string fileContent((std::istreambuf_iterator<char>(input_file)), std::istreambuf_iterator<char>());
    unsigned char hash[SHA_DIGEST_LENGTH];
    SHA1(reinterpret_cast<const unsigned char *>(fileContent.c_str()), fileContent.size(), hash);
    output_file.write(reinterpret_cast<const char *>(hash), sizeof(hash));
}

void generateRandomHex(std::ofstream &output_file)
{
    std::random_device rd;
    std::mt19937 generator(rd());
    std::uniform_int_distribution<int> distribution(0, 255);

    constexpr int bufferSize = 12;
    char buffer[bufferSize];

    for (int i = 0; i < bufferSize; ++i)
    {
        buffer[i] = static_cast<char>(distribution(generator));
    }

    output_file.write(buffer, bufferSize);

    // For testing purposes
    // output_file.write("\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF", 12);
}

std::string calculateSHA1(const std::string &str)
{
    unsigned char hash[SHA_DIGEST_LENGTH];
    SHA1(reinterpret_cast<const unsigned char *>(str.c_str()), str.size(), hash);

    std::stringstream ss;
    for (int i = 0; i < SHA_DIGEST_LENGTH; ++i)
    {
        ss << std::hex << std::setw(2) << std::setfill('0') << static_cast<int>(hash[i]);
    }

    return ss.str();
}

void copyFile(const std::string &source, const std::string &destination)
{
    std::ifstream sourceFile(source, std::ios::binary);
    if (!sourceFile)
    {
        std::cerr << "Failed to open source file: " << source << std::endl;
        return;
    }

    std::ofstream destinationFile(destination, std::ios::binary);
    if (!destinationFile)
    {
        std::cerr << "Failed to create destination file: " << destination << std::endl;
        return;
    }

    destinationFile << sourceFile.rdbuf();
}

void processFiles(const std::string &path, const std::string &domainString, const std::string &outputDir)
{
    std::string fileString = std::regex_replace(removeDomain(domainString, path), std::regex("hiddendot"), ".");
    fileString = std::regex_replace(fileString, std::regex("\\\\"), "/");

    std::ofstream output_file(outputDir + "/Manifest.mbdb", std::ios::app | std::ios::binary);
    writeStringWithLength(output_file, domainString);
    writeStringWithLength(output_file, fileString);

    if (std::filesystem::is_regular_file(path))
    {
        output_file.write("\xFF\xFF\x00\x14", 4);
        writeHash(output_file, path);
        output_file.write("\xFF\xFF\x81\xFF\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\xF5\x00\x00\x01\xF5", 20);
        generateRandomHex(output_file);
        struct stat st;
        if (stat(path.c_str(), &st) == 0)
        {
            uint64_t fileSize = static_cast<uint64_t>(st.st_size);

            // Convert to big endian
            for (int i = 7; i >= 0; --i)
            {
                unsigned char byte = static_cast<unsigned char>((fileSize >> (8 * i)) & 0xFF);
                output_file.put(byte);
            }
        }
        else
        {
            output_file.write("\x00\x00\x00\x00\x00\x00\x00\x00", 8);
        }
        output_file.write("\x04\x00", 2);
        output_file.close();

        // Rename file to its domain-path hash
        std::string hash = calculateSHA1(domainString + "-" + fileString);
        std::string newFile = outputDir + "/" + hash;
        copyFile(path, newFile);
    }
    else if (std::filesystem::is_directory(path))
    {
        output_file.write("\xFF\xFF\xFF\xFF\xFF\xFF\x41\xFF\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x01\xF5\x00\x00\x01\xF5", 24);
        generateRandomHex(output_file);
        output_file.write("\x00\x00\x00\x00\x00\x00\x00\x00\x04\x00", 10);
        output_file.close();

        for (const auto &entry : std::filesystem::directory_iterator(path))
        {
            const auto &filePath = entry.path();
            processFiles(filePath.string(), domainString, outputDir);
        }
    }
}

std::string basename(const std::string &path)
{
    size_t lastSlash = path.find_last_of("/\\");
    std::string filename = path.substr(lastSlash + 1);
    return filename;
}

bool createDirectory(const std::string &dirPath)
{
    try
    {
        if (std::filesystem::create_directory(dirPath))
        {
            return true;
        }
        else
        {
            std::cerr << "Failed to create directory." << std::endl;
            return false;
        }
    }
    catch (const std::filesystem::filesystem_error &ex)
    {
        std::cerr << "Failed to create directory: " << ex.what() << std::endl;
        return false;
    }
}

bool removeDirectoryIfExists(const std::string &dirPath)
{
    if (std::filesystem::exists(dirPath) && std::filesystem::is_directory(dirPath))
    {
        try
        {
            std::filesystem::remove_all(dirPath);
            return true;
        }
        catch (const std::filesystem::filesystem_error &ex)
        {
            std::cerr << "Failed to remove directory: " << ex.what() << std::endl;
            return false;
        }
    }
    return false;
}

int main(int argc, char *argv[])
{
    if (argc != 3)
    {
        std::cout << "Usage: " << argv[0] << " <indir> <outdir>" << std::endl;
        return 1;
    }

    std::string indir = argv[1];
    std::string outdir = argv[2];

    struct stat st;
    if (stat(indir.c_str(), &st) != 0 || !S_ISDIR(st.st_mode))
    {
        std::cout << indir << " is not a directory" << std::endl;
        return 1;
    }

    removeDirectoryIfExists(outdir);
    createDirectory(outdir);

    // NOTE: Manifest.mbdb tracks the locations and SHA1 hashes of each file in the backup
    std::ofstream output_file(outdir + "/Manifest.mbdb", std::ios::binary);
    if (!output_file)
    {
        std::cerr << "Failed to create output file" << std::endl;
        return 1;
    }

    // Manifest.mbdb file header
    std::string header = "mbdb\x05\x00";
    output_file.write(header.c_str(), 6);
    output_file.close();

    // Iterate over all domains
    for (const auto &domainEntry : std::filesystem::directory_iterator(indir))
    {
        if (domainEntry.is_directory())
        {
            std::string domain = domainEntry.path().string();
            std::string domainString = basename(domain);
            if (domainString == "ConfigProfileDomain")
            {
                domainString = "SysSharedContainerDomain-systemgroup.com.apple.configurationprofiles";
            }
            std::cout << domainString << std::endl;

            processFiles(domain, domainString, outdir);
        }
    }

    // Generate Info.plist
    std::ofstream infoPlist(outdir + "/Info.plist", std::ios::binary);
    infoPlist << R"(<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
</dict>
</plist>
)";
    infoPlist.close();

    // Generate Status.plist
    std::ofstream statusPlist(outdir + "/Status.plist", std::ios::binary);
    statusPlist << R"(<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BackupState</key>
	<string>new</string>
	<key>Date</key>
	<date>1970-01-01T00:00:00Z</date>
	<key>IsFullBackup</key>
	<false/>
	<key>SnapshotState</key>
	<string>finished</string>
	<key>UUID</key>
	<string>00000000-0000-0000-0000-000000000000</string>
	<key>Version</key>
	<string>2.4</string>
</dict>
</plist>
)";
    statusPlist.close();

    // Generate Manifest.plist
    std::ofstream manifestPlist(outdir + "/Manifest.plist", std::ios::binary);
    manifestPlist << R"(<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BackupKeyBag</key>
	<data>
	VkVSUwAAAAQAAAAFVFlQRQAAAAQAAAABVVVJRAAAABDud41d1b9NBICR1BH9JfVtSE1D
	SwAAACgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAV1JBUAAA
	AAQAAAAAU0FMVAAAABRY5Ne2bthGQ5rf4O3gikep1e6tZUlURVIAAAAEAAAnEFVVSUQA
	AAAQB7R8awiGR9aba1UuVahGPENMQVMAAAAEAAAAAVdSQVAAAAAEAAAAAktUWVAAAAAE
	AAAAAFdQS1kAAAAoN3kQAJloFg+ukEUY+v5P+dhc/Welw/oucsyS40UBh67ZHef5ZMk9
	UVVVSUQAAAAQgd0cg0hSTgaxR3PVUbcEkUNMQVMAAAAEAAAAAldSQVAAAAAEAAAAAktU
	WVAAAAAEAAAAAFdQS1kAAAAoMiQTXx0SJlyrGJzdKZQ+SfL124w+2Tf/3d1R2i9yNj9z
	ZCHNJhnorVVVSUQAAAAQf7JFQiBOS12JDD7qwKNTSkNMQVMAAAAEAAAAA1dSQVAAAAAE
	AAAAAktUWVAAAAAEAAAAAFdQS1kAAAAoSEelorROJA46ZUdwDHhMKiRguQyqHukotrxh
	jIfqiZ5ESBXX9txi51VVSUQAAAAQfF0G/837QLq01xH9+66vx0NMQVMAAAAEAAAABFdS
	QVAAAAAEAAAAAktUWVAAAAAEAAAAAFdQS1kAAAAol0BvFhd5bu4Hr75XqzNf4g0fMqZA
	ie6OxI+x/pgm6Y95XW17N+ZIDVVVSUQAAAAQimkT2dp1QeadMu1KhJKNTUNMQVMAAAAE
	AAAABVdSQVAAAAAEAAAAA0tUWVAAAAAEAAAAAFdQS1kAAAAo2N2DZarQ6GPoWRgTiy/t
	djKArOqTaH0tPSG9KLbIjGTOcLodhx23xFVVSUQAAAAQQV37JVZHQFiKpoNiGmT6+ENM
	QVMAAAAEAAAABldSQVAAAAAEAAAAA0tUWVAAAAAEAAAAAFdQS1kAAAAofe2QSvDC2cV7
	Etk4fSBbgqDx5ne/z1VHwmJ6NdVrTyWi80Sy869DM1VVSUQAAAAQFzkdH+VgSOmTj3yE
	cfWmMUNMQVMAAAAEAAAAB1dSQVAAAAAEAAAAA0tUWVAAAAAEAAAAAFdQS1kAAAAo7kLY
	PQ/DnHBERGpaz37eyntIX/XzovsS0mpHW3SoHvrb9RBgOB+WblVVSUQAAAAQEBpgKOz9
	Tni8F9kmSXd0sENMQVMAAAAEAAAACFdSQVAAAAAEAAAAA0tUWVAAAAAEAAAAAFdQS1kA
	AAAo5mxVoyNFgPMzphYhm1VG8Fhsin/xX+r6mCd9gByF5SxeolAIT/ICF1VVSUQAAAAQ
	rfKB2uPSQtWh82yx6w4BoUNMQVMAAAAEAAAACVdSQVAAAAAEAAAAA0tUWVAAAAAEAAAA
	AFdQS1kAAAAo5iayZBwcRa1c1MMx7vh6lOYux3oDI/bdxFCW1WHCQR/Ub1MOv+QaYFVV
	SUQAAAAQiLXvK3qvQza/mea5inss/0NMQVMAAAAEAAAACldSQVAAAAAEAAAAA0tUWVAA
	AAAEAAAAAFdQS1kAAAAoD2wHX7KriEe1E31z7SQ7/+AVymcpARMYnQgegtZD0Mq2U55u
	xwNr2FVVSUQAAAAQ/Q9feZxLS++qSe/a4emRRENMQVMAAAAEAAAAC1dSQVAAAAAEAAAA
	A0tUWVAAAAAEAAAAAFdQS1kAAAAocYda2jyYzzSKggRPw/qgh6QPESlkZedgDUKpTr4Z
	Z8FDgd7YoALY1g==
	</data>
	<key>Lockdown</key>
	<dict/>
	<key>SystemDomainsVersion</key>
	<string>20.0</string>
	<key>Version</key>
	<string>9.1</string>
</dict>
</plist>
)";
    manifestPlist.close();

    return 0;
}
