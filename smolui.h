/*
** Copyright (c) 2023 Mario Nachbaur
** Copyright (c) 2023 ashn <me@ashn.dev>
**
** This library is free software; you can redistribute it and/or modify it
** under the terms of the MIT license. See `microui.c` for details.
*/

#ifndef SMOLUI_H
#define SMOLUI_H

#include <raylib.h>
#include "microui.h"

// Set the text height/width callbacks and the font.
// Providing a NULL font pointer wll use the default raylib font.
void smol_setup_font(mu_Context* ctx, Font const* font);

// Handle all keyboard & mouse events.
void smol_handle_input(mu_Context* ctx);

// Draw controls, text & icons using raylib.
void smol_render(mu_Context* ctx);

#endif // SMOLUI_H
