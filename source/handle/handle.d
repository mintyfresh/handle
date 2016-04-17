
module handle.handle;

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

    I opCast(I : uint)()
    {
        return cast(uint) _counter << 16 | _index;
    }
}
