#include <stdio.h>
#include <stdlib.h>

#include <unistd.h>


int main(int argc, char * argv[]){
   int flags, opt;
   int nsecs, tfnd;
   printf("argc is %d\n%s\n", argc, argv[1]);
   system("pwd");
   if(chdir(argv[1]) == -1) {
       fprintf(stderr, "chdir failed\n");
   } else {
       fprintf(stderr, "chdir success\n");
   }
   system("pwd");
   nsecs = 0;
   tfnd = 0;
   flags = 0;
   while ((opt = getopt(argc, argv, "nt:")) != -1) {
       switch (opt) {
        case 'n':
            flags = 1;
            break;
        case 't':
            nsecs = atoi(optarg);
            tfnd = 1;
            break;
        default: /* '?' */
            fprintf(stderr, "Usage: %s [-t nsecs] [-n] name\n",
                    argv[0]);
            return -1;
       }
   }
   printf("flags=%d; tfnd=%d; optind=%d\n", flags, tfnd, optind);
   if (optind >= argc) {
       fprintf(stderr, "Expected argument after options\n");
       return -2;
   }
   printf("name argument = %s\n", argv[optind]);
   return 0;
}
