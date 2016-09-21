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

my @paper_set = ('01000', '00100', '00010', '00001');
my @paper_set = ('01000');

#01000 = 경향신문 - 
#00100 = 동아일보 - Dong A
#00010 = 매일경제 = Kyunghyang Daily News
#00001 = 한겨레 = Hankyoreh
#한국 = Korea

my @term_set = ('(%EB%B6%88%ED%99%95%EC%8B%A4%EC%84%B1%20%7C%20%EB%B6%88%ED%99%95%EC%8B%A4)%20%26%20(%EA%B2%BD%EC%A0%9C%EC%9D%98%20%7C%20%EA%B2%BD%EC%A0%9C%20%7C%20%EC%82%AC%EC%97%85%20%7C%20%EB%AC%B4%EC%97%AD%20%7C%20%EC%83%81%EC%97%85)%20%26%20(%EC%A0%95%EB%B6%80%20%7C%20%EC%B2%AD%EC%99%80%EB%8C%80%20%7C%20%EA%B5%AD%ED%9A%8C%20%7C%20%EC%83%81%EC%9B%90%20%7C%20%ED%95%98%EC%9B%90%20%7C%20%EB%8B%B9%EA%B5%AD%20%7C%20%EC%A0%9C%EC%A0%95%20%7C%20%EC%A0%9C%EC%A0%95%EB%B2%95%20%7C%20%EC%9E%85%EB%B2%95%20%7C%20%EC%A0%95%EC%B9%98%EC%A0%81%20%7C%20%EC%A0%95%EC%B1%85%20%7C%20%EB%B0%A9%EC%B9%A8%20%7C%20%EC%8B%9C%EC%B1%85%20%7C%20%EC%84%B8%EA%B8%88%20%7C%20%EC%84%B8%20%7C%20%EC%A7%80%EC%B6%9C%20%7C%20%EC%86%8C%EB%B9%84%20%7C%20%EA%B7%9C%EC%A0%9C%20%7C%20%ED%86%B5%EC%A0%9C%20%7C%20%EA%B7%9C%EC%A0%95%20%7C%20%ED%95%9C%EA%B5%AD%EC%9D%80%ED%96%89%20%7C%20%ED%95%9C%EC%9D%80%20%7C%20%EC%A4%91%EC%95%99%EC%9D%80%ED%96%89%20%7C%20%EC%98%88%EC%82%B0%20%7C%20%EC%A0%81%EC%9E%90%20%7C%20%EB%B6%80%EC%A1%B1%20%7C%20%EA%B0%9C%ED%98%81%20%7C%20%EA%B0%9C%EC%84%A0%20%7C%20%EA%B8%88%EB%A6%AC%20%7C%20%EC%9D%B4%EC%9C%A8%20%7C%20%EB%B6%81%EA%B2%BD%20%7C%20%EB%B2%A0%EC%9D%B4%EC%A7%95%20%7C%20WTO%20%7C%20%EC%84%B8%EA%B3%84%EB%AC%B4%EC%97%AD%EA%B8%B0%EA%B5%AC%20%7C%20%EB%AC%B4%EC%97%AD%EC%A0%95%EC%B1%85%20%7C%20%EC%9E%AC%EB%AC%B4%EB%B6%80%20%7C%20%EC%8B%A0%EC%9A%A9%EC%A0%90%EC%88%98%20%7C%20%EB%B2%95%20%7C%20%EB%B2%95%EC%95%88%20%7C%20%EB%B6%80%EC%B2%98%20%7C%20%EA%B8%B0%ED%9A%8D%EC%9E%AC%EC%A0%95%EB%B6%80%20%7C%20%EB%B2%95%EB%AC%B4%EB%B6%80%20%7C%20%ED%97%88%EA%B0%80%20%7C%20%EC%8A%B9%EC%9D%B8%20%7C%20%EC%9D%B8%EA%B0%80%20%7C%20%EC%B1%84%EB%AC%B4%20%7C%20%EB%B6%80%EC%B1%84%20%7C%20%EA%B5%AD%EC%B1%84%20%7C%20%EB%8C%80%EC%99%B8%EC%B1%84%EB%AC%B4%20%7C%20%EB%82%B4%EA%B5%AD%EC%B1%84%20%7C%20%EC%A3%BC%EC%8B%9D%20%7C%20%EC%A3%BC%EC%8B%9D%EC%88%98%EC%9D%B5%EB%A5%A0%20%7C%20%EC%A3%BC%EA%B0%80%20%7C%20%EC%BD%94%EC%8A%A4%ED%94%BC%20%7C%20%EC%BD%94%EC%8A%A4%EB%8B%A5%20%7C%20%EA%B8%88%EC%9C%B5%EC%9C%84%EA%B8%B0%20%7C%20%EC%9E%AC%EC%A0%95%EC%9C%84%EA%B8%B0%20%7C%20%EC%84%B8%EA%B3%84%EA%B8%88%EC%9C%B5%EC%9C%84%EA%B8%B0%20%7C%20%EB%A6%AC%EB%A7%8C%20%7C%20%EB%B6%81%ED%95%9C%EB%8F%84%EB%B0%9C%20%7C%20%EB%B6%81%ED%95%9C%ED%95%B5%20%7C%20%EB%B6%81%ED%95%B5%20%7C%20%EB%82%A8%EB%B6%81%ED%9A%8C%EB%8B%B4)');
my @term_set = ('(%EB%B6%88%ED%99%95%EC%8B%A4%EC%84%B1%20%7C%20%EB%B6%88%ED%99%95%EC%8B%A4)');

my @year_loop = (1998 .. 1998);

foreach $paper (@paper_set) {
	foreach $term (@term_set) {
		for my $year (@year_loop) {
		my @month_loop = (1..12);
			foreach my $month (@month_loop) {
				my $ie = Win32::IEAutomation->new(visible=>0, 'InternetExplorer.Application' )  or die "error starting IE";
				$ie->{RegisterAsBrowser} = 1;

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
				my $url = "http://newslibrary.naver.com/search/searchDetails.nhn#%7B%22mode%22%3A1%2C%22sort%22%3A0%2C%22trans%22%3A%221%22%2C%22pageSize%22%3A10%2C%22keyword%22%3A%22".$term."%22%2C%22startDate%22%3A%22".$year."-".$month."-".$day_begin."%22%2C%22endDate%22%3A%22".$year."-".$month."-".$day_end."%22%2C%22status%22%3A%22success%22%2C%22office%22%3A%22".$paper."%22%2C%22pageno%22%3A%2210%22%2C%22section%22%3A%22111111111%22%2C%22type%22%3A%22111111111111111111111111111%22%2C%22scope%22%3A%2210%22%2C%22page%22%3A1%7D";
				#print $url;
				my $r= $agent->get($url);
				
				my $pre_content = $agent->content();
				#display("$pre_content");

				######HERE WE'RE HAVING TO LOGIN
				if ($pre_content =~ m/naverLoginURL/is) {
					print "LOGIN PAGE HIT!!\n\n";
					my $url = "https://nid.naver.com/nidlogin.login?mode=form&url=http%3A//newslibrary.naver.com/search/searchDetails.nhn";
					my $url = "https://nid.naver.com/nidlogin.login";
					my $r= $agent->get($url);

					my $username = "srbaker";
					my $password = "idw2rtp13";
					
					#$ie->getTextBox('name:', "id")->SetValue($username);
					#$ie->getTextBox('name:', "pw")->SetValue($password);
					#$ie->getButton('caption:', "Sign in")->Click;

					my $r= $agent->submit_form(fields => { pw => $password, id =>$username, label_pw_area => $password, label_id_area =>$username, encpw=> $password, encnm=>$username, pw_area=> $password, id_area=>$username});
				}
				
				my $content = $agent->content();
				display("$content");

				for (my $attempt = 1 ; (!($r->is_success) && $attempt <= $max_attempts) ; $attempt++) {
					print STDERR "Retrying to get a search going ($term: $month-$day_begin-$year)\n";
					sleep(60);
					$r = $agent->get($url);	# Go to this URL
				}
				if (!($r->is_success)) {
					die ("Can't get search going... Stopped while trying to get $term: $month-$day_begin-$year\n");
				}
				
				#########Here we we're loading the results page again after logging in
				my $url = "http://newslibrary.naver.com/search/searchDetails.nhn#%7B%22mode%22%3A1%2C%22sort%22%3A0%2C%22trans%22%3A%221%22%2C%22pageSize%22%3A10%2C%22keyword%22%3A%22".$term."%22%2C%22startDate%22%3A%22".$year."-".$month."-".$day_begin."%22%2C%22endDate%22%3A%22".$year."-".$month."-".$day_end."%22%2C%22status%22%3A%22success%22%2C%22office%22%3A%22".$paper."%22%2C%22pageno%22%3A%2210%22%2C%22section%22%3A%22111111111%22%2C%22type%22%3A%22111111111111111111111111111%22%2C%22scope%22%3A%2210%22%2C%22page%22%3A1%7D";
				
				$ie -> gotoURL($url);
				
				while( $ie->{Busy} ) {
					while ($ie->SpinMessageLoop()) { select undef,undef,undef,0.5; }
				}

				sleep(2);
				$ie->WaitforDone();
				$content = $ie->PageText();
				#display("$content");

				##Here capture the number of results from the search page
				$content =~ m/\(1-10\/(\d+?,?\d+)/is;
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
				$ie ->closeIE();
			}
		}
	}
}
close (TARGET);
