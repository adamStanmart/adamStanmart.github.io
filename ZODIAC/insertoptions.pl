#!/usr/local/bin/perl -w
use CGI;
use JBDB;

$baseurl = "/dbimages/";

%signs = ('cap'=>1,'aqu'=>2,'pis'=>3,'ari'=>4,'tau'=>5,'gem'=>6,'can'=>7,'leo'=>8,'vir'=>9,'lib'=>10,'sco'=>11,'sag'=>12);

#print STDERR "Document name = $ENV{'DOCUMENT_NAME'}\n";
my $doc = $ENV{'DOCUMENT_NAME'};


$doc =~ m/gal_(...)(.)\.html/;

$sign = $signs{$1};
$gender = $2;

$width = 500;
$height = 400;
$width2 = 600;
$height2 = 500;

my $jscript = qq(
             <script language=JavaScript>
             function displaylarge(imageurl) {
                 imagepreview = window.open("","preview_window","resizable,width=$width,height=$height");
                 imagepreview.focus();
                 imagepreview.location=imageurl;
                 return false;
             }             
             function displaylarge2(imageurl) {
                 imagepreview = window.open("","preview_window","scrollbars,resizable,width=$width2,height=$height2");
                 imagepreview.focus();
                 imagepreview.location=imageurl;
                 return false;
             }             
             </script>
 );

my $replacement = qq($jscript
		     <table border="0" cellpadding="3" cellspacing="0" width="100%">
		     <tr>
		     <td colspan="2" bgcolor="#2e2e2e"><font color="#dddddd" face="Helvetica" size="2"><b>
		     <form name="FormName" action="../order_form01.pl" method="get" target="main">
		   ORDERING:</b></font><font color="#dddddd" face="Helvetica" size="1"> Select quantity...<br>
		     </font><font color="#ff66ff" face="Helvetica" size="1">( all prices shown are in Australian dollars <a href="http://www.rmg-c.se/rmg/currency.htm" target="_blank" onclick="displaylarge2('http://www.rmg-c.se/rmg/currency.htm');return false;">currency conversion</a>)</font></td>
		     </tr>		     
		     );


my $i = 1;
my $sqlQuery = "select * from options order by option_id";
$a = JBDB::RunQuery($sqlQuery);
while (%hash = $a->fetchhash) {

    $price = $hash{price};
    $title = $hash{title};
    $dsize = $hash{dsize};
    $davailability = $hash{davailability};
    $quantity_name = "quantity_${sign}_${gender}_$hash{option_id}";

    $image = $baseurl.$hash{fn_large};
    $imagepreview = qq(<A HREF="$image" target="_blank" onclick="displaylarge('$image');return false;">);

    $replacement .= qq(<tr>
		       <td width="60" bgcolor="#363636" valign="top">
		       <div align="right">
		       <font color="#dddddd" face="Helvetica" size="1">qty:<input type="text" name="$quantity_name" size="3" value="0"></font></div>
		       </td>
		       <td width="260" bgcolor="#363636"><font color="#dddddd" face="Helvetica" size="1"><b>${imagepreview}Option $i.</A></b> <b>$title \$$price</b><br>$dsize<br>$davailability</font></td>
		       </tr>
		       );
    $i++;
}

$replacement .= qq(						  
    <tr>
    <td width="60" bgcolor="black"><font color="#131313">.</font></td>
    <td width="260" bgcolor="black"><font color="#dddddd" face="Helvetica" size="1"><input type="submit" value="proceed to ordering options..." name="submitButtonName"></font></td>
    </tr>
    </table>
    );

print $replacement;
