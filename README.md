# Accessor

After trying very hard, I have to admit that my mind is too weak to understand lens. So I decided to roll my own data access library with no fancy categories but only getters, setters and fmaps chained together. 

To get started:

```hs
import Accessor
```

An accessor is a getter with a setter.

For record fields, the accessors are defined as follows:

```hs
data Point = Point {_x :: Int, _y :: Int}

x = accessor _x (\elem record -> record {x = elem})
y = accessor _y (\elem record -> record {y = elem})
```

With an accessor, you can view, set, and transform data of the record:

```hs
point = Point 1 2
view x point -- 1
set x 3 point -- Point 3 2
over x (+1) point -- Point 2 2
```

For a nested record, accessors can be composed using `dot`:

```hs
data Line = Line {_start :: Point, _end :: Point}
start = accessor _start (\elem record -> record {_start = elem})
end = accessor _end (\elem record -> record {_end = elem})


data Point = Point {_x :: Int, _y :: Int}
x = accessor _x (\elem record -> record {_x = elem})
y = accessor _y (\elem record -> record {_y = elem})

line = Line (Point 1 2) (Point 3 4)

start_x = view (dot start x) line -- 1
end_y = view (dot end y) line -- 4
```

If the field is a functor, the accessor should be composed with the next accessor using `facc`. For example:

```hs
data Address = Address {_detail :: String, _code :: String }
detail = accessor _detail (\elem record -> record {_detail = elem}) 
code = accessor _code (\elem record -> record {_code = elem}) 

data Person = Person {_name :: String, _addr :: Maybe Address }
name = accessor _name (\elem record -> record {_name = elem}) 
addr= accessor _addr (\elem record -> record {_addr = elem}) 
```

Let there be Alice living in Shanghai:

```hs
alice = Person
    { _name = "Alice"
    , _addr = Just Address
        { _detail = "Shanghai"
        , _code = "200000"
        }
    }
```

You can view/modify Alice's address detail:

```hs
s = view (dot addr $ facc detail) alice -- Just "Shanghai"
```

The use of `fmap` inside of `facc` ensures that `Nothing` is handled properly.

Accessor of the nth element of a list is `listAt n`, and for 0 to 9, there are shortcuts: `_0` to `_9`.

```hs
view _1 [1,2,3] -- 2
view (dot _1 _1) [[1,2,3], [4,5,6]] -- 5
set _0 42 [1,2,3] -- [42,2,3]
over _1 (+1) [1,2,3] -- [1,3,3]
```

Lists are also functors, so you can `fmap` over it using `facc`, which is the same as `map`:

```hs
over (facc self) (+1) [1,2,3] -- [2,3,4]
over (dot _1 $ facc self) (+1) [[1,2], [3,4]] -- [[1,2],[4,5]]
```
