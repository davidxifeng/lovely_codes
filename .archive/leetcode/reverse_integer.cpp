// 11/23/2014 15:55
// 11/23/2014 16:27

class Solution {
public:
int atoi(char *p) {
    char c;
    int r = 0;
    while ((c = *p++)) {
        int t;
        t = r * 10;
        if ( t < r || t % 10 != 0) {
            r = 0;
            break;
        }
        int s;
        s = t + c - '0';
        if ( s < t) {
            r = 0;
            break;
        }
        r = s;
    }
    return r;
}

int itoa(int i, char *p) {
    int c = 0;
    while (i >= 10) {
        *p++ = '0' + i % 10;
        i = i / 10;
        c++;
    }
    if (i > 0) {
        *p++ = '0' + i % 10;
    }
    return c;
}

int reverse(int x) {
    char cs [16];

    int is_ne = 0;

    if ( x < 0) {
        is_ne = 1;
        x = -x;
    } else if (x < 10) {
        return x;
    }

    for(int i = 0; i < 16; ++i) {
        cs[i] = '\0';
    }

    itoa(x, cs);
    int r = atoi(cs);
    return is_ne ? -r : r;
}

};
