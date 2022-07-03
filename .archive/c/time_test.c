/*
 *来源于网上博客,不是我写的
*/
#include<stdio.h>
#include<stdlib.h>
#include<time.h>
#include<sys/time.h>
#include<errno.h>
#include<string.h>
#include<unistd.h>
#include<sys/types.h>
#include<sys/select.h>

#define tm_to_mysql_datetime(lt, mysql_time) sprintf(mysql_time,\
    "%4d-%02d-%02d %02d:%02d:%02d", lt->tm_year + 1900, lt->tm_mon + 1,\
    lt->tm_mday, lt->tm_hour, lt->tm_min, lt->tm_sec)

#define make_time(time, year, month, day, hour, minute, second) \
    time.tm_year = year - 1900;\
    time.tm_mon = month - 1;\
    time.tm_mday = day;\
    time.tm_hour = hour;\
    time.tm_min = minute;\
    time.tm_sec = second

void test_file(void)
{
    FILE * f = fopen("test_file.txt", "r+");
    fseek(f, -2, SEEK_END);
    char value;
    fread(&value, 1, 1, f);
    printf("%c", value);
    value = ';';
    fseek(f, -1, SEEK_CUR);
    fwrite(&value, 1, 1, f);
    fclose(f);
}

void test_format_time(void)
{
    char s[20];
    struct tm log_time;
    time_t now;
    time(&now);
    char * hi = "test sizeof string literal";
    char hi2[] = "test sizeof string literal";
    //sizeof hi is 8

    //sizeof hi2 is 27 (strlen() + '\0')
    printf("now is %ld\n", now);
    memcpy(&log_time, localtime(&now), sizeof(log_time));
    struct tm * tm = & log_time;
    tm_to_mysql_datetime(tm, s);
    puts(s);
    //printf("\n%lu\n", strlen(s));// 19
    make_time(log_time, 2013,2,21,0,0,0);
    time_t time_a = mktime(&log_time);
    puts(ctime(&time_a));
    struct tm time2;
    make_time(time2, 2013,2,21,23,59,59);
    time_t time_b = mktime(&time2);
    puts(ctime(&time_b));
    printf("%d",time_b - time_a);
}

//int timer_main(int argc, char **argv)
int main(int argc, char **argv)
{
    unsigned int nTimeTestSec = 0;
    unsigned int nTimeTest = 0;
    struct timeval tvBegin;
    struct timeval tvNow;
    int ret = 0;
    unsigned int nDelay = 0;
    struct timeval tv;
    int fd = 1;
    int i = 0;
    struct timespec req;

    unsigned int delay[20] =
        {500000, 100000, 50000, 10000, 1000, 900, 500, 100, 10, 1, 0};
    int nReduce = 0;

    fprintf(stderr, "%19s%12s%12s%12s\n", "fuction", "time(usec)", "realtime", "reduce");
    fprintf(stderr, "----------------------------------------------------\n");
    for (i = 0; i < 20; i++)
    {
        if (delay[i] <= 0)
            break;
        nDelay = delay[i];
        //test sleep
        gettimeofday(&tvBegin, NULL);
        ret = usleep(nDelay);
        if(ret == -1)
        {
            fprintf(stderr, "usleep error, errno=%d [%s]\n", errno, strerror(errno));
        }
        gettimeofday(&tvNow, NULL);
        nTimeTest = (tvNow.tv_sec - tvBegin.tv_sec) * 1000000 + tvNow.tv_usec - tvBegin.tv_usec;
        nReduce = nTimeTest - nDelay;

         fprintf (stderr, "\t usleep       %8u   %8u   %8d\n", nDelay, nTimeTest,nReduce);

         //test nanosleep
         req.tv_sec = nDelay/1000000;
         req.tv_nsec = (nDelay%1000000) * 1000;

         gettimeofday(&tvBegin, NULL);
         ret = nanosleep(&req, NULL);
         if (-1 == ret)
         {
            fprintf (stderr, "\t nanousleep   %8u   not support\n", nDelay);
         }
         gettimeofday(&tvNow, NULL);
         nTimeTest = (tvNow.tv_sec - tvBegin.tv_sec) * 1000000 + tvNow.tv_usec - tvBegin.tv_usec;
         nReduce = nTimeTest - nDelay;
         fprintf (stderr, "\t nanosleep    %8u   %8u   %8d\n", nDelay, nTimeTest,nReduce);

         //test select
         tv.tv_sec = 0;
         tv.tv_usec = nDelay;

         gettimeofday(&tvBegin, NULL);
         ret = select(0, NULL, NULL, NULL, &tv);
         if (-1 == ret)
         {
            fprintf(stderr, "select error. errno = %d [%s]\n", errno, strerror(errno));
         }

         gettimeofday(&tvNow, NULL);
         nTimeTest = (tvNow.tv_sec - tvBegin.tv_sec) * 1000000 + tvNow.tv_usec - tvBegin.tv_usec;
         nReduce = nTimeTest - nDelay;
         fprintf (stderr, "\t select       %8u   %8u   %8d\n", nDelay, nTimeTest,nReduce);

         //pselcet
         req.tv_sec = nDelay/1000000;
         req.tv_nsec = (nDelay%1000000) * 1000;

         gettimeofday(&tvBegin, NULL);
         ret = pselect(0, NULL, NULL, NULL, &req, NULL);
         if (-1 == ret)
         {
            fprintf(stderr, "select error. errno = %d [%s]\n", errno, strerror(errno));
         }

         gettimeofday(&tvNow, NULL);
         nTimeTest = (tvNow.tv_sec - tvBegin.tv_sec) * 1000000 + tvNow.tv_usec - tvBegin.tv_usec;
         nReduce = nTimeTest - nDelay;
         fprintf (stderr, "\t pselect      %8u   %8u   %8d\n", nDelay, nTimeTest,nReduce);

         fprintf (stderr, "--------------------------------\n");

    }
    return 0;
}
