#include <stdio.h>
#include <unistd.h>
#include <sys/wait.h>

int
main(int argc, char * argv[]) {

    pid_t pid;
    if ( (pid = fork() ) < 0 ) {
        puts("error fork");
        return -1;
    } else if( pid == 0) {
        puts("in sub process, before execl");
        if( execl("/home/david/david/lovely_codes/linux/run_test",
                    "run_test", (char *)NULL) < 0) {
            puts("error execl");
            return -2;
        }
    }
    puts("in parent process");
    if(waitpid(pid, NULL, 0) < 0 ) {
        puts("error wait");
        return -3;
    }
    puts("sub process end");
    return 0;
}
