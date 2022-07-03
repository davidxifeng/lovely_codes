#include <stdio.h>
#include <ftw.h>
#define _GNU_SOURCE 1
#include <fnmatch.h>
#undef _GNU_SOURCE

static const char *filters[] = {
    "*.c", "*.cpp"
    //"*.c", "*.cpp", "*.gif", "*.png"
};

static int callback(const char *fpath, const struct stat *sb, int typeflag) {
    /* if it's a file */
    if (typeflag == FTW_F) {
        int i;
        /* for each filter, */
        for (i = 0; i < sizeof(filters) / sizeof(filters[0]); i++) {
            /* if the filename matches the filter, */
            if (fnmatch(filters[i], fpath, FNM_CASEFOLD) == 0) {
                /* do something */
                printf("found file: %s\n", fpath);
                break;
            }
        }
    }

    /* tell ftw to continue */
    return 0;
}

int main() {
    ftw(".", callback, 16);
}
