#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <sys/wait.h>
#include <signal.h>

static
void on_signal_child(int i) {
    fputs("on signal child", stderr);
}

static
void on_signal_with_arg(int sig, siginfo_t * sig_info, void * unused) {
    fputs("on signal child", stderr);
    fprintf(stderr, "sig is %d, code is %d, pid is %u\n", sig, sig_info->si_code, 
            sig_info->si_pid);
}

int
main(int argc, char * argv[]) {

    struct sigaction signal_child;
    memset(&signal_child, 0, sizeof(signal_child));
#if 1
    signal_child.sa_sigaction = on_signal_with_arg;
    sigemptyset(&signal_child.sa_mask);
    signal_child.sa_flags = SA_SIGINFO;
#else
    signal_child.sa_handler = on_signal_child;
    sigfillset(&signal_child.sa_mask);
#endif
    int r;

    //-1 on error, 0 on success
    r = sigaction(SIGCHLD, &signal_child, NULL);
    if ( r == -1 ) {
        puts("sigaction error");
        return -1;
    }

    printf("parent pid is %u\n", getpid());

    pid_t pid;
    if ( (pid = fork() ) < 0 ) {
        puts("error fork");
        return -1;
    } else if( pid == 0) {
        puts("in sub process, before execl");
        printf("current pid is %u\n", getpid());
        if( execl("/home/david/david/lovely_codes/linux/run_test",
                    "love_jack", (char *)NULL) < 0) {
            puts("error execl");
            return -2;
        }
    }
    printf("in parent process, child pid is %u\n", pid);
    /*
    if(waitpid(pid, NULL, 0) < 0 ) {
        puts("error wait");
        return -3;
    }
    puts("sub process end");
    */
    sleep(8);
    return 0;
}
