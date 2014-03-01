#!/usr/bin/env ruby

require 'bluecloth'

exit unless ARGV && ARGV.size > 0

src = ARGV.shift

browse = if ARGV.include? '-b'
           true
         else
           false
         end


s = IO.read src

html = BlueCloth.new( s ).to_html
tmpl = DATA.read
page_out = "web/index.html"


title =  src
tmpl.gsub!( 'BODY', html)
tmpl.gsub!( 'TITLE', title  )

p RUBY_PLATFORM
# Need to cross-OS this part

if browse

  if RUBY_PLATFORM =~ /w32/
    Thread.new do
    File.open( page_out  , "wb") { |f| f.print tmpl }
    print `ch #{File.expand_path page_out} `
    end
  else
    Thread.new do
      File.open( page_out , "wb") { |f| f.print tmpl }
      print `firefox #{page_out}`
    end
  end

  sleep 5

  exit
end


__END__
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" 
"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>TITLE</title>
<style type='text/css'>
body {
  font-family:  Helvetica, arial, sans-serif;
  color: #333;
    background-color: white;
} 

#wrapper {
width: 600px;
margin-left:10%;
}

h1, h2, h3, h4 {
  font-family:  Verdana, sans-serif;  
}

h1 {
  margin-top: 100px;
}
table { 
  border: solid black 1px;
  border-collapse:collapse;

}


td { 
  border: solid black 1px;

}


</style>


<link type="text/css" rel="stylesheet" href="/style/main.css" media="screen" />
</head>
<body>
<div id='wrapper'>
BODY
</div>  
</body>
</html>
