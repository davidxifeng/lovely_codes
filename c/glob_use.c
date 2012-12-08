#include <stdio.h>
#include <glob.h>

int main(int argc, char * argv[])
{
		glob_t data;
		data.gl_offs = 1;
		glob("/home/david/david/lovely_codes/c/*.c", GLOB_TILDE, NULL, &data);
		int i = 0;
		for(; i< data.gl_pathc; i++)
		{
				puts(data.gl_pathv[i]);
		}
		globfree(&data);
		return 0;
}
