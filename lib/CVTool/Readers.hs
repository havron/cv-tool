{-# LANGUAGE DeriveGeneric #-}

module CVTool.Readers (readJson, readYaml, readToml) where

import Data.Aeson as Ae (eitherDecode', FromJSON(..), toJSON, fromJSON, Result(..))
import Data.ByteString
import Data.Either
import Data.Text (Text)
import Data.Yaml (decodeEither)
import GHC.Generics
import System.Exit
import Text.Pandoc (readNative, Pandoc(..))
import Text.Parsec
import Text.Toml

data CVData = CVData {
  name :: String
} deriving (Generic, Show)

instance FromJSON CVData

buildPandoc :: (a -> Either String CVData) -> a -> Pandoc
buildPandoc parser rawData = 
  case parser rawData of
        Right cvData -> Pandoc metaCvData []
        -- TODO: Actually print exception
        Left errMsg  -> Prelude.head $ Data.Either.rights [readNative "hello"]
  where metaCvData = Meta fold

tomlToJson :: Text -> Result CVData
tomlToJson inputData = 
  case parseTomlDoc "InputCVData" inputData of
        Right toml  -> fromJSON . toJSON $ toml
        Left err    -> Ae.Error $ "TOML parse error:" ++ (show $ errorPos err)

eitherDecodeToml inputData = 
  case tomlToJson inputData of
        Success jsonData             -> Right jsonData
        Ae.Error err         -> Left $ "TOML parse error:" ++ err

readJson = buildPandoc eitherDecode'
readYaml = buildPandoc decodeEither
readToml = buildPandoc eitherDecodeToml