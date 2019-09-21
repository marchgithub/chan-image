module Main where

import qualified Data.ByteString.Lazy.Char8 as L8
import Control.Applicative
import Control.Monad
import Data.Maybe
import Network.HTTP.Simple
import System.Environment
import System.IO
import System.Directory
import Chan

main :: IO ()
main = do
    [url, folderName] <- getArgs
    response <- httpLBS . parseRequest_ $ url
    let thread = fromJust . parseThread . getResponseBody $ response
    let posts = op_post thread : reply_posts thread
    createDirectoryIfMissing False folderName
    withCurrentDirectory folderName $ downloadImages posts

downloadImages :: [Post] -> IO ()
downloadImages posts = do
    let fileinfo = catMaybes $ imgURL <$> posts
    downloadToFile `mapM_` fileinfo

downloadToFile :: (FileName, FileURL) -> IO ()
downloadToFile (url, filename) = do
    let putFile handle = getResponseBody <$> (httpLBS . parseRequest_ . L8.unpack $ url) >>= L8.hPutStr handle
    putStrLn $ "Downloading " ++ show filename
    withBinaryFile (L8.unpack filename) WriteMode putFile

