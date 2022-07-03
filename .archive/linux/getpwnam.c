// Sat 23:53 Dec 03
// demo usage of password database operations API of UNIX
// test on macOS

#include <sys/types.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <pwd.h>

int main(int argc, char const* argv[]) {
  int bufsize;

  if ((bufsize = sysconf(_SC_GETPW_R_SIZE_MAX)) == -1)
    abort();

  char buffer[bufsize];
  struct passwd pwd, *result = NULL;
  if (getpwuid_r(getuid(), &pwd, buffer, bufsize, &result) != 0 || !result)
    abort();

  printf("user name: %s\n", pwd.pw_name);
  printf("pwd: %s\n", pwd.pw_passwd);
  printf("uid: %d\n", pwd.pw_uid);
  printf("gid: %d\n", pwd.pw_gid);
  printf("home dir: %s\n", pwd.pw_dir);
  printf("gecos: %s\n", pwd.pw_gecos);
  printf("shell: %s\n", pwd.pw_shell);
  return 0;
}

