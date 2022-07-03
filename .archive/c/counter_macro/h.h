#ifndef __MY_COUNTER__

    #define __MY_COUNTER__ 0

    #define mk(a, b, c) a ## b ## c
    #define make_three_digit(a, b, c) mk(a, b, c)
    #define mk2(b, c) b ## c
    #define make_two_digit(b, c) mk2(b, c)

#else

#undef CS3

#if (__MY_COUNTER__ + 1) / 100 == 0
    #define CS3 0
#elif (__MY_COUNTER__ + 1) / 100 == 1
    #define CS3 1
#elif (__MY_COUNTER__ + 1) / 100 == 2
    #define CS3 2
#elif (__MY_COUNTER__ + 1) / 100 == 3
    #define CS3 3
#elif (__MY_COUNTER__ + 1) / 100 == 4
    #define CS3 4
#elif (__MY_COUNTER__ + 1) / 100 == 5
    #define CS3 5
#elif (__MY_COUNTER__ + 1) / 100 == 6
    #define CS3 6
#elif (__MY_COUNTER__ + 1) / 100 == 7
    #define CS3 7
#elif (__MY_COUNTER__ + 1) / 100 == 8
    #define CS3 8
#elif (__MY_COUNTER__ + 1) / 100 == 9
    #define CS3 9
#endif

#undef CS2
#if ((__MY_COUNTER__ + 1) % 100) / 10 == 0
    #define CS2 0
#elif ((__MY_COUNTER__ + 1) % 100) / 10  == 1
    #define CS2 1
#elif ((__MY_COUNTER__ + 1) % 100) / 10 == 2
    #define CS2 2
#elif ((__MY_COUNTER__ + 1) % 100) / 10 == 3
    #define CS2 3
#elif ((__MY_COUNTER__ + 1) % 100) / 10 == 4
    #define CS2 4
#elif ((__MY_COUNTER__ + 1) % 100) / 10 == 5
    #define CS2 5
#elif ((__MY_COUNTER__ + 1) % 100) / 10 == 6
    #define CS2 6
#elif ((__MY_COUNTER__ + 1) % 100) / 10 == 7
    #define CS2 7
#elif ((__MY_COUNTER__ + 1) % 100) / 10 == 8
    #define CS2 8
#elif ((__MY_COUNTER__ + 1) % 100) / 10 == 9
    #define CS2 9
#endif


#undef CS1
#if (__MY_COUNTER__ + 1) % 10 == 0
    #define CS1 0
#elif (__MY_COUNTER__ + 1) % 10 == 1
    #define CS1 1
#elif (__MY_COUNTER__ + 1) % 10 == 2
    #define CS1 2
#elif (__MY_COUNTER__ + 1) % 10 == 3
    #define CS1 3
#elif (__MY_COUNTER__ + 1) % 10 == 4
    #define CS1 4
#elif (__MY_COUNTER__ + 1) % 10 == 5
    #define CS1 5
#elif (__MY_COUNTER__ + 1) % 10 == 6
    #define CS1 6
#elif (__MY_COUNTER__ + 1) % 10 == 7
    #define CS1 7
#elif (__MY_COUNTER__ + 1) % 10 == 8
    #define CS1 8
#elif (__MY_COUNTER__ + 1) % 10 == 9
    #define CS1 9
#endif

#undef D3
#if CS3 == 0
#define D3  0
#elif CS3 == 1
#define D3  1
#elif CS3 == 2
#define D3  2
#elif CS3 == 3
#define D3  3
#elif CS3 == 4
#define D3  4
#elif CS3 == 5
#define D3  5
#elif CS3 == 6
#define D3  6
#elif CS3 == 7
#define D3  7
#elif CS3 == 8
#define D3  8
#elif CS3 == 9
#define D3  9
#endif

#undef D2
#if CS2 == 0
#define D2  0
#elif CS2 == 1
#define D2  1
#elif CS2 == 2
#define D2  2
#elif CS2 == 3
#define D2  3
#elif CS2 == 4
#define D2  4
#elif CS2 == 5
#define D2  5
#elif CS2 == 6
#define D2  6
#elif CS2 == 7
#define D2  7
#elif CS2 == 8
#define D2  8
#elif CS2 == 9
#define D2  9
#endif


#undef D1
#if CS1 == 0
#define D1  0
#elif CS1 == 1
#define D1  1
#elif CS1 == 2
#define D1  2
#elif CS1 == 3
#define D1  3
#elif CS1 == 4
#define D1  4
#elif CS1 == 5
#define D1  5
#elif CS1 == 6
#define D1  6
#elif CS1 == 7
#define D1  7
#elif CS1 == 8
#define D1  8
#elif CS1 == 9
#define D1  9
#endif

#undef __MY_COUNTER__
#if CS3
    #define __MY_COUNTER__ make_three_digit(D3, D2, D1)
#elif CS2
    #define __MY_COUNTER__ make_two_digit(D2, D1)
#else
    #define __MY_COUNTER__ D1
#endif

#endif
