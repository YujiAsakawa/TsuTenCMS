# -*- coding: utf-8 -*-
require 'series'

class Series
   attr_reader :title, :author, :dname, :name, :fname, :author_fname, :author_html_fname, :footer_name, :text, :date, :color
   public :parse, :page_count, :page_links, :page_template
end

class Content
   attr_reader :fname, :after
end

BASE = 'read/diet/' #TODO: read ディレクトリに統合したい。

describe Series do
   before do
      @navi = NaviMenu.new('2010-4-1')
      @tts = Series.new(BASE, @navi)
   end
  
   describe '初期化' do
      it { @tts.dname.should == BASE }
      it { @tts.name.should == 'diet'}
      it { @tts.fname.should == BASE + 'diet_top.txt' }
      it { @tts.footer_name.should == BASE + 'diet_top_footer.html' }
      it { @tts.author_fname == BASE + 'kobayashi.txt'}
      it { @tts.author_html_fname == BASE + 'kobayashi.html'}
      it { @tts.text.should be_an_instance_of String }
      describe '更新日を知っている' do
         it { @tts.date.should == '4/1' }
      end
      #    describe 'シリーズカラーを知っている' do TODO: 廃止
      #      it { @tts.color.should == 'CornFlowerBlue'}
      #    end
      describe '提供者の氏名を知っている' do
         it { @tts.author_name.should == '小林 一行(こばやし いっこう)' }
      end
   end

   describe '外部インターフェイスとして' do
      describe '同値性を比較できる' do
         it do
            @tts.should == Series.new(BASE,  NaviMenu.new('2010-4-1'))
         end
         it do
            @tts.should_not == Series.new('relax/cat/',  NaviMenu.new('2010-4-1'))
         end
         it do
            @tts.should_not == Series.new(BASE,  NaviMenu.new('2010-4-2'))
         end
      end
   end

   describe 'プライベートメソッドで' do
      describe 'ページ計算できる' do
         it do
            @tts.page_size = 2
            @tts.page_count(5).should == 3
         end
         it do
            @tts.page_size = 2
            @tts.page_count(4).should == 2
         end
         it { @tts.page_count(20).should == 2 }
         it { @tts.page_count(19).should == 2 }
         it { @tts.page_count(7).should == 1 }
      end
      describe 'ページネーションテンプレートを取得できる' do
         it { @tts.page_template(1, 1).should == ["%d\n", [1]] }
         it { @tts.page_template(2, 2).should == [%{%s\n<span class="round_box">2</span>\n}, [1]] }
         it { @tts.page_template(1, 2).should == [%{<span class="round_box">1</span>\n%s\n}, [2]] }
         it { @tts.page_template(1, 3).should == [%{<span class="round_box">1</span>\n%s\n%s\n}, [2, 3]] }
         it { @tts.page_template(3, 4).should == [%{%s\n%s\n<span class="round_box">3</span>\n%s\n}, [1, 2, 4]] }
         it { @tts.page_template(1, 5).should == [%{<span class="round_box">1</span>\n%s\n%s\n..%s\n}, [2, 3, 5]] }
         it { @tts.page_template(1, 6).should == [%{<span class="round_box">1</span>\n%s\n%s\n..%s\n}, [2, 3, 6]] }
         it { @tts.page_template(2, 7).should == [%{%s\n<span class="round_box">2</span>\n%s\n..%s\n}, [1, 3, 7]] }
         it { @tts.page_template(3, 7).should == [%{%s\n%s\n<span class="round_box">3</span>\n%s\n..%s\n}, [1, 2, 4, 7]] }
         it { @tts.page_template(5, 7).should == [%{%s\n..%s\n<span class="round_box">5</span>\n%s\n%s\n}, [1, 4, 6, 7]] }
         it { @tts.page_template(6, 7).should == [%{%s\n..%s\n<span class="round_box">6</span>\n%s\n}, [1, 5, 7]] }
         it { @tts.page_template(7, 7).should == [%{%s\n..%s\n%s\n<span class="round_box">7</span>\n}, [1, 5, 6]] }
         it { @tts.page_template(4, 7).should == [%{%s\n..%s\n<span class="round_box">4</span>\n%s\n..%s\n}, [1, 3, 5, 7]] }
         it { @tts.page_template(5, 8).should == [%{%s\n..%s\n<span class="round_box">5</span>\n%s\n..%s\n}, [1, 4, 6, 8]] }
         it { @tts.page_template(6, 10).should == [%{%s\n..%s\n<span class="round_box">6</span>\n%s\n..%s\n}, [1, 5, 7, 10]] }
      end
   end

   describe 'シリーズのインデックスページを作成する' do
      before do
         FileUtils.rm_f BASE + 'diet_top.html'
         FileUtils.rm_f BASE + 'diet_top2.html'
         FileUtils.rm_f BASE + 'diet_top3.html'
      end
      it do
         @tts.page_size = 2
         @tts.put_html
         File.read(BASE + 'diet_top.html').should == File.read(BASE + "diet_top_ref1.html")
         File.read(BASE + 'diet_top2.html').should == File.read(BASE + "diet_top_ref2.html")
         File.read(BASE + 'diet_top3.html').should == File.read(BASE + "diet_top_ref3.html")
      end
      it { @tts.contents.last.link.should == '<h3 class="link_caption clearfix"><a href="diet_0001.html"><span class="mini orange">1</span>&nbsp;&nbsp;<span>楽しいダイエットの世界へようこそ！</span><span class="mini">(12/3)</span></a></h3>' + "\n" }
      describe 'html を生成する' do
         it do
            File.open(BASE + 'diet_top_test.html', 'w'){|f| f.puts @tts.to_htmls.first}
            @tts.to_htmls.first.should == File.read(BASE + 'diet_top_ref.html')
         end
         describe 'put_html' do
            before do
               FileUtils.rm_f 'study/book/book_top.html'
            end
            it do
               book = Series.new('study/book/', NaviMenu.new('2010-4-30'))
               book.put_html
               File.read('study/book/book_top.html').should == File.read('study/book/book_top_ref.html')
            end
         end
         describe 'ページネーション出来る' do
            it do
               @tts.page_size = 2
               @tts.instance_eval{page_count}.times do |n|
                  @tts.to_htmls[n].should == File.read(BASE + "diet_top_ref#{n + 1}.html")
               end
            end
            describe 'ページリンクを生成する' do
               it { @tts.page_links(1, 3).should == %!<section id="pages">\n<span class="round_box">1</span>\n<a href="diet_top2.html"><span class="round_box">2</span></a>\n<a href="diet_top3.html"><span class="round_box">3</span></a>\n<span class="mini">page</span>\n</section>\n! }
               it { @tts.page_links(2, 3).should == %!<section id="pages">\n<a href="diet_top.html"><span class="round_box">1</span></a>\n<span class="round_box">2</span>\n<a href="diet_top3.html"><span class="round_box">3</span></a>\n<span class="mini">page</span>\n</section>\n! }
               it { @tts.page_links(3, 3).should == %!<section id="pages">\n<a href="diet_top.html"><span class="round_box">1</span></a>\n<a href="diet_top2.html"><span class="round_box">2</span></a>\n<span class="round_box">3</span>\n<span class="mini">page</span>\n</section>\n! }
               it { @tts.page_links(1, 1).should == '' }
            end
         end
         describe 'シリーズフッタを生成する' do
            before do
               FileUtils.rm_f 'read/diary/diary_top.html'
            end
            it do
               diary = Series.new('read/diary/', @navi)
               diary.put_html
               File.read('read/diary/diary_top.html').should == File.read('read/diary/diary_top_ref.html')
            end
         end
      end
   end

   describe 'コンテンツを生成する' do
      before do
         FileUtils.rm_f BASE + 'diet_0001.html'
         FileUtils.rm_f BASE + 'diet_0002.html'
         FileUtils.rm_f BASE + 'diet_0003.html'
         FileUtils.rm_f BASE + 'diet_0004.html'
         FileUtils.rm_f BASE + 'diet_0005.html'
         FileUtils.rm_f BASE + 'diet_0006.html'
      end
      it do
         lambda do
            @tts.put_contents
         end.should change{FileTest.exist? BASE + 'diet_0005.html'}.from(false).to(true)
      end
      it do
         lambda do
            @tts.add_content
            @tts.put_contents
         end.should change{FileTest.exist? BASE + 'diet_0006.html'}.from(false).to(true)
      end
      it do
         @tts.add_content
         @tts.put_contents
         File.read(BASE + 'diet_0001.html').should == File.read(BASE + "diet_0001_ref.html")
         File.read(BASE + 'diet_0005.html').should == File.read(BASE + "diet_0005_ref.html")
         File.read(BASE + 'diet_0006.html').should == File.read(BASE + "diet_0006_ref.html")
      end
   end

   describe '提供者紹介ページを生成する' do
      before do
         FileUtils.rm_f BASE + 'kobayashi.html'
      end
      it do
         lambda do
            @tts.put_author_html
         end.should change{FileTest.exist? BASE + 'kobayashi.html'}.from(false).to(true)
      end
      it do
         @tts.put_author_html
         File.read(BASE + 'kobayashi.html').should == File.read(BASE + "kobayashi_ref.html")
      end
   end

   describe 'コンテンツ紹介ページを生成する' do
      before do
         FileUtils.rm_f BASE + 'diet_0000.html'
      end
      it do
         lambda do
            @tts.put_info_html
         end.should change{FileTest.exist? BASE + 'diet_0000.html'}.from(false).to(true)
      end
   end

   describe 'シリーズ・ディレクトリを探索する' do
      before do
         @tts.add_content
         @nct = @tts.contents.first
      end
      describe '新規のコンテントを読み込める' do
         it { @nct.should  be_an_instance_of Content }
         it { @nct.number.should == 6 }
         describe 'コンテントのナビゲーションは「次」はない' do
            it { @nct.after.should be_false }
         end
         describe 'シリーズインデックスにも追加される' do
            it { @tts.contents.first.link.should == '<h3 class="link_caption clearfix"><a href="diet_0006.html"><span class="mini orange">6</span>&nbsp;&nbsp;<span>継続こそ力</span><span class="mini">(4/1)</span></a></h3>' + "\n" }
         end
         describe '新規コンテントフラッグが真' do
            it do
               @tts.new_content?.should be_true
            end
         end
      end
      describe '新規コンテントがない場合' do
         before do
            @not_new = Series.new('study/english/', NaviMenu.new('2012-05-03'))
         end
         it do
            @not_new.add_content
            @not_new.new_content?.should be_false
         end
         it do
            @not_new.add_content
            @not_new.contents.first.after.should be_false
         end
         it do
            bef = @not_new.contents.first
            @not_new.add_content
            @not_new.contents.first.should == bef
         end
      end
   end

   describe 'ソースファイルを作成する' do
      it { @tts.to_s.should == File.read(BASE + 'diet_top.txt') }
      it do
         @tts.add_content
         @tts.put_source
         File.read(BASE + 'diet_top.txt').should == File.read(BASE + 'diet_top_new.txt')
      end
      after do
         FileUtils.cp BASE + 'diet_top_ref.txt', BASE + 'diet_top.txt'
         FileUtils.rm_f BASE + 'diet_top.txt.bk'
      end
   end
   describe 'ソースファイルを読み込む' do
      describe 'シリーズタイトルを読み込める' do
         it { @tts.title.should ==  'キモチからダイエット' }
      end
      describe 'コンテントタイトルを読み込める' do
         it { @tts.contents.last.heading.should == ('■No.1 楽しいダイエットの世界へようこそ！(12/3)') }
         it do
            book = Series.new('study/book/', NaviMenu.new('2010-4-30'))
            book.contents.first.heading.should == ('■No.2 「結果を出す人」はノートに何を書いているのか<br />美崎栄一郎著(2/1)')
         end
      end
      describe '提供者ファイル名を読み込める' do
         it do
            @tts.author.should == 'kobayashi'
         end
      end
      describe 'コンテンツを取得できる' do
         it { @tts.contents.size.should == 5 }
         it { @tts.contents.first.should be_an_instance_of Content }
      end
      describe 'コンテンツ行がない場合' do
         it do
            cat = Series.new('relax/cat/', NaviMenu.new('2010-4-1'))
            cat.add_content
            cat.contents.first.should == Content.new('relax/cat/cat_0001.txt', cat, false)
         end
      end
      describe 'ソースファイルがない場合' do
         it do
            lambda do
               Series.new('read/no_contents/', NaviMenu.new('2012-5-3'))
            end.should raise_error(RuntimeError, 'read/no_contents/no_contents_top.txt がありません。(series)'.encode(TEXT_CODE))
         end
      end
   end
end

