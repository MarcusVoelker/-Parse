{-|
Module      : Text.LParse.TokenStream
Description : Underlying data structure for sequential parsing
Copyright   : (c) Marcus Völker, 2017
License     : MIT
Maintainer  : marcus.voelker@rwth-aachen.de

This module contains the `TokenStream` class, an abstraction of lists, similar to `Traversable`, but geared for use with LParse
-}
module Text.LParse.TokenStream where 

import Data.Maybe
import Data.Traversable

-- | `TokenStream` abstracts a list, i.e., something that has a next element to process and a rest afterwards
class (Functor t, Foldable t) => TokenStream t where
    -- | `top` gives the next element to process. Similar to `head`
    top :: t a -> a
    -- | `rest` gives what is left after processing `top`. Similar to `tail`
    rest :: t a -> t a
    -- | `nil` gives the empty `TokenStream`. Similar to `[]`
    nil :: t a
    -- | `cons` prepends an element to the `TokenStream`. Similar to `(:)`
    cons :: a -> t a -> t a

instance TokenStream [] where
    top = head
    rest = tail
    nil = []
    cons = (:)

instance TokenStream Maybe where
    top = fromJust
    rest = const Nothing
    nil = Nothing
    cons a _ = Just a

-- | `TokenStream` version of `drop` 
skipN :: (TokenStream s) => Int -> s a -> s a
skipN 0 x = x
skipN n x = rest $ skipN (n-1) x

-- | `TokenStream` version of `zip`
sZip :: (TokenStream s) => s a -> s b -> s (a,b)
sZip = sZipWith (,)

-- | `TokenStream` version of `zipWith`
sZipWith :: (TokenStream s) => (a -> b -> c) -> s a -> s b -> s c
sZipWith f l r | null l || null r = nil
               | otherwise      = f (top l) (top r) `cons` (sZipWith f (rest l) (rest r))

-- | `TokenStream` version of `filter`
sFilter :: (TokenStream s) => (a -> Bool) -> s a -> s a
sFilter c x | null x = nil
            | c (top x) = (top x) `cons` sFilter c (rest x)
            | otherwise = sFilter c (rest x)