using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace skynet_client
{
    public class CryptUtils
    {
        private static ulong P = 0xffffffffffffffc5ul;
        private static ulong G = 5;
        private static ulong mul_mod_p(ulong a, ulong b)
        {
            ulong m = 0;
            while (b != 0)
            {
                if ((b & 1) != 0)
                {
                    ulong t = P - a;
                    if (m >= t) m -= t;
                    else m += a;
                }
                if (a >= P - a) a = a * 2 - P;
                else a = a * 2;
                b >>= 1;
            }
            return m;

        }
        private static ulong pow_mod_p(ulong a, ulong b)
        {
            if (b == 1) return a;
            ulong t = pow_mod_p(a, b >> 1);
            t = mul_mod_p(t, t);
            if ((b % 2) != 0) t = mul_mod_p(t, a);
            return t;
        }

        // a ^ b % p
        private static ulong powmodp(ulong a, ulong b)
        {
            if (a > P) a %= P;
            return pow_mod_p(a, b);
        }

        public static ulong dhexchange(ulong i)
        {
            return powmodp(G, i);
        }

        public static ulong dhsecret(ulong x, ulong y)
        {
            return powmodp(x, y);
        }


        // Constants are the integer part of the sines of integers (in radians) * 2^32.
        private static uint[] k = {
            0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee ,
            0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501 ,
            0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be ,
            0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821 ,
            0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa ,
            0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8 ,
            0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed ,
            0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a ,
            0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c ,
            0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70 ,
            0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05 ,
            0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665 ,
            0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039 ,
            0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1 ,
            0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1 ,
            0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
        };

        // r specifies the per-round shift amounts
        private static int[] r = {
            7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
            5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20,
            4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
            6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21
        };

        // left rotate function definition
        private static uint LEFTROTATE(uint x, int c) {
            return (((x) << (c)) | ((x) >> (32 - (c))));
        }

        private static ulong hmac(ulong x, ulong y)
        {
            uint [] w = new uint[16];
            uint a, b, c, d, f, g, temp;
            uint i;

            uint x0, x1, y0, y1;
            x0 = (uint)x;
            x1 = (uint)(x>> 32);
            y0 = (uint)y;
            y1 = (uint)(y>> 32);

            a = 0x67452301u;
            b = 0xefcdab89u;
            c = 0x98badcfeu;
            d = 0x10325476u;

            for (i = 0; i < 16; i += 4)
            {
                w[i] = x1;
                w[i + 1] = x0;
                w[i + 2] = y1;
                w[i + 3] = y0;
            }

            for (i = 0; i < 64; i++)
            {
                if (i < 16)
                {
                    f = (b & c) | ((~b) & d);
                    g = i;
                }
                else if (i < 32)
                {
                    f = (d & b) | ((~d) & c);
                    g = (5 * i + 1) % 16;
                }
                else if (i < 48)
                {
                    f = b ^ c ^ d;
                    g = (3 * i + 5) % 16;
                }
                else
                {
                    f = c ^ (b | (~d));
                    g = (7 * i) % 16;
                }

                temp = d;
                d = c;
                c = b;
                b = b + LEFTROTATE((a + f + k[i] + w[g]), r[i]);
                a = temp;

            }
            ulong result;
            result = a ^ b;
            result <<= 32;
            result += c ^ d;
            return result;
        }

        public static ulong hmac64(ulong challenge, ulong secret)
        {
            ulong r = hmac(challenge, secret); 
            string s = String.Format("x is {0:X}, y is {1:X}, r is {2:X}", challenge, secret, r);
            Console.WriteLine(s);
            byte[] r_buf = BitConverter.GetBytes(r);
            string bs = Convert.ToBase64String(r_buf);
            return r;
        }
    }

}
