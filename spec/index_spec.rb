# -*- coding: utf-8 -*-
require 'index'

class Series
   attr_reader :title, :dname, :name, :fname, :text, :contents, :date
   public :parse, :page_count
end

class Content
   attr_reader :fname, :after
end

class Index
   attr_reader :mode, :category_name
   attr_writer :date
   public :new_contents, :category_title, :contents, :about, :useful, :information, :close, :parse_date, :read_daily
end

=begin
NEWLY = <<EOB
<tr><td colspan="2">
<hr class=border>
<center>
<div class=padding>
<div class=newly_title><font size="2">新着情報<br /></font></div>
<div class=newly>
<font size="1">
【にゃんこのたまり場(1)】<br />
<a href="joyful/cat/cat_0001.html">ｺﾞｰﾙﾃﾞﾝ･ｳｲｰｸの猫達</a><br />
【ｷﾓﾁからﾀﾞｲｴｯﾄ(6)】<br />
<a href="joyful/diet/diet_0006.html">継続こそ力</a><br />
</font>
</div>
</div>
</center>
<hr class=border>
</tr></td>
EOB

NEW_CONTENTS = <<EOB.chomp
【にゃんこのたまり場(1)】<br />
<a href="joyful/cat/cat_0001.html">ｺﾞｰﾙﾃﾞﾝ･ｳｲｰｸの猫達</a><br />
【ｷﾓﾁからﾀﾞｲｴｯﾄ(6)】<br />
<a href="joyful/diet/diet_0006.html">継続こそ力</a><br />
EOB

USEFUL_CLOSE = <<EOB
<tr><td colspan="2" class=tiny><a href="useful/useful.html"><font size="1">→もっと見る</a></font></td></tr>
<tr><td colspan="2">&nbsp;</tr></td>
<tr><th colspan="2" class=border><hr class=border></td></tr>
EOB
=end

BASE = 'read/diet/'

describe Index do
   before(:each) do
      @tti = Index.new(Date.new(2010,4,18))
   end

   describe '初期化' do
      describe '更新日を知っている' do
         it { @tti.date.should == Date.new(2010,4,18) }
      end
#      describe 'カテゴリフォルダを知っている' do
#         it { @tti.category.should == [Pathname.new('joyful'), Pathname.new('stepup')] }
#      end
#   end
   describe 'プライベートメソッドとして' do
      describe '日付文字列から Date オブジェクトを作成する' do
         it { @tti.parse_date('4/04').should == Date.new(Time.now.year,4,4) }
         it { @tti.parse_date('2009/12/5').should == Date.new(2009,12,5) }
         it { @tti.parse_date('09/12/25').should == Date.new(2009,12,25) }
         it { @tti.parse_date('2-4').should == Date.new(Time.now.year,2,4) }
         it { @tti.parse_date('2009-12-3').should == Date.new(2009,12,3) }
         it { @tti.parse_date('09-12-24').should == Date.new(2009,12,24) }
         it { @tti.parse_date('0303').should == Date.new(Time.now.year,3,3) }
         it { @tti.parse_date('100304').should == Date.new(2010,3,4) }
         it { @tti.parse_date('20091206').should == Date.new(2009,12,6) }
         it do
            lambda do
               @tti.parse_date('4_16')
            end.should raise_error(StandardError, '4_16 は日付の指定として問題があります'.encode(TEXT_CODE))
         end
      end

#      describe 'daily.txt から日替わりテキストを読み込む' do
#         it do
#            @tti.date = Date.new(2010,04,1)
#            @tti.read_daily.should == '2010/04/01:通勤時間を　　　:地獄から天国へ　:DSC07468.jpg:@溜池山王:赤口 ｴｲﾌﾟﾘﾙﾌｰﾙ'.split(':')
#         end
#         describe 'エラー処理' do
#            it do
#               @tti.date = Date.new(2010,04,30)
#               lambda do
#                  @tti.read_daily
#               end.should raise_error('daily.txt に 2010/04/30 の行がありません。'.encode(TEXT_CODE))
#            end
#            it do
#               FileUtils.rm 'daily.txt'
#               lambda do
#                  @tti.read_daily
#               end.should raise_error('daily.txt が見つかりません。'.encode(TEXT_CODE))
#            end
#            after do
#               FileUtils.cp 'daily.txt.bk', 'daily.txt'
#            end
#         end
      end
   end

