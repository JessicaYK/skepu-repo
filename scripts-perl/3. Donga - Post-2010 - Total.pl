# ===================================================================== #
# Web-scraping the total number of articles from Donga (Post 2010)
# Author: Scott R. Baker, Jessica YK Koh
# Modified: 2016/08/10 
# ===================================================================== #
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
my ($target) = "$pwd/../output/counts/dongapost2010total.csv";
my $agent = new WWW::Mechanize(quiet => 1 , onerror => undef , stack_depth => 30);
$agent->agent_alias( 'Windows IE 6' );

open (TARGET, ">$target") or die ("Couldn't open $target for writing\n");

my @term_set = ('.');
my @year_loop = (2010 .. 2016);
my @month_loop = (1 .. 12);
my @day_loop = (1 .. 31);

foreach $term (@term_set) {
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
			
				###Now fill in the various elements of the search like dates, term, paper
				my $sdate = "$year$month_new$day_begin";
				my $edate = "$year$month_new$day_end";
				print "fromDate: $sdate, toDate: $edate \n";
			
				#########Here we will determine the number of results for each day only for the given terms###################
				my $url = "http://news.donga.com/Pdf?media=1&query=.&range=1&p0=&sdate=".$sdate."&edate=".$edate;
				my $r= $agent->get($url);

				my $content = $agent->content();
				#display("$content");

				##Here capture the number of results from the search page
				if ($content =~ m/<strong class="num">(\d+),(\d+)/) {
					$results = ($1.$2);
				} elsif ($content =~ m/<strong class="num">(\d+)건/) {
					$results = ($1);
				} else {
					$results = 0;
				}
				print $results." Results \n";

			##Here we print the number of results to target file
			print "Newspaper is: Donga Ilbo \n";
			print "$month - $year \n\n\n";
			print TARGET $paper.",".$month.",".$year.",".$term.",";
			print TARGET $results."\n";
			sleep $sleep_per_obs;
		}
	}
}

close (TARGET);
  