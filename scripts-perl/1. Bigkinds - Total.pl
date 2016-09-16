# ============================================================ #
# Web-scraping the number of Korean EPU articles from Bigkinds
# Author: Scott R. Baker, Jessica YK Koh
# Modified: 2016/08/10 
# ============================================================ #
use WWW::Mechanize;
use HTML::Display;
use utf8;
use Win32::IEAutomation;
use Cwd;

# This sets the expected waiting time between observations (to avoid the website from locking)
my $sleep_per_obs = 1;

# This sets the maximum number of attempts to get a page. If after this amount we still get an error, we give up.
my $max_attempts = 70;

my $pwd = cwd();
my ($target) = "$pwd/../output/counts/bigkindstotal.csv";
my $agent = new WWW::Mechanize(quiet => 1 , onerror => undef , stack_depth => 30);
$agent->agent_alias( 'Windows IE 6' );

open (TARGET, ">$target") or die ("Couldn't open $target for writing\n");

my @paper_set = ('01101001', '01101101', '01100101', '02100101', '02100601');

#01100401 = Donga Ilbo (not in Bigkinds)
#01101001 = Hankyoreh
#01101101 = Hankook Ilbo
#01100101 = Kyunghang Daily News
#02100101 = Maeil Economic Daily
#02100601 = Korea Economic Daily

my @year_loop = (1990 .. 2016);
my @month_loop = (1 .. 12);
my @day_loop = (1 .. 31);

foreach $paper (@paper_set) {
	for my $year (@year_loop) {
		foreach my $month (@month_loop) {
			my $day_begin = "01";
			if ($month==2) {
				$day_end = 28;
			}
			elsif ($month==4||$month==6||$month==9||$month==11) {
				$day_end = 30;
			}
			elsif ($month==1||$month==3||$month==5||$month==7||$month==8||$month==10||$month==12) {
				$day_end = 31;
			}
			
			if ($month < 10) {
			$month_new = "0".$month;
			} else {
			$month_new = $month;
			}
			
			
			#########Here we will determine the number of results for each day only for the given terms
			my $url = "http://www.bigkinds.or.kr/search/totalSearchList.do";
			my $r= $agent->get($url);
			
			
			for (my $attempt = 1 ; (!($r->is_success) && $attempt <= $max_attempts) ; $attempt++) {
				print STDERR "Retrying to get a search going ($term: $month-$day_begin-$year)\n";
				sleep(60);
				$r = $agent->get($url);	# Go to this URL
			}
			if (!($r->is_success)) {
				die ("Can't get search going... Stopped while trying to get $term: $month-$day_begin-$year\n");
			}

			
			my $content = $agent->content();
			#display("$content");	##Display the Bigkinds page

			###Now fill in the various elements of the search like dates, term, paper
			my $fromDate = "$year$month_new$day_begin";
			my $toDate = "$year$month_new$day_end";
			my $popKeyword = "$term";
			print "fromDate: $fromDate, toDate: $toDate \n";
			
			##Now submit the form to get to the search page
			my $r= $agent -> submit_form(form_name => 'topSearchForm', fields => { fromDate => $fromDate, toDate => $toDate, provider_code => $paper});
			
			for (my $attempt = 1 ; (!($r->is_success) && $attempt <= $max_attempts) ; $attempt++) {
				print STDERR "Retrying to get a search going ($term)\n";
				sleep(300);
				$r = $agent->get($url);	# Go to this URL
			}
			if (!($r->is_success)) {
				die ("Can't get search going... Stopped while trying to get $term\n");
			}

			$content = $agent->content();
			#display("$content");
			
			##Here capture the number of results from the search page
			if ($content =~ m/<span class="count">\((\d+),(\d+)/) {
				$results = ($1.$2);
			} elsif (($content =~ m/<span class="count">\((\d+)건/) ) {
				$results = ($1);
			} else {
				$results = 0;
			}
			print $results." Results \n";

			##Here we print the number of results to target file
			print "Newspaper is: ".$paper."\n";
			print "$month - $year \n\n\n";
			print TARGET $paper.",".$month.",".$year.",".$term.",";
			print TARGET $results."\n";
			sleep $sleep_per_obs;
		}
	}	
}
close (TARGET);
  