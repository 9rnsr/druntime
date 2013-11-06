/**
 * TypeInfo support code.
 *
 * Copyright: Copyright Kenji Hara 2013.
 * License:   <a href="http://www.boost.org/LICENSE_1_0.txt">Boost License 1.0</a>.
 * Authors:   Kenji Hara
 */

module rt.typeinfo.ti_S;

// struct

class TypeInfo_xS : TypeInfo_Const
{
    override void postblit(void* p) const
    {
        if (xpostblit)
            (*xpostblit)(p);
    }

    // constant postblit
    void function(void*) xpostblit;
}

class TypeInfo_yS : TypeInfo_Invariant
{
    override void postblit(void* p) const
    {
        if (xpostblit)
            (*xpostblit)(p);
    }

    // immutable postblit
    void function(void*) xpostblit;
}

class TypeInfo_NgS : TypeInfo_Inout
{
    override void postblit(void* p) const
    {
        if (xpostblit)
            (*xpostblit)(p);
    }

    // unique postblit
    void function(void*) xpostblit;
}

/+
class TypeInfo_OS : TypeInfo_Shared
{
    override void postblit(void* p) const
    {
        if (xpostblit)
            (*xpostblit)(p);
    }

    // shared postblit
    void function(void*) xpostblit;
}

class TypeInfo_OxS : TypeInfo_Shared
{
    override void postblit(void* p) const
    {
        if (xpostblit)
            (*xpostblit)(p);
    }

    // shared const postblit
    void function(void*) xpostblit;
}

class TypeInfo_ONgS : TypeInfo_Shared
{
    override void postblit(void* p) const
    {
        if (xpostblit)
            (*xpostblit)(p);
    }

    // shared inout  postblit
    void function(void*) xpostblit;
}
+/
