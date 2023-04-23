#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdbool.h>
#include <string.h>
#include <ctype.h>
#include <getopt.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <ftw.h>

int unlink_cb(const char *fpath, const struct stat *sb, int typeflag, struct FTW *ftwbuf)
{
    int rv = remove(fpath);

    if (rv)
        perror(fpath);

    return rv;
}

int rmrf(char *path)
{
    return nftw(path, unlink_cb, 64, FTW_DEPTH | FTW_PHYS);
}

int main(int argc, char *argv[])
{
    char *indir = NULL;
    char *outdir = NULL;

    int c = 0;
    const struct option longopts[] = {
        {"indir", required_argument, NULL, 'i'},
        {"outdir", required_argument, NULL, 'o'}
    };

    /* parse cmdline args */
    while ((c = getopt_long(argc, argv, "i:o:", longopts, NULL)) != -1)
    {
        switch (c)
        {
        case 'i':
            if (!*optarg)
            {
                fprintf(stderr, "ERROR: UDID argument must not be empty!\n");
                return 2;
            }
            indir = strdup(optarg);
            break;
        case 'o':
            if (!*optarg)
            {
                fprintf(stderr, "ERROR: UDID argument must not be empty!\n");
                return 2;
            }
            outdir = strdup(optarg);
            break;
        default:
            fprintf(stderr, "Usage: %s -i <indir> -o <outdir>\n", argv[0]);
            return 1;
        }
    }

    if (indir == NULL || outdir == NULL)
    {
        fprintf(stderr, "Usage: %s -i <indir> -o <outdir>\n", argv[0]);
        return 1;
    }

    if (access(indir, F_OK) == -1) {
        fprintf(stderr, "Error: Input directory %s does not exist\n", indir);
        return 1;
    }

    if (access(outdir, F_OK) != -1) {
        if (rmrf(outdir) != 0) {
            fprintf(stderr, "Error: Cannot remove directory %s\n", outdir);
            return 1;
        }
    }

    int status = mkdir(outdir, S_IRWXU | S_IRWXG | S_IROTH | S_IXOTH);

    if (status != 0) {
        fprintf(stderr, "Error: Failed to create directory %s.\n", outdir);
    }

    char* manifestFile = malloc(strlen(outdir) + 14);
    strcpy(manifestFile, outdir);
    strcat(manifestFile, "/Manifest.mbdb");
    FILE* file = fopen(manifestFile, "a+");
    if (file == NULL) {
        fprintf(stderr, "Error: Failed to open file %s.\n", manifestFile);
        return 1;
    }

    char* header = "mbdb\x05\x00";
    fprintf(file, "%s", header);
    


    fclose(file);
    free(manifestFile);
    free(indir);
    free(outdir);
    return 0;

}