
module handle.handle;

import std.traits;

struct Handle(T)
{
private:
    ushort _index;
    ushort _counter;

public:
    @property
    ushort counter() const
    {
        return _counter;
    }

    @property
    ushort index() const
    {
        return _index;
    }

    I opCast(I)() if(isIntegral!I)
    {
        return cast(I) _counter << 16 | _index;
    }
}
