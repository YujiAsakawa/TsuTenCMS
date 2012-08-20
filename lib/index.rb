# -*- coding: utf-8 -*-
require 'pathname'
require 'util'
require 'parts'
require 'series'

MAIN_PROGRAM_NAME = 'tsuten.rb'
#TODO: STDERR.set_encoding 'UTF-8', 'SHIFT_JIS' でよいかも。
TEXT_CODE = MAIN_PROGRAM_NAME == $PROGRAM_NAME ? 'Shift_JIS' : 'UTF-8'

class Index
   include Util

   INDEX_FILE = 'index.html'
   SOURCE = 'index.txt'
   WEEK = %w[日 月 火 水 木 金 土]
   IMG_EX = %w[gif jpeg jpg png]
   CATEGORY = [:study, :read, :relax]
   NOT_SUPPORT = /blog/

   def initialize(date)
      @date = date.instance_of?(Date) ? date : parse_date(date)
      @category = CATEGORY.map{|dn| Pathname.new(dn.to_s)}
      @series = []
      @navi = NaviMenu.new(@date)
      @category.each do |ct| #TODO: NaviMenu との重複をなくしたい。
         ct.each_entry do |sr|
            unless Regexp.union(/\A\.+\z/, NOT_SUPPORT) === sr.to_s
               @series << Series.new((ct + sr).to_s + '/', @navi)
            end
         end
      end
      @mode = false
#      @color = 'MediumSeaGreen'
#      @sub_color = 'YellowGreen'
   end

   attr_reader :date, :category, :series

   def put_html #TODO: navi_menu でコンテンツを作成する。
      mk_contents
      open(INDEX_FILE, 'w') do |html|
         html.puts to_html
      end
      if MAIN_PROGRAM_NAME == $PROGRAM_NAME
         begin
#            puts new_contents.to_s.encode(TEXT_CODE)
         rescue Encoding::UndefinedConversionError
            warn '新規コンテンツの表題でコンソールに表示できない文字が含まれていて結果を表示できませんが、 html は正常に作成されました。'.encode(TEXT_CODE)
         end
      end
   end

   def to_html
      html = ''
      html << INDEX_HEADER.gsub(/〓date〓/, fmday)
      html << mk_daily_photo
      html << @navi.to_html
      html << mk_recommend
=begin
      html << NAVI_HEADER #TODO: NaviMenu の to_html に移行する
      html << @navi.topix_html
      CATEGORY.each do |category|
         html << @navi.category_html(category)
      end
      html << NAVI_FOOTER
=end
      html << FOOTER.gsub(%r!../../!, '')
      html
   end

   def mk_contents
      @series.each do |tts|
         tts.add_content
      end
      @navi.new_contents = new_contents
      @series.each do |tts|
         tts.put_contents
         tts.put_html
         tts.put_source
      end
   end

   def mk_daily_photo
      texts = read_daily
      #TODO: daily.txt の不要になったカラムを整理すると texts の index が変わる。
      <<EOB
		<!-- 日替わり写真スペース -->
		<section id="photo_space">
			<div id="photo_bloc">
				<img src="#{texts[3]}" alt="#{texts[4]}" />
				<p class="photo_exp">#{texts[4]}</p>
			</div>
		</section>
		<!-- 日替わり写真スペースここまで -->
EOB
   end

   def mk_recommend
      <<EOB
		<!-- おすすめ情報 -->
		<section id="tsuten_ad">
			<div class="gradient_bar_gray caption">通勤天国おすすめ情報</div>
#{recommend_lines.join("\n")}
		</section>
		<!-- おすすめ情報ここまで -->
EOB
   end

=begin
   def mk_daily
      texts = read_daily
      <<EOB
<tr><td rowspan="4"><img src="big_neko.gif" /></td>
    <td class=phrase><font size="1">  ＿＿＿＿＿＿＿＿</font></td></tr>
<tr><td class=phrase><font size="1"><#{texts[1]}|</font></td></tr>
<tr><td class=phrase><font size="1">|#{texts[2]}|</font></td></tr>
<tr><td class=phrase><font size="1">  ￣￣￣￣￣￣￣￣</font></td></tr>
<tr><td colspan="2" class=caption><center><font size="1">#{jpday}</font></center></td></tr>
<tr><td colspan="2" class=caption><center><font size="1">#{texts[5]}</font></center></td></tr>
<tr><td colspan="2"><center><img src="#{texts[3]}" /></center></td></tr>
<tr><td colspan="2"class=caption><center><font size="1">#{texts[4]}</font></center></td></tr>
EOB
   end

   def mk_newly
      <<EOB
<tr><td colspan="2">
<hr class=border>
<center>
<div class=padding>
<div class=newly_title><font size="2">新着情報<br /></font></div>
<div class=newly>
<font size="1">
#{new_contents}
</font>
</div>
</div>
</center>
<hr class=border>
</tr></td>
EOB
   end
