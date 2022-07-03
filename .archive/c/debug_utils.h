#pragma once

#define DAVID_DEBUG 1

#if DAVID_DEBUG
#define dbg(format, ...) debug_output(format, ##__VA_ARGS__)
#else
#define dbg(format, ...)
#endif

void debug_output(const char * format, ...);
