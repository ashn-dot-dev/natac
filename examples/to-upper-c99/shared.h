#ifndef SHARED_H
#define SHARED_H

typedef enum NBN_LogType {
    NBN_LOG_INFO,
    NBN_LOG_ERROR,
    NBN_LOG_DEBUG,
    NBN_LOG_TRACE,
    NBN_LOG_WARNING,
} NBN_LogType;

void NBN_Log(NBN_LogType type, const char *fmt, ...);
#define NBN_LogInfo(...) NBN_Log(__VA_ARGS__)
#define NBN_LogError(...) NBN_Log(__VA_ARGS__)
#define NBN_LogDebug(...) NBN_Log(__VA_ARGS__)
#define NBN_LogTrace(...) NBN_Log(__VA_ARGS__)
#define NBN_LogWarning(...) NBN_Log(__VA_ARGS__)

#include <nbnet.h>

void NBN_Driver_Init(void);

#define NAME "to-upper"
#define ADDR "127.0.0.1"
#define PORT 31415
#define TICK_RATE 2 // ticks per second
#define BUSY_CODE 42

#define MESSAGE_TYPE 0
#define MESSAGE_LENGTH 255
struct message {
    unsigned int length;
    char data[MESSAGE_LENGTH];
};

struct message* message_create(void);
void message_destroy(struct message* self);
int message_serialize(struct message* self, NBN_Stream* stream);

#endif /* SHARED_H */
