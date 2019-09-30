module Chan.Types
    ( Post(..)
    , Thread(..)
    , FileName
    , FileURL
    ) where

import qualified Data.ByteString.Lazy.Char8 as L8

type FileName = L8.ByteString
type FileURL = L8.ByteString

data Post = Post
    { id :: L8.ByteString
    , content :: L8.ByteString
    , imgURL :: Maybe (FileURL, FileName)
    } deriving (Show)

data Thread = Thread
    { op_post :: Post
    , reply_posts :: [Post]
    } deriving (Show)
