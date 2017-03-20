function popup(url, name, width, height)
{
settings=
"toolbar=yes,location=yes,directories=yes,"+
"status=no,menubar=no,scrollbars=yes,"+
"resizable=yes,width="+width+",height="+height;

MyNewWindow=window.open("http://"+url,name,settings);
}

/*
Place the following in the body --

<a href="#" onclick="popup('www.yahoo.com', 'win1', 300, 300); return false">
Visit </a>
*/