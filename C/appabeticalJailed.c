// Rory Madden 2023

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#include <getopt.h>
#include <plist/plist.h>
#include <libimobiledevice/libimobiledevice.h>
#include <libimobiledevice/sbservices.h>
#include "uthash.h"

typedef struct
{
    char *key;
    char *value;
    UT_hash_handle hh;
} Entry;

Entry *hash_table = NULL;

void add_entry(const char *key, const char *value)
{
    Entry *entry;
    HASH_FIND_STR(hash_table, key, entry);
    if (entry == NULL)
    {
        entry = malloc(sizeof(Entry));
        entry->key = strdup(key);
        HASH_ADD_KEYPTR(hh, hash_table, entry->key, strlen(entry->key), entry);
    }
    entry->value = strdup(value);
}

char *get_value(const char *key)
{
    Entry *entry;
    HASH_FIND_STR(hash_table, key, entry);
    return entry != NULL ? entry->value : NULL;
}

typedef struct
{
    plist_t *array;
    size_t used;
    size_t size;
} Items;

void initItems(Items *a, size_t initialSize)
{
    a->array = malloc(initialSize * sizeof(plist_t));
    a->used = 0;
    a->size = initialSize;
}

void resizeItems(Items *a, size_t newSize)
{
    a->array = realloc(a->array, (a->size + newSize) * sizeof(plist_t));
    a->size = a->size + newSize;
}

void insertItem(Items *a, plist_t element)
{
    a->array[a->used++] = element;
}

void freeItems(Items *a)
{
    free(a->array);
    a->array = NULL;
    a->used = a->size = 0;
}

void toLower(char *str)
{
    for (size_t i = 0; i < strlen(str); ++i)
    {
        str[i] = tolower(str[i]);
    }
}

int compare_displayNames(const void *a, const void *b)
{
    plist_t node_a = *(plist_t *)a;
    plist_t node_b = *(plist_t *)b;

    char *str_a = NULL;
    char *str_b = NULL;

    bool widget_a = false;
    bool widget_b = false;
    int widget_size_a = 0;
    int widget_size_b = 0;

    plist_t displayName_a = plist_dict_get_item(node_a, "displayName");
    if (!displayName_a)
    {
        plist_t iconType = plist_dict_get_item(node_a, "iconType");
        if (iconType)
        {
            char *type = NULL;
            plist_get_string_val(iconType, &type);
            if (strcmp("custom", type) == 0)
            {
                widget_a = true;
                plist_t iconSize = plist_dict_get_item(node_a, "gridSize");
                char *size = NULL;
                plist_get_string_val(iconSize, &size);
                if (strcmp("small", size) == 0)
                {
                    widget_size_a = 4;
                }
                else if (strcmp("medium", size) == 0)
                {
                    widget_size_a = 8;
                }
                else if (strcmp("large", size) == 0)
                {
                    widget_size_a = 16;
                }
            }
            else if (strcmp("app", type) == 0)
            {
                plist_t bundleIdentifier = plist_dict_get_item(node_a, "bundleIdentifier");
                char *bundle = NULL;
                plist_get_string_val(bundleIdentifier, &bundle);
                str_a = strdup(get_value(bundle));
            }
        }
    }
    else
    {
        plist_get_string_val(displayName_a, &str_a);
    }
    plist_t displayName_b = plist_dict_get_item(node_b, "displayName");
    if (!displayName_b)
    {
        plist_t iconType = plist_dict_get_item(node_b, "iconType");
        if (iconType)
        {
            char *type = NULL;
            plist_get_string_val(iconType, &type);
            if (strcmp("custom", type) == 0)
            {
                widget_b = true;
                plist_t iconSize = plist_dict_get_item(node_b, "gridSize");
                char *size = NULL;
                plist_get_string_val(iconSize, &size);
                if (strcmp("small", size) == 0)
                {
                    widget_size_b = 4;
                }
                else if (strcmp("medium", size) == 0)
                {
                    widget_size_b = 8;
                }
                else if (strcmp("large", size) == 0)
                {
                    widget_size_b = 16;
                }
            }
            else if (strcmp("app", type) == 0)
            {
                plist_t bundleIdentifier = plist_dict_get_item(node_b, "bundleIdentifier");
                char *bundle = NULL;
                plist_get_string_val(bundleIdentifier, &bundle);
                str_b = strdup(get_value(bundle));
            }
        }
    }
    else
    {
        plist_get_string_val(displayName_b, &str_b);
    }

    if (widget_a || widget_b)
    {
        if (widget_a && widget_b)
        {
            return widget_size_a > widget_size_b ? -1 : 1;
        }
        else if (widget_a)
        {
            return -1;
        }
        else if (widget_b)
        {
            return 1;
        }
    }
    toLower(str_a);
    toLower(str_b);
    return strcmp(str_a, str_b);
}

