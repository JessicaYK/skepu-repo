use WWW::Mechanize;
use HTML::Display;
use utf8;

# This sets the expected waiting time between observations (to avoid the website from locking)
my $sleep_per_obs = 1;

# This sets the maximum number of attempts to get a page. If after this amount we still get an error, we give up.
my $max_attempts = 70;

my ($target) = @ARGV;
my $agent = new WWW::Mechanize(quiet => 1 , onerror => undef , stack_depth => 30);
$agent->agent_alias( 'Windows IE 6' );

open (TARGET, ">$target") or die ("Couldn't open $target for writing\n");

my @paper_set = ('01100401','01101001','01101101','01100101','02100101','02100601');

#01100401 = Donga Ilbo
#01101001 = Hankyoreh
#01101101 = Hankook Ilbo
#01100101 = Kyunghang Daily News
#02100101 = Maeil Economic Daily
#02100601 = Korea Economic Daily

my @term_set = ('(불확실성|불확실) (경제의|경제|사업|무역|상업) (정부|청와대|국회|상원|하원|당국|제정|제정법|입법|정치적|정책|방침|시책|세금|세|지출|소비|규제|통제|규정|한국은행|한은|중앙은행|예산|적자|부족|개혁|개선|금리|이율|북경|베이징|WTO|세계무역기구|무역정책|재무부|신용점수|법|법안|부처|기획재정부|법무부|허가|승인|인가|채무|부채|국채|대외채무|내국채|주식|주식수익률|주가|코스피|코스닥|금융위기|재정위기|세계금융위기|리만|북한도발|북한핵|북핵|남북회담)');
my @year_loop = (2015 .. 2015);
my @month_loop = (9..11);

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
				
				#########Here we will determine the number of results for each day only for the given terms
				my $url = "http://www.mediagaon.or.kr/jsp/sch/mtotal/search.jsp";
				my $r= $agent->get($url);
				#print $url;
				
				for (my $attempt = 1 ; (!($r->is_success) && $attempt <= $max_attempts) ; $attempt++) {
					print STDERR "Retrying to get a search going ($term: $month-$day_begin-$year)\n";
					sleep(60);
					$r = $agent->get($url);	# Go to this URL
				}
				if (!($r->is_success)) {
					die ("Can't get search going... Stopped while trying to get $term: $month-$day_begin-$year\n");
				}

				my $content = $agent->content();
				#display("$content");
				
				###Now fill in the various elements of the search like dates, term, paper
				my $startDate = "$year.$month.$day_begin";
				my $endDate = "$year.$month.$day_end";
				my $query = "$term";
				###This is the newspaper; must check online to figure out which ID is for which paper
				my $prefixQuery = "<ProviderId:contains:$paper>";

				###Here we're making the form accept Korean characters as an input
				$agent->form_name('frmSearch')->accept_charset('euc-kr');

				##Now submit the form to get to the search page
				my $r= $agent->submit_form(form_name => 'frmSearch', fields => { startDate => $startDate, endDate =>$endDate, query=>$query , prefixQuery=>$prefixQuery });
				
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
				$content =~ m/totalCount" value="(\d+)"/is;
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
  