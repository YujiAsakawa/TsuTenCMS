# -*- coding: utf-8 -*-
require 'index'

date = ARGV[0] ? ARGV[0] : Date.today
$OVER_WRITE = true #TODO: NaviMenu のインクルード対応まで '-f' == ARGV[1] #TODO: opt parse を使う
$ARCIVE = '-arcive' == ARGV[2] #TODO: opt parse を使う

p $OVER_WRITE
p $ARCIVE

@tsu_ten = Index.new(date)
@tsu_ten.put_html
