#include <assert.h>
#include <stdarg.h>
#include <stdbool.h>
#include <stdio.h>

typedef enum NBN_LogType {
    NBN_LOG_INFO,
    NBN_LOG_ERROR,
    NBN_LOG_DEBUG,
    NBN_LOG_TRACE,
    NBN_LOG_WARNING,
} NBN_LogType;

void NBN_Log(NBN_LogType type, const char *fmt, ...);
#define NBN_LogInfo(...) NBN_Log(NBN_LOG_INFO, __VA_ARGS__)
#define NBN_LogError(...) NBN_Log(NBN_LOG_ERROR, __VA_ARGS__)
#define NBN_LogDebug(...) NBN_Log(NBN_LOG_DEBUG, __VA_ARGS__)
#define NBN_LogTrace(...) NBN_Log(NBN_LOG_TRACE, __VA_ARGS__)
#define NBN_LogWarning(...) NBN_Log(NBN_LOG_WARNING, __VA_ARGS__)

#define NBNET_IMPL
#include <nbnet.h>

#if defined(__EMSCRIPTEN__)
#include <net_drivers/webrtc.h>
#elif defined(NBN_WEBRTC_NATIVE)
#include <net_drivers/webrtc_c.h>
#else
#include <net_drivers/udp.h>
#endif

void NBN_Log_SetIsEnabled(NBN_LogType type, bool enabled);
bool NBN_Log_GetIsEnabled(NBN_LogType type);
void NBN_Driver_Init(void);

bool NBN_Log_IsEnabled[] = {
    [NBN_LOG_INFO] = true,
    [NBN_LOG_ERROR] = true,
    [NBN_LOG_DEBUG] = true,
    [NBN_LOG_TRACE] = true,
    [NBN_LOG_WARNING] = true,
};

void NBN_Log_SetIsEnabled(NBN_LogType type, bool enabled)
{
    assert(NBN_LOG_INFO <= type && type <= NBN_LOG_WARNING);

    NBN_Log_IsEnabled[type] = enabled;
}

bool NBN_Log_GetIsEnabled(NBN_LogType type)
{
    assert(NBN_LOG_INFO <= type && type <= NBN_LOG_WARNING);

    return NBN_Log_IsEnabled[type];
}

void NBN_Log(NBN_LogType type, const char *fmt, ...)
{
    assert(NBN_LOG_INFO <= type && type <= NBN_LOG_WARNING);
    assert(fmt != NULL);

    if (!NBN_Log_IsEnabled[type]) {
        return;
    }

    static const char *strings[] = {
        [NBN_LOG_INFO] = "INFO",
        [NBN_LOG_ERROR] = "ERROR",
        [NBN_LOG_DEBUG] = "DEBUG",
        [NBN_LOG_TRACE] = "TRACE",
        [NBN_LOG_WARNING] = "WARNING",
    };

    va_list args;
    va_start(args, fmt);

    fprintf(stderr, "[nbnet %s] ", strings[type]);
    vfprintf(stderr, fmt, args);
    fprintf(stderr, "\n");

    va_end(args);
}

void NBN_Driver_Init(void)
{
#if defined(__EMSCRIPTEN__)
#ifdef NBN_TLS
    bool enable_tls = true;
#else
    bool enable_tls = false;
#endif
    NBN_WebRTC_Config cfg = {
        .enable_tls = enable_tls,
        .cert_path = NULL,
        .key_path = NULL,
    };
    NBN_WebRTC_Register(cfg);

#elif defined(NBN_WEBRTC_NATIVE)
#ifdef NBN_TLS
    bool enable_tls = true;
#else
    bool enable_tls = false;
#endif
    /* publicly avaliable servers */
    const char *ice_servers[] = {
        "stun.l.google.com:19302",
        "stun1.l.google.com:19302",
        "stun2.l.google.com:19302",
        "stun3.l.google.com:19302",
        "stun4.l.google.com:19302",
    };
    NBN_WebRTC_C_Config cfg = {
        .ice_servers = ice_servers,
        .ice_servers_count = sizeof(ice_servers) / sizeof(*ice_servers),
        .enable_tls = enable_tls,
        .cert_path = NULL,
        .key_path = NULL,
        .passphrase = NULL,
        .log_level = RTC_LOG_VERBOSE
    };
    NBN_WebRTC_C_Register(cfg);

#else
    NBN_UDP_Register();
#endif
}
