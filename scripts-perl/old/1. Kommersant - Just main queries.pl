use WWW::Mechanize;
use HTML::Display;
use LWP::Debug qw(+);

# This sets the expected waiting time between observations (to avoid the website from locking)
my $sleep_per_obs = 5;

# This sets the maximum number of attempts to get a page. If after this amount we still get an error, we give up.
my $max_attempts = 70;

my ($target) = @ARGV;
my $agent = new WWW::Mechanize(quiet => 1 , onerror => undef , stack_depth => 30);
$agent->agent_alias( 'Windows Mozilla' );

open (TARGET, ">Kommersant_EPU_Data/$target") or die ("Couldn't open $target for writing\n");

my @paper_set = ("Kommersant");

#Terms sets are: all, EU, US version, Europe version, Expanded with no tax/budget/spending terms; equity uncert; expanded EPU =US+Euro
my @term_set = ('', '%28%ED%E5%EE%EF%F0%E5%E4%E5%EB%B8%ED%ED%EE%F1%F2%FC+%7C+%ED%E5%EE%EF%F0%E5%E4%E5%EB%E5%ED%ED%FB%E9+%7C+%ED%E5%F3%E2%E5%F0%E5%ED%ED%EE%F1%F2%FC%29+%2B+%28%FD%EA%EE%ED%EE%EC%E8%F7%E5%F1%EA%E8%E9+%7C+%FD%EA%EE%ED%EE%EC%E8%EA%E0%29', '%28%ED%E5%EE%EF%F0%E5%E4%E5%EB%B8%ED%ED%EE%F1%F2%FC+%7C+%ED%E5%EE%EF%F0%E5%E4%E5%EB%E5%ED%ED%FB%E9+%7C+%ED%E5%F3%E2%E5%F0%E5%ED%ED%EE%F1%F2%FC%29+%2B+%28%FD%EA%EE%ED%EE%EC%E8%F7%E5%F1%EA%E8%E9+%7C+%FD%EA%EE%ED%EE%EC%E8%EA%E0%29+%2B+%28%CA%F0%E5%EC%EB%FC+%7C+%22%D4%E5%E4%E5%F0%E0%EB%FC%ED%EE%E5+%F1%EE%E1%F0%E0%ED%E8%E5%22+%7C+%C4%F3%EC%E0+%7C+%22%D1%EE%E2%E5%F2+%D4%E5%E4%E5%F0%E0%F6%E8%E8%22+%7C+%E7%E0%EA%EE%ED%EE%E4%E0%F2%E5%EB%FC%F1%F2%E2%EE+%7C+%F0%E5%E3%F3%EB%E8%F0%EE%E2%E0%ED%E8%E5+%7C+%EA%EE%ED%F2%F0%EE%EB%FC+%7C+%F3%EF%F0%E0%E2%EB%E5%ED%E8%E5+%7C+%F0%E5%E3%F3%EB%E8%F0%F3%FE%F9%E8%E9+%7C+%ED%EE%F0%EC%E0%F2%E8%E2%ED%FB%E9+%7C+%22%D6%E5%ED%F2%F0%E0%EB%FC%ED%FB%E9+%C1%E0%ED%EA%22+%7C+%22%C1%E0%ED%EA+%D0%EE%F1%F1%E8%E8%22+%7C+%22%D6%C1+%D0%D4%22+%7C+%D6%E5%ED%F2%F0%EE%E1%E0%ED%EA+%7C+%22%D6%C1+%D0%EE%F1%F1%E8%E8%22+%7C+%E4%E5%F4%E8%F6%E8%F2+%7C+%E7%E0%EA%EE%ED+%7C+%22%E7%E0%EA%EE%ED%EE%E4%E0%F2%E5%EB%FC%ED%FB%E9+%E0%EA%F2%22+%7C+%22%EF%EE%F1%F2%E0%ED%EE%E2%EB%E5%ED%E8%E5+%EF%F0%E0%E2%E8%F2%E5%EB%FC%F1%F2%E2%E0%22+%7C+%22%F3%EA%E0%E7+%CF%F0%E5%E7%E8%E4%E5%ED%F2%E0%22+%7C+%22%EF%EE%F1%F2%E0%ED%EE%E2%EB%E5%ED%E8%E5+%EC%E8%ED%E8%F1%F2%E5%F0%F1%F2%E2%E0%22%29', '%28%ED%E5%EE%EF%F0%E5%E4%E5%EB%B8%ED%ED%EE%F1%F2%FC+%7C+%ED%E5%EE%EF%F0%E5%E4%E5%EB%E5%ED%ED%FB%E9+%7C+%ED%E5%F3%E2%E5%F0%E5%ED%ED%EE%F1%F2%FC%29+%2B+%28%FD%EA%EE%ED%EE%EC%E8%F7%E5%F1%EA%E8%E9+%7C+%FD%EA%EE%ED%EE%EC%E8%EA%E0%29+%2B+%28%EF%EE%EB%E8%F2%E8%EA%E0+%7C+%ED%E0%EB%EE%E3+%7C+%F0%E0%F1%F5%EE%E4%EE%E2%E0%ED%E8%E5+%7C+%F0%E0%F1%F5%EE%E4%FB+%7C+%F0%E5%E3%F3%EB%E8%F0%EE%E2%E0%ED%E8%E5+%7C+%EA%EE%ED%F2%F0%EE%EB%FC+%7C+%F3%EF%F0%E0%E2%EB%E5%ED%E8%E5+%7C+%F0%E5%E3%F3%EB%E8%F0%F3%FE%F9%E8%E9+%7C+%ED%EE%F0%EC%E0%F2%E8%E2%ED%FB%E9+%7C+%22%D6%E5%ED%F2%F0%E0%EB%FC%ED%FB%E9+%C1%E0%ED%EA%22+%7C+%22%C1%E0%ED%EA+%D0%EE%F1%F1%E8%E8%22+%7C+%22%D6%C1+%D0%D4%22+%7C+%D6%E5%ED%F2%F0%EE%E1%E0%ED%EA+%7C+%22%D6%C1+%D0%EE%F1%F1%E8%E8%22+%7C+%E1%FE%E4%E6%E5%F2+%7C+%E4%E5%F4%E8%F6%E8%F2%29' , '%28%ED%E5%F3%E2%E5%F0%E5%ED%ED%EE%F1%F2%FC+%7C+%ED%E5%EE%EF%F0%E5%E4%E5%EB%B8%ED%ED%EE%F1%F2%FC+%7C+%ED%E5%EE%EF%F0%E5%E4%E5%EB%E5%ED%ED%FB%E9%29+%2B+%28%E1%E8%E7%ED%E5%F1+%7C+%F2%EE%F0%E3%EE%E2%EB%FF+%7C+%EA%EE%EC%EC%E5%F0%F6%E8%FF+%7C+%FD%EA%EE%ED%EE%EC%E8%F7%E5%F1%EA%E8%E9+%7C+%FD%EA%EE%ED%EE%EC%E8%EA%E0%29+%2B+%28%CF%F0%E0%E2%E8%F2%E5%EB%FC%F1%F2%E2%EE+%7C+%22%C1%E5%EB%FB%E9+%C4%EE%EC%22+%7C+%E3%EE%F1%F3%E4%E0%F0%F1%F2%E2%EE+%7C+%CA%F0%E5%EC%EB%FC+%7C+%22%D4%E5%E4%E5%F0%E0%EB%FC%ED%EE%E5+%F1%EE%E1%F0%E0%ED%E8%E5%22+%7C+%C4%F3%EC%E0+%7C+%22%D1%EE%E2%E5%F2+%D4%E5%E4%E5%F0%E0%F6%E8%E8%22+%7C+%F0%F3%EA%EE%E2%EE%E4%F1%F2%E2%EE+%7C+%22%EE%F0%E3%E0%ED%FB+%E2%EB%E0%F1%F2%E8%22+%7C+%22%EE%F4%E8%F6%E8%E0%EB%FC%ED%FB%E5+%E2%EB%E0%F1%F2%E8%22+%7C+%22%F0%F3%EA%EE%E2%EE%E4%FF%F9%E8%E5+%EE%F0%E3%E0%ED%FB%22+%7C+%E3%EE%F1%F3%E4%E0%F0%F1%F2%E2%E5%ED%ED+%7C+%E7%E0%EA%EE%ED%EE%E4%E0%F2%E5%EB%FC%F1%F2%E2%EE+%7C+%F0%E5%E3%F3%EB%E8%F0%EE%E2%E0%ED%E8%E5+%7C+%EA%EE%ED%F2%F0%EE%EB%FC+%7C+%F3%EF%F0%E0%E2%EB%E5%ED%E8%E5+%7C+%F0%E5%E3%F3%EB%E8%F0%F3%FE%F9%E8%E9+%7C+%ED%EE%F0%EC%E0%F2%E8%E2%ED%FB%E9+%7C+%22%D6%E5%ED%F2%F0%E0%EB%FC%ED%FB%E9+%C1%E0%ED%EA%22+%7C+%22%C1%E0%ED%EA+%D0%EE%F1%F1%E8%E8%22+%7C+%22%D6%C1+%D0%D4%22+%7C+%D6%E5%ED%F2%F0%EE%E1%E0%ED%EA+%7C+%22%D6%C1+%D0%EE%F1%F1%E8%E8%22+%7C+%E4%E5%F4%E8%F6%E8%F2+%7C+%22%E8%E7%EC%E5%ED%E5%ED%E8%FF+%E7%E0%EA%EE%ED%EE%E4%E0%F2%E5%EB%FC%F1%F2%E2%E0%22+%7C+%E7%E0%EA%EE%ED+%7C+%22%E7%E0%EA%EE%ED%EE%E4%E0%F2%E5%EB%FC%ED%FB%E9+%E0%EA%F2%22+%7C+%22%EF%EE%F1%F2%E0%ED%EE%E2%EB%E5%ED%E8%E5+%EF%F0%E0%E2%E8%F2%E5%EB%FC%F1%F2%E2%E0%22+%7C+%22%F3%EA%E0%E7+%CF%F0%E5%E7%E8%E4%E5%ED%F2%E0%22+%7C+%22%EF%EE%F1%F2%E0%ED%EE%E2%EB%E5%ED%E8%E5+%EC%E8%ED%E8%F1%F2%E5%F0%F1%F2%E2%E0%22%29' , '%28%ED%E5%EE%EF%F0%E5%E4%E5%EB%B8%ED%ED%EE%F1%F2%FC+%7C+%ED%E5%EE%EF%F0%E5%E4%E5%EB%E5%ED%ED%FB%E9+%7C+%ED%E5%F3%E2%E5%F0%E5%ED%ED%EE%F1%F2%FC%29+%2B+%28%FD%EA%EE%ED%EE%EC%E8%F7%E5%F1%EA%E8%E9+%7C+%FD%EA%EE%ED%EE%EC%E8%EA%E0%29+%2B+%28%C0%EA%F6%E8%FF+%7C+%22%E4%EE%F5%EE%E4%ED%EE%F1%F2%FC+%E0%EA%F6%E8%E8%22+%7C+%22%D6%E5%ED%E0+%E0%EA%F6%E8%E8%22+%7C+%22%C8%ED%E4%E5%EA%F1+%D0%D2%D1%22+%7C+%22%C8%ED%E4%E5%EA%F1+%CC%CC%C2%C1%22%29', '%28%ED%E5%EE%EF%F0%E5%E4%E5%EB%B8%ED%ED%EE%F1%F2%FC+%7C+%ED%E5%EE%EF%F0%E5%E4%E5%EB%E5%ED%ED%FB%E9+%7C+%ED%E5%F3%E2%E5%F0%E5%ED%ED%EE%F1%F2%FC%29+%2B+%28%FD%EA%EE%ED%EE%EC%E8%F7%E5%F1%EA%E8%E9+%7C+%FD%EA%EE%ED%EE%EC%E8%EA%E0%29+%2B+%28%CA%F0%E5%EC%EB%FC+%7C+%22%C1%E0%ED%EA+%D0%EE%F1%F1%E8%E8%22+%7C+%22%D1%EE%E2%E5%F2+%D4%E5%E4%E5%F0%E0%F6%E8%E8%22+%7C+%22%D4%E5%E4%E5%F0%E0%EB%FC%ED%EE%E5+%F1%EE%E1%F0%E0%ED%E8%E5%22+%7C+%22%D6%C1+%D0%D4%22+%7C+%22%D6%C1+%D0%EE%F1%F1%E8%E8%22+%7C+%22%D6%E5%ED%F2%F0%E0%EB%FC%ED%FB%E9+%C1%E0%ED%EA%22+%7C+%22%E7%E0%EA%EE%ED%EE%E4%E0%F2%E5%EB%FC%ED%FB%E9+%E0%EA%F2%22+%7C+%%EF%EE%EB%E8%F2%E8%EA%E0+%7C+%22%EF%EE%F1%F2%E0%ED%EE%E2%EB%E5%ED%E8%E5+%EF%F0%E0%E2%E8%F2%E5%EB%FC%F1%F2%E2%E0%22+%7C+%22%F3%EA%E0%E7+%CF%F0%E5%E7%E8%E4%E5%ED%F2%E0%22+%7C+%C4%F3%EC%E0+%7C+%D6%E5%ED%F2%F0%EE%E1%E0%ED%EA+%7C+%E4%E5%F4%E8%F6%E8%F2+%7C+%E7%E0%EA%EE%ED%EE%E4%E0%F2%E5%EB%FC%F1%F2%E2%EE+%7C+%E7%E0%EA%EE%ED+%7C+%EA%EE%ED%F2%F0%EE%EB%FC+%7C+%ED%EE%F0%EC%E0%F2%E8%E2%ED%FB%E9+%7C+%F0%E5%E3%F3%EB%E8%F0%EE%E2%E0%ED%E8%E5+%7C+%F0%E5%E3%F3%EB%E8%F0%F3%FE%F9%E8%E9+%7C+%F3%EF%F0%E0%E2%EB%E5%ED%E8%E5+%7C+%E1%FE%E4%E6%E5%F2+%7C+%ED%E0%EB%EE%E3+%7C+%F0%E0%F1%F5%EE%E4%EE%E2%E0%ED%E8%E5+%7C+%F0%E0%F1%F5%EE%E4%FB+%7C+%22%EF%EE%F1%F2%E0%ED%EE%E2%EB%E5%ED%E8%E5+%EC%E8%ED%E8%F1%F2%E5%F0%F1%F2%E2%E0%22%29');

