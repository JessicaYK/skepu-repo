# ============================================================ #
# Web-scraping the number of Korean EPU articles from Bigkinds
# Author: Scott R. Baker, Jessica YK Koh
# Modified: 2017/05/06 
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
my ($target) = "$pwd/../output/counts/bigkinds.csv";
my $agent = new WWW::Mechanize(quiet => 1 , onerror => undef , stack_depth => 30);
$agent->agent_alias( 'Windows IE 6' );

open (TARGET, ">$target") or die ("Couldn't open $target for writing\n");

my @paper_set = ('01101001', '01101101', '01100101', '02100101', '02100601');
my @paper_set = ('01101001');

#01100401 = Donga Ilbo (not in Bigkinds)
#01101001 = Hankyoreh
#01101101 = Hankook Ilbo
#01100101 = Kyunghang Daily News
#02100101 = Maeil Economic Daily
#02100601 = Korea Economic Daily

my @term_set = ('("불확실성" OR "불확실") AND ("경제의" OR "경제" OR "무역" OR "상업") AND ("정부" OR "청와대" OR "국회" OR "당국" OR "제정" OR "제정법" OR "입법" OR "정책" OR "방침" OR "시책" OR "세금" OR "세" OR "규제" OR "통제" OR "규정" OR "한국은행" OR "한은" OR "중앙은행" OR "적자" OR "부족" OR "세계무역기구" OR "법" OR "법안" OR "기획재정부" OR "기재부")');
my @term_set = ('("불확실성" OR "불확실")');
my @year_loop = (2016 .. 2016);
my @month_loop = (1 .. 1);
my @day_loop = (1 .. 31);

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
				$month_new = "0".$month;
				} else {
				$month_new = $month;
				}
				
				#########Here we will determine the number of results for each day only for the given terms
				my $url = "http://www.bigkinds.or.kr/";
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
				display("$content");	##Display the Bigkinds page

			}
		}
	}
}
close (TARGET);