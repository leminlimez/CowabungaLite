#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <getopt.h>
#include <plist/plist.h>
#include <libimobiledevice/libimobiledevice.h>
#include <libimobiledevice/sbservices.h>
#include "uthash.h"

// const char *UUID = "00008030-001219041E7A402E";

void scoutArray(plist_t array)
{
    int num_items = plist_array_get_size(array);
    for (int j = 0; j < num_items; j++)
    {
        plist_t dict = plist_array_get_item(array, j);
        plist_t displayName = plist_dict_get_item(dict, "displayName");
        if (displayName)
        {
            plist_t bundleIdentifier = plist_dict_get_item(dict, "bundleIdentifier");
            if (bundleIdentifier)
            {
                char *name = NULL;
                plist_get_string_val(displayName, &name);
                char *bundle = NULL;
                plist_get_string_val(bundleIdentifier, &bundle);
                printf("%s,%s\n", bundle, name);
            }
            else
            {
                plist_t listType = plist_dict_get_item(dict, "listType");
                if (listType)
                {
                    char *type = NULL;
                    plist_get_string_val(listType, &type);
                    if (strcmp("folder", type) == 0)
                    {
                        plist_t iconLists = plist_dict_get_item(dict, "iconLists");
                        if (iconLists)
                        {
                            int size = plist_array_get_size(iconLists);
                            for (int i = 0; i < size; i++)
                            {
                                plist_t iconListsArray = plist_array_get_item(iconLists, i);
                                scoutArray(iconListsArray);
                            }
                        }
                    }
                }
            }
        }
    }
}

void scoutAllApps(plist_t icon_state)
{
    int size = plist_array_get_size(icon_state);
    for (int i = 0; i < size; i++)
    {
        plist_t array = plist_array_get_item(icon_state, i);
        scoutArray(array);
    }
}

void plist_write(plist_t plist, const char *filename) {
  char *buffer;
  uint32_t length;

  plist_to_xml(plist, &buffer, &length);

  FILE *fp;
  fp = fopen(filename, "w");
  fwrite(buffer, sizeof(char), length, fp);
  fclose(fp);
}

int main(int argc, char *argv[])
{
    idevice_error_t idevice_ret = IDEVICE_E_UNKNOWN_ERROR;
    idevice_t device;
    plist_t icon_state;
    sbservices_client_t sbservice_t;
    char *udid = NULL;

    int c = 0;
    const struct option longopts[] = {
        {"udid", required_argument, NULL, 'u'}};

    /* parse cmdline args */
    while ((c = getopt_long(argc, argv, "u:", longopts, NULL)) != -1)
    {
        switch (c)
        {
        case 'u':
            if (!*optarg)
            {
                fprintf(stderr, "ERROR: UDID argument must not be empty!\n");
                return 2;
            }
            udid = strdup(optarg);
            break;
        default:
            fprintf(stderr, "ERROR: Required argument(s) missing!\n");
            fprintf(stderr, "Usage: %s -u <udid>\n", argv[0]);
            return 1;
        }
    }

    if (udid == NULL)
    {
        fprintf(stderr, "Usage: %s -u <udid>\n", argv[0]);
        return 1;
    }

    // Get device
    idevice_ret = idevice_new(&device, udid);
    if (idevice_ret != IDEVICE_E_SUCCESS)
    {
        printf("No device found\n");
        return -1;
    }

    // Get client
    sbservices_error_t sb_client_err_code = sbservices_client_start_service(device, &sbservice_t, "iPhone");
    if (sb_client_err_code != SBSERVICES_E_SUCCESS)
    {
        printf("Unable to create SpringBoard client: %d\n", sb_client_err_code);
        return -1;
    }

    // Get icon state
    sbservices_error_t sb_icon_err_code = sbservices_get_icon_state(sbservice_t, &icon_state, "2");
    if (sb_icon_err_code == SBSERVICES_E_SUCCESS)
    {
        // scoutAllApps(icon_state);
        plist_write(icon_state, "sb_before.plist");


        // Set icon state
        // sbservices_error_t sb_icon_write_err_code = sbservices_set_icon_state(sbservice_t, icon_state);
    }
}