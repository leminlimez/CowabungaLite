//
//  locsimUtils.c
//  Cowabunga Lite
//
//  Created by lemin on 9/16/23.
//

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <getopt.h>
#include <libimobiledevice/libimobiledevice.h>
#include <libimobiledevice/lockdown.h>
#include <libimobiledevice/service.h>
#include <libkern/OSByteOrder.h>

#define DT_SIMULATELOCATION_SERVICE "com.apple.dt.simulatelocation"

int main(int argc, char *argv[])
{
    char *udid = NULL;
    bool getMountStatus = false;
    bool resetLocation = false;
    char *lat = NULL;
    char *lon = NULL;
    
    uint32_t mode = 0; // 0 for set, 1 for reset

    idevice_t device = NULL;
    
    int c = 0;
    const struct option longopts[] = {
        {"udid", required_argument, NULL, 'u'},
        {"getMountStatus", no_argument, NULL, 'm'},
        {"reset", required_argument, NULL, 'r'},
        {"lat", required_argument, NULL, 'l'},
        {"lon", required_argument, NULL, 's'}
    };
    
    /* parse cmdline args */
    // args: u = uuid, m = getMountStatus, L = lat, s = lon
    while ((c = getopt_long(argc, argv, "u:m:r:l:s:", longopts, NULL)) != -1)
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
                getMountStatus = true;
                break;
                
            case 'r':
                mode = 1;
                resetLocation = true;
                break;
                
            case 'l':
                if (!*optarg)
                {
                    fprintf(stderr, "ERROR: Latitude argument must not be empty!\n");
                    return 2;
                }
                lat = strdup(optarg);
                break;
                
            case 's':
                if (!*optarg)
                {
                    fprintf(stderr, "ERROR: Longitude argument must not be empty!\n");
                    return 2;
                }
                lon = strdup(optarg);
                break;
                
            default:
                break;
        }
    }
    
    if (udid == NULL)
    {
        fprintf(stderr, "Usage: %s -u <udid>\n", argv[0]);
        return 3;
    }
    
    printf("%s", lat);
    printf("%s", lon);
    
    if (!getMountStatus && !resetLocation && (lat == NULL || lon == NULL)) {
        fprintf(stderr, "Usage: %s -u <udid> -l <latitude> -s <longitude>\n", argv[0]);
        return 3;
    }
    
    // Get device
    if (idevice_new_with_options(&device, udid, IDEVICE_LOOKUP_USBMUX) != IDEVICE_E_SUCCESS) {
        if (udid) {
            printf("ERROR: Device %s not found!\n", udid);
        } else {
            printf("ERROR: No device found!\n");
        }
        return -1;
    }
    
    lockdownd_client_t lockdown;
    lockdownd_client_new_with_handshake(device, &lockdown, "LocSim");
    
    lockdownd_service_descriptor_t svc = NULL;
    lockdownd_error_t lerr = lockdownd_start_service(lockdown, DT_SIMULATELOCATION_SERVICE, &svc);
    
    if (lerr != LOCKDOWN_E_SUCCESS) {
        lockdownd_client_free(lockdown);
        idevice_free(device);
        printf("ERROR: Could not start the simulatelocation service: %s\nMake sure a developer disk image is mounted!\n", lockdownd_strerror(lerr));
        if (getMountStatus) {
            return 0;
        } else {
            return 4;
        }
    } else if (getMountStatus) {
        lockdownd_client_free(lockdown);
        idevice_free(device);
        return 1;
    }
    lockdownd_client_free(lockdown);
    
    service_client_t service = NULL;

    service_error_t serr = service_client_new(device, svc, &service);

    lockdownd_service_descriptor_free(svc);

    if (serr != SERVICE_E_SUCCESS) {
        lockdownd_client_free(lockdown);
        idevice_free(device);
        printf("ERROR: Could not connect to simulatelocation service (%d)\n", serr);
        return 5;
    }
    
    uint32_t l;
    uint32_t s = 0;
    if (resetLocation) {
        l = OSSwapHostToBigInt32(mode);
        service_send(service, (const char*)&l, 4, &s);
        idevice_free(device);
        return 0;
    } else {
        l = OSSwapHostToBigInt32(mode);
        printf("%d", l);
        service_send(service, (const char*)&l, 4, &s);
        int len = 4 + strlen(lat) + 4 + strlen(lon);
        char *buf = static_cast<char*>(malloc(len));
        uint32_t latlen;
        latlen = strlen(lat);
        l = OSSwapHostToBigInt32(latlen);
        printf("%d", l);
        printf("%d\n", latlen);
        memcpy(buf, &l, 4);
        memcpy(buf+4, lat, latlen);
        uint32_t longlen = strlen(lon);
        l = OSSwapHostToBigInt32(longlen);
        memcpy(buf+4+latlen, &l, 4);
        memcpy(buf+4+latlen+4, lon, longlen);
        
        s = 0;
        service_send(service, buf, len, &s);
        
        free(buf);
        
        idevice_free(device);
        return 0;
    }
}
