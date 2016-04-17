
module handle.handle;

import std.traits;

struct Handle(T)
{
private:
    ushort _index;
    ushort _counter;

public:
    /++
     + Constructs a new handle from an index and update counter state.
     ++/
    this(ushort index, ushort counter)
    {
        _index   = index;
        _counter = counter;
    }

    /++
     + Reconstructs a packed handle.
     ++/
    this(uint handle)
    {
        _index   = cast(ushort)((handle >>  0) & 0xFFFF);
        _counter = cast(ushort)((handle >> 16) & 0xFFFF);
    }

    /++
     + The update counter of the handle, that guarantees the validity of a handle.
     +
     + Returns:
     +   The update counter.
     ++/
    @property
    ushort counter() const
    {
        return _counter;
    }

    /++
     + The index of the stored element into the handle manager.
     +
     + Returns:
     +   The index of the handle.
     ++/
    @property
    ushort index() const
    {
        return _index;
    }

    /++
     + Packs a handle into a uint.
     ++/
    I opCast(I : uint)() const
    {
        return cast(I) _counter << 16 | _index;
    }

    /++
     + Computes the hash of a handle (its packed value).
     ++/
    hash_t toHash() const
    {
        return cast(uint) this;
    }
}
