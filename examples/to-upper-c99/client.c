#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include "shared.h"

int
main(int argc, char** argv)
{
    if (argc != 2) {
        fprintf(stderr, "Usage: client TEXT\n");
        exit(EXIT_FAILURE);
    }

    const char *text = argv[1];
    if (strlen(text) > MESSAGE_LENGTH) {
        fprintf(stderr, "error: text length cannot exceed %d bytes\n", MESSAGE_LENGTH);
        exit(EXIT_FAILURE);
    }

    NBN_Driver_Init();
    if (NBN_GameClient_StartEx(NAME, ADDR, PORT, false, NULL, 0) < 0) {
        fprintf(stderr, "error: failed to start client\n");
        exit(EXIT_FAILURE);
    }

    NBN_GameClient_RegisterMessage(
        MESSAGE_TYPE,
        (NBN_MessageBuilder)message_create,
        (NBN_MessageDestructor)message_destroy,
        (NBN_MessageSerializer)message_serialize);

    double dt = 1.0 / TICK_RATE;
    bool connected = false;
    bool running = true;
    while (running) {
        int ev = -1;
        while ((ev = NBN_GameClient_Poll()) != NBN_NO_EVENT) {
            if (ev < 0) {
                fprintf(stderr, "error: failed to poll event\n");
                running = false;
                break;
            }

            if (ev == NBN_CONNECTED) {
                fprintf(stderr, "info: connected\n");
                connected = true;
            }

            if (ev == NBN_DISCONNECTED) {
                fprintf(stderr, "info: disconnected\n");
                connected = false;
                running = false;
                if (NBN_GameClient_GetServerCloseCode() == BUSY_CODE) {
                    fprintf(stderr, "error: another client is already connected\n");
                }
                break;
            }

            if (ev == NBN_MESSAGE_RECEIVED) {
                fprintf(stderr, "info: message received\n");
                NBN_MessageInfo info = NBN_GameClient_GetMessageInfo();
                assert(info.type == MESSAGE_TYPE);
                struct message *received = (struct message *)info.data;
                fprintf(stderr, "incoming message: %.*s (%u bytes)\n", (int)received->length, received->data, received->length);
                message_destroy(received);
            }
        }

        if (connected) {
            struct message* outgoing = message_create();
            unsigned int length = strlen(text);
            outgoing->length = length;
            memcpy(outgoing->data, text, length);
            fprintf(stderr, "outgoing message: %.*s (%u bytes)\n", (int)outgoing->length, outgoing->data, outgoing->length);

            if (NBN_GameClient_SendReliableMessage(MESSAGE_TYPE, outgoing) < 0) {
                fprintf(stderr, "error: failed to send message\n");
                running = false;
                break;
            }
        }

        if (NBN_GameClient_SendPackets() < 0) {
            fprintf(stderr, "error: failed to send packets\n");
            running = false;
            break;
        }

        usleep(dt * 1000000);
    }

    NBN_GameClient_Stop();
    return 0;
}
