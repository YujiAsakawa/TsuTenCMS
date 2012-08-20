# -*- coding: utf-8 -*-
require 'content'

class Content
   attr_reader :dname, :text, :footer_name, :color
   public :trim_null_line, :parse, :navigation, :footer
end

NULL_LINE = <<EOB
■こだわり社長の成功統計学
§アナタと同じ顔に出逢ったことありますか？
〓nill_line〓
朝、出勤していると、六本木ヒルズのJ-WAVEスタジオからラジオの声が聞こえてきた・・・

『今から出すクイズは、正解も不正解もありません。』


僕「正解がないクイズってなんだよ？」
EOB

FOOTER_CHECK = <<EOB
</td></tr>
<tr><td>&nbsp;</td></tr>
<tr><td class=script>
この情報のモトになっているネタはこちら<br />
携帯用 <br />
<a href="http://merumo.ne.jp/00567198.html">http://merumo.ne.jp/00567198.html</a><br />
PC用 <br />
<a href="http://archive.mag2.com/0001016240/index.html">http://archive.mag2.com/0001016240/index.html</a><br />
EOB

BASE = 'read/diet/'

describe Content do
   before(:each) do
      @series = Series.new(BASE, NaviMenu.new('2010-12-3'))
      @ttc = Content.new(BASE + 'diet_0001.txt', @series, true)
   end

   describe '初期化' do #NO_SPEC: 日付を直接指定する場合
      it { @ttc.body.should be_an_instance_of String }

      describe 'dnameを知っている' do
         it { @ttc.dname.should == BASE }
      end
      describe 'top_pathを知っている' do
         it { @ttc.top_path.should == 'diet_top.html' }
      end
      describe 'titleを知っている' do
         it { @ttc.title.should == '楽しいダイエットの世界へようこそ！' }
      end
      describe 'シリーズタイトルを知っている' do
         it { @ttc.series.should == 'キモチからダイエット' }
      end
      describe '執筆者を知っている' do
         it { @ttc.author == 'kobayashi' }
      end
      describe 'file_header を知っている' do
         it { @ttc.file_header.should == 'diet' }
      end
      describe 'footer_name を知っている' do
         it { @ttc.footer_name.should == 'read/diet/diet_footer.html' }
      end
      #      describe 'シリーズカラーを知っている' do TODO: 廃止
      #         it { @ttc.color.should == 'CornFlowerBlue'}
      #      end
   end

   describe 'プライベートメソッドで' do
      describe '本文冒頭の空行を削除できる' do
         it do
            null = NULL_LINE.sub("〓nill_line〓\n", "\n\n")
            unnull = NULL_LINE.sub("〓nill_line〓\n", "")
            @ttc.trim_null_line(null).should == unnull
         end
      end
   end

   describe '外部インターフェイスとして' do
      describe '同値性を比較できる' do #NO_SPEC: NaviMenu と日付の兼ね合いを再検討
         it do
            @ttc.should == Content.new(BASE + 'diet_0001.txt', @series, true)
         end
         it do
            @ttc.should_not == Content.new(BASE + 'diet_0002.txt', @series, true)
         end
         it do
            @ttc.should_not == Content.new(BASE + 'diet_0001.txt', Series.new(BASE, NaviMenu.new('2010-12-4')), true)
         end
         it do
            @ttc.should_not == Content.new(BASE + 'diet_0001.txt', @series, false)
         end
      end

      describe 'ソートできる' do
         it do
            [ Content.new(BASE + 'diet_0002.txt', Series.new(BASE, NaviMenu.new('2010-12-10'))),
               Content.new(BASE + 'diet_0003.txt', Series.new(BASE, NaviMenu.new('2010-12-17'))),
               Content.new(BASE + 'diet_0001.txt', @series)
            ].sort.map(&:number).should == [1,2,3]
         end
      end
      describe 'fnameを知っている' do
         it { @ttc.fname.should == BASE + 'diet_0001.txt' }
      end
      describe 'numberを知っている' do
         it { @ttc.number.should == 1 }
      end
      describe '新規登録日を知っている' do
         it { @ttc.date.should == '12/3' }
      end
      describe 'htmlのパスを生成できる' do
         it { @ttc.html_path.should == BASE + 'diet_0001.html' }
      end
      describe '表題を生成できる' do
         it { @ttc.heading.should == '■No.1 楽しいダイエットの世界へようこそ！(12/3)' }
      end
      describe '表題リンクを生成できる' do
         it { @ttc.link.should == '<h3 class="link_caption clearfix"><a href="diet_0001.html"><span class="mini orange">1</span>&nbsp;&nbsp;<span>楽しいダイエットの世界へようこそ！</span><span class="mini">(12/3)</span></a></h3>' + "\n" }
         it do
            @ttc.parse('§リサ・ランドール　異次元は存在する((/))リサ・ランドール+若田光一著')
            @ttc.link.should == '<h3 class="link_caption clearfix"><a href="diet_0001.html"><span class="mini orange">1</span>&nbsp;&nbsp;<span>リサ・ランドール　異次元は存在する<br />　　リサ・ランドール+若田光一著</span><span class="mini">(12/3)</span></a></h3>' + "\n"
         end
      end
      describe '新着用シリーズ名を生成できる' do
         it { @ttc.newly_series.should == '【キモチからダイエット(1)】' }
      end
   end

   describe 'htmlの作成' do
      before do
         @diary = Content.new('read/diary/diary_0100.txt', Series.new('read/diary/', NaviMenu.new('2010-12-3')), true)
      end
      describe 'htmlを出力する' do
         before do
            FileUtils.rm_f 'read/diary/diary_0100.html'
         end
         it do
            @diary.put_html
            File.read('read/diary/diary_0100.html').should == File.read('read/diary/diary_0100_ref.html')
         end
         it do
            @diary.after = false
            @diary.put_html
            File.read('read/diary/diary_0100.html').should == File.read('read/diary/diary_0100_not_after.html')
         end
      end
      describe 'シリーズの紹介 html を出力する' do
         before do
            FileUtils.rm_f BASE + 'diet_0000.html'
            @diet_info = Content.new(BASE + 'diet_0000.txt', @series, false)
         end
         it do
            @diet_info.put_html
            File.read(BASE + 'diet_0000.html').should == File.read(BASE + 'diet_0000_ref.html')
         end
      end
      describe 'htmlを生成する' do
         it { pending; @ttc.to_html.should == File.read('read/diet/diet_0001_ref.html') }
         it { @diary.to_html.should == File.read('read/diary/diary_0100_ref.html') }
         it do
            pending
            @book = Content.new('stepup/book/book_0002.txt', @series, false)
            @book.to_html.should == File.read('stepup/book/book_0002_ref.html')
         end
      end
   end

   describe 'ソースを読み込んで変換できる' do
      describe 'パーザで' do
         describe 'html のエスケープができる' do
            it { @ttc.parse('目下"ﾀﾞｲｴｯﾄ検定"を勉強').should == "目下&quot;ダイエット検定&quot;を勉強<br />\n" }
            it { @ttc.parse('目下&quot;ﾀﾞｲｴｯﾄ検定&quot;を勉強').should == "目下&quot;ダイエット検定&quot;を勉強<br />\n" }
            it { @ttc.parse('目下&ﾀﾞｲｴｯﾄ検定&を勉強').should == "目下&amp;ダイエット検定&amp;を勉強<br />\n" }
            it { @ttc.parse('目下<ﾀﾞｲｴｯﾄ検定>を勉強').should == "目下&lt;ダイエット検定&gt;を勉強<br />\n" }
         end
         describe 'シリーズタイトルを取得できる' do
            it do
               @ttc.parse('《通勤地獄極楽日記》')
               @ttc.series.should == '通勤地獄極楽日記'
            end
            it do
               @ttc.parse('■にゃんこのたまり場')
               @ttc.series.should == 'にゃんこのたまり場'
            end
         end
         describe 'コンテントタイトルを取得できる' do
            it do
               @ttc.parse('§ゴールデン・ウイークの猫達')
               @ttc.title.should == 'ゴールデン・ウイークの猫達'
            end
            describe '改行を挿入できる' do
               it do
                  @ttc.parse('§リサ・ランドール　異次元は存在する((/))リサ・ランドール+若田光一著')
                  @ttc.title.should == 'リサ・ランドール　異次元は存在する<br />リサ・ランドール+若田光一著'
               end
            end
         end
         describe '通常行は</ br>を付加する' do
            it do
               @ttc.parse("猫2号は結構ご機嫌。\n").should == "猫2号は結構ご機嫌。<br />\n"
            end
            it do
               @ttc.parse("\n").should == "<br />\n"
            end
         end
         describe 'image タグを生成できる' do
            it { @ttc.parse('◆DSC04994.jpg').should == %!<img src="DSC04994.jpg" /><br />\n! }
            it do
               @ttc.parse('◆DSC04994.jpg:脂肪燃焼ｽｰﾌﾟ').should == %!<img src="DSC04994.jpg" /><br />\n脂肪燃焼スープ<br />\n!
            end
         end
         describe 'インクルードファイルを挿入できる' do
            before do
               @book = Content.new('study/book/book_0002.txt', @series, false)
            end
            it { @book.parse('◆book_0002_amazon.html').should == File.read('study/book/book_0002_amazon.html') }
            it do
               lambda do
                  @book.parse('◆not_exist_file.html')
               end.should raise_error(StandardError, 'study/book/not_exist_file.html が見つかりません。'.encode(TEXT_CODE))
            end
         end
         describe '強調表示を生成できる' do
            it do
               @ttc.parse('通常表示((*強調表示*))通常表示に戻る').should == %!通常表示<em>強調表示</em>通常表示に戻る<br />\n!
            end
         end
         describe '前後のナビゲーションリンクを生成できる' do
            it do
               @ttc.navigation.should == <<-"EOB"
<div id="content_pages">
<a href = "diet_0002.html"><img src="../../images/next.png" alt="次へ" width="55px" height="24px" /></a>
</div>
               EOB
            end
            it do
               ttc2 = Content.new(BASE + 'diet_0002.txt', Series.new(BASE, NaviMenu.new('2010-12-10')))
               ttc2.navigation.should == <<-"EOB"
<div id="content_pages">
<a href = "diet_0001.html"><img src="../../images/previous.png" alt="前へ" width="55px" height="24px" /></a>
&nbsp;
<a href = "diet_0003.html"><img src="../../images/next.png" alt="次へ" width="55px" height="24px" /></a>
</div>
               EOB
            end
            it do
               ttc3 = Content.new(BASE + 'diet_0003.txt', Series.new(BASE, NaviMenu.new('2010-12-17')), false)
               ttc3.navigation.should == <<-"EOB"
<div id="content_pages">
<a href = "diet_0002.html"><img src="../../images/previous.png" alt="前へ" width="55px" height="24px" /></a>
</div>
               EOB
            end
         end
         describe 'コンテント・フッタを読み込める' do
            it do
               @ttc.footer.should == FOOTER_CHECK
            end
         end
      end
   end
end
