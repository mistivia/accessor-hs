module Main where

import Accessor
import Test.HUnit
import System.Exit

testListSet_1 :: Test
testListSet_1 = TestCase (assertEqual "list set 1" expect result) where
  result =
    let lst = [1,2,3] :: [Int]
    in set _0 42 lst
  expect = [42,2,3]
      
testListSet_2 :: Test
testListSet_2 = TestCase (assertEqual "list set 2" expect result) where
  result =
    let lst = [[1,2,3],[4,5,6],[7,8,9]] :: [[Int]]
    in set (_1 # _1) 42 lst
  expect = [[1,2,3],[4,42,6],[7,8,9]]

testListSet_3 :: Test
testListSet_3 = TestCase (assertEqual "list set 3" expect result) where
  result =
    let lst = [[1,2,3],[4,5,6],[7,8,9]] :: [[Int]]
    in over (_1 #> self) (+1) lst
  expect = [[1,2,3],[5,6,7],[7,8,9]]

testListSet_4 :: Test
testListSet_4 = TestCase (assertEqual "list set 4" expect result) where
  result =
    let lst = [[[1,2,3],[4,5,6],[7,8,9]]] :: [[[Int]]]
    in set (_0 # _1 # _1) 42 lst
  expect = [[[1,2,3],[4,42,6],[7,8,9]]]

testTuple_1 :: Test
testTuple_1 = TestCase (assertEqual "tuple 1" expect result) where
  result  = view (self #> sndAcc) $ Just (1 :: Int, 42 :: Int)
  expect = Just 42

testTuple_2 :: Test
testTuple_2 = TestCase (assertEqual "tuple 2" expect result) where
  result = view (self #> _1 # _2 # _3) Nothing :: Maybe Int
  expect = Nothing

data Person = Person
  { _name :: String,
    _address :: Maybe Address
  }
  deriving (Show)
name :: Accessor Person String String
name = accessor _name (\n x -> x {_name = n})
address :: Accessor Person (Maybe Address) (Maybe Address)
address = accessor _address (\n x -> x {_address = n})

data Address = Address
  { _city :: String,
    _zipInfos :: [Maybe ZipInfo]
  }
  deriving (Show)
city :: Accessor Address String String
city = accessor _city (\n x -> x {_city = n})
zipInfos :: Accessor Address [Maybe ZipInfo] [Maybe ZipInfo]
zipInfos = accessor _zipInfos (\n x -> x {_zipInfos = n})

data ZipInfo = ZipInfo
  { _code :: String,
    _extraInfo :: Maybe String
  }
  deriving (Show)
code :: Accessor ZipInfo String String
code = accessor _code (\n x -> x {_code = n})
extraInfo :: Accessor ZipInfo (Maybe String) (Maybe String)
extraInfo = accessor _extraInfo (\n x -> x {_extraInfo = n})

recordTests :: [Test]
recordTests = 
  let
    alice = Person
     { _name = "Alice"
     , _address = Just Address
       { _city = "Shanghai"
       , _zipInfos =
         [ Just ZipInfo
             { _code = "200000"
             , _extraInfo = Nothing
             },
           Just ZipInfo
             { _code = "200002"
             , _extraInfo = Nothing
             }
         ]
       }
     }
  in
    [ let 
        tname = "record view"
        result = view name alice
        expect = "Alice"
      in TestCase (assertEqual tname result expect)
    , let 
        tname = "record fmap view"
        result = view (address #> city) alice
        expect = Just "Shanghai"
      in TestCase (assertEqual tname result expect)
    , let
        tname = "record multiple fmap view"
        result = view (address #> zipInfos #> self #> code) alice
        expect = Just [Just "200000", Just "200002"]
      in TestCase (assertEqual tname expect result)
    , let
        tname = "record multiple fmap edit"
        newAlice =  over (address #> zipInfos #> self #> code) (++ "uwu") alice
        result = view (address #> zipInfos #> self #> code) newAlice
        expect = Just [Just "200000uwu", Just "200002uwu"]
      in TestCase (assertEqual tname expect result)
    ]

main :: IO ()
main = do
  let mytests = TestList $ 
        [ testListSet_1
        ,  testListSet_2
        , testListSet_3
        , testTuple_1
        , testTuple_2
        ]
         ++ recordTests
  results <- runTestTT mytests
  if errors results + failures results == 0 then
      exitSuccess
  else
      exitWith (ExitFailure 1)
