//
//  SHA256.m
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/24/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import "SHA256.h"

@implementation SHA256


//  SHA 256 C code taken from wikiPedia article
//  Author Karl Malbrain, malbrain@yahoo.com

//#ifdef unix
typedef unsigned long long uint64;
//#else
//typedef unsigned __int64 uint64;
//#endif

typedef unsigned long ulong;
typedef unsigned char uchar;

//	private structure for SHA
//  move to header file

typedef struct {
	uchar buff[512/8];	// buffer, digest when full
	ulong h[256/32];	// state variable of digest
	uint64 length;		// number of bytes in digest
	int next;			// next buffer available
} SHA256;

//2^32 times the cube root of the first 64 primes 2..311

static ulong k[64] = {
0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2 };

//	store 64 bit integer

void putlonglong (uint64 what, uchar *where)
{
	*where++ = what >> 56;
	*where++ = what >> 48;
	*where++ = what >> 40;
	*where++ = what >> 32;
	*where++ = what >> 24;
	*where++ = what >> 16;
	*where++ = what >> 8;
	*where++ = what;
}

//	store 32 bit integer

void putlong (ulong what, uchar *where)
{
	*where++ = what >> 24;
	*where++ = what >> 16;
	*where++ = what >> 8;
	*where++ = what;
}

//	retrieve 32 bit integer

ulong getlong (uchar *where)
{
	ulong ans;
	
	ans = *where++ << 24;
	ans |= *where++ << 16;
	ans |= *where++ << 8;
	ans |= *where++;
	return ans;
}

//	right rotate bits

ulong rotate (ulong what, int bits)
{
	return (what >> bits) | (what << (32 - bits));
}

//	right shift bits

ulong shift (ulong what, int bits)
{
	return what >> bits;
}

//	start new SHA run

void sha256_begin (SHA256 *sha)
{
	sha->length = 0;
	sha->next = 0;
	
	// 2^32 times the square root of the first 8 primes 2..19
	sha->h[0] = 0x6a09e667;
	sha->h[1] = 0xbb67ae85;
	sha->h[2] = 0x3c6ef372;
	sha->h[3] = 0xa54ff53a;
	sha->h[4] = 0x510e527f;
	sha->h[5] = 0x9b05688c;
	sha->h[6] = 0x1f83d9ab;
	sha->h[7] = 0x5be0cd19;
}

//	digest SHA buffer contents
//	to state variable

void sha256_digest (SHA256 *sha)
{
	ulong nxt, s0, s1, maj, t0, t1, ch;
	ulong a,b,c,d,e,f,g,h;
	ulong w[64];
	int i;
	
	sha->next = 0;
	
	for( i = 0; i < 16; i++ )
		w[i] = getlong (sha->buff + i * sizeof(ulong));
	
	for( i = 16; i < 64; i++ ) {
		s0 = rotate(w[i-15], 7) ^ rotate(w[i-15], 18) ^ shift(w[i-15], 3);
		s1 = rotate(w[i-2], 17) ^ rotate(w[i-2], 19) ^ shift (w[i-2], 10);
		w[i] = w[i-16] + s0 + w[i-7] + s1;
	}
	
	a = sha->h[0];
	b = sha->h[1];
	c = sha->h[2];
	d = sha->h[3];
	e = sha->h[4];
	f = sha->h[5];
	g = sha->h[6];
	h = sha->h[7];
	
	for( i = 0; i < 64; i++ ) {
		s0 = rotate (a, 2) ^ rotate (a, 13) ^ rotate (a, 22);
		maj = (a & b) ^ (b & c) ^ (c & a);
		t0 = s0 + maj;
		s1 = rotate (e, 6) ^ rotate (e, 11) ^ rotate (e, 25);
		ch = (e & f) ^ (~e & g);
		t1 = h + s1 + ch + k[i] + w[i];
		
		h = g;
		g = f;
		f = e;
		e = d + t1;
		d = c;
		c = b;
		b = a;
		a = t0 + t1;
	}
	
	sha->h[0] += a;
	sha->h[1] += b;
	sha->h[2] += c;
	sha->h[3] += d;
	sha->h[4] += e;
	sha->h[5] += f;
	sha->h[6] += g;
	sha->h[7] += h;
}

//	add to current SHA buffer
//	digest when full

void sha256_next (SHA256 *sha, uchar *what, int len)
{
	while( len-- ) {
		sha->length++;
		sha->buff[sha->next] = *what++;
		if( ++sha->next == 512/8 )
			sha256_digest (sha);
	}
}

//	finish SHA run, output 256 bit result

void sha256_finish (SHA256 *sha, uchar *out)
{
	int idx;
	
	// trailing bit pad
	
	sha->buff[sha->next] = 0x80;
	
	if( ++sha->next == 512/8 )
		sha256_digest (sha);
	
	// pad with zeroes until almost full
	// leaving room for length, below
	
	while( sha->next != 448/8 ) {
		sha->buff[sha->next] = 0;
		if( ++sha->next == 512/8 )
			sha256_digest (sha);
	}
	
	// n.b. length doesn't include padding from above
	
	putlonglong (sha->length * 8, sha->buff + 448/8);
	sha->next += sizeof(uint64);	// must be full now
	
	sha256_digest (sha);
	
	// output the result, big endian
	
	for( idx = 0; idx < 256/32; idx++ )
		putlong (sha->h[idx], out + idx * sizeof(ulong));
}

//#ifdef STANDALONE

#include <stdlib.h>
#include <stdio.h>

/*
 * these are the standard FIPS-180-2 test vectors
 * from Chris Devine
 */

static char *msg[] = 
{
"abc",
"abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq",
NULL
};

static char *val[] =
{
"ba7816bf8f01cfea414140de5dae2223" \
"b00361a396177a9cb410ff61f20015ad",
"248d6a61d20638b8e5c026930c3e6039" \
"a33ce45964ff2167f6ecedd419db06c1",
"cdc76e5c9914fb9281a1c7e284d73e67" \
"f1809a48a497200e046d39ccc7112cd0"
};

/*
int main( int argc, char *argv[] )
{
	
	unsigned char sha256sum[32];
	unsigned char buf[1000];
	char output[65];
	SHA256 sha[1];
	int i, j;
	
    printf( "\n SHA-256 Validation Tests:\n\n" );
    memset( buf, 'a', 1000 );
	
    for( i = 0; i < 3; i++ )
    {
        printf( " Test %d ", i + 1 );
        sha256_begin( sha );
		
        if( i < 2 )
            sha256_next( sha, msg[i], strlen( msg[i] ) );
        else
            for( j = 0; j < 1000; j++ )
                sha256_next( sha, buf, 1000 );
		
        sha256_finish( sha, sha256sum );
		
        for( j = 0; j < 32; j++ )
            sprintf( output + j * 2, "%02x", sha256sum[j] );
		
        if( memcmp( output, val[i], 64 ) )
        {
            printf( "failed!\n" );
            return( 1 );
        }
		
        printf( "passed.\n" );
    }
	
    printf( "\n" );
    return( 0 );
}*/

@end
