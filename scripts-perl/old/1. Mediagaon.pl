use WWW::Mechanize;
use HTML::Display;
use utf8;

# This sets the expected waiting time between observations (to avoid the website from locking)
my $sleep_per_obs = 1;

# This sets the maximum number of attempts to get a page. If after this amount we still get an error, we give up.
my $max_attempts = 70;

my ($target) = bigkinds.csv;
my $agent = new WWW::Mechanize(quiet => 1 , onerror => undef , stack_depth => 30);
$agent->agent_alias( 'Windows IE 6' );

open (TARGET, ">$target") or die ("Couldn't open $target for writing\n");

my @paper_set = ('01100401', '01101001', '01101101', '01100101', '02100101', '02100601');

#01100401 = Donga Ilbo
#01101001 = Hankyoreh
#01101101 = Hankook Ilbo
#01100101 = Kyunghang Daily News
#02100101 = Maeil Economic Daily
#02100601 = Korea Economic Daily

my @term_set = ('(불확실성 OR 불확실) AND (경제의 OR 경제 OR 무역 OR 상업) AND (정부 OR 청와대 OR 국회 OR 당국 OR 제정 OR 제정법 OR 입법 OR 정책 OR 방침 OR 시책 OR 세금 OR 세 OR 규제 OR 통제 OR 규정 OR 한국은행 OR 한은 OR 중앙은행 OR 적자 OR 부족 OR WTO OR 세계무역기구 OR 법 OR 법안 OR 기획재정부 OR 기재부)');
my @year_loop = (2014 .. 2014);
my @month_loop = (1..12);
my @day_loop = (1..31);

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
				my $url = "http://www.bigkinds.or.kr/search/totalSearchList.do";
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
				my $r= $agent->submit_form(form_name => 'frmSearch', fields => { fromDate => $startDate, toDate =>$endDate, query=>$query , prefixQuery=>$prefixQuery });
				
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
  