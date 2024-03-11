#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#include "shared.h"

struct message*
message_create(void)
{
    return malloc(sizeof(struct message));
}

void
message_destroy(struct message* self)
{
    free(self);
}

int
message_serialize(struct message* self, NBN_Stream *stream)
{
    NBN_SerializeUInt(stream, self->length, 0, MESSAGE_LENGTH);
    NBN_SerializeBytes(stream, self->data, self->length);
    return 0;
}