###New expanded term set (US + Euro P terms)
my @term_set = ('%28%ED%E5%EE%EF%F0%E5%E4%E5%EB%B8%ED%ED%EE%F1%F2%FC+%7C+%ED%E5%EE%EF%F0%E5%E4%E5%EB%E5%ED%ED%FB%E9+%7C+%ED%E5%F3%E2%E5%F0%E5%ED%ED%EE%F1%F2%FC%29+%2B+%28%FD%EA%EE%ED%EE%EC%E8%F7%E5%F1%EA%E8%E9+%7C+%FD%EA%EE%ED%EE%EC%E8%EA%E0%29+%2B+%28%CA%F0%E5%EC%EB%FC+%7C+%22%C1%E0%ED%EA+%D0%EE%F1%F1%E8%E8%22+%7C+%22%D1%EE%E2%E5%F2+%D4%E5%E4%E5%F0%E0%F6%E8%E8%22+%7C+%22%D4%E5%E4%E5%F0%E0%EB%FC%ED%EE%E5+%F1%EE%E1%F0%E0%ED%E8%E5%22+%7C+%22%D6%C1+%D0%D4%22+%7C+%22%D6%C1+%D0%EE%F1%F1%E8%E8%22+%7C+%22%D6%E5%ED%F2%F0%E0%EB%FC%ED%FB%E9+%C1%E0%ED%EA%22+%7C+%22%E7%E0%EA%EE%ED%EE%E4%E0%F2%E5%EB%FC%ED%FB%E9+%E0%EA%F2%22+%7C+%%EF%EE%EB%E8%F2%E8%EA%E0+%7C+%22%EF%EE%F1%F2%E0%ED%EE%E2%EB%E5%ED%E8%E5+%EF%F0%E0%E2%E8%F2%E5%EB%FC%F1%F2%E2%E0%22+%7C+%22%F3%EA%E0%E7+%CF%F0%E5%E7%E8%E4%E5%ED%F2%E0%22+%7C+%C4%F3%EC%E0+%7C+%D6%E5%ED%F2%F0%EE%E1%E0%ED%EA+%7C+%E4%E5%F4%E8%F6%E8%F2+%7C+%E7%E0%EA%EE%ED%EE%E4%E0%F2%E5%EB%FC%F1%F2%E2%EE+%7C+%E7%E0%EA%EE%ED+%7C+%EA%EE%ED%F2%F0%EE%EB%FC+%7C+%ED%EE%F0%EC%E0%F2%E8%E2%ED%FB%E9+%7C+%F0%E5%E3%F3%EB%E8%F0%EE%E2%E0%ED%E8%E5+%7C+%F0%E5%E3%F3%EB%E8%F0%F3%FE%F9%E8%E9+%7C+%F3%EF%F0%E0%E2%EB%E5%ED%E8%E5+%7C+%E1%FE%E4%E6%E5%F2+%7C+%ED%E0%EB%EE%E3+%7C+%F0%E0%F1%F5%EE%E4%EE%E2%E0%ED%E8%E5+%7C+%F0%E0%F1%F5%EE%E4%FB+%7C+%22%EF%EE%F1%F2%E0%ED%EE%E2%EB%E5%ED%E8%E5+%EC%E8%ED%E8%F1%F2%E5%F0%F1%F2%E2%E0%22%29');