#   describe 'カテゴリフォルダをトラバースする' do
#      describe 'シリーズフォルダをトラバースする' do
#         it { @tti.series.map(&:dname).should == ['joyful/cat/', 'joyful/diary/', 'joyful/diet/', 'stepup/book/', 'stepup/english/', 'stepup/nlp/']}
#         it { @tti.series.map(&:dname).should_not be_include('/joyful/blog')}
#         it { @tti.series.first.should == Series.new('joyful/cat/', Date.new(2010,4,18)) }
#         describe 'コンテンツ関連処理' do
#            describe '新規コンテントを登録する' do
#               it do
#                  lambda do
#                     @tti.series[2].add_content
#                  end.should change{@tti.series[2].contents.first.number}.from(5).to(6)
#               end
#            end
#            describe 'コンテンツ一覧を作成する' do
#               it { @tti.series.last.to_htmls.first.split("\n")[20].should == '<tr><td>  3<a href="english_0003.html">｢英語にはまってます｣</a>(12/1)</td></tr>' }
#            end
#         end
#      end
#   end

   describe 'インデックスページを作成する' do
      describe 'ファイル出力する' do
         before(:all) do

            FileUtils.cp BASE + 'diet_top_ref.txt', BASE + 'diet_top.txt'
            FileUtils.cp 'relax/cat/cat_top_ref.txt', 'relax/cat/cat_top.txt'

#            FileUtils.rm_f(((1..6).map{|n| "diet_000#{n}.html"} + %w[diet_top.html diet_top.txt.bk]).map{|f| BASE + f})
#            FileUtils.rm_f %w[diary_0100.html diary_top.html diary_top.txt.bk].map{|f| 'joyful/diary/' + f}
#            FileUtils.rm_f %w[cat_0001.html cat_top.html cat_top.txt.bk].map{|f| 'joyful/cat/' + f}
#            FileUtils.rm_f(((1..2).map{|n| "book_000#{n}.html"} + %w[book_top.html book_top.txt.bk]).map{|f| 'stepup/book/' + f})
#            FileUtils.rm_f(((1..3).map{|n| "english_000#{n}.html"} + %w[english_top.html englis_top.txt.bk]).map{|f| 'stepup/english/' + f})
         end
         before(:all) do
            @news = Index.new(Date.new(2010,4,1))
            @news.put_html
         end
         it do
            File.read(Index::INDEX_FILE).should == File.read('index_ref.html')
         end
         describe 'html とインデックスソースを出力する' do
            it { File.read(BASE + 'diet_top.html').should == File.read(BASE + "diet_top_new.html") }
            it { pending '新しい行が追加されていない。 2012-05-10' ;File.read(BASE + 'diet_top.txt').should == File.read(BASE + 'diet_top_new.txt') }
            it { File.read('study/english/english_top.txt').should == File.read('study/english/english_top.txt.bk') }
            it { File.read('study/book/book_top.txt').should == File.read('study/book/book_top.txt.bk') } 
         end
#         describe '更新リストを生成する' do
#            it do
#               @news.new_contents.should == NEW_CONTENTS
#            end
#         end
#         describe '新着情報を生成する' do
#           it do
#              @news.mk_newly.should == NEWLY
#           end
#           describe '平等または、意図に沿って三つを選択する' do
#              it do
#                 pending '当面は全部表示する'
#               end
#            end
#         end
      end

      describe '日替わり写真を生成する' do
         it do
            @tti.date = Date.new(2010,4,1)
            @tti.mk_daily_photo.should == File.read('daily_photo_ref1.txt')
         end
         it do
            @tti.date = Date.new(2010,4,5)
            @tti.mk_daily_photo.should == File.read('daily_photo_ref5.txt')
         end
      end

      describe 'おすすめ情報を生成する' do
         it { @tti.mk_recommend.should == File.read('recommend_ref.txt') }
      end
=begin
      describe '日替わりパーツを生成する' do
         it do
            @tti.date = Date.new(2010,4,1)
            @tti.mk_daily.should == File.read('daily_parts1.txt')
         end
         it do
            @tti.date = Date.new(2010,4,5)
            @tti.mk_daily.should == File.read('daily_parts5.txt')
         end
      end
