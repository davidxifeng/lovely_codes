#include <ncurses.h>
#include <locale.h>

// created at 2016-5-27
// compile: gcc -o demo demo.c -lncurses


/*
 * draw a box with inner size (w, h)
 * */
static void draw_frame(int x, int y, int w, int h) {
  mvaddstr(y, x, "+");
  mvaddstr(y + h, x, "+");
  mvaddstr(y, x + w, "+");
  mvaddstr(y + h, x + w, "+");

  for (int i = 1; i < w; i++) {
    mvaddstr(y, x + i, "-");
  }
  for (int i = 1; i < w; i++) {
    mvaddstr(y + h, x + i, "-");
  }
  for (int i = 1; i < h; i++) {
    mvaddstr(y + i, x, "|");
  }
  for (int i = 1; i < h; i++) {
    mvaddstr(y + i, x + w, "|");
  }

}

int main(int argc, char const* argv[])
{
  setlocale(LC_ALL, "");

  initscr();

  // set mode
  cbreak(); // one character; nocbreak: new line
  noecho(); // turn off echo
  curs_set(0); // 0不可视 1 2 可视

  draw_frame(25, 5, 30, 15);

  mvaddstr(0, 0, "hello world 你好世界");
  mvaddstr(2, 10, "1234567890");
  mvaddstr(3, 20, "abcdef");

  mvaddstr(4, 10, "12345六七八九十");
  mvaddstr(5, 15, "unix bsd");
  mvaddstr(5, 0, "中文");
  mvaddstr(6, 5, "你好世界");

  getch();

  // end
  endwin();
  return 0;
}
