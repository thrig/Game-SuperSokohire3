/* Random.xs - random number generation functions */

#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <stdint.h>

#include "jsf.h"

MODULE = Game::SuperSokohire3::Random		PACKAGE = Game::SuperSokohire3::Random		
PROTOTYPES: DISABLE

# 50/50 of 0 or 1, hopefully
UV
coinflip ()
    CODE:
        RETVAL = ranval() & 1;
    OUTPUT:
        RETVAL

# init_jsf - setup the RNG (see src/jsf.*)
# the seed should be a 32-bit unsigned value, 
#   my $seed = unpack 'L', pack 'L', ...;
#   init_jsf($seed);
void
init_jsf (seed)
    UV seed
    PPCODE:
        raninit(seed);

# random integer in the range 0..max-1
UV
irand (uint32_t max)
    CODE:
        RETVAL = ranval() % max;
    OUTPUT:
        RETVAL

# one in N odds of happening
UV
onein (uint32_t N)
    CODE:
        RETVAL = 0 == ranval() % N;
    OUTPUT:
        RETVAL

# pick a random element of an array ref
SV *
pick (avref)
    AV *avref;
    PREINIT:
        SSize_t len, rnd;
        SV **svp;
    CODE:
        len = av_len(avref) + 1;
        if (len == 0) XSRETURN_UNDEF;
        rnd = ranval() % len;
        svp = av_fetch(avref, rnd, FALSE);
        SvREFCNT_inc(*svp);
        RETVAL = *svp;
    OUTPUT:
        RETVAL

# random y,x point within some bounds
void
rnd_point (uint32_t ymax, uint32_t xmax)
    PREINIT:
        uint32_t y, x;
    PPCODE:
        y = ranval() % ymax;
        x = ranval() % xmax;
        EXTEND(SP, 2);
        mPUSHu(y);
        mPUSHu(x);
        XSRETURN(2);

# roll some dice and add them up
UV
roll (uint32_t count, uint32_t sides)
    PREINIT:
        uint32_t sum;
    CODE:
        sum = count;
        while (count--) sum += ranval() % sides;
        RETVAL = sum;
    OUTPUT:
        RETVAL
