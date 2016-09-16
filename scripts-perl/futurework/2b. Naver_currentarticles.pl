use WWW::Mechanize;
use HTML::Display;
use utf8;
use Win32::IEAutomation;

# This sets the expected waiting time between observations (to avoid the website from locking)
my $sleep_per_obs = 2;

# This sets the maximum number of attempts to get a page. If after this amount we still get an error, we give up.
my $max_attempts = 70;

my ($target) = @ARGV;
my $agent = new WWW::Mechanize(autocheck => 1, quiet => 1 , onerror => undef , stack_depth => 30);
$agent->agent_alias( 'Windows Mozilla' );
$agent->max_redirect(5);

open (TARGET, ">$target") or die ("Couldn't open $target for writing\n");

my @paper_set = ('020','009','028');

#032 = 경향신문 - Kyunghyang Daily News
#020 = 동아일보 - Dong A News
#009 = 매일경제 = Maeil Economic News
#028 = 한겨레 = Hankyoreh
#한국 = Korea

#my @term_set = ("(%B0%E6%C1%A6%C0%C7%20|%20%B0%E6%C1%A6%20|%20%BB%E7%BE%F7%20|%20%B9%AB%BF%AA%20|%20%BB%F3%BE%F7)%20&%20(%BA%D2%C8%AE%BD%C7%BC%BA%20|%20%BA%D2%C8%AE%BD%C7)%20&%20(%C1%A4%BA%CE%20|%20%C3%BB%BF%CD%B4%EB%20|%20%B1%B9%C8%B8%20|%20%BB%F3%BF%F8%20|%20%C7%CF%BF%F8%20|%20%B4%E7%B1%B9%20|%20%C1%A6%C1%A4%20|%20%C1%A6%C1%A4%B9%FD%20|%20%C0%D4%B9%FD%20|%20%C1%A4%C4%A1%C0%FB%20|%20%C1%A4%C3%A5%20|%20%B9%E6%C4%A7%20|%20%BD%C3%C3%A5%20|%20%BC%BC%B1%DD%20|%20%BC%BC%20|%20%C1%F6%C3%E2%20|%20%BC%D2%BA%F1%20|%20%B1%D4%C1%A6%20|%20%C5%EB%C1%A6%20|%20%B1%D4%C1%A4%20|%20%C7%D1%B1%B9%C0%BA%C7%E0%20|%20%C7%D1%C0%BA%20|%20%C1%DF%BE%D3%C0%BA%C7%E0%20|%20%BF%B9%BB%EA%20|%20%C0%FB%C0%DA%20|%20%BA%CE%C1%B7%20|%20%B0%B3%C7%F5%20|%20%B0%B3%BC%B1%20|%20%B1%DD%B8%AE%20|%20%C0%CC%C0%B2%20|%20%BA%CF%B0%E6%20|%20%BA%A3%C0%CC%C2%A1%20|%20WTO%20|%20%BC%BC%B0%E8%B9%AB%BF%AA%B1%E2%B1%B8%20|%20%B9%AB%BF%AA%C1%A4%C3%A5%20|%20%C0%E7%B9%AB%BA%CE%20|%20%BD%C5%BF%EB%C1%A1%BC%F6%20|%20%B9%FD%20|%20%B9%FD%BE%C8%20|%20%BA%CE%C3%B3%20|%20%B1%E2%C8%B9%C0%E7%C1%A4%BA%CE%20|%20%B9%FD%B9%AB%BA%CE%20|%20%C7%E3%B0%A1%20|%20%BD%C2%C0%CE%20|%20%C0%CE%B0%A1%20|%20%C3%A4%B9%AB%20|%20%BA%CE%C3%A4%20|%20%B1%B9%C3%A4%20|%20%B4%EB%BF%DC%C3%A4%B9%AB%20|%20%B3%BB%B1%B9%C3%A4%20|%20%C1%D6%BD%C4%20|%20%C1%D6%BD%C4%BC%F6%C0%CD%B7%FC%20|%20%C1%D6%B0%A1%20|%20%C4%DA%BD%BA%C7%C7%C1%F6%BC%F6%20|%20%C4%DA%BD%BA%B4%DA%C1%F6%BC%F6%20|%20%B1%DD%C0%B6%C0%A7%B1%E2%20|%20%C0%E7%C1%A4%C0%A7%B1%E2%20|%20%BC%BC%B0%E8%B1%DD%C0%B6%C0%A7%B1%E2%20|%20%B8%AE%B8%B8%20|%20%BA%CF%C7%D1%B5%B5%B9%DF%20|%20%BA%CF%C7%D1%C7%D9%20|%20%BA%CF%C7%D9%20|%20%B3%B2%BA%CF%C8%B8%B4%E3)");
#my @term_set = ("(%28%BA%D2%C8%AE%BD%C7%BC%BA+%7C+%BA%D2%C8%AE%BD%C7+%7C+%B0%E6%C1%A6%C0%C7+%7C+%B0%E6%C1%A6+%7C+%BB%E7%BE%F7+%7C+%B9%AB%BF%AA+%7C+%BB%F3%BE%F7%29+%26+%28%C1%A4%BA%CE+%7C+%C3%BB%BF%CD%B4%EB+%7C+%B1%B9%C8%B8+%7C+%BB%F3%BF%F8+%7C+%C7%CF%BF%F8+%7C+%B4%E7%B1%B9+%7C+%C1%A6%C1%A4+%7C+%C1%A6%C1%A4%B9%FD+%7C+%C0%D4%B9%FD+%7C+%C1%A4%C4%A1%C0%FB+%7C+%C1%A4%C3%A5+%7C+%B9%E6%C4%A7+%7C+%BD%C3%C3%A5+%7C+%BC%BC%B1%DD+%7C+%BC%BC+%7C+%C1%F6%C3%E2+%7C+%BC%D2%BA%F1+%7C+%B1%D4%C1%A6+%7C+%C5%EB%C1%A6+%7C+%B1%D4%C1%A4+%7C+%C7%D1%B1%B9%C0%BA%C7%E0+%7C+%C7%D1%C0%BA+%7C+%C1%DF%BE%D3%C0%BA%C7%E0+%7C+%BF%B9%BB%EA+%7C+%C0%FB%C0%DA+%7C+%BA%CE%C1%B7+%7C+%B0%B3%C7%F5+%7C+%B0%B3%BC%B1+%7C+%B1%DD%B8%AE+%7C+%C0%CC%C0%B2+%7C+%BA%CF%B0%E6+%7C+%BA%A3%C0%CC%C2%A1+%7C+WTO+%7C+%BC%BC%B0%E8%B9%AB%BF%AA%B1%E2%B1%B8+%7C+%B9%AB%BF%AA%C1%A4%C3%A5+%7C+%C0%E7%B9%AB%BA%CE+%7C+%BD%C5%BF%EB%C1%A1%BC%F6+%7C+%B9%FD+%7C+%B9%FD%BE%C8+%7C+%BA%CE%C3%B3+%7C+%B1%E2%C8%B9%C0%E7%C1%A4%BA%CE+%7C+%B9%FD%B9%AB%BA%CE+%7C+%C7%E3%B0%A1+%7C+%BD%C2%C0%CE+%7C+%C0%CE%B0%A1+%7C+%C3%A4%B9%AB+%7C+%BA%CE%C3%A4+%7C+%B1%B9%C3%A4+%7C+%B4%EB%BF%DC%C3%A4%B9%AB+%7C+%B3%BB%B1%B9%C3%A4+%7C+%C1%D6%BD%C4+%7C+%C1%D6%BD%C4%BC%F6%C0%CD%B7%FC+%7C+%C1%D6%B0%A1+%7C+%C4%DA%BD%BA%C7%C7+%7C+%C4%DA%BD%BA%B4%DA+%7C+%B1%DD%C0%B6%C0%A7%B1%E2+%7C+%C0%E7%C1%A4%C0%A7%B1%E2+%7C+%BC%BC%B0%E8%B1%DD%C0%B6%C0%A7%B1%E2+%7C+%B8%AE%B8%B8+%7C+%BA%CF%C7%D1%B5%B5%B9%DF+%7C+%BA%CF%C7%D1%C7%D9+%7C+%BA%CF%C7%D9+%7C+%B3%B2%BA%CF%C8%B8%B4%E3%29)");
my @term_set = ('(%BA%D2%C8%AE%BD%C7%BC%BA+%7C+%BA%D2%C8%AE%BD%C7)+%2B+(%B0%E6%C1%A6%C0%C7+%7C+%B0%E6%C1%A6+%7C+%BB%E7%BE%F7+%7C+%B9%AB%BF%AA+%7C+%BB%F3%BE%F7)+%2B+(%C1%A4%BA%CE+%7C+%C3%BB%BF%CD%B4%EB+%7C+%B1%B9%C8%B8+%7C+%BB%F3%BF%F8+%7C+%C7%CF%BF%F8+%7C+%B4%E7%B1%B9+%7C+%C1%A6%C1%A4+%7C+%C1%A6%C1%A4%B9%FD+%7C+%C0%D4%B9%FD+%7C+%C1%A4%C4%A1%C0%FB+%7C+%C1%A4%C3%A5+%7C+%B9%E6%C4%A7+%7C+%BD%C3%C3%A5+%7C+%BC%BC%B1%DD+%7C+%BC%BC+%7C+%C1%F6%C3%E2+%7C+%BC%D2%BA%F1+%7C+%B1%D4%C1%A6+%7C+%C5%EB%C1%A6+%7C+%B1%D4%C1%A4+%7C+%C7%D1%B1%B9%C0%BA%C7%E0+%7C+%C7%D1%C0%BA+%7C+%C1%DF%BE%D3%C0%BA%C7%E0+%7C+%BF%B9%BB%EA+%7C+%C0%FB%C0%DA+%7C+%BA%CE%C1%B7+%7C+%B0%B3%C7%F5+%7C+%B0%B3%BC%B1+%7C+%B1%DD%B8%AE+%7C+%C0%CC%C0%B2+%7C+%BA%CF%B0%E6+%7C+%BA%A3%C0%CC%C2%A1+%7C+WTO+%7C+%BC%BC%B0%E8%B9%AB%BF%AA%B1%E2%B1%B8+%7C+%B9%AB%BF%AA%C1%A4%C3%A5+%7C+%C0%E7%B9%AB%BA%CE+%7C+%BD%C5%BF%EB%C1%A1%BC%F6+%7C+%B9%FD+%7C+%B9%FD%BE%C8+%7C+%BA%CE%C3%B3+%7C+%B1%E2%C8%B9%C0%E7%C1%A4%BA%CE+%7C+%B9%FD%B9%AB%BA%CE+%7C+%C7%E3%B0%A1+%7C+%BD%C2%C0%CE+%7C+%C0%CE%B0%A1+%7C+%C3%A4%B9%AB+%7C+%BA%CE%C3%A4+%7C+%B1%B9%C3%A4+%7C+%B4%EB%BF%DC%C3%A4%B9%AB+%7C+%B3%BB%B1%B9%C3%A4+%7C+%C1%D6%BD%C4+%7C+%C1%D6%BD%C4%BC%F6%C0%CD%B7%FC+%7C+%C1%D6%B0%A1+%7C+%C4%DA%BD%BA%C7%C7+%7C+%C4%DA%BD%BA%B4%DA+%7C+%B1%DD%C0%B6%C0%A7%B1%E2+%7C+%C0%E7%C1%A4%C0%A7%B1%E2+%7C+%BC%BC%B0%E8%B1%DD%C0%B6%C0%A7%B1%E2+%7C+%B8%AE%B8%B8+%7C+%BA%CF%C7%D1%B5%B5%B9%DF+%7C+%BA%CF%C7%D1%C7%D9+%7C+%BA%CF%C7%D9+%7C+%B3%B2%BA%CF%C8%B8%B4%E3)');

