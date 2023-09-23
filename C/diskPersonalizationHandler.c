//
//  diskPersonalizationHandler.c
//  
//
//  Created by lemin on 9/22/23.
//
// personal compile code so I don't forget: gcc diskPersonalizationHandler.c -o diskPersonalizationHandler -limobiledevice-1.0.6 -L/opt/homebrew/lib -I/opt/homebrew/include -lcrypto -lssl

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <getopt.h>
#include <plist/plist.h>
#include <libimobiledevice/libimobiledevice.h>
#include <libimobiledevice/lockdown.h>
#include <libimobiledevice/property_list_service.h>
#include <openssl/sha.h>

#define MOBILE_IMAGE_MOUNTER_SERVICE "com.apple.mobile.mobile_image_mounter"

// MARK: Upload Personalized Image
void uploadPersonalizedImage(property_list_service_client_t plist_client, char *path, char *hash) {
    // image.dmg path
    char *imagePath;
    strcpy(imagePath, path);
    strcat(imagePath, "/Image.dmg");
    
    // get the image file size
    FILE* f = fopen(imagePath, "r");
    if (f == NULL) {
        printf("File Not Found!\n");
        return;
    }
    
    fseek(f, 0L, SEEK_END);
    long int fs = ftell(f);
    rewind(f);
    
    // allocate buffer
    char *buffer = calloc(1, ls + 1);
    if (!buffer) {
        fclose(f);
        return;
    }
    
    // copy into buffer
    if (fread(buffer, ls, 1, f) != 1) {
        fclose(f);
        free(buffer);
        return;
    }
    
    // create the plist
    plist_t plist = plist_new_dict();
    // set the plist properties
    // let the service know that we are about to upload an image
    plist_dict_set_item(plist, "Command", plist_new_string("ReceiveBytes"));
    plist_dict_set_item(plist, "ImageType", plist_new_string("Personalized"));
    plist_dict_set_item(plist, "ImageSize", plist_new_uint(fs));
    plist_dict_set_item(plist, "ImageSignature", plist_new_data(hash, strlen(hash)));
    
    // send the plist and recieve a response back
    property_list_service_error_t send_err_code = property_list_service_send_xml_plist(plist_client, plist);
    plist_t plistOut;
    property_list_service_error_t recieve_err_code = property_list_service_receive_plist(plist_client, &plistOut);
    
    plist_t status = plist_dict_get_item(plistOut, "Status");
    if (status) {
        char *statusResult = NULL;
        plist_get_string_val(status, &statusResult);
        if (statusResult == "ReceiveBytesAck") {
            // send the image and recieve a response back
            service_error_t service_err_code = service_send();
        }
    }
    
    fclose(f);
    free(buffer);
}

// MARK: Query Personalization Manifest
void queryPersonalizationManifest(property_list_service_client_t plist_client, const char *hash, char *outKey) {
    // create the plist
    plist_t plist = plist_new_dict();
    // set the plist properties
    plist_dict_set_item(plist, "Command", plist_new_string("QueryPersonalizationManifest"));
    plist_dict_set_item(plist, "PersonalizedImageType", plist_new_string("DeveloperDiskImage"));
    plist_dict_set_item(plist, "ImageType", plist_new_string("DeveloperDiskImage"));
    plist_dict_set_item(plist, "ImageSignature", plist_new_data(hash, strlen(hash)));
    
    // send the plist and recieve a response back
    property_list_service_error_t send_err_code = property_list_service_send_xml_plist(plist_client, plist);
    plist_t plistOut;
    property_list_service_error_t recieve_err_code = property_list_service_receive_plist(plist_client, &plistOut);
    
    // get image signature
    plist_t imageSignature = plist_dict_get_item(plistOut, "ImageSignature");
    if (imageSignature) {
        plist_get_string_val(imageSignature, &outKey);
    }
}

// MARK: Obtain/Request Manifest
int obtainManifest(char *udid, property_list_service_client_t plist_client, char *path, char *manifest) {
    // image.dmg path
    char *imagePath;
    strcpy(imagePath, path);
    strcat(imagePath, "/Image.dmg");
    
    // build manifest path
    char *buildManifestPath;
    strcpy(buildManifestPath, path);
    strcat(buildManifestPath, "/BuildManifest.plist");
    
    FILE *imageStream = fopen(imagePath, "rb");
    if (imageStream != NULL) {
        SHA512_CTX sha384;
        SHA384_Init(&sha384);
        
        unsigned char buffer[4096];
        size_t bytesRead;
        while ((bytesRead = fread(buffer, 1, sizeof(buffer), imageStream)) > 0) {
            SHA384_Update(&sha384, buffer, bytesRead);
        }
        
        unsigned char hash[SHA384_DIGEST_LENGTH];
        SHA384_Final(hash, &sha384);
        
        fclose(imageStream);
        
        queryPersonalizationManifest(plist_client, &hash, manifest);
    } else {
        FILE *manifestStream = fopen(buildManifestPath, "rb");
        if (manifestStream != NULL) {
//            manifest = GetManifestFromTSS(propListServiceHandle, PlistHelper.ReadPlistDictFromStream(manifestStream));
            
            fclose(manifestStream);
        } else {
            printf("ERROR: failed to obtain manifest for device.");
            return -1;
        }
    }
    return 0;
}

