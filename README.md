# Handle
A D library for handles. Handles are a fast, compact, and serializable alternative to pointers. Further more, handles are memory safe and will never dangle, and loose handles will never cause memory leaks.

Handles are a fast and light-weight alternative to conventional or reference-counted pointers in high performance systems such as game engines.

# A Short Example

```d
import handle;

void main()
{
    auto manager = new HandleManager!string;
    
    // Handles are easy to use.
    auto hello = manager.add("Hello World");
    assert(manager[handle] == "Hello World");
    
    // Handles are easy to serialize.
    uint packed = cast(uint) hello;
    auto handle = Handle!string(packed);
    
    // Handles will never dangle.
    manager.remove(handle);
    assert(manager[handle] is null);
}
```

# License

MIT
