#include <raylib.h>

int x = 0;
int y = 20;
int const w = 32;
int const h = 32;
int dx = 4;
int dy = 4;

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
        int const font_size = 20;
        int text_width = MeasureText(text, font_size);
        int text_height = GetFontDefault().baseSize;
        int text_x = GetScreenWidth() / 2 - text_width / 2;
        int text_y = GetScreenHeight() / 2 - text_height;
        DrawText(text, text_x, text_y, font_size, LIGHTGRAY);

        x += dx;
        y += dy;
        if (x <= 0 || (x + w) >= GetScreenWidth()) {
            dx *= -1;
        }
        if (y <= 0 || (y + h) >= GetScreenHeight()) {
            dy *= -1;
        }
        DrawRectangle(x, y, w, h, DARKGRAY);

        EndDrawing();
    }

    CloseWindow();
    return 0;
}
