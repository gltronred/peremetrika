{-# LANGUAGE TupleSections #-}

module Lib where

import Types

import Data.Function
import qualified Data.IntMap as M
import Data.IntMap (IntMap)
import Data.List
import Data.Ord

toIM :: (a -> Int) -> (a -> b) -> [a] -> IntMap [b]
toIM getKey getEl =
  M.fromList .
  map (\i -> (getKey $ head i, map getEl i)) .
  groupBy ((==)`on`getKey) .
  sortBy (comparing getKey)

toState :: [Input] -> State
toState = M.map (M.map head . toIM iDst iCount) . toIM iSrc id

toPercents :: State -> IM (Int, IM Double)
toPercents = M.map $ \m -> let
  s = M.foldr (+) 0 m
  in (s,) $ M.map ((/fromIntegral s) . fromIntegral) m

pereMain :: IO ()
pereMain = do
  putStrLn "Hello world!"

