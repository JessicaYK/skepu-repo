use WWW::Mechanize;
use HTML::Display;
use utf8;

# This sets the expected waiting time between observations (to avoid the website from locking)
my $sleep_per_obs = 1;

# This sets the maximum number of attempts to get a page. If after this amount we still get an error, we give up.
my $max_attempts = 70;

my ($target) = @ARGV;
my $agent = new WWW::Mechanize(quiet => 1 , onerror => undef , stack_depth => 30);
$agent->agent_alias( 'Windows Mozilla' );

open (TARGET, ">$target") or die ("Couldn't open $target for writing\n");

my @term_set = ('불확실성');
my @term_set = ('(불확실성|불확실) (경제의|경제|무역|상업) (정부|청와대|국회|당국|제정|제정법|입법|정책|방침|시책|세금|세|규제|통제|규정|한국은행|한은|중앙은행|적자|부족|WTO|세계무역기구|법|법안|기획재정부|기재부)');
my @term_set = ('(불확실성|불확실)');
my @term_set = ('(불확실성');

my @year_loop = (2000 .. 2016);
my @month_loop = (1..12);

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
		
			#########Here we will determine the number of results for each day only for the given terms
			my $url = "http://srchdb1.chosun.com/pdf/i_archive/search.jsp";
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
			my $startDate = "$year$month$day_begin";
			my $endDate = "$year$month$day_end";
			###Here we're making the form accept Korean characters as an input
			$agent->form_number(2);
			$agent->form_number(2)->accept_charset('euc-kr');
			$agent->field('FV', $term);
			$agent->field('requestSearchPage','simple');
			$agent->field('collectionName','gisa');
			$agent->tick('INDEX_FV','TI');
			$agent->tick('INDEX_FV','KW');
			$agent->tick('INDEX_FV','TX');
			$agent->field('AU_FV','');
			$agent->field('SEARCH_OPTION','false');
			$agent->field('FILTER_CN','');
			$agent->field('FILTER_WC','');
			$agent->field('WC_OPTION','within');
			$agent->field('PD_F1',$startDate);
			$agent->field('PD_F2',$endDate);
			$agent->field('PD_TYPE','false');
			$agent->field('PD_F0','year');
			$agent->field('PD_OP',1);
			$agent->field('PP_F1','');
			$agent->field('LIMIT',20);
			$agent->field('LIST_TYPE','true');
			$agent->field('DATA_SORT',4);
			$agent->submit();
			
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
			$content =~ m/<font color="red" class="SFont">.*?(\d+).*?<\/font>/is;
			$results = ($1);
			if (!$results) {
				$results = 0;
			}
			print $results." Results \n";

			##Here we print the number of results to target file
			#print "$term \n";
			print "Newspaper is: Chosun \n";
			print "$month - $year \n\n\n";
			print TARGET $paper.",".$month.",".$year.",".$term.",";
			print TARGET $results."\n";
			sleep $sleep_per_obs;
		}
	}
}
close (TARGET);
  