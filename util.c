#include <math.h>
#include <stdint.h>
#include <stdio.h>
#include <time.h>

#define NSEC_PER_SEC 1000000000

void
sleep_sec(double sec)
{
    time_t s = (time_t)sec;
    intmax_t n = (s - (intmax_t)sec) * NSEC_PER_SEC;
    struct timespec ts = {
        .tv_sec = s,
        .tv_nsec = n,
    };

    if (nanosleep(&ts, NULL) < 1) {
        perror("nanosleep");
    }
}
