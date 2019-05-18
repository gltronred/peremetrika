{-# LANGUAGE DeriveGeneric #-}

module Types where

import Data.IntMap (IntMap)
import Data.Map (Map)
import Data.Time
import GHC.Generics

type LaneId = Int

data Graph v e = Graph
  { gVertices :: IntMap v
  , gEdges :: Map (Int,Int) e
  } deriving (Eq,Show,Read)

data ElType
  = Car
  | Bus
  | Person
  deriving (Eq,Show,Read,Generic)

data FlowEl = FlowEl
  { feType :: ElType
  , feArrival :: UTCTime
  , feSrc :: Int
  , feTgt :: Int
  } deriving (Eq,Show,Read,Generic)

data Part = Part
  { pType :: ElType
  , pFlowEl :: FlowEl
  , pt, v :: Pt
  } deriving (Eq,Show,Read,Generic)

data LightMode
  = Red
  | Yellow
  | Green
  deriving (Eq,Show,Read,Generic)

type Pt = (Double,Double)

data Edge = Edge
  { eLight :: LightMode
  , eParts :: [Part]
  } deriving (Eq,Show,Read,Generic)

data State = State
  { sCrossroad :: Graph [FlowEl] Edge
  } deriving (Eq,Show,Read,Generic)