void sort_apps(plist_t icon_state, int start, int finish, bool together)
{
    Items items = {NULL, 0, 0};
    for (int i = start; i <= finish; i++)
    {
        plist_t array = plist_array_get_item(icon_state, i);
        if (!array || plist_get_node_type(array) != PLIST_ARRAY)
        {
            printf("Error: Invalid or missing array in plist\n");
        }

        int num_items = plist_array_get_size(array);
        if (together)
        {
            if (!items.array)
            {
                initItems(&items, num_items);
            }
            else
            {
                resizeItems(&items, num_items);
            }
        }
        else
        {
            initItems(&items, num_items);
        }

        for (int j = 0; j < num_items; j++)
        {
            plist_t plistCopy = plist_copy(plist_array_get_item(array, j));
            insertItem(&items, plistCopy);
        }

        if (!together)
        {
            qsort(items.array, num_items, sizeof(plist_t), compare_displayNames);
            for (int j = 0; j < num_items; j++)
            {
                plist_array_set_item(array, items.array[j], j);
            }
            freeItems(&items);
        }
    }

    if (together)
    {
        qsort(items.array, items.used, sizeof(plist_t), compare_displayNames);
        int currentPage = start;
        plist_t currentThing = plist_new_array();
        for (int i = 0; i < items.used; i++)
        {
            plist_array_append_item(currentThing, items.array[i]);
            if (i + 1 < items.used && (i + 1) % 24 == 0)
            {
                plist_array_set_item(icon_state, currentThing, currentPage);
                currentThing = plist_new_array();
                currentPage++;
            }
        }
        plist_array_set_item(icon_state, currentThing, currentPage);
        // for (int i = currentPage + 1; i <= finish; i++) {
        //     plist_array_set_item(icon_state, plist_new_array(), i);
        // }
        freeItems(&items);
    }
}

void plist_write(plist_t plist, const char *filename)
{
    char *buffer;
    uint32_t length;

    plist_to_xml(plist, &buffer, &length);

    FILE *fp;
    fp = fopen(filename, "w");
    fwrite(buffer, sizeof(char), length, fp);
    fclose(fp);
}

plist_t plist_read(const char *filename)
{
    plist_t plist = NULL;

    // Read the plist file
    FILE *fp = fopen(filename, "r");
    if (fp)
    {
        fseek(fp, 0, SEEK_END);
        int size = ftell(fp);
        rewind(fp);
        char *buffer = malloc(size);
        fread(buffer, size, 1, fp);
        fclose(fp);

        // Parse the plist data
        plist_from_memory(buffer, size, &plist);
        free(buffer);

        if (plist && plist_get_node_type(plist) == PLIST_ARRAY) {
            return plist;
        }
    }

    return NULL;
}