###Main query is EU and (US + Euro P term EPU)
my @term_set = ('%28%ED%E5%EE%EF%F0%E5%E4%E5%EB%B8%ED%ED%EE%F1%F2%FC+%7C+%ED%E5%EE%EF%F0%E5%E4%E5%EB%E5%ED%ED%FB%E9+%7C+%ED%E5%F3%E2%E5%F0%E5%ED%ED%EE%F1%F2%FC%29+%2B+%28%FD%EA%EE%ED%EE%EC%E8%F7%E5%F1%EA%E8%E9+%7C+%FD%EA%EE%ED%EE%EC%E8%EA%E0%29','%28%ED%E5%EE%EF%F0%E5%E4%E5%EB%B8%ED%ED%EE%F1%F2%FC+%7C+%ED%E5%EE%EF%F0%E5%E4%E5%EB%E5%ED%ED%FB%E9+%7C+%ED%E5%F3%E2%E5%F0%E5%ED%ED%EE%F1%F2%FC%29+%2B+%28%FD%EA%EE%ED%EE%EC%E8%F7%E5%F1%EA%E8%E9+%7C+%FD%EA%EE%ED%EE%EC%E8%EA%E0%29+%2B+%28%CA%F0%E5%EC%EB%FC+%7C+%22%C1%E0%ED%EA+%D0%EE%F1%F1%E8%E8%22+%7C+%22%D1%EE%E2%E5%F2+%D4%E5%E4%E5%F0%E0%F6%E8%E8%22+%7C+%22%D4%E5%E4%E5%F0%E0%EB%FC%ED%EE%E5+%F1%EE%E1%F0%E0%ED%E8%E5%22+%7C+%22%D6%C1+%D0%D4%22+%7C+%22%D6%C1+%D0%EE%F1%F1%E8%E8%22+%7C+%22%D6%E5%ED%F2%F0%E0%EB%FC%ED%FB%E9+%C1%E0%ED%EA%22+%7C+%22%E7%E0%EA%EE%ED%EE%E4%E0%F2%E5%EB%FC%ED%FB%E9+%E0%EA%F2%22+%7C+%%EF%EE%EB%E8%F2%E8%EA%E0+%7C+%22%EF%EE%F1%F2%E0%ED%EE%E2%EB%E5%ED%E8%E5+%EF%F0%E0%E2%E8%F2%E5%EB%FC%F1%F2%E2%E0%22+%7C+%22%F3%EA%E0%E7+%CF%F0%E5%E7%E8%E4%E5%ED%F2%E0%22+%7C+%C4%F3%EC%E0+%7C+%D6%E5%ED%F2%F0%EE%E1%E0%ED%EA+%7C+%E4%E5%F4%E8%F6%E8%F2+%7C+%E7%E0%EA%EE%ED%EE%E4%E0%F2%E5%EB%FC%F1%F2%E2%EE+%7C+%E7%E0%EA%EE%ED+%7C+%EA%EE%ED%F2%F0%EE%EB%FC+%7C+%ED%EE%F0%EC%E0%F2%E8%E2%ED%FB%E9+%7C+%F0%E5%E3%F3%EB%E8%F0%EE%E2%E0%ED%E8%E5+%7C+%F0%E5%E3%F3%EB%E8%F0%F3%FE%F9%E8%E9+%7C+%F3%EF%F0%E0%E2%EB%E5%ED%E8%E5+%7C+%E1%FE%E4%E6%E5%F2+%7C+%ED%E0%EB%EE%E3+%7C+%F0%E0%F1%F5%EE%E4%EE%E2%E0%ED%E8%E5+%7C+%F0%E0%F1%F5%EE%E4%FB+%7C+%22%EF%EE%F1%F2%E0%ED%EE%E2%EB%E5%ED%E8%E5+%EC%E8%ED%E8%F1%F2%E5%F0%F1%F2%E2%E0%22%29');

my @year_loop = (2014 .. 2014);
my @month_loop = (7..9);

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
				if ($term eq '') {
					$day_begin = 18;
					$day_end = 24;
				}
				
				#########Here we will determine the number of results for each day only for the given terms
				my $url = "http://www.kommersant.ru/Search/Results?places=1&categories=&isbankrupt=&datestart=".$day_begin.".".$month.".".$year."&dateend=".$day_end.".".$month.".".$year."&sort_type=0&sort_dir=&regions=&results_count=&page=1&search_query=".$term."";
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
				display("$content");

				$content =~ m/b-main-search-found__legend">.*?<strong>.*?(\d+).*?<\/strong>.*?<\/div>/is;
				$results = ($1);
				if (!$results) {
					$results = 0;
				}
				print $results." Results \n";

				##prints the number of results to target file
				#print "$term \n";
				print $paper."\n";
				print "$month - $year \n\n\n";
				print TARGET $paper.",".$month.",".$year.",".$term.",";
				print TARGET $results."\n";
				sleep $sleep_per_obs;
			}
		}
	}
}

close (TARGET);
  