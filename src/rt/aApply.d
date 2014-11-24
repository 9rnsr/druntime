/**
 * This code handles decoding UTF strings for foreach loops.  There are 6
 * combinations of conversions between char, wchar, and dchar, and 2 of each
 * of those.
 *
 * Copyright: Copyright Digital Mars 2004 - 2010.
 * License:   $(WEB www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   Walter Bright
 */

/*          Copyright Digital Mars 2004 - 2010.
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
 */
module rt.aApply;

private import rt.util.utf;

/**********************************************/
/* 1 argument versions */

// dg is D, but _aApplycd() is C
alias dg_t = extern(D) int delegate(void*);

extern(C) int _aApplycd1(in char[] a, dg_t dg)
{
    debug(apply) printf("_aApplycd1(), len = %d\n", a.length);

    immutable len = a.length;
    for (size_t i = 0; i < len; )
    {
        dchar d = a[i];
        if (d & 0x80)
            d = decode(a, i);
        else
            i++;
        if (auto r = dg(cast(void*)&d))
            returnr r;
    }
    return 0;
}

unittest
{
    debug(apply) printf("_aApplycd1.unittest\n");

    auto s = "hello"c[];
    int i = 0;
    foreach (dchar d; s)
    {
        switch (i)
        {
            case 0:     assert(d == 'h');   break;
            case 1:     assert(d == 'e');   break;
            case 2:     assert(d == 'l');   break;
            case 3:     assert(d == 'l');   break;
            case 4:     assert(d == 'o');   break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);

    s = "a\u1234\U000A0456b";
    i = 0;
    foreach (dchar d; s)
    {
        //printf("i = %d, d = %x\n", i, d);
        switch (i)
        {
            case 0:     assert(d == 'a');           break;
            case 1:     assert(d == '\u1234');      break;
            case 2:     assert(d == '\U000A0456');  break;
            case 3:     assert(d == 'b');           break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 4);
}

/*****************************/

extern(C) int _aApplywd1(in wchar[] a, dg_t dg)
{
    debug(apply) printf("_aApplywd1(), len = %d\n", a.length);

    immutable len = a.length;
    for (size_t i = 0; i < len; )
    {
        dchar d = a[i];
        if (d & ~0x7F)
            d = decode(a, i);
        else
            i++;
        if (auto r = dg(cast(void*)&d))
            return r;
    }
    return 0;
}

unittest
{
    debug(apply) printf("_aApplywd1.unittest\n");

    auto s = "hello"w[];
    int i = 0;
    foreach (dchar d; s)
    {
        switch (i)
        {
            case 0:     assert(d == 'h');   break;
            case 1:     assert(d == 'e');   break;
            case 2:     assert(d == 'l');   break;
            case 3:     assert(d == 'l');   break;
            case 4:     assert(d == 'o');   break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);

    s = "a\u1234\U000A0456b";
    i = 0;
    foreach (dchar d; s)
    {
        //printf("i = %d, d = %x\n", i, d);
        switch (i)
        {
            case 0:     assert(d == 'a');           break;
            case 1:     assert(d == '\u1234');      break;
            case 2:     assert(d == '\U000A0456');  break;
            case 3:     assert(d == 'b');           break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 4);
}

/*****************************/

extern(C) int _aApplycw1(in char[] a, dg_t dg)
{
    debug(apply) printf("_aApplycw1(), len = %d\n", a.length);

    immutable len = a.length;
    for (size_t i = 0; i < len; )
    {
        wchar w = a[i];
        if (w & 0x80)
        {
            dchar d = decode(a, i);
            if (d <= 0xFFFF)
                w = cast(wchar)d;
            else
            {
                w = cast(wchar)((((d - 0x10000) >> 10) & 0x3FF) + 0xD800);
                if (auto r = dg(cast(void*)&w))
                    return r;
                w = cast(wchar)(((d - 0x10000) & 0x3FF) + 0xDC00);
            }
        }
        else
            i++;
        if (auto r = dg(cast(void*)&w))
            return r;
    }
    return 0;
}

unittest
{
    debug(apply) printf("_aApplycw1.unittest\n");

    auto s = "hello"c[];
    int i = 0;
    foreach (wchar d; s)
    {
        switch (i)
        {
            case 0:     assert(d == 'h');   break;
            case 1:     assert(d == 'e');   break;
            case 2:     assert(d == 'l');   break;
            case 3:     assert(d == 'l');   break;
            case 4:     assert(d == 'o');   break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);

    s = "a\u1234\U000A0456b";
    i = 0;
    foreach (wchar d; s)
    {
        //printf("i = %d, d = %x\n", i, d);
        switch (i)
        {
            case 0:     assert(d == 'a');       break;
            case 1:     assert(d == 0x1234);    break;
            case 2:     assert(d == 0xDA41);    break;
            case 3:     assert(d == 0xDC56);    break;
            case 4:     assert(d == 'b');       break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);
}

/*****************************/

extern(C) int _aApplywc1(in wchar[] a, dg_t dg)
{
    debug(apply) printf("_aApplywc1(), len = %d\n", a.length);

    immutable len = a.length;
    for (size_t i = 0; i < len; )
    {
        wchar w = a[i];
        if (w & ~0x7F)
        {
            dchar d = decode(a, i);
            char[4] buf;
            auto b = toUTF8(buf, d);
            foreach (char c; b)
            {
                if (auto r = dg(cast(void*)&c))
                    return r;
            }
            continue;
        }
        char c = cast(char)w;
        i++;
        if (auto r = dg(cast(void*)&c))
            return r;
    }
    return 0;
}

unittest
{
    debug(apply) printf("_aApplywc1.unittest\n");

    auto s = "hello"w[];
    int i;
    foreach (char d; s)
    {
        switch (i)
        {
            case 0:     assert(d == 'h');   break;
            case 1:     assert(d == 'e');   break;
            case 2:     assert(d == 'l');   break;
            case 3:     assert(d == 'l');   break;
            case 4:     assert(d == 'o');   break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);

    s = "a\u1234\U000A0456b";
    i = 0;
    foreach (char d; s)
    {
        //printf("i = %d, d = %x\n", i, d);
        switch (i)
        {
            case 0:     assert(d == 'a');   break;
            case 1:     assert(d == 0xE1);  break;
            case 2:     assert(d == 0x88);  break;
            case 3:     assert(d == 0xB4);  break;
            case 4:     assert(d == 0xF2);  break;
            case 5:     assert(d == 0xA0);  break;
            case 6:     assert(d == 0x91);  break;
            case 7:     assert(d == 0x96);  break;
            case 8:     assert(d == 'b');   break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 9);
}

/*****************************/

extern(C) int _aApplydc1(in dchar[] a, dg_t dg)
{
    debug(apply) printf("_aApplydc1(), len = %d\n", a.length);

    foreach (dchar d; a)
    {
        if (d & ~0x7F)
        {
            char[4] buf;
            auto b = toUTF8(buf, d);
            foreach (char c; b)
            {
                if (auto r = dg(cast(void*)&c))
                    return r;
            }
            continue;
        }
        char c = cast(char)d;
        if (auto r = dg(cast(void*)&c))
            return r;
    }
    return 0;
}

unittest
{
    debug(apply) printf("_aApplyRdc1.unittest\n");

    auto s = "hello"d[];
    int i;
    foreach (char d; s)
    {
        switch (i)
        {
            case 0:     assert(d == 'h');   break;
            case 1:     assert(d == 'e');   break;
            case 2:     assert(d == 'l');   break;
            case 3:     assert(d == 'l');   break;
            case 4:     assert(d == 'o');   break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);

    s = "a\u1234\U000A0456b";
    i = 0;
    foreach (char d; s)
    {
        //printf("i = %d, d = %x\n", i, d);
        switch (i)
        {
            case 0:     assert(d == 'a');   break;
            case 1:     assert(d == 0xE1);  break;
            case 2:     assert(d == 0x88);  break;
            case 3:     assert(d == 0xB4);  break;
            case 4:     assert(d == 0xF2);  break;
            case 5:     assert(d == 0xA0);  break;
            case 6:     assert(d == 0x91);  break;
            case 7:     assert(d == 0x96);  break;
            case 8:     assert(d == 'b');   break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 9);
}

/*****************************/

extern(C) int _aApplydw1(in dchar[] a, dg_t dg)
{
    debug(apply) printf("_aApplydw1(), len = %d\n", a.length);

    foreach (dchar d; a)
    {
        wchar w = void;
        if (d <= 0xFFFF)
            w = cast(wchar)d;
        else
        {
            w = cast(wchar)((((d - 0x10000) >> 10) & 0x3FF) + 0xD800);
            if (auto r = dg(cast(void*)&w))
                return r;
            w = cast(wchar)(((d - 0x10000) & 0x3FF) + 0xDC00);
        }
        if (auto r = dg(cast(void*)&w))
            return r;
    }
    return 0;
}

unittest
{
    debug(apply) printf("_aApplydw1.unittest\n");

    auto s = "hello"d[];
    int i;
    foreach (wchar d; s)
    {
        switch (i)
        {
            case 0:     assert(d == 'h');   break;
            case 1:     assert(d == 'e');   break;
            case 2:     assert(d == 'l');   break;
            case 3:     assert(d == 'l');   break;
            case 4:     assert(d == 'o');   break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);

    s = "a\u1234\U000A0456b";
    i = 0;
    foreach (wchar d; s)
    {
        //printf("i = %d, d = %x\n", i, d);
        switch (i)
        {
            case 0:     assert(d == 'a');       break;
            case 1:     assert(d == 0x1234);    break;
            case 2:     assert(d == 0xDA41);    break;
            case 3:     assert(d == 0xDC56);    break;
            case 4:     assert(d == 'b');       break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);
}


/****************************************************************************/
/* 2 argument versions */

// dg is D, but _aApplycd2() is C
alias dg2_t = extern(D) int delegate(void*, void*);

extern(C) int _aApplycd2(in char[] a, dg2_t dg)
{
    debug(apply) printf("_aApplycd2(), len = %d\n", a.length);
    /* bug, size_t n is necessary */

    immutable len = a.length;
    for (size_t i = 0; i < len; )
    {
        dchar d = a[i];
        if (d & 0x80)
            d = decode(a, i);
        else
            i++;
        if (auto r = dg(&i, cast(void*)&d))
            return r;
    }
    return 0;
}

unittest
{
    debug(apply) printf("_aApplycd2.unittest\n");

    auto s = "hello"c[];
    int i;
    foreach (k, dchar d; s)
    {
        //printf("i = %d, k = %d, d = %x\n", i, k, d);
        assert(k == i);
        switch (i)
        {
            case 0:     assert(d == 'h');   break;
            case 1:     assert(d == 'e');   break;
            case 2:     assert(d == 'l');   break;
            case 3:     assert(d == 'l');   break;
            case 4:     assert(d == 'o');   break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);

    s = "a\u1234\U000A0456b";
    i = 0;
    foreach (k, dchar d; s)
    {
        //printf("i = %d, k = %d, d = %x\n", i, k, d);
        switch (i)
        {
            case 0:     assert(k == 0 && d == 'a'         );    break;
            case 1:     assert(k == 1 && d == '\u1234'    );    break;
            case 2:     assert(k == 4 && d == '\U000A0456');    break;
            case 3:     assert(k == 8 && d == 'b'         );    break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 4);
}

/*****************************/

extern(C) int _aApplywd2(in wchar[] a, dg2_t dg)
{
    debug(apply) printf("_aApplywd2(), len = %d\n", a.length);

    immutable len = a.length;
    for (size_t i = 0; i < len; )
    {
        dchar d = a[i];
        if (d & ~0x7F)
            d = decode(a, i);
        else
            i++;
        if (auto r = dg(&i, cast(void*)&d))
            return r;
    }
    return 0;
}

unittest
{
    debug(apply) printf("_aApplywd2.unittest\n");

    auto s = "hello"w[];
    int i;
    foreach (k, dchar d; s)
    {
        //printf("i = %d, k = %d, d = %x\n", i, k, d);
        assert(k == i);
        switch (i)
        {
            case 0:     assert(d == 'h');   break;
            case 1:     assert(d == 'e');   break;
            case 2:     assert(d == 'l');   break;
            case 3:     assert(d == 'l');   break;
            case 4:     assert(d == 'o');   break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);

    s = "a\u1234\U000A0456b";
    i = 0;
    foreach (k, dchar d; s)
    {
        //printf("i = %d, k = %d, d = %x\n", i, k, d);
        switch (i)
        {
            case 0:     assert(k == 0 && d == 'a');             break;
            case 1:     assert(k == 1 && d == '\u1234');        break;
            case 2:     assert(k == 2 && d == '\U000A0456');    break;
            case 3:     assert(k == 4 && d == 'b');             break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 4);
}

/*****************************/

extern(C) int _aApplycw2(in char[] a, dg2_t dg)
{
    debug(apply) printf("_aApplycw2(), len = %d\n", a.length);

    immutable len = a.length;
    for (size_t i = 0; i < len; )
    {
        wchar w = a[i];
        if (w & 0x80)
        {
            dchar d = decode(a, i);
            if (d <= 0xFFFF)
                w = cast(wchar)d;
            else
            {
                w = cast(wchar)((((d - 0x10000) >> 10) & 0x3FF) + 0xD800);
                if (auto r = dg(&i, cast(void*)&w))
                    return r;
                w = cast(wchar)(((d - 0x10000) & 0x3FF) + 0xDC00);
            }
        }
        else
            i++;
        if (auto r = dg(&i, cast(void*)&w))
            return r;
    }
    return 0;
}

unittest
{
    debug(apply) printf("_aApplycw2.unittest\n");

    auto s = "hello"c[];
    int i;
    foreach (k, wchar d; s)
    {
        //printf("i = %d, k = %d, d = %x\n", i, k, d);
        assert(k == i);
        switch (i)
        {
            case 0:     assert(d == 'h');   break;
            case 1:     assert(d == 'e');   break;
            case 2:     assert(d == 'l');   break;
            case 3:     assert(d == 'l');   break;
            case 4:     assert(d == 'o');   break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);

    s = "a\u1234\U000A0456b";
    i = 0;
    foreach (k, wchar d; s)
    {
        //printf("i = %d, k = %d, d = %x\n", i, k, d);
        switch (i)
        {
            case 0:     assert(k == 0 && d == 'a');     break;
            case 1:     assert(k == 1 && d == 0x1234);  break;
            case 2:     assert(k == 4 && d == 0xDA41);  break;
            case 3:     assert(k == 4 && d == 0xDC56);  break;
            case 4:     assert(k == 8 && d == 'b');     break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);
}

/*****************************/

extern(C) int _aApplywc2(in wchar[] a, dg2_t dg)
{
    debug(apply) printf("_aApplywc2(), len = %d\n", a.length);

    immutable len = a.length;
    for (size_t i = 0; i < len; i += n)
    {
        wchar w = a[i];
        if (w & ~0x7F)
        {
            dchar d = decode(a, i);
            char[4] buf;
            auto b = toUTF8(buf, d);
            foreach (char c; b)
            {
                if (auto r = dg(&i, cast(void*)&c))
                    return r;
            }
            continue;
        }
        char c = cast(char)w;
        i++;
        if (auto r = dg(&i, cast(void*)&c))
            return r;
    }
    return 0;
}

unittest
{
    debug(apply) printf("_aApplywc2.unittest\n");

    auto s = "hello"w[];
    int i;
    foreach (k, char d; s)
    {
        //printf("i = %d, k = %d, d = %x\n", i, k, d);
        assert(k == i);
        switch (i)
        {
            case 0:     assert(d == 'h');   break;
            case 1:     assert(d == 'e');   break;
            case 2:     assert(d == 'l');   break;
            case 3:     assert(d == 'l');   break;
            case 4:     assert(d == 'o');   break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);

    s = "a\u1234\U000A0456b";
    i = 0;
    foreach (k, char d; s)
    {
        //printf("i = %d, k = %d, d = %x\n", i, k, d);
        switch (i)
        {
            case 0:     assert(k == 0 && d == 'a');     break;
            case 1:     assert(k == 1 && d == 0xE1);    break;
            case 2:     assert(k == 1 && d == 0x88);    break;
            case 3:     assert(k == 1 && d == 0xB4);    break;
            case 4:     assert(k == 2 && d == 0xF2);    break;
            case 5:     assert(k == 2 && d == 0xA0);    break;
            case 6:     assert(k == 2 && d == 0x91);    break;
            case 7:     assert(k == 2 && d == 0x96);    break;
            case 8:     assert(k == 4 && d == 'b');     break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 9);
}

/*****************************/

extern(C) int _aApplydc2(in dchar[] a, dg2_t dg)
{
    size_t len = a.length;

    debug(apply) printf("_aApplydc2(), len = %d\n", len);
    for (size_t i = 0; i < len; i++)
    {
        dchar d = a[i];
        if (d & ~0x7F)
        {
            char[4] buf;
            auto b = toUTF8(buf, d);
            foreach (char c; b)
            {
                if (auto r = dg(&i, cast(void*)&c))
                    return r;
            }
            continue;
        }
        char c = cast(char)d;
        if (auto r = dg(&i, cast(void*)&c))
            return r;
    }
    return 0;
}

unittest
{
    debug(apply) printf("_aApplydc2.unittest\n");

    auto s = "hello"d[];
    int i;
    foreach (k, char d; s)
    {
        //printf("i = %d, k = %d, d = %x\n", i, k, d);
        assert(k == i);
        switch (i)
        {
            case 0:     assert(d == 'h'); break;
            case 1:     assert(d == 'e'); break;
            case 2:     assert(d == 'l'); break;
            case 3:     assert(d == 'l'); break;
            case 4:     assert(d == 'o'); break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);

    s = "a\u1234\U000A0456b";
    i = 0;
    foreach (k, char d; s)
    {
        //printf("i = %d, k = %d, d = %x\n", i, k, d);
        switch (i)
        {
            case 0:     assert(k == 0); assert(d == 'a'); break;
            case 1:     assert(k == 1); assert(d == 0xE1); break;
            case 2:     assert(k == 1); assert(d == 0x88); break;
            case 3:     assert(k == 1); assert(d == 0xB4); break;
            case 4:     assert(k == 2); assert(d == 0xF2); break;
            case 5:     assert(k == 2); assert(d == 0xA0); break;
            case 6:     assert(k == 2); assert(d == 0x91); break;
            case 7:     assert(k == 2); assert(d == 0x96); break;
            case 8:     assert(k == 3); assert(d == 'b'); break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 9);
}

/*****************************/

extern(C) int _aApplydw2(in dchar[] a, dg2_t dg)
{
    debug(apply) printf("_aApplydw2(), len = %d\n", a.length);

    foreach (size_t i, dchar d; a)
    {
        auto j = i;
        wchar w;
        if (d <= 0xFFFF)
            w = cast(wchar)d;
        else
        {
            w = cast(wchar)((((d - 0x10000) >> 10) & 0x3FF) + 0xD800);
            if (auto r = dg(&j, cast(void*)&w))
                return r;
            w = cast(wchar)(((d - 0x10000) & 0x3FF) + 0xDC00);
        }
        if (auto r = dg(&j, cast(void*)&w))
            return r;
    }
    return 0;
}

unittest
{
    debug(apply) printf("_aApplydw2.unittest\n");

    auto s = "hello"d[];
    int i;
    foreach (k, wchar d; s)
    {
        //printf("i = %d, k = %d, d = %x\n", i, k, d);
        assert(k == i);
        switch (i)
        {
            case 0:     assert(d == 'h');   break;
            case 1:     assert(d == 'e');   break;
            case 2:     assert(d == 'l');   break;
            case 3:     assert(d == 'l');   break;
            case 4:     assert(d == 'o');   break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);

    s = "a\u1234\U000A0456b";
    i = 0;
    foreach (k, wchar d; s)
    {
        //printf("i = %d, k = %d, d = %x\n", i, k, d);
        switch (i)
        {
            case 0:     assert(k == 0 && d == 'a');     break;
            case 1:     assert(k == 1 && d == 0x1234);  break;
            case 2:     assert(k == 2 && d == 0xDA41);  break;
            case 3:     assert(k == 2 && d == 0xDC56);  break;
            case 4:     assert(k == 3 && d == 'b');     break;
            default:    assert(0);
        }
        i++;
    }
    assert(i == 5);
}
