# ============================================================ #
# Web-scraping the number of Korean EPU articles from Donga
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
my ($target) = "$pwd/../output/counts/dongapre2010epu.csv";
my $agent = new WWW::Mechanize(quiet => 1 , onerror => undef , stack_depth => 30);
$agent->agent_alias( 'Windows IE 6' );

open (TARGET, ">$target") or die ("Couldn't open $target for writing\n");

my @term_set = ('%28%EB%B6%88%ED%99%95%EC%8B%A4%EC%84%B1+OR+%EB%B6%88%ED%99%95%EC%8B%A4%29+AND+%28%EA%B2%BD%EC%A0%9C%EC%9D%98+OR+%EA%B2%BD%EC%A0%9C+OR+%EB%AC%B4%EC%97%AD+OR+%EC%83%81%EC%97%85%29+AND+%28%EC%A0%95%EB%B6%80+OR+%EC%B2%AD%EC%99%80%EB%8C%80+OR+%EA%B5%AD%ED%9A%8C+OR+%EB%8B%B9%EA%B5%AD+OR+%EC%A0%9C%EC%A0%95+OR+%EC%A0%9C%EC%A0%95%EB%B2%95+OR+%EC%9E%85%EB%B2%95+OR+%EC%A0%95%EC%B1%85+OR+%EB%B0%A9%EC%B9%A8+OR+%EC%8B%9C%EC%B1%85+OR+%EC%84%B8%EA%B8%88+OR+%EC%84%B8+OR+%EA%B7%9C%EC%A0%9C+OR+%ED%86%B5%EC%A0%9C+OR+%EA%B7%9C%EC%A0%95+OR+%ED%95%9C%EA%B5%AD%EC%9D%80%ED%96%89+OR+%ED%95%9C%EC%9D%80+OR+%EC%A4%91%EC%95%99%EC%9D%80%ED%96%89+OR+%EC%A0%81%EC%9E%90+OR+%EB%B6%80%EC%A1%B1+OR+WTO+OR+%EC%84%B8%EA%B3%84%EB%AC%B4%EC%97%AD%EA%B8%B0%EA%B5%AC+OR+%EB%B2%95+OR+%EB%B2%95%EC%95%88+OR+%EA%B8%B0%ED%9A%8D%EC%9E%AC%EC%A0%95%EB%B6%80+OR+%EA%B8%B0%EC%9E%AC%EB%B6%80%29');
my @year_loop = (1920 .. 2009);
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
				my $url = "http://news.donga.com/Pdf?p1=&media=16&query=".$term."&range=1&search_date=5&sdate=".$sdate."&edate=".$edate;
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
  