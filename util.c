#include <math.h>
#include <stdint.h>
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

    // XXX: Need to handle nanosleep error(s).
    (void)nanosleep(&ts, NULL);
}