=end

   def mk_menu
      menu = ''
      File.foreach(SOURCE) do |line|
         text = normalize(line.chomp)
         case text
         when /\A§/
            menu << category_title(text)
         when /\A■/
            menu << contents(text)
         when /\A(◎|●)/
            hr = '◎' == $1 ? :hr : false
            menu << about(text, hr)
         when /\A[▼▲◆]/
            menu << useful(text)
         when /\A★/
            menu << information(text)
         when /\A\z/
            menu << close
         else
            raise "#{text} : はインデックス作成に不正な行です".encode(TEXT_CODE)
         end
      end
      menu
   end

   private
   def parse_date(date)
      today = Date.today
      year = today.year
      mon = today.mon
      day = today.day
      case date
      when %r!\A(\d{2,4}[-/])?(\d{1,2})[-/](\d{1,2})\Z!
         year = $1.to_i if $1
         mon = $2.to_i
         day = $3.to_i
      when /\A\d{4,8}\z/
         case date.size
         when 8
            year = date.slice(-8, 4).to_i
         when 6
            year = date.slice(-6, 2).to_i
         end
         mon = date.slice(-4, 2).to_i
         day = date.slice(-2, 2).to_i
      else
         raise "#{date} は日付の指定として問題があります".encode(TEXT_CODE)
      end
      Date.parse("#{year}-#{mon}-#{day}", true)
   end

   def jpday
      '%d年%d月%d日(%s)' % [@date.year, @date.mon, @date.day, WEEK[@date.wday]]
   end

   def fmday
      @date.strftime('%Y/%m/%d(%a)')
   end

   def read_daily
      #TODO: daily.txt の不要になったカラムを整理する。
      day_text = @date.strftime('%Y/%m/%d')
      result = []
      raise 'daily.txt が見つかりません。'.encode(TEXT_CODE) unless FileTest.exist? 'daily.txt'
      File.foreach('daily.txt') do |line|
         if /^#{day_text}/ === line
            result = normalize(line).chomp.split(':')
         else
            next
         end
      end
      raise "daily.txt に #{day_text} の行がありません。".encode(TEXT_CODE) if result.empty?
      result[4].gsub!(/[\s　]/, '')
      result
   end

   def recommend_lines
      lines = []
      raise 'recommend.txt が見つかりません。'.encode(TEXT_CODE) unless FileTest.exist? 'recommend.txt'
      File.foreach('recommend.txt') do |line|
         fname, heading =  line.chomp.split(':')
         lines << %!\t\t\t<h3 class="link_caption clearfix"><img src="images/icon.png" alt="アイコン" width="28px" height="24px" /><a href="./recommend/#{fname}.html"><span>#{heading}</span></a></h3>!

      end
      lines
   end

   def new_contents
      @series.find_all{|se| se.new_content?}.collect {|se|  se.contents.first }
   end

=begin
   def new_contents
      @series.find_all{|se| se.new_content?}.collect do |se|
         nc = se.contents.first
         %!#{nc.newly_series}<br />\n<a href="#{nc.html_path}">#{nc.title}</a><br />!
      end.join("\n")
   end
=end

   def category_title(text)
      title, @category_name = text.sub(/\A§/, '').split(':')
      %!<tr><th colspan="2" class=category_title bgcolor="#{@sub_color}"><font size="3" color="White">#{title}</font></th></tr>\n!
   end

   def contents(text)
      title, name = text.sub(/\A■/, '').split(':')
      img_fname = ''
      IMG_EX.each do |ex|
         img_fname = "#{name}.#{ex}"
         break if FileTest.exist?(img_fname)
      end
      %!<tr><td rowspan="2"><img src="#{img_fname}" /></td><th class=category><font size="1"><a href="#{@category_name}/#{name}/#{name}_top.html">#{title}</a></font></th></tr>\n!
   end

   def about(text, hr = false)
      text.sub!(/\A(◎|●)/, '')
      if hr
         %!<tr><td class=category><font size="1">#{text}</font></td></tr>\n<tr><td colspan="2"><hr></td></tr>\n!
      else
         %!<tr><td class=category><font size="1">#{text}</font></td></tr>\n!
      end
   end

   def useful(text)
      @mode = :useful
      mark, value = text.match(/\A([▼▲◆])(.+)/).values_at(1,2)
      texts = value.split(':')
      column =  %!<td class=information><img src="#{texts[0]}.gif"><font size="1"><a href="http://#{texts[2]}">#{texts[1]}</a></font></td>!
      case mark
      when '▲'
         "<tr>#{column}\n"
      when '▼'
         "    #{column}</tr>\n"
      when '◆'
         "<tr>#{column}</tr>\n"
      end
   end

   def information(text)
#      @mode = false
      texts = text.sub(/\A★/, '').split(':')
      protocol = /@/ === texts[2] ? 'mailto:' : 'project/'
      %!<tr><td colspan="2" class=information><img src="#{texts[0]}.gif"><font size="1"><a href="#{protocol}#{texts[2]}">#{texts[1]}</a></font></td></tr>\n!
   end

   def close
      result = ''
      if @mode == :useful
         result << <<EOB
<tr><td colspan="2" class=tiny><a href="useful/useful.html"><font size="1">→もっと見る</a></font></td></tr>
<tr><td colspan="2">&nbsp;</tr></td>
<tr><th colspan="2" class=border><hr class=border></td></tr>
EOB
      end
      result
   end
end