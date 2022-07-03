#include <stdio.h>

#include <glob.h>

//for strerror
#include <string.h>
#include <errno.h>
#include <sys/select.h>
#include <sys/time.h>

typedef
void (*do_timer_proc)(float);
//minimalism linux select single thread timer
void test_select(do_timer_proc func){
    int r;
    struct timeval main_loop_timer;
    struct timeval last_timeval;
    struct timeval current_timeval;

begin_main_loop:
    gettimeofday(&last_timeval, NULL);
    //这两个值可能会被修改,所以select调用过后每次重新设置
    main_loop_timer.tv_sec = 1;
    main_loop_timer.tv_usec = 500;
    r = select(0, NULL, NULL, NULL, &main_loop_timer);
    // -1 error, otherwise success
    if (r == -1){
        fprintf(stderr, "main select return error! errno  %d, %s\n", errno,
                strerror(errno));
    } else {
        gettimeofday(&current_timeval, NULL);
        float arg_time;//单位秒钟
        long sec_span = current_timeval.tv_sec - last_timeval.tv_sec;
        long msec_span = current_timeval.tv_usec - last_timeval.tv_usec;
        arg_time = sec_span + (msec_span * 0.001f);
        func(arg_time);
    }
    goto begin_main_loop;
}


void do_print(float time);
int test_glob(void);

int main(int argc, char * argv[]) {
    test_glob();
    return 0;
}

int test_glob(void) {
    glob_t data;
    data.gl_offs = 1;
    glob("/home/david/david/lovely_codes/c/*.c", GLOB_TILDE, NULL, &data);
    int i = 0;
    for(; i< data.gl_pathc; i++) {
        puts(data.gl_pathv[i]);
    }
    globfree(&data);
    return 0;
}


void do_print(float time) {
    puts("just do a print");
    printf("use second %f\n", time);
}


