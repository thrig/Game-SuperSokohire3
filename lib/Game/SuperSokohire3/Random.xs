/* Random.xs - random number generation functions (and more)
 *
 * $Id: Random.xs,v 1.8 2022/06/05 05:14:54 jmates Exp $
 */

#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <stdint.h>

#include "jsf.h"

MODULE = Game::SuperSokohire3::Random		PACKAGE = Game::SuperSokohire3::Random		
PROTOTYPES: DISABLE

void
bypair (callback, ...)
    SV *callback;
    PREINIT:
        int i;
        SV *y, *x;
    PPCODE:
        if (!(items & 1)) croak("uneven number of arguments");
        dSP;
        for (i = 1; i < items; i += 2) {
            y = ST(i);
            x = ST(i + 1);
            ENTER;
            SAVETMPS;
            PUSHMARK(SP);
            EXTEND(SP, 2);
            PUSHs(y);
            PUSHs(x);
            PUTBACK;
            call_sv(callback, G_DISCARD);
            SPAGAIN;
            FREETMPS;
            LEAVE;
        }

# 50/50 of 0 or 1, hopefully
UV
coinflip ()
    CODE:
        RETVAL = ranval() & 1;
    OUTPUT:
        RETVAL

# splice a random element out of an array reference (destructive pick)
SV *
extract (avref)
    AV *avref;
    PREINIT:
        SSize_t i, len, rnd;
        SV *dunno, **swap;
    CODE:
        len = av_len(avref) + 1;
        if (len == 0) XSRETURN_UNDEF;
        rnd = ranval() % len;
        dunno = av_delete(avref, rnd, 0);
        if (rnd != len - 1) {
            swap = av_fetch(avref, len - 1, FALSE);
            av_store(avref, rnd, *swap);
            AvFILLp(avref) -= 1;
            AvMAX(avref) -= 1;
        }
        SvREFCNT_inc(dunno);
        RETVAL = dunno;
    OUTPUT:
        RETVAL

# init_jsf - setup the RNG (see src/jsf.*)
void
init_jsf (uint32_t seed)
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

# pick a random element of an array ref (harmless extract)
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

void
random_point (uint32_t ymax, uint32_t xmax)
    PREINIT:
        uint32_t y, x;
    PPCODE:
        y = ranval() % ymax;
        x = ranval() % xmax;
        EXTEND(SP, 2);
        mPUSHu(y);
        mPUSHu(x);
        XSRETURN(2);

# assuming 0..3 as directions
UV
random_turn (uint32_t dir)
    CODE:
        RETVAL = (dir + ((ranval() & 1) ? 1 : -1)) & 3;
    OUTPUT:
        RETVAL

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
