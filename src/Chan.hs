{-# LANGUAGE OverloadedStrings #-}
module Chan
    ( Post(..)
    , Thread(..)
    , parseThread
    , FileName
    , FileURL
    ) where

import Chan.Types

import Text.HTML.Scalpel
import Control.Applicative
import Control.Monad(guard)
import qualified Data.ByteString.Lazy.Char8 as L8

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

        -- alternatives below are defined depending on where to find the
        -- filename
        spoilered = do
            filename <- attr "title" fileText
            guard (filename /= L8.empty)
            return filename

        nameTooLong = do
            filename <- attr "title" fileLink
            guard (filename /= L8.empty)
            return filename

        notSpoilered = text fileLink

        fileText =  "div" @: [hasClass "fileText"]
        fileLink =  fileText //  "a"

        postContainers = "div" @: [hasClass "postContainer"]
