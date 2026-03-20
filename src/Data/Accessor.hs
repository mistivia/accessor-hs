module Data.Accessor
    ( accessor
    , Accessor
    , AccessorImpl
    , view
    , over
    , set
    , listAcc
    , fstAcc
    , sndAcc
    , _0, _1, _2, _3, _4
    , _5, _6, _7, _8, _9
    , facc
    )
where

type AccessorImpl s w r = (w -> w) -> s -> (s, r)

accessorImpl :: (s -> a) -> (a -> s -> s) -> AccessorImpl s a a
accessorImpl getter setter f x = (setter newVal x, getter x) where
  newVal = f (getter x)

viewImpl :: AccessorImpl s a b -> s -> b
viewImpl acc = snd . acc id

overImpl :: AccessorImpl s a b -> (a -> a) -> s -> s
overImpl acc f = fst . acc f

dot :: AccessorImpl s1 a1 a1 -> AccessorImpl a1 w2 r -> AccessorImpl s1 w2 r
dot ac1 ac2 modifier obj =
    (newObj, value)
    where
      newObj = overImpl ac1 (overImpl ac2 modifier) obj
      value = viewImpl ac2 (viewImpl ac1 obj)

accessor :: (s1 -> a1) -> (a1 -> s1 -> s1) -> AccessorImpl a1 w2 r -> AccessorImpl s1 w2 r
accessor a b = dot $ accessorImpl a b

type Accessor s1 a1 = forall w2 r. AccessorImpl a1 w2 r -> AccessorImpl s1 w2 r

type AppliedToSelf f a = (AccessorImpl a a a -> f)

self :: AccessorImpl a a a
self = accessorImpl id const

view :: AppliedToSelf (AccessorImpl s a b) a -> s -> b
view acc = snd . acc self id

over :: AppliedToSelf (AccessorImpl s a b) a -> (a -> a) -> s -> s
over acc f = fst . acc self f

set :: AppliedToSelf (AccessorImpl s a b) a ->  a -> s -> s
set acc x = overImpl (acc self) (const x)

facc :: Functor f => AccessorImpl middle updated toRead -> AccessorImpl (f middle) updated (f toRead)
facc acc modifier obj =
    (newObj, value)
    where
        newObj = fmap (overImpl acc modifier) obj
        value = fmap (viewImpl acc) obj

listAcc :: Int -> Accessor [a] a
listAcc idx = accessor getter setter where
    getter = (!! max 0 idx)
    setter n lst = take idx lst ++ [n] ++ drop (idx + 1) lst

_0 :: Accessor [a] a
_1 :: Accessor [a] a
_2 :: Accessor [a] a
_3 :: Accessor [a] a
_4 :: Accessor [a] a
_5 :: Accessor [a] a
_6 :: Accessor [a] a
_7 :: Accessor [a] a
_8 :: Accessor [a] a
_9 :: Accessor [a] a

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

fstAcc :: Accessor (a, b) a
fstAcc = accessor getter setter where
    getter (a, _) = a
    setter n x = (n, snd x)

sndAcc :: Accessor (a, b) b
sndAcc = accessor getter setter where
    getter (_, b) = b
    setter n x = (fst x, n)
