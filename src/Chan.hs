{-# LANGUAGE OverloadedStrings #-}
module Chan
    ( Post(..)
    , Thread(..)
    , parseThread
    , FileName
    , FileURL
    ) where

import Text.HTML.Scalpel
import Control.Applicative
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

parseThread :: L8.ByteString -> Maybe Thread
parseThread body = scrapeStringLike body thread
    where
        thread :: Scraper L8.ByteString Thread
        thread =
            Thread <$> chroot postContainers opPost
                   <*> chroots postContainers replyPost

        opPost =
            Post <$> attr "id" ("div" @: [hasClass "opContainer"])
                 <*> text "blockQuote"
                 <*> (getFileURL <|> empty)

        replyPost =
            Post <$> attr "id" ("div" @: [hasClass "replyContainer"])
                 <*> text "blockQuote"
                 <*> (getFileURL <|> empty)

        getFileURL =
            Just <$> ((,) <$> ((L8.append "http:") <$> attr "href" fileLink)
                          <*> (spoilered <|> nameTooLong <|> notSpoilered))

        spoilered = do
            filename <- attr "title" fileText
            if filename == L8.empty
                then empty
                else return filename

        nameTooLong = do
            filename <- attr "title" fileLink
            if filename == L8.empty
                then empty
                else return filename

        notSpoilered = text fileLink

        fileText =  "div" @: [hasClass "fileText"]
        fileLink =  fileText //  "a"

        postContainers = "div" @: [hasClass "postContainer"]