=end

#      describe 'インデックス・ソースからカテゴリメニューを生成する' do
#         it do
#            @tti.mk_menu.should == File.read('menu_parts.txt')
#         end
#         describe 'メニューの各要素を生成する' do
#            before do
#               @category_link = @tti.category_title('§通勤で自分磨き:stepup')
#            end
#            describe 'カテゴリ見出しを生成する' do
#               it do
#                  @category_link.should ==
#                    %!<tr><th colspan="2" class=category_title bgcolor="YellowGreen"><font size="3" color="White">通勤で自分磨き</font></th></tr>\n!
#               end
#               it do
#                  @tti.category_title('§通勤お役立ち情報').should ==
#                    %!<tr><th colspan="2" class=category_title bgcolor="YellowGreen"><font size="3" color="White">通勤お役立ち情報</font></th></tr>\n!
#               end
#               it { @tti.category_name == 'stepup'}
#            end
#            describe 'コンテンツリンクを生成する' do
#               it do
#                  @tti.contents('■英会話一日一言:english').should ==
#                    %!<tr><td rowspan="2"><img src="english.png" /></td><th class=category><font size="1"><a href="stepup/english/english_top.html">英会話一日一言</a></font></th></tr>\n!
#               end
#               it do
#                  @tti.category_title('§通勤おもしろ情報:joyful')
#                  @tti.contents('■気まぐれ筆跡診断:graphology').should ==
#                    %!<tr><td rowspan="2"><img src="graphology.gif" /></td><th class=category><font size="1"><a href="joyful/graphology/graphology_top.html">気まぐれ筆跡診断</a></font></th></tr>\n!
#               end
#               it do
#                  @tti.contents('■気まぐれ筆跡診断:graphology')
#               end
#            end
#            describe 'コンテンツ紹介文を生成する' do
#               it { @tti.about('◎有名人の深層心理を解明かす').should ==%!<tr><td class=category><font size="1">有名人の深層心理を解明かす</font></td></tr>\n! }
#            end
#            describe 'お役立ち情報リンクを生成する' do
#               it do
#                  @tti.useful('▲mini_hiyo:乗換案内:norikae.mobi/').should ==
#                    %!<tr><td class=information><img src="mini_hiyo.gif"><font size="1"><a href="http://norikae.mobi/">乗換案内</a></font></td>\n!
#               end
#               it do
#                  @tti.useful('▼mini_hiyo:乗換案内:norikae.mobi/').should ==
#                    %!    <td class=information><img src="mini_hiyo.gif"><font size="1"><a href="http://norikae.mobi/">乗換案内</a></font></td></tr>\n!
#               end
#               it do
#                  @tti.useful('◆mini_hiyo:乗換案内:norikae.mobi/').should ==
#                    %!<tr><td class=information><img src="mini_hiyo.gif"><font size="1"><a href="http://norikae.mobi/">乗換案内</a></font></td></tr>\n!
#               end
#               it do
#                  @tti.useful('◆mini_hiyo:乗換案内:norikae.mobi/')
#                  @tti.mode.should == :useful
#               end
#            end
#            describe 'サイト情報リンクを生成する' do
#               it do
#                  @tti.information('★mini_zou:通天企画:project.html').should ==
#                    %!<tr><td colspan="2" class=information><img src="mini_zou.gif"><font size="1"><a href="project/project.html">通天企画</a></font></td></tr>\n!
#               end
#               it do
#                  @tti.information('★mini_hiyo:お問合せ:info@tsu-ten.com').should ==
#                    %!<tr><td colspan="2" class=information><img src="mini_hiyo.gif"><font size="1"><a href="mailto:info@tsu-ten.com">お問合せ</a></font></td></tr>\n!
#               end
#            end
#            describe 'カテゴリをとじる' do
#               describe 'お役立ち情報の場合' do
#                  it do
#                     @tti.useful('◆hiyo:乗換案内:norikae.mobi/')
#                     @tti.close.should == USEFUL_CLOSE
#                  end
#               end
#               describe 'コンテンツの場合' do
#                  it do
#                     @tti.contents('■気まぐれ筆跡診断:graphology')
#                     @tti.close.should == ""
#                  end
#               end
#            end
#         end
#      end
   end
end