void scoutAllApps(plist_t icon_state)
{
    int size = plist_array_get_size(icon_state);
    for (int i = 0; i < size; i++)
    {
        plist_t array = plist_array_get_item(icon_state, i);
        int num_items = plist_array_get_size(array);
        for (int j = 0; j < num_items; j++)
        {
            plist_t dict = plist_array_get_item(array, j);
            plist_t displayName = plist_dict_get_item(dict, "displayName");
            if (displayName)
            {
                plist_t bundleIdentifier = plist_dict_get_item(dict, "displayIdentifier");
                if (bundleIdentifier)
                {
                    char *name = NULL;
                    plist_get_string_val(displayName, &name);
                    char *bundle = NULL;
                    plist_get_string_val(bundleIdentifier, &bundle);
                    add_entry(bundle, name);
                    printf("%s %s\n", name, bundle);
                }
            }
        }
    }
}

int main(int argc, char *argv[])
{
    idevice_error_t idevice_ret = IDEVICE_E_UNKNOWN_ERROR;
    idevice_t device;
    plist_t icon_state;
    sbservices_client_t sbservice_t;
    char *udid = NULL;
    int start = -1;
    int finish = -1;
    bool together = false;
    bool backup = false;
    bool restore = false;
    char *location = NULL;

    int c = 0;
    const struct option longopts[] = {
        {"udid", required_argument, NULL, 'u'}};

    /* parse cmdline args */
    while ((c = getopt_long(argc, argv, "u:s:f:tbrl:", longopts, NULL)) != -1)
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
        case 's':
            if (!*optarg)
            {
                fprintf(stderr, "ERROR: Start argument must not be empty!\n");
                return 2;
            }
            if (sscanf(optarg, "%d", &start) != 1 || start < 1)
            {
                fprintf(stderr, "ERROR: Start argument must be a page number!\n");
                return 2;
            }
            break;
        case 'f':
            if (!*optarg)
            {
                fprintf(stderr, "ERROR: Finish argument must not be empty!\n");
                return 2;
            }
            if (sscanf(optarg, "%d", &finish) != 1 || finish < 1)
            {
                fprintf(stderr, "ERROR: Finish argument must be a page number!\n");
                return 2;
            }
            break;
        case 't':
            together = true;
            break;
        case 'b':
            backup = true;
            break;
        case 'r':
            restore = true;
            break;
        case 'l':
            if (!*optarg)
            {
                fprintf(stderr, "ERROR: Location argument must not be empty!\n");
                return 2;
            }
            location = strdup(optarg);
            break;
        default:
            fprintf(stderr, "ERROR: Required argument(s) missing!\n");
            fprintf(stderr, "Usage: %s -u <udid> -s <start> -f <finish> [-t]\n", argv[0]);
            return 1;
        }
    }

    if (udid == NULL)
    {
        fprintf(stderr, "Usage: %s -u <udid> -s <start> -f <finish> [-t]\n", argv[0]);
        return 1;
    }
    else if (start == -1 || finish == -1)
    {
        if (!backup && !restore)
        {
            fprintf(stderr, "Usage: %s -u <udid> -s <start> -f <finish> [-t]\n", argv[0]);
            return 1;
        } else if (backup && restore) {
            fprintf(stderr, "Usage: %s -u <udid> -[b/r] -l location\n", argv[0]);
            return 1;
        } else if ((backup || restore) && location == NULL) {
            fprintf(stderr, "Usage: %s -u <udid> -[b/r] -l location\n", argv[0]);
            return 1;
        }
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

    if (restore)
    {
        plist_t new_state = plist_read(location);
        sbservices_error_t sb_icon_write_err_code = sbservices_set_icon_state(sbservice_t, new_state);
    }
    else
    {
        // Get icon state
        sbservices_error_t sb_icon_err_code = sbservices_get_icon_state(sbservice_t, &icon_state, "2");
        if (sb_icon_err_code == SBSERVICES_E_SUCCESS)
        {
            if (backup)
            {
                plist_write(icon_state, location);
            }
            else
            {
                scoutAllApps(icon_state);
                sort_apps(icon_state, start, finish, together);

                // Set icon state
                sbservices_error_t sb_icon_write_err_code = sbservices_set_icon_state(sbservice_t, icon_state);
            }
        }
    }
}
