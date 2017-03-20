#!/usr/local/bin/perl -w

$script = "/zodiac/insertoptions.pl";

while ($filename = shift) {
    $replacement = qq(<!--#exec cgi="$script" -->);

    open FILE, "< $filename";
    open FILE2, "> ../$filename";
    $string1 = qq|<table border="0" cellpadding="3" cellspacing="0" width="100%">|;
    $string2 = qq|</table>|;
    $out = 1;
    while ($data = <FILE>) {
	if (($out != 2)&&($data =~ s/(.*)($string1)(.*)/$1/)) {
	    $out = 0;
	    print FILE2 $replacement;
	}
	if ((!$out)&&($data =~ s/(.*)($string2)(.*)/$3/)) {
	    $out = 2;
	}
	print FILE2 $data if $out;
    }
}


