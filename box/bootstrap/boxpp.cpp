#include <stdio.h>
#include <sapi/xclie/php_xclie.h>

int main(int argc, char** argv) {
    struct xclie_exec args = { 0, };
    int retVal = 0;

    args.prepend_script = "core/.box-env.php";
    args.entry_script = "core/boxpp.php";

    args.argc = argc;
    args.argv = argv;

    if ((retVal = xclie_run(&args)) != XCLIX_SUCCESS) {
        switch (retVal) {
        case XCLIX_CANT_STARTUP:
            fprintf(stderr, "Unknown error: PHP startup routines failure.\n");
            break;

        case XCLIX_NO_FILE_SPEC:
            fprintf(stderr, "No file specified. are you sure that \"entry_script\" set?\n");
            break;

        case XCLIX_NO_PERMISSION:
            fprintf(stderr, "No permission to read the entry script: %s.\n", args.entry_script);
            break;

        case XCLIX_NO_SUCH_FILE:
            fprintf(stderr, "No such file existed: %s.\n", args.entry_script);
            break;
        }

        return -1;
    }

    return 0;
}