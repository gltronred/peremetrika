{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE TupleSections #-}

module Lib where

import           Types

import           Control.Monad.IO.Class
import           Data.Aeson
import qualified Data.ByteString.Lazy.Char8 as B
import           Data.Function
import           Data.HashMap.Strict (HashMap)
import qualified Data.HashMap.Strict as HM
import           Data.IntMap (IntMap)
import qualified Data.IntMap as M
import           Data.List
import           Data.Ord
import qualified Data.Text as ST
import qualified Data.Text.Lazy as T
import qualified Data.Text.IO as TIO
import           System.Environment
import           System.Process
import           Text.Ginger
import           Text.Printf
import qualified Web.Scotty as S

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

toId k = (k+3)`div`2`mod`4

flowXml :: IM (Int, IM Double) -> String
flowXml =
  brack "routes" .
  M.foldlWithKey' (\acc k ident -> acc ++ mkFlow k ident) "" .
  M.map fst
  where brack t s = concat ["<", t, ">", s, "</", t, ">"]
        mkFlow k ident = let
          ks = show $ toId k
          probs = printf "%0.3f" $ fromIntegral ident / (60::Double)
          in concat
             [ "<flow id=\"", ks, "\" from=\"", ks, "c\" begin=\"0\" end=\"3600\" probability=\"", probs,"\"/>"]

mkEdge :: (Int, Double) -> String
mkEdge (to, p) = concat
  [ "<toEdge id=\"c", show $ toId to,"\" probability=\"", ps,"\"/>" ]
  where ps = printf "%0.3f" p

mkEdgeGroups :: (Int, IM Double) -> String
mkEdgeGroups (from, m) = concat
  [ "<fromEdge id=\"", show $ toId from, "c\">"
  , concatMap mkEdge (M.assocs m)
  , "</fromEdge>"
  ]

turnsXml :: IM (Int, IM Double) -> String
turnsXml m = let
  ms = M.assocs $ M.map snd m
  in concat $
     [ "<turns>"
     , "<interval begin=\"0\" end=\"3600\" >"] ++
     map mkEdgeGroups ms ++
     [ "</interval>"
     , "<sink edges=\"c0 c1 c2 c3\"/>"
     , "</turns>"
     ]

pereMain :: IO ()
pereMain = do
  -- get params
  [dpFile, jtrRouter, sumo, conv] <- getArgs
  Right dp <- fmap (toPercents . toState) . eitherDecode <$> B.readFile dpFile
  writeFile "flow.xml" $ flowXml dp
  writeFile "turns.xml" $ turnsXml dp

  -- ginger template loading
  let resolver = fmap Just . readFile
  Right tpl <- parseGingerFile resolver "small.net.xml.j2"

  -- run web server
  S.scotty 8080 $ do
    S.post "/query" $ do
      speed <- S.param "speed"
      [tl1,tl2,tl3,tl4] <- fmap (/3.6) <$> S.param "svetofor"
      -- apply template
      let context = HM.fromList
            [ ("speed" :: ST.Text, ST.pack $ show (speed :: Double))
            , ("tl1", ST.pack $ show (tl1 :: Double))
            , ("tl2", ST.pack $ show tl2)
            , ("tl3", ST.pack $ show tl3)
            , ("tl4", ST.pack $ show tl4)
            ]
      liftIO $ TIO.writeFile "net.xml" $ easyRender context tpl

      -- create network params
      liftIO $ callProcess jtrRouter [ "-r", "flow.xml"
                                     , "-t", "turns.xml"
                                     , "-n", "net.xml"
                                     , "-b", "0"
                                     , "-e", "3600"
                                     , "-o", "routes.xml"]
      stat <- liftIO $ readProcess sumo [ "-n", "net.xml"
                                        , "-r", "routes.xml"
                                        , "--duration-log.statistics"
                                        , "--fcd-output","result.xml"
                                        ] ""
      res <- liftIO $ readFile "result.xml"
      Right fcd <- liftIO $
                   eitherDecode . B.pack <$> readProcess conv [] res
      S.json $ HM.fromList [ ("fcd" :: T.Text, fcd :: Value)
                           , ("stat", String $
                                      T.unlines $
                                      reverse $ take 20 $ reverse $
                                      T.lines $
                                      T.toStrict $ T.pack stat) ]
  putStrLn "Hello world!"

