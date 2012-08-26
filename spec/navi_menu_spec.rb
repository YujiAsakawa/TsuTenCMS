# -*- coding: utf-8 -*-
require 'navi_menu'

class Series
   attr_reader :title, :dname, :name, :fname, :text, :contents, :date
   public :parse, :page_count
end

class Content
   #   attr_reader :fname, :after
end

class Index
   attr_reader :mode, :category_name
   attr_writer :date
   public :new_contents, :category_title, :contents, :about, :useful, :information, :close, :parse_date, :read_daily
end

CATEGORY=<<EOB
<div id="study">
<ul>
<li class="link_caption clearfix"><img src="../../images/nobasu.png" alt="のばすくん" width="32px" height="30px" /><a href="../../study/book/book_top.html"><span>&nbsp;&nbsp;4946inaの 本の紹介</span><br /><span class="mini">いな</span></a></li>
<li class="link_caption clearfix"><img src="../../images/nobasu.png" alt="のばすくん" width="32px" height="30px" /><a href="../../study/english/english_top.html"><span>&nbsp;&nbsp;英会話一日一言</span><br /><span class="mini">イムラン</span></a></li>
<li class="link_caption clearfix"><img src="../../images/nobasu.png" alt="のばすくん" width="32px" height="30px" /><a href="../../study/nlp/nlp_top.html"><span>&nbsp;&nbsp;世界が変わるNLP</span><br /><span class="mini">ほげ</span></a></li>
</ul>
</div>
EOB

TOPIX= <<EOB
<div id="topix">
<ul>
<li class="link_caption clearfix"><img src="images/tanoshimu.png" alt="たのしむくん" width="32px" height="30px" /><a href="read/diary/diary_0100.html">美味しくダイエット!脂肪燃焼スープ!<br><span class="mini">&nbsp;&nbsp;&nbsp;&nbsp;通勤地獄極楽日記(100)</span></a></li>
<li class="link_caption clearfix"><img src="images/nobasu.png" alt="のばすくん" width="32px" height="30px" /><a href="study/book/book_0002.html">「結果を出す人」はノートに何を書いているのか<br />美崎栄一郎著<br><span class="mini">&nbsp;&nbsp;&nbsp;&nbsp;4946inaの 本の紹介(2)</span></a></li>
</ul>
</div>
EOB

CONTENT = <<EOB.gsub("\n", "")
<li class="link_caption clearfix">
<img src="../../images/nobasu.png" alt="のばすくん" width="32px" height="30px" />
<a href="../../study/english/english_top.html"><span>&nbsp;&nbsp;英会話一日一言</span></a>
</li>
EOB

NEW_CONTENT = <<EOB.gsub("\n", "")
<li class="link_caption clearfix">
<img src="../../images/tanoshimu.png" alt="たのしむくん" width="32px" height="30px" />
<a href="../../read/diet/diet_0001.html">楽しいダイエットの世界へようこそ！<br>
<span class="mini">&nbsp;&nbsp;&nbsp;&nbsp;キモチからダイエット(1)</span>
</a>
</li>
EOB

BASE = 'read/diet/'

describe NaviMenu do
   before(:all) do
      @navi = NaviMenu.new('2010-4-18')
      @tts = Series.new(BASE, @navi)

      FileUtils.cp BASE + 'diet_top_ref.txt', BASE + 'diet_top.txt'
      FileUtils.cp 'relax/cat/cat_top_ref.txt', 'relax/cat/cat_top.txt'
      FileUtils.rm_f(((1..6).map{|n| "diet_000#{n}.html"} + %w[diet_top.html diet_top.txt.bk]).map{|f| BASE + f})
      FileUtils.rm_f %w[diary_0100.html diary_top.html diary_top.txt.bk].map{|f| 'read/diary/' + f}
      FileUtils.rm_f %w[cat_0001.html cat_top.html cat_top.txt.bk].map{|f| 'relax/cat/' + f}
      FileUtils.rm_f(((1..2).map{|n| "book_000#{n}.html"} + %w[book_top.html book_top.txt.bk]).map{|f| 'study/book/' + f})
      FileUtils.rm_f(((1..3).map{|n| "english_000#{n}.html"} + %w[english_top.html englis_top.txt.bk]).map{|f| 'study/english/' + f})
   end

   describe 'シリーズフォルダをトラバースする' do
      before do
         @serie_hash = {}
         @navi.series.each do |category, series|
            @serie_hash[category] = series.map(&:dname)
         end
      end
      it { @serie_hash.should == {study: ['study/book/', 'study/english/', 'study/nlp/'], read: ['read/diary/', 'read/diet/'], relax: ['relax/cat/']} }
   end

   describe 'シリーズリンクを生成する' do
      it { @navi.series_link('■英会話一日一言:english', :study, '../../').should == CONTENT }
   end

   describe '新着コンテンツリンクを生成する' do
      before { @nc =  Content.new(BASE + 'diet_0001.txt', @tts, true) }
      it { @navi.new_link(@nc, '../../').should == NEW_CONTENT}
   end

   describe 'カテゴリリストを生成する' do
      it { @navi.category_html(:study, '../../').should == CATEGORY}
   end

   describe '新着リストを生成する' do
      before do
         @navi.new_contents = [
            Content.new('read/diary/diary_0100.txt', @tts, true),
            Content.new('study/book/book_0002.txt', @tts, false)
         ]
      end

      it { @navi.topix_html('').should == TOPIX}
   end

   describe '日付文字列を生成できる' do
      it { @navi.date_text.should == '4/18' }
   end
end
