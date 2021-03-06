{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PartialTypeSignatures #-}
{-# LANGUAGE MultiWayIf #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE RecursiveDo #-}
{-# LANGUAGE CPP #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
module DocumentData where

import Control.Lens hiding (reviews)
import Control.Monad
import Control.Monad.Fix
import Control.Monad.IO.Class
import Data.Text (Text)
import qualified Data.Text as T
import Reflex.Dom.Core
import Data.Char

import Common.TR

type ReaderDocumentData =
  (ReaderDocumentId, Text, (Int, Maybe Int), Int
   , [(Int, AnnotatedPara)])


dummyData :: ReaderDocumentData
dummyData = (ReaderDocumentId 1, "dummy", (1, Nothing), endPara, annText)
  where
    endPara = length longText1
    annText = zip [1..] longText1

longText1 = take 100 $ concat $ repeat $ map oneLine plainText1
  where
    oneLine = map oneChar . T.unpack
    oneChar c = if isKana c
      then Left (T.singleton c)
      else Right
        (Vocab [KanjiWithReading (Kanji $ T.singleton c) (T.singleton 'い')]
        , [], False)


-- 3040 - 30ff
isKana c = c > l && c < h
  where l = chr $ 12352
        h = chr $ 12543

-- 3400 - 9faf
isKanji c = c > l && c < h
 where l = chr $ 13312
       h = chr $ 40879

plainText1 =
  [ "東京オリンピック・パラリンピックをめぐり、安倍総理大臣は、ＩＯＣ＝国際オリンピック委員会のバッハ会長と電話会談し、１年程度の延期を提案したのに対し、バッハ会長は、全面的に同意する意向を示し、遅くとも来年夏までに開催することで合意しました。"
  , "安倍総理大臣は、24日夜８時から、およそ45分間、総理大臣公邸で、ＩＯＣのバッハ会長と電話会談を行い、大会組織委員会の森会長や東京都の小池知事、橋本担当大臣らも同席しました。"
  , "会談で、安倍総理大臣とバッハ会長は、選手や各国の競技団体などの意向を踏まえ、東京オリンピック・パラリンピックの中止はないということを確認しました。"
  , "そして、安倍総理大臣が、「開催国・日本として、現下の状況を踏まえ、世界のアスリートの皆さんが最高のコンディションでプレーでき、観客の皆さんにとって、安全で安心な大会とするためにおおむね１年程度延期することを軸に検討してもらいたい」と述べたのに対し、バッハ会長は、「100％同意する」と述べ、東京大会は延期せざるをえないという認識で一致しました。"
  , "そして、安倍総理大臣とバッハ会長は、ＩＯＣと大会組織委員会、東京都など、関係機関が一体となり、遅くとも来年夏までに開催することで合意しました。"
  , "会談のあと、安倍総理大臣は記者団に対し「今後、人類が新型コロナウイルス感染症に打ち勝った証しとして完全な形で東京大会を開催するためにバッハ会長と緊密に連携していくことで一致した。日本は、開催国の責任をしっかりと果たしていきたい」と述べました。"
  , "山梨県の長崎知事は臨時の会見を開き、県内で新型コロナウイルスへの感染が拡大している状況などを踏まえ、県立学校の休校措置を当初の予定より２週間ほど伸ばし、今月19日まで延長することを明らかにしました。小中学校については地域の実情などに応じて各市町村が判断するとしたうえで、再開する場合は感染症対策に万全を期すよう呼びかけています。"
  , "長崎知事は５日、県庁で臨時の会見を開き、「感染拡大防止に万全を期すため県立学校の休業を今月19日まで延長することを要請した。県内でここ数日に確認された感染者の中に感染経路がわからない人がいることや、公共交通機関での感染リスクが高いことなどから再開を遅らせる」と述べました。"
  , "県教育委員会によりますと、今月19日まで休校措置が延期されるのは県立高校30校と特別支援学校11校で、再開については県の衛生管理部局とともに状況を見極めながら改めて判断するとしています。"
  , "県内の小中学校については地域の実情などに応じて管轄する各市町村が判断するとしたうえで、６日以降、入学式や始業式を開催する場合は感染症対策に万全を期すよう呼びかけました。"
  , "さらに長崎知事は、感染者や濃厚接触者の行動などが把握できていないとして、中央市が市内の８つの小中学校の再開を今月19日まで見送るほか、ほかにも再開の延長を検討している自治体があることを明らかにしました。"
  , "新型コロナウイルスの患者が重症化した場合に行われる集中治療について日本集中治療医学会は、医療体制の崩壊が非常に早く訪れるおそれがあるとして、専門知識や経験のある医師などを早急に確保すべきだとする緊急声明を出しました。"
  , "専門の医師などで作る日本集中治療医学会は今月１日に緊急声明を発表しました。"
  , "それによりますと、先月末の時点でイタリアの死亡率は11.7％だったのに対しドイツでは1.1％で、これは主に集中治療の体制の違いが要因だとしています。"
  , "日本は人口10万当たりの集中治療のベッド数がイタリアの半分以下で、このままでは集中治療体制の崩壊が非常に早く訪れることも予想される、と危機感を示しています。"
  , "また、新型コロナウイルスの患者の場合、集中治療室では感染予防のため通常の４倍の看護師が必要だとしています。"
  , "さらに人工呼吸器や、症状が非常に重い患者に使われる「ＥＣＭＯ（エクモ）」と呼ばれる人工心肺装置などの機器を扱える医師や看護師が少ないと指摘しています。"
  , "このため、国内にあるおよそ6500床の集中治療室のうち、実際に新型コロナウイルスの患者に対応できるのは1000床に満たない可能性があるほか、台数を増やしたとしても今の体制では対応しきれないと指摘しています。"
  , "このため学会は、重症患者を治療した経験のある医師を早急に確保するなどして、集中治療体制を維持するためのあらゆる方策を考えるべきだと訴えています。"
  , "取り出した血液に直接酸素を送り込むことで肺の機能を一時的に代行する高度な治療で、装着中、肺を休ませることで回復につなげようとするものです。"
  , "日本集中治療医学会によりますと、先月30日の時点で、国内では新型コロナウイルスによる肺炎患者少なくとも40人がＥＣＭＯによる治療を受け、このうちおよそ半数の19人が回復に向かった一方、６人は死亡したということです。"
  , "学会によりますと、ＥＣＭＯは国内におよそ1400台ありますが、装着や管理に専門的な技術が必要なため対応できる医師や看護師に限りがあり、新型コロナウイルスの患者に対応できるのはおよそ500人分ほどだとしています。"
  , "政府は緊急経済対策や今年度の補正予算に対策費を計上し、メーカーに増産を呼びかけるほか、装置を扱える人材を育成して派遣する体制を整備する方針です。"
  ]
