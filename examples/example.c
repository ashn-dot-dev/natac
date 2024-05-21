#include <raylib.h>
#include <raymath.h>

float const w = 32.0f;
float const h = 32.0f;
Vector2 position = {.x = 0.0, .y = 20.0};
Vector2 velocity = {.x = 4.0, .y = 4.0};

int
main(void)
{
    InitWindow(640, 480, "EXAMPLE");
    SetTargetFPS(60);

    while (!WindowShouldClose()) {
        BeginDrawing();
        ClearBackground(RAYWHITE);

        DrawFPS(2, 2);

        char const* const text = "RAYLIB WINDOW IN C";
        float const font_size = 20.0f;
        float const font_spacing = 2.0f;
        Vector2 text_size = MeasureTextEx(GetFontDefault(), text, font_size, font_spacing);
        Vector2 text_position = {
            .x = GetScreenWidth() / 2.0f - text_size.x / 2.0f,
            .y = GetScreenHeight() / 2.0f - text_size.y,
        };
        DrawTextEx(GetFontDefault(), text, text_position, font_size, font_spacing, LIGHTGRAY);

        position = Vector2Add(position, velocity);
        if (position.x <= 0.0 || (position.x + w) >= GetScreenWidth()) {
            velocity.x *= -1.0;
        }
        if (position.y <= 0.0 || (position.y + h) >= GetScreenHeight()) {
            velocity.y *= -1.0;
        }
        DrawRectangleV(position, (Vector2){.x = w, .y = h}, DARKGRAY);

        EndDrawing();
    }

    CloseWindow();
    return 0;
}
