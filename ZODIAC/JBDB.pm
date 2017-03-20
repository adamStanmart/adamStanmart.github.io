package JBDB;

################################################################################
## Externally modifyable variables :
################################################################################
$databasetype = "mysql";
$site_databasename = "rudiphoto";
$databasehostname = "localhost";
$databaseusername = "ibsa";
$databasepassword = "ibsa2895";
$rows_works = 1;
$logfile = "/tmp/rudiphoto.log";

do "../../site.conf";
require "../../site.conf";



################################################################################
## Shouldn't need to change anything after here....
################################################################################
use DBI;

## Open the logfile
open LOG, ">>$logfile";

## Read in th config file to override above values.
do 'jbdb.conf'; 

$dbReconectWaitPeriod = 10;
$maxDBConnectTries = 10;
$debug = 1;

$databaseconnectstring = "dbi:$databasetype:database=$site_databasename:host=$databasehostname" if $databasetype eq "mysql";

## Internally modifyable variables :
$count_tries = 0;

################################################################################
## Runs the given query and returns results if successfull :
################################################################################
sub RunQuery($) {
    my ($sqlQuery) = @_;
    
    connectDB() if (!$DB);  ## Connect first time if needed.
    
    print LOG "JBDB : '$sqlQuery'.\n" if $debug;
    
  QUERY:

    my $sth = $DB->prepare($sqlQuery);
    my $res;
    if (!($res = $sth->execute)) {
	errorMessage("ERROR '".$DB->errstr()."' with query '$sqlQuery'");
        if (0) { ## Code to detect if server 'closed' and reconnect.... ***
            ## Try to reconnect and re run query if we can connect :
	    errorMessage("Lost Connection to DB.  Attempting Reconnect...");
            goto QUERY if (connectDB());  ## If it connects then try again.
        }
        return;  # Fail.
    }

    ## Return an object containing the link :
    my($self) = {};
    bless($self, "main::JBDB");
    $self->{'sth'} = $sth;    
    $self->{'query'} = $sqlQuery;    
    return $self;
}


################################################################################
## Connects to the DB
################################################################################
sub connectDB($;) {
    my ($class) = @_;

    my $count_tries = 0;

    $drh = DBI->install_driver("$databasetype"); # Load the database driver. Returns a driver
    $DB = DBI->connect($databaseconnectstring, $databaseusername,$databasepassword);

    while (!$DB) {
	errorMessage("Unable to connect to the database : $site_databasename ($count_tries) with string '$databaseconnectstring' (U:$databaseusername,P:$databasepassword)");
	sleep $dbReconectWaitPeriod;  ## Wait a little while...
	$DB = $drh->connect($databaseconnectstring, $databaseusername,$databasepassword);
	$count_tries++;  ## Tried again...
	if ($count_tries > $maxDBConnectTries) {
	    return 0;
	}
    }
    return 1;
}

sub fetchhash ($) {
    my($self) = shift;
    my $sth = $self->{'sth'};
    my($ref) = $sth->fetchrow_hashref;
    if ($ref) {
        %$ref;
    } else {
        ();
    }
}

sub fetchrow ($) {
    my($self) = shift;
    my $sth = $self->{'sth'};
    my($ref) = $sth->fetchrow;
    if ($ref) {
        @$ref;
    } else {
        ();
    }
}

sub numrows($) {
    my($self) = shift;
    my $sth = $self->{'sth'};
    if ($rows_works) {
    	$sth->rows();
    } else {
    	my $countQuery = $self->{'query'};
	$countQuery =~ s/select\s+(.*)\s+from/select count(*) as num from/i; 
	$countQuery =~ s/(group by \S+)//i; 
	$countQuery =~ s/(order by \S+)//i; 
	$countQuery =~ s/\s+DESC//i; 
	$countQuery =~ s/\s+ASC//i; 
	my $a = RunQuery($countQuery);
	if ($a) {
		%hash = $a->fetchhash;	
		return $hash{num};
	} else {
		-1;
	}
    }
}

sub getLastInsertID() { 
    my $sth = $self->{'sth'};
#    return $DB->func("_INSERT_ID");
#    return $sth->{"insertid"};
    my $a = RunQuery("SELECT LAST_INSERT_ID() as lastid");
    if ($a) {
	%hash = $a->fetchhash;	
	return $hash{lastid};
    } else {
	-1;
    }
}

sub errorMessage($) {
    my $error  = shift;
    print STDERR "JBDB : ERROR : '$error'\n";
    print LOG "JBDB : ERROR : '$error'\n";
}

sub quote($) {
    $_ = shift;
    s/'/\\'/g;
    return "'".$_."'";
}
1;

