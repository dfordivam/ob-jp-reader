{-# LANGUAGE TypeSynonymInstances #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE StandaloneDeriving #-}

module Common.TR
  where

import Control.Lens hiding (reviews)
import Data.Aeson hiding (Value)
import Data.Default
import Data.Int
import Data.Text (Text)
import Data.Time.Calendar
import Data.List.NonEmpty (NonEmpty(..))
import qualified Data.Text as T
import Data.These
import Data.Vector (Vector)
import GHC.Generics

tshow :: (Show a) => a -> Text
tshow = (T.pack . show)

newtype Kanji = Kanji { unKanji :: Text }
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

newtype Rank = Rank { unRank :: Int }
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

newtype Meaning = Meaning { unMeaning :: Text }
  deriving (Eq, Generic, Show, ToJSON, FromJSON)

newtype MeaningNotes = MeaningNotes { unMeaningNotes :: Text }
  deriving (Eq, Generic, Show, ToJSON, FromJSON)

newtype Reading = Reading { unReading :: Text }
  deriving (Eq, Generic, Show, ToJSON, FromJSON)

newtype ReadingNotes = ReadingNotes { unReadingNotes :: Text }
  deriving (Eq, Generic, Show, ToJSON, FromJSON)

newtype Grade = Grade { unGrade :: Int }
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

newtype StrokeCount = StrokeCount { unStrokeCount :: Int }
  deriving (Eq, Generic, Show, ToJSON, FromJSON)

newtype JlptLevel = JlptLevel { unJlptLevel :: Int }
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

newtype WikiRank = WikiRank { unWikiRank :: Int }
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

newtype WkLevel = WkLevel { unWkLevel :: Int }
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

newtype RadicalId = RadicalId { unRadicalId :: Int }
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

newtype KanjiId = KanjiId { unKanjiId :: Int }
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

type VocabId = Int
-- newtype VocabId = VocabId { unVocabId :: Int }
--   deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON, Binary, Value)

newtype SrsEntryId = SrsEntryId { unSrsEntryId :: Int64 }
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

newtype SentenceId = SentenceId { unSentenceId :: Int64 }
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

newtype SrsLevel = SrsLevel { unSrsLevel :: Int }
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

newtype Vocab = Vocab { unVocab :: [KanjiOrKana] }
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

data KanjiOrKana
  = KanjiWithReading Kanji Text
  | Kana Text
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

vocabToKana :: Vocab -> Text
vocabToKana (Vocab ks) = mconcat $ map getFur ks
  where
    getFur (KanjiWithReading _ t) = t
    getFur (Kana t) = t

vocabToText :: Vocab -> Text
vocabToText (Vocab ks) = mconcat $ map f ks
  where f (KanjiWithReading (Kanji k) _) = k
        f (Kana k) = k

getVocabField:: Vocab -> Text
getVocabField (Vocab ks) = mconcat $ map f ks
  where f (Kana t) = t
        f (KanjiWithReading k _) = unKanji k

data KanjiDetails = KanjiDetails
  { _kanjiId             :: KanjiId
  , _kanjiCharacter      :: Kanji
  , _kanjiGrade          :: Maybe Grade
  , _kanjiMostUsedRank   :: Maybe Rank
  , _kanjiJlptLevel      :: Maybe JlptLevel
  , _kanjiOnyomi         :: [Reading]
  , _kanjiKunyomi        :: [Reading]
  , _kanjiNanori         :: [Reading]
  , _kanjiWkLevel        :: Maybe WkLevel
  , _kanjiMeanings       :: [Meaning]
  }
  deriving (Eq, Generic, Show, ToJSON, FromJSON)


data VocabDetails = VocabDetails
  { _vocabId             :: VocabId
  , _vocab               :: Vocab
  , _vocabIsCommon       :: Bool
  , _vocabFreqRank       :: Maybe Rank
  , _vocabMeanings       :: [Meaning]
  }
  deriving (Generic, Show, ToJSON, FromJSON)

data SentenceData = SentenceData
  { _sentenceContents :: NonEmpty AnnotatedPara
  , _sentenceLinkedEng :: [Text]
  }
  deriving (Generic, Show, ToJSON, FromJSON)

data AdditionalFilter = AdditionalFilter
  { readingKana :: Text
  , readingType :: ReadingType
  , meaningText :: Text
  }
  deriving (Generic, Show, ToJSON, FromJSON)

instance Default AdditionalFilter where
  def = AdditionalFilter "" KunYomi ""

data ReadingType = OnYomi | KunYomi | Nanori
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

type SrsEntryField = NonEmpty Text

-- Used in Srs browse widget to show list of items
data SrsItem = SrsItem
 {
   srsItemId :: SrsEntryId
 , srsItemField :: SrsEntryField
 }
  deriving (Generic, Show, ToJSON, FromJSON)

