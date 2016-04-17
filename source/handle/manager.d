
module handle.manager;

import handle.handle;

import std.traits;

class HandleManager(T, size_t entryCount = 2 ^^ 12) if(entryCount > 0)
{
private:
    struct HandleEntry
    {
        T object;

        ushort counter = 1;
        ushort nextFreeIndex;

        bool active;

        this(ushort nextFreeIndex)
        {
            this.nextFreeIndex = nextFreeIndex;
        }

        bool matches(Handle!T handle) const
        {
            return active && handle.counter == counter;
        }
    }

private:
    ushort _activeCount    = 0;
    ushort _firstFreeIndex = 0;

    HandleEntry[entryCount] _entries;

public:
    this()
    {
        clear;
    }

    /++
     + Stores an element in the handle manager, returning a unique handle for
     + that element.
     +
     + Params:
     +   object - The element to store in the handle manager.
     +
     + Returns:
     +   A handle referring to the element that was stored in the handle manager.
     ++/
    Handle!T add(T object)
    in
    {
        assert(_activeCount < entryCount);
    }
    body
    {
        auto next = _firstFreeIndex;
        assert(next < entryCount);
        assert(!_entries[next].active);

        // Also update the next-free-index for fast allocation.
        _firstFreeIndex = _entries[next].nextFreeIndex;
        _entries[next].nextFreeIndex = 0;

        _entries[next].counter++;
        _entries[next].active = true;
        _entries[next].object = object;
        _activeCount++;

        return Handle!T(next, _entries[next].counter);
    }

    @property
    enum size_t capacity = entryCount;

    /++
     + Clears the handle manager, returning it to its initial state.
     ++/
    void clear()
    {
        _activeCount    = 0;
        _firstFreeIndex = 0;

        foreach(ushort index; 1 .. entryCount)
        {
            _entries[index - 1] = HandleEntry(index);
        }

        // Last entry does a wrap-around.
        _entries[$ - 1] = HandleEntry(0);
    }

    /++
     + Retrieves an element from the handle manager by its handle. If no element
     + exists at the handle, or the handle is no longer valid, null is returned.
     + If the type of the stored element cannot store null, an exception is
     + raised instead.
     +
     + Params:
     +   handle - The handle of the element being accessed.
     +
     + Returns:
     +   An element stored in the handle manager.
     ++/
    T get(Handle!T handle) const
    {
        T value;

        if(get(handle, value))
        {
            return value;
        }
        else
        {
            // Check if the type can store a null.
            static if(isAssignable!(T, typeof(null)))
            {
                return null;
            }
            else
            {
                assert(0, "No value exists at handle.");
            }
        }
    }

    /++
     + Retrieves an element from the handle manager by its handle, storing the
     + result in an out parameter.
     +
     + Params:
     +   handle - The handle of the element being accessed.
     +   object - The out parameter in which the result is stored.
     +
     + Returns:
     +   true if the handle was valid and referred to an element, false otherwise.
     ++/
    bool get(Handle!T handle, out T object) const
    in
    {
        assert(handle.index < entryCount);
    }
    body
    {
        if(_entries[handle.index].matches(handle))
        {
            object = _entries[handle.index].object;
            return true;
        }

        return false;
    }

    /++
     + Returns the number of elements currently stored in the handle manager.
     +
     + Returns:
     +   The length of the handle manager.
     ++/
    @property
    size_t length() const
    {
        return _activeCount;
    }

    T opIndex(Handle!T handle) const
    {
        return get(handle);
    }

    T opIndexAssign(T object, Handle!T handle)
    {
        if(replace(handle, object))
        {
            return object;
        }
        else
        {
            assert(0, "No value exists at handle.");
        }
    }

    /++
     + Removes an element from the handle manager.
     +
     + Params:
     +   handle - The handle of the element being removed.
     +
     + Returns:
     +   true if the handle was valid and an element was removed, false otherwise.
     ++/
    bool remove(Handle!T handle)
    in
    {
        assert(handle.index < entryCount);
    }
    body
    {
        if(_entries[handle.index].matches(handle))
        {
            // Clear the reference as well to assist the GC.
            _entries[handle.index].nextFreeIndex = _firstFreeIndex;
            _entries[handle.index].active = false;
            _entries[handle.index].object = T.init;

            // Also update next-free-index.
            _firstFreeIndex = handle.index;
            _activeCount--;

            return true;
        }

        return false;
    }

    /++
     + Replaces the element referred to by a handle in the handle manager.
     +
     + Params:
     +   handle - The handle of the element being replaced.
     +   object - The new value of the handle.
     +
     + Returns:
     +   true if the handle was valid and an element was replaced, false otherwise.
     ++/
    bool replace(Handle!T handle, T object)
    in
    {
        assert(handle.index < entryCount);
    }
    body
    {
        if(_entries[handle.index].matches(handle))
        {
            _entries[handle.index].object = object;
            return true;
        }

        return false;
    }
}

unittest
{
    auto manager = new HandleManager!(string, 2);

    auto handle1 = manager.add("foo");
    auto handle2 = manager.add("bar");

    assert(manager.get(handle1) == "foo");
    assert(manager.get(handle2) == "bar");
    assert(manager.length == 2);

    assert(manager.replace(handle2, "baz"));
    assert(manager.get(handle2) == "baz");
    assert(manager.length == 2);

    assert(manager.remove(handle2));
    assert(manager.get(handle2) is null);
    assert(manager.get(handle1) == "foo");
    assert(manager.length == 1);
}
