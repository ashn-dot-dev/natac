#include <ctype.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include <time.h>
#include <unistd.h>

#include "shared.h"

int
main(void)
{
    NBN_Driver_Init();
    if (NBN_GameServer_StartEx(NAME, PORT, false) < 0) {
        fprintf(stderr, "error: failed to start the server\n");
        exit(EXIT_FAILURE);
    }

    NBN_GameServer_RegisterMessage(
        MESSAGE_TYPE,
        (NBN_MessageBuilder)message_create,
        (NBN_MessageDestructor)message_destroy,
        (NBN_MessageSerializer)message_serialize);

    double dt = 1.0 / TICK_RATE;
    NBN_ConnectionHandle client = 0;
    while (true) {
        int ev = -1;
        while ((ev = NBN_GameServer_Poll()) != NBN_NO_EVENT) {
            if (ev < 0) {
                fprintf(stderr, "error: failed to poll event\n");
                break;
            }

            if (ev == NBN_NEW_CONNECTION) {
                fprintf(stderr, "info: new connection\n");
                if (client != 0) {
                    NBN_GameServer_RejectIncomingConnectionWithCode(BUSY_CODE);
                }
                else {
                    client = NBN_GameServer_GetIncomingConnection();
                    NBN_GameServer_AcceptIncomingConnection();
                }
            }

            if (ev == NBN_CLIENT_DISCONNECTED) {
                fprintf(stderr, "info: disconnected\n");
                assert(NBN_GameServer_GetDisconnectedClient() == client);
                client = 0;
            }

            if (ev == NBN_CLIENT_MESSAGE_RECEIVED) {
                fprintf(stderr, "info: message received\n");

                NBN_MessageInfo info = NBN_GameServer_GetMessageInfo();
                assert(info.sender == client);
                assert(info.type == MESSAGE_TYPE);
                struct message* incoming = (struct message*)info.data;
                fprintf(stderr, "incoming message: %.*s (%u bytes)\n", (int)incoming->length, incoming->data, incoming->length);

                struct message* outgoing = message_create();
                outgoing->length = incoming->length;
                for (unsigned i = 0; i < outgoing->length; ++i) {
                    outgoing->data[i] = toupper(incoming->data[i]);
                }
                fprintf(stderr, "outgoing message: %.*s (%u bytes)\n", (int)outgoing->length, outgoing->data, outgoing->length);

                NBN_GameServer_SendReliableMessageTo(client, MESSAGE_TYPE, outgoing);
                message_destroy(incoming);
            }
        }

        if (NBN_GameServer_SendPackets() < 0) {
            fprintf(stderr, "error: failed to send packets\n");
            break;
        }

        usleep(dt * 1000000);
    }

    NBN_GameServer_Stop();
    return 0;
}
