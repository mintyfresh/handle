# Handle
A D library for handles. Handles are a fast, compact, and serializable alternative to pointers. Further more, handles are memory safe and will never dangle, and loose handles will never cause memory leaks.

Handles are a fast and light-weight alternative to conventional or reference-counted pointers in high performance systems such as game engines.

# A Short Example

Below is a brief example of handles used to store strings. Any type can be used, however.

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

## Capacity

Internally, the `HandleManager` class operates on a static array of predefined size (as a performance optimization). The default capacity of a HandleManager is 4096 (`2 ^^ 12`), but it accepts a second template argument as an override. For example,

```d
void main()
{
    // Allocate enough storage for 500 handles.
    auto manager = new HandleManager!(string, 500);

    static assert(manager.capacity == 500);
    
    // . . .
}
```

# License

MIT
