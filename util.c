#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <time.h>

void
sleep_sec(double sec)
{
    time_t s = (time_t)sec;
    double n = ((double)s - sec) * 1000000000;
    struct timespec ts = {
        .tv_sec = s,
        .tv_nsec = n,
    };

    if (nanosleep(&ts, NULL) < 1) {
        perror("nanosleep");
    }
}