my @year_loop = (2013 .. 2013);
my @month_loop = (1..1);


foreach $paper (@paper_set) {
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
					$month = "0".$month;
				}
			
				#########Here we will try to load the results page
				my $url = "http://news.naver.com/main/search/search.nhn?refresh=&so=rel.dsc&stPhoto=&stPaper=&stRelease=&detail=0&rcsection=&query=".$term."&x=38&y=11&sm=all.basic&pd=4&startDate=".$year."-".$month."-".$day_begin."&endDate=".$year."-".$month."-".$day_end."&newscode=".$paper."";
				#print $url;
				my $r= $agent->get($url);
				

				my $content = $agent->content();
				#display("$content");

				for (my $attempt = 1 ; (!($r->is_success) && $attempt <= $max_attempts) ; $attempt++) {
					print STDERR "Retrying to get a search going ($term: $month-$day_begin-$year)\n";
					sleep(60);
					$r = $agent->get($url);	# Go to this URL
				}
				if (!($r->is_success)) {
					die ("Can't get search going... Stopped while trying to get $term: $month-$day_begin-$year\n");
				}
				

				##Here capture the number of results from the search page
				$content =~ m/result_num">.*?\/.*?(\d*,?\d+)/is;
				$results = ($1);
				if (!$results) {
					$results = 0;
				}
				print $results." Results \n";

				##Here we print the number of results to target file
				#print "$term \n";
				print "Newspaper is: ".$paper."\n";
				print "$month - $year \n\n\n";
				print TARGET $paper.",".$month.",".$year.",".$term.",";
				print TARGET $results."\n";
				sleep $sleep_per_obs;
			}
		}
	}
}
close (TARGET);
