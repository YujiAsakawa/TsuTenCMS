# -*- coding: utf-8 -*-
require 'pp'
require 'cgi'
#require 'moji'
require 'nkf'

module Util
   Encoding.default_external = 'UTF-8'
   Z_ASCII = %w[！ ” ＃ ＄ ％ ＆ ’ （ ） ＊ ＋ ， － ． ／ ０ １ ２ ３ ４ ５ ６ ７ ８ ９ ： ； ＜ ＝ ＞ ？ ＠ Ａ Ｂ Ｃ Ｄ Ｅ Ｆ Ｇ Ｈ Ｉ Ｊ Ｋ Ｌ Ｍ Ｎ Ｏ Ｐ Ｑ Ｒ Ｓ Ｔ Ｕ Ｖ Ｗ Ｘ Ｙ Ｚ ［ ］ ＾ ＿ ‘ ａ ｂ ｃ ｄ ｅ ｆ ｇ ｈ ｉ ｊ ｋ ｌ ｍ ｎ ｏ ｐ ｑ ｒ ｓ ｔ ｕ ｖ ｗ ｘ ｙ ｚ ｛ ｜ ｝ ￣]
   Z_YEN = %w[￥]
   Z_KANA = %w[ァ ア ィ イ ゥ ウ ェ エ ォ オ カ キ ク ケ コ サ シ ス セ ソ タ チ ッ ツ テ ト ナ ニ ヌ ネ ノ ハ ヒ フ ヘ ホ マ ミ ム メ モ ャ ヤ ュ ユ ョ ヨ ラ リ ル レ ロ ヮ ワ ヰ ヱ ヲ ン ヵ ヶ]
   Z_GANA = %w[ガ ギ グ ゲ ゴ ザ ジ ズ ゼ ゾ ダ ヂ ヅ デ ド バ パ ビ ピ ブ プ ベ ペ ボ ポ ヴ]
   Z_KIGO = %w[。 「 」 、 ゛ ゜ ー ・]
   ZEN = Z_ASCII + Z_YEN + Z_KANA + Z_GANA + Z_KIGO
   Z_CONV_TEXT = Z_ASCII.join('') + 'ヮヰヱヵヶ￥'

   H_ASCII = %w[! " # $ % & ' ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [ ] ^ _ ` a b c d e f g h i j k l m n o p q r s t u v w x y z { | } ~]
   H_YEN = %w[\\]
   H_KANA = %w[ｧ ｱ ｨ ｲ ｩ ｳ ｪ ｴ ｫ ｵ ｶ ｷ ｸ ｹ ｺ ｻ ｼ ｽ ｾ ｿ ﾀ ﾁ ｯ ﾂ ﾃ ﾄ ﾅ ﾆ ﾇ ﾈ ﾉ ﾊ ﾋ ﾌ ﾍ ﾎ ﾏ ﾐ ﾑ ﾒ ﾓ ｬ ﾔ ｭ ﾕ ｮ ﾖ ﾗ ﾘ ﾙ ﾚ ﾛ ﾜ ﾜ ｲ ｴ ｦ ﾝ ｶ ｹ]
   H_GANA = %w[ｶﾞ ｷﾞ ｸﾞ ｹﾞ ｺﾞ ｻﾞ ｼﾞ ｽﾞ ｾﾞ ｿﾞ ﾀﾞ ﾁﾞ ﾂﾞ ﾃﾞ ﾄﾞ ﾊﾞ ﾊﾟ ﾋﾞ ﾋﾟ ﾌﾞ ﾌﾟ ﾍﾞ ﾍﾟ ﾎﾞ ﾎﾟ ｳﾞ]
   H_KIGO = %w[｡ ｢ ｣ ､ ﾞ ﾟ ｰ ･]
   HAN = H_ASCII + H_YEN + H_KANA + H_GANA + H_KIGO
   H_CONV_TEXT = H_ASCII.join('') + 'ﾜｲｴｶｹ\\'

   private
   def normalize(text)
      z2h(CGI::escapeHTML(CGI::unescapeHTML(text)))
   end

   def z2h(text)
#      text.tr!(Z_CONV_TEXT, H_CONV_TEXT)
      NKF.nkf('-WwX', text)
#      -j -s -e -w -w16 出力するエンコーディングを指定する
#        -j ISO-2022-JP (7bit JIS) を出力する(デフォルト)
#        -s Shift_JIS を出力する
#        -e EUC-JP を出力する
#        -w UTF-8 を出力する(BOMなし)
#        -w16 UTF-16 LE を出力する
#      -J -S -E -W -W16 入力文字列のエンコーデイングの推定値を指定する。
#        -J 入力に JIS を仮定する
#        -S 入力に Shift_JIS と X0201片仮名(いわゆる半角片仮名)
#           を仮定する。-xを指定しない場合はX0201片仮名(いわゆる半角片仮名)はX0208の
#           片仮名(いわゆる全角片仮名)に変換される
#        -E 入力に EUC-JP を仮定する
#        -W 入力に UTF-8 を仮定する
#        -W16 入力に UTF-16LE を仮定する
#      -Z[0-3] X0208 アルファベットを ASCII に変換する
#        -Z -Z0 X0208 アルファベットを ASCII に変換する
#        -Z1 X0208空白(いわゆる全角空白)を ASCII の空白に変換する
#        -Z2 X0208空白(いわゆる全角空白)を ASCII の空白2つに変換する
#        -Z3 X0208の＞、＜、”、＆、を '&gt;', '&lt;', '&quot;', '&amp;' に変換する
#        -Z4 X0208片仮名(いわゆる全角片仮名) をJIS X 0201片仮名(いわゆる半角片仮名) に変換する
#      -X X0201片仮名(いわゆる半角片仮名)をX0208の片仮名(いわゆる全角片仮名)に変換する
#      -x X0201片仮名(いわゆる半角片仮名)をX0208の片仮名(いわゆる全角片仮名)に変換せずに
#         出力する。ISO-2022-JP で出力するときは ESC-(-I を、EUC-JPで出力するときは SSO を使う。
   end

   def truncate(text)
      text = "#{text[0, 14]}…" if 15 < text.size
      text
   end
   
   def get_color
      '' #IO.read(@dname + 'color.css')[/color:\s*(.+)\s*;/, 1] TODO: get_color 廃止
   end

   def include_file(text)
      html = ''
      case text
      when /\A(.+\.(?:jpg|jpeg|png|gif|bmp)):?(.*)/
         image = $1
         caption = $2
         html << mk_image(image, caption)
      else
         include_fname = dname + text
         if FileTest.exist? include_fname
            html << File.read(include_fname)
         else
            raise StandardError, "#{include_fname} が見つかりません。".encode(TEXT_CODE)
         end
      end
      html
   end

   def mk_image(image, caption)
      tag = ''
      tag << %!<img src="#{image}" /><br />\n!
      if caption and !caption.empty?
         tag << "#{caption}<br />\n"
      end
      tag
   end
end
