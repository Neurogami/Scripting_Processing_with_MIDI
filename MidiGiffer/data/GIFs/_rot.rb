#!/usr/bin/env ruby

%w{
animated-greytone001_600-1200.20_jpg.gif 
animated-greytone001_600-1300.20_jpg.gif 
animated-greytone001_600-1400.20_gif.gif 
animated-greytone001_600-1600.20_jpg.gif 
animated-greytone001_600-1800.20_gif.gif 
animated-greytone001_600-1800.20_jpg.gif 
animated-greytone001_600-2500.20_jpg.gif 
animated-greytone001_600-3100.20_gif.gif 
animated-greytone001_600-4000.20_gif.gif 
animated-greytone001_600-600.20_gif.gif 
animated-greytone001_600-900.20_jpg.gif 
animated-greytone001_600_magenta-1500.20_gif.gif 
animated-greytone001_600_magenta-1700.20_jpg.gif 
animated-greytone001_600_magenta-4400.20_jpg.gif 
}.each do |i|

  #c = "convert  #{i} -distort SRT -45  rot45_#{i}" 
  #warn `#{c}`

  c = "convert  #{i}  -flop  flop_#{i}" 
  warn `#{c}`

end
