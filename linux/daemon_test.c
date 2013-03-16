/*
 * main.c
 *
 *  Created on: Mar 5, 2013
 *      Author: david
 */
#include <stdio.h>
#include <string.h> //for strerror
#include <errno.h> //for errno
#include <sys/select.h>
#include <sys/time.h>
#include <signal.h>
#include <time.h>


#define true 1
#define false 0
#define bool int


typedef void (*simple_timer_proc)(float);

static bool g_quit_on_int_signal = false;

static void on_signal_action(int i) {
    fputs("\nquiting\n", stderr);
    g_quit_on_int_signal = true;
}
/* minimalism linux select single thread timer
 * 中断定时器循环的方法: 使用ctrl+c信号
 * use Ctrl+C/ SIGINT to stop program
 * */
void simple_select_timer(unsigned int interval, simple_timer_proc func) {

    puts("begin main loop");

    struct sigaction sa;
    memset(&sa, 0, sizeof(sa));
    sa.sa_handler = on_signal_action;
    sigfillset(&sa.sa_mask);
    sigaction(SIGINT, &sa, NULL);

    struct timeval main_loop_timer;
    struct timeval last_timeval;
    struct timeval current_timeval;

    unsigned int sec, mis;
    sec = interval / 1000;
    mis = interval % 1000;

    while (true) {
        if (gettimeofday(&last_timeval, NULL) != 0 )
        {
            fprintf(stderr, "gettimeofday error! errno  %d, %s\n", errno,
                    strerror(errno));
        }
        //文档上说这两个值可能会被修改,所以select调用过后每次重新设置
        //reset this value after call select()
        main_loop_timer.tv_sec = sec;
        main_loop_timer.tv_usec = mis;
        int r = select(0, NULL, NULL, NULL, &main_loop_timer);
        // -1 error, otherwise success
        if (g_quit_on_int_signal) {
            break;
        }
        if (r == -1) {
            fprintf(stderr, "main select return error! errno  %d, %s\n", errno,
                strerror(errno));
        }
        else
        {
            if (gettimeofday(&current_timeval, NULL) != 0)
            {
                fprintf(stderr, "gettimeofday error! errno  %d, %s\n", errno,
                    strerror(errno));
            }
            float arg_time; //单位秒钟 unit: second
            long sec_span = current_timeval.tv_sec - last_timeval.tv_sec;
            long msec_span = current_timeval.tv_usec - last_timeval.tv_usec;
            arg_time = sec_span + (msec_span * 0.000001f);//1000 000
            func(arg_time);
        }
    }
    puts("end main loop");
}

void just_test(float span) {
    puts("programming running...");
    printf("%f\n", span);
    FILE * f = fopen("/tmp/test_daemon.txt", "a");
    time_t now = time(NULL);
    fprintf(f, "%s\n", ctime(&now));
    fclose(f);
    //if (test > 10.0) {
     //   int * pi = NULL;
      //  printf("%d\n", 2 + *pi);
    //}
}

int main(int argc, char * argv[]) {
    simple_select_timer(1000, just_test);
    puts("exit 0");
    return 0;
}