// MARK: Enable Dev Mode With Personalized Image
int enableDevModeWithImage(char *udid, char *path) {
    // handler variables
    idevice_error_t idevice_ret = IDEVICE_E_UNKNOWN_ERROR;
    idevice_t device;
    lockdownd_client_t lockdown;
    property_list_service_client_t plist_client;
    
    // get device
    idevice_ret = idevice_new(&device, udid);
    if (idevice_ret != IDEVICE_E_SUCCESS)
    {
        printf("ERROR: No device found\n");
        return -1;
    }
    
    // get lockdownd client
    lockdownd_error_t lockdownd_err_code = lockdownd_client_new_with_handshake(device, &lockdown, "LocSimMounter");
    if (lockdownd_err_code != LOCKDOWN_E_SUCCESS) {
        printf("ERROR: Unable to create lockdownd client: %d\n", lockdownd_err_code);
        return -1;
    }
    
    // start the image mounter service
    lockdownd_service_descriptor_t svc = NULL;
    lockdownd_error_t mount_err_code = lockdownd_start_service(lockdown, MOBILE_IMAGE_MOUNTER_SERVICE, &svc);
    if (mount_err_code != LOCKDOWN_E_SUCCESS) {
        printf("ERROR: Unable to start the image mounter service: %s\n", lockdownd_strerror(mount_err_code));
        return -1;
    }
    
    // get plist service client
    property_list_service_error_t plist_err_code = property_list_service_client_new(device, svc, &plist_client);
    if (plist_err_code != PROPERTY_LIST_SERVICE_E_SUCCESS) {
        printf("ERROR: Unable to create plist client: %d\n", plist_err_code);
        return -1;
    }
    
    // obtain manifest
    char *manifest = NULL;
    int manifest_err_code = obtainManifest(udid, plist_client, path, manifest);
    if (manifest_err_code != 0) {
        return -1;
    }
    
    if (manifest == NULL) {
        printf("ERROR: Unable to get manifest\n");
        return -1;
    }
    
    // upload the image to the device
    
    return 0;
}

// MARK: Main Function
int main(int argc, char *argv[]) {
    // input variables
    char *udid = NULL;
    char *path = NULL;
    int mode = 0;
    
    int c = 0;
    const struct option longopts[] = {
        {"udid", required_argument, NULL, 'u'},
        {"mode", required_argument, NULL, 'm'},
        {"path", required_argument, NULL, 'p'}
    };
    
    /* parse cmdline args */
    // args: u = uuid
    while ((c = getopt_long(argc, argv, "u:m:p:", longopts, NULL)) != -1)
    {
        switch (c) {
            case 'u':
                if (!*optarg)
                {
                    fprintf(stderr, "ERROR: UDID argument must not be empty!\n");
                    return 2;
                }
                udid = strdup(optarg);
                break;
                
            case 'm':
                if (!*optarg)
                {
                    fprintf(stderr, "ERROR: Mode argument must not be empty!\n");
                    return 2;
                }
                mode = atoi(strdup(optarg));
                break;
                
            case 'p':
                if (!*optarg)
                {
                    fprintf(stderr, "ERROR: Path argument must not be empty!\n");
                    return 2;
                }
                path = strdup(optarg);
                break;
                
            default:
                fprintf(stderr, "ERROR: Required arguments missing!\n");
                fprintf(stderr, "Usage: %s -u <udid> -m <mode>\n", argv[0]);
                break;
        }
    }
    
    if (udid == NULL)
    {
        fprintf(stderr, "Usage: %s -u <udid> -m <mode>\n", argv[0]);
        return 1;
    }
    
    if (mode == 1)
    {
        if (path == NULL)
        {
            fprintf(stderr, "ERROR: Required path argument missing!\n");
            fprintf(stderr, "Usage: %s -u <udid> -m <mode> -p <path>\n", argv[0]);
            return 1;
        }
        // enable dev mode
        return enableDevModeWithImage(udid, path);
    }
    else
    {
        // no valid mode was chosen
        fprintf(stderr, "ERROR: No valid mode selected!\n");
        return 1;
    }
}
