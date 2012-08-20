# -*- coding: utf-8 -*-
require 'pathname'
require 'util'
require 'parts'
require 'index'
require 'series'

class NaviMenu
   Faceicon = Struct.new(:name, :file)
   CATEGORYS = {
      study: Faceicon.new('のばすくん', 'nobasu.png'),
      read: Faceicon.new('たのしむくん', 'tanoshimu.png'),
      relax: Faceicon.new('なごむくん', 'nagomu.png')
   }

   attr_accessor :new_contents
   attr_reader :date, :series

   def initialize(date)
      @date = date.instance_of?(Date) ? date : parse_date(date)
      @new_contents = []
      @series = {}
      CATEGORYS.keys.each do |name|
         path = Pathname.new(name.to_s)
         path.each_entry do |dir| #TODO: 並び順を指定できるようにしたい。
            @series[name] ||= []
            @series[name] << Series.new((path + dir).to_s + '/', self) unless /\A\.+\z/ === dir.to_s
         end
      end
   end

   def category_html(category, base_path = '')
      html = %(<div id="#{category}">\n<ul>\n)
      @series[category].each do |serie| #TODO: series_link を使う。
         html << %(<li class="link_caption clearfix">)
         html << faceicon(category, base_path)
         html << %(<a href="#{base_path}#{serie.dname}#{serie.name}_top.html"><span>&nbsp;&nbsp;#{serie.title}</span></a></li>\n)
      end
      html << %(</ul>\n</div>\n)
      html
   end

   def topix_html(base_path = '')
      html = %(<div id="topix">\n<ul>\n)
      @new_contents.each do |nc|
            html << new_link(nc, base_path) + "\n"
         end
      html << %(</ul>\n</div>\n)
   end

   def series_link(text, category, base_path = '')
      title, name = text.sub(/\A■/, '').split(':')
      <<-EOB.gsub("\n", "")
<li class="link_caption clearfix">
#{faceicon(category, base_path)}
<a href="#{base_path}#{category}/#{name}/#{name}_top.html"><span>&nbsp;&nbsp;#{title}</span></a>
</li>
      EOB
   end

   def new_link(content, base_path = '')
      <<-EOB.gsub("\n", "")
<li class="link_caption clearfix">
#{faceicon(content.category, base_path)}
<a href="#{base_path}#{content.html_path}">#{content.title}<br>
<span class="mini">&nbsp;&nbsp;&nbsp;&nbsp;#{content.series}(#{content.number})</span>
</a>
</li>
      EOB
   end

   def to_html(base_path = '')
      html = NAVI_HEADER.dup
      html << topix_html(base_path)
      CATEGORYS.keys.each do |category|
         html << category_html(category, base_path)
      end
      html << NAVI_FOOTER
      html
   end

   def date_text
      "%d/%d" % [@date.mon, @date.day]
   end

   private
   def mk_contents
      @series.each do |_, category|
         category.each do |series|
            series.add_content
            series.put_contents
            series.put_html
            series.put_source
         end
      end
   end

   def faceicon(category, base_path = '')
      icon = CATEGORYS[category]
      %(<img src="#{base_path}images/#{icon.file}" alt="#{icon.name}" width="32px" height="30px" />)
   end

   def parse_date(date)
      return date if date.instance_of?(Date)
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
end
