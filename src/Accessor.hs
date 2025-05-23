module Accessor
    ( accessor
    , Accessor
    , view
    , over
    , set
    , (#)
    , (#>)
    , listAcc
    , fstAcc
    , sndAcc
    , self
    , _0, _1, _2, _3, _4
    , _5, _6, _7, _8, _9
    )
where

type Accessor s w r = (w -> w) -> s -> (s, r)

accessor :: (s -> a) -> (a -> s -> s) -> Accessor s a a
accessor getter setter f x = (setter newVal x, getter x) where
  newVal = f (getter x)

view :: Accessor s a b -> s -> b
view acc = snd . acc id

over :: Accessor s a b -> (a -> a) -> s -> s
over acc f = fst . acc f

set :: Accessor s a b ->  a -> s -> s
set acc x = over acc (const x)

infixr #

(#) ::
    Accessor s1 a1 a1 -> Accessor a1 w2 r -> Accessor s1 w2 r
(#) = composeAccessors where
  composeAccessors ac1 ac2 modifier obj =
    (newObj, value)
    where
      newObj = over ac1 (over ac2 modifier) obj
      value = view ac2 (view ac1 obj)

infixr #>

(#>) :: (Functor f) =>
    Accessor obj (f middle) (f middle) -> Accessor middle end result
    -> Accessor obj end (f result)
(#>) = composeFunctorAccesors where
  composeFunctorAccesors ac1 ac2 modifier obj =
    (newObj, value)
    where
      newObj = over ac1 (fmap $ over ac2 modifier) obj
      value = fmap (view ac2) (view ac1 obj)

self :: Accessor a a a
self = accessor id const 

listAcc :: Int -> Accessor [a] a a
listAcc idx = accessor getter setter where
    getter = (!! max 0 idx)
    setter n lst = take idx lst ++ [n] ++ drop (idx + 1) lst

_0 :: Accessor [a] a a
_1 :: Accessor [a] a a
_2 :: Accessor [a] a a
_3 :: Accessor [a] a a
_4 :: Accessor [a] a a
_5 :: Accessor [a] a a
_6 :: Accessor [a] a a
_7 :: Accessor [a] a a
_8 :: Accessor [a] a a
_9 :: Accessor [a] a a

_0 = listAcc 0
_1 = listAcc 1
_2 = listAcc 2
_3 = listAcc 3
_4 = listAcc 4
_5 = listAcc 5
_6 = listAcc 6
_7 = listAcc 7
_8 = listAcc 8
_9 = listAcc 9

fstAcc :: Accessor (a, b) a a
fstAcc = accessor getter setter where
    getter (a, _) = a
    setter n x = (n, snd x)

sndAcc :: Accessor (a, b) b b
sndAcc = accessor getter setter where
    getter (_, b) = b
    setter n x = (fst x, n)