data SrsReviewStats = SrsReviewStats
  { _srsReviewStats_pendingCount :: Int
  , _srsReviewStats_correctCount :: Int
  , _srsReviewStats_incorrectCount :: Int
  }
  deriving (Generic, Show, ToJSON, FromJSON)

instance Default SrsReviewStats where
  def = SrsReviewStats 0 0 0

data ReviewType =
    ReviewTypeRecogReview
  | ReviewTypeProdReview
  deriving (Eq, Ord, Enum, Bounded, Generic, Show, ToJSON, FromJSON)

type AnnotatedPara = [(Either Text (Vocab, [VocabId], Bool))]

type AnnotatedDocument = Vector AnnotatedPara

newtype ReaderDocumentId = ReaderDocumentId { unReaderDocumentId :: Int }
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

newtype BookId = BookId { unBookId :: Int }
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

newtype ArticleId = ArticleId { unArticleId :: Int }
  deriving (Eq, Ord, Generic, Show, ToJSON, FromJSON)

data ReaderSettings = ReaderSettings
  { _fontSize  :: Int
  , _rubySize  :: Int
  , _lineHeight :: Int
  , _verticalMode :: Bool
  , _numOfLines :: Int
  }
  deriving (Generic, Show, ToJSON, FromJSON)

instance Default ReaderSettings where
  def = ReaderSettings 120 105 150 False 400

capitalize :: Text -> Text
capitalize m = T.unwords $ T.words m & _head  %~ f
  where
    f t
      | T.head t == ('-') = t
      | elem t ignoreList = t
      | otherwise = T.toTitle t
    ignoreList = ["to", "a", "an"]

 -- showSense :: Sense -> Text
-- showSense s = mconcat
--       [ showPos $ s ^.. sensePartOfSpeech . traverse
--       , p $ s ^.. senseInfo . traverse
--       , showGlosses $ take 5 $ s ^.. senseGlosses . traverse . glossDefinition]
--   where
--     p [] = ""
--     p c = "(" <> (T.intercalate ", " c) <> ") "

--     showGlosses ms = T.intercalate ", " $ map capitalize ms

--     showPos ps = p psDesc
--       where
--         psDesc = catMaybes $ map f ps
--         f PosNoun = Just $ "Noun"
--         f PosPronoun = Just $ "Pronoun"
--         f (PosVerb _ _) = Just $ "Verb"
--         f (PosAdverb _) = Just $ "Adv."
--         f (PosAdjective _) = Just $ "Adj."
--         f PosSuffix = Just $ "Suffix"
--         f PosPrefix = Just $ "Prefix"
--         f _ = Nothing

-- SrsEntry

newtype SrsInterval = SrsInterval { unSrsInterval :: Integer }
  deriving (Generic, Show, ToJSON, FromJSON)

-- If the user suspends a card and then resume later
-- 1. It was due when suspended -> make immediately available for review
-- 2. not due -> no suspend?

data SrsEntryState = NewReview |
  Suspended SrsInterval | NextReviewDate Day SrsInterval
  deriving (Generic, Show, ToJSON, FromJSON)

-- SRS algo
-- Correct Answer ->
--   (answer date - due date + last interval) * ease factor
-- Wrong Answer ->
--   last interval * ease factor

-- ease factor depends on SrsEntryStats

data SrsEntryStats = SrsEntryStats
  { _failureCount :: Int
  , _successCount :: Int
  } deriving (Generic, Show, ToJSON, FromJSON)

-- By Default do
-- Prod + Recog(M + R) for Vocab with kanji in reading (Can be decided on FE)
-- Prod + Recog(M) for Vocab with only kana reading
-- Recog - for Kanji review
--
-- The default field will be chosen
-- 1. From user entered text
-- 2. Vocab with maximum kanjis
data SrsEntry = SrsEntry
  {  _reviewState :: These (SrsEntryState, SrsEntryStats) (SrsEntryState, SrsEntryStats)
  -- XXX Does this require grouping
  -- readings also contain other/alternate readings
   , _readings :: NonEmpty Reading
   , _meaning :: NonEmpty Meaning
   , _readingNotes :: Maybe ReadingNotes
   , _meaningNotes :: Maybe MeaningNotes
   , _field :: SrsEntryField
  } deriving (Generic, Show, ToJSON, FromJSON)

-- APIs -- may be move from here


-- isSameAs t1 t2
--   | T.length t1 == T.length t2 = all compareChars (zip (T.unpack t1) (T.unpack t2))
--   | otherwise = False

-- isSameAsC c1 c2 = compareChars (c1, c2)

-- compareChars = f
--   where
--     f ('ヶ', c2) = elem c2 ['か', 'が','ヶ', 'ケ']
--     f ('ケ', c2) = elem c2 ['か', 'が','ヶ', 'ケ']
--     f (c1, c2) = c1 == c2

makeLenses ''ReaderSettings
