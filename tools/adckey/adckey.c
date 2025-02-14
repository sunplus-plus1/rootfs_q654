#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/input.h>
#include <time.h>
#include <string.h>
#include <stdbool.h>
#include <syslog.h>
#include <stdarg.h>

#define KEY_FACTORYRESET  0x2ff
#define KEY_VOLUMEDOWN	114
#define KEY_VOLUMEUP    115

#define FILE_PATH "/proc/bus/input/devices"
#define TARGET_NAME "adc-keys"
#define BUFFER_SIZE 1024
#define EVENT_PATH "/dev/input/"  // Base path for event devices

void keylog (const char *format, ...) {
    va_list args;

    // Open the log file in append mode
    FILE *logfile = fopen("/tmp/adckey.log", "a");
    if (logfile == NULL) {
        perror("Failed to open log file");
        return;
    }

    // Start processing variadic arguments
    va_start(args, format);

    // Write formatted output to the file
    vfprintf(logfile, format, args);

    // Cleanup
    va_end(args);
    fclose(logfile);
}

void run_app(const char *app) {
    keylog ("Running app: %s\n", app);
    system(app);
}

bool find_adckeys(char *devicePath, size_t size) {
    FILE *file = fopen(FILE_PATH, "r");
    if (!file) {
        keylog ("Failed to open %s\n", FILE_PATH);
        return false;
    }

    char line[BUFFER_SIZE];
    bool found = false;
    char eventDevice[BUFFER_SIZE] = "";

    while (fgets(line, sizeof(line), file)) {
        keylog ("%s", line);
        // Check for the device name
        if (strstr(line, "Name=\"" TARGET_NAME "\"")) {
            found = true;
            keylog ("found %s\n", TARGET_NAME);
        }

        // If inside the adc-keys block, check for Handlers
        if (found && strstr(line, "Handlers=")) {
            char *eventPos = strstr(line, "event");
            if (eventPos) {
                sscanf(eventPos, "%s", eventDevice);
                snprintf(devicePath, size, "%s%s", EVENT_PATH, eventDevice);  // Construct full path
                keylog ("Input evice: %s\n", devicePath);
            }
            break;
        }
    }

    fclose(file);
    return (devicePath[0] != '\0');  // Return true if device found
}

int main(int argc, char *argv[]) {
    if (argc != 3) {
        keylog ( "Usage: %s <pass_sec> <app_to_run>\n", argv[0]);
        return 1;
    }

    int pass_sec = atoi(argv[1]);
    const char *app_to_run = argv[2];
    int fd;
    struct input_event ev;
    time_t key_press_time = 0;

    char devicePath[BUFFER_SIZE] = "";

    if (find_adckeys(devicePath, sizeof(devicePath))) {
        fd = open(devicePath, O_RDONLY);
        if (fd < 0) {
            keylog ( "Failed to open %s\n", devicePath);
            return 0;
        }
        keylog ("device = %s\n", devicePath);
        keylog ("Monitoring key events...\n");

        while (read(fd, &ev, sizeof(struct input_event)) > 0) {
            if (ev.type == EV_KEY) {
                if (ev.value == 1) { // Key press
                    key_press_time = time(NULL);
                    keylog ("Key %d pressed\n", ev.code);
                }
                else if (ev.value == 0 && ev.code==KEY_FACTORYRESET) { // Key release
                    time_t duration = time(NULL) - key_press_time;
                    keylog ("Key %d released after %ld seconds\n", ev.code, duration);
                    if (duration >= pass_sec) {
                        run_app(app_to_run);
                    }
                }
            }
        }
        close(fd);
    } else {
        keylog ("%s\n", "adc-keys event device not found!");
    }
    return 0;
}