{-# LANGUAGE DeriveGeneric #-}

module Types where

import Data.Aeson
import Data.IntMap (IntMap)
import GHC.Generics

data Input = Input
  { iSrc :: Int
  , iDst :: Int
  , iCount :: Int
  } deriving (Eq,Show,Read,Generic)

instance FromJSON Input where
  parseJSON = genericParseJSON opts
instance ToJSON Input where
  toJSON = genericToJSON opts
  toEncoding = genericToEncoding opts

data VehType
  = Car
  | Person
  deriving (Eq,Show,Read,Generic)

instance ToJSON VehType

data Vehicle = Vehicle
  { vX, vY :: Double
  , vAngle :: Double
  , vType :: VehType
  } deriving (Eq,Show,Read,Generic)

instance ToJSON Vehicle where
  toJSON = genericToJSON opts
  toEncoding = genericToEncoding opts

data Output = Output
  { oTime :: Double
  , oVehicles :: [Vehicle]
  } deriving (Eq,Show,Read,Generic)

instance ToJSON Output where
  toJSON = genericToJSON opts
  toEncoding = genericToEncoding opts

opts :: Options
opts = defaultOptions
  { fieldLabelModifier = camelTo2 '-' . drop 1 }

type State = IntMap (IntMap Int)

type IM = IntMap


