#!/usr/bin/env perl
## File: options.pl
## Version: 2.0
## Date 2018-01-10
## License: GNU GPL v3 or greater
## Copyright (C) 2017-18 Harald Hope

use strict;
use warnings;
# use diagnostics;
use 5.008;
use Data::Dumper qw(Dumper); # print_r

use Getopt::Long qw(GetOptions);
# Note: default auto_abbrev is enabled, that's fine
Getopt::Long::Configure ('bundling', 'no_ignore_case', 
'no_getopt_compat', 'no_auto_abbrev','pass_through');

### START DEFAULT CODE ##
my (@app);
my (%files,%system_files);
my $start = '';
my $end = '';
my $b_irc = 1;
my $bsd_type = '';
my $b_display = 1;
my $b_root = 0;
my $b_log;
my $extra = 2;
my @paths = ('/sbin','/bin','/usr/sbin','/usr/bin','/usr/X11R6/bin','/usr/local/sbin','/usr/local/bin');

my (@test,
%colors,%dl,%show,%use,
$b_update,$b_weather,
$debug,$display,$ftp_alt,$output_type,$ps_count);
## Tools
my $display_opt = '';

sub error_handler {
	my ($err, $one, $two) = @_;
	print "Err: $err Value: $one Value2: $two\n";
}
sub get_color_scheme {
	return 32;
}
sub get_defaults {}
sub set_color_scheme {}
sub set_display_width {}
sub set_downloader {}
sub set_perl_downloader {}
sub show_options {}
sub show_version {}
sub update_me {}
{
package CheckRecommends;
sub run {}
};


### END DEFAULT CODE ##

### START CODE REQUIRED BY THIS MODULE ##

### START MODULE CODE ##

sub get_options{
	eval $start if $b_log;
	my (@args) = @_;
	$show{'short'} = 1;
	my ($b_downloader,$b_recommends,$b_updater,$b_version,$help_type,
	$self_download, $download_id);
	GetOptions (
	'A|audio' => sub {
		$show{'short'} = 0;
		$show{'audio'} = 1;},
	'b|basic' => sub {
		$show{'short'} = 0;
		$show{'battery'} = 1;
		$show{'cpu-basic'} = 1;
		$show{'raid-basic'} = 1;
		$show{'disk-total'} = 1;
		$show{'graphic'} = 1;
		$show{'info'} = 1;
		$show{'machine'} = 1;
		$show{'network'} = 1;
		$show{'system'} = 1;},
	'B|battery' => sub {
		$show{'short'} = 0;
		$show{'battery'} = 1;
		$show{'battery-forced'} = 1; },
	'c|color:i' => sub {
		my ($opt,$arg) = @_;
		if ( $arg >= 0 && $arg <= get_color_scheme('count') ){
			set_color_scheme($arg);
		}
		elsif ( $arg >= 94 && $arg <= 99 ){
			$colors{'selector'} = $arg;
		}
		else {
			error_handler('bad-arg', $opt, $arg);
		} },
	'C|cpu' => sub {
		$show{'short'} = 0;
		$show{'cpu'} = 1; },
	'd|disk-all' => sub {
		$show{'short'} = 0;
		$show{'disk'} = 1;
		$show{'optical-full'} = 1; },
	'D' => sub {
		$show{'short'} = 0;
		$show{'disk'} = 1; },
	'f|flags' => sub {
		$show{'short'} = 0;
		$show{'cpu'} = 1;
		$show{'cpu-flag'} = 1; },
	'F|full' => sub {
		$show{'short'} = 0;
		$show{'audio'} = 1;
		$show{'battery'} = 1;
		$show{'cpu'} = 1;
		$show{'disk'} = 1;
		$show{'graphic'} = 1;
		$show{'info'} = 1;
		$show{'machine'} = 1;
		$show{'network'} = 1;
		$show{'network-advanced'} = 1;
		$show{'partition'} = 1;
		$show{'raid'} = 1;
		$show{'sensor'} = 1;
		$show{'system'} = 1; },
	'G|graphics' => sub {
		$show{'short'} = 0;
		$show{'graphic'} = 1; },
	'i|ip' => sub {
		$show{'short'} = 0;
		$show{'ip'} = 1;
		$show{'network'} = 1;
		$show{'network-advanced'} = 1;
		$b_downloader = 1 if ! check_program('dig');},
	'I|info' => sub {
		$show{'short'} = 0;
		$show{'info'} = 1; },
	'l|label' => sub {
		$show{'short'} = 0;
		$show{'label'} = 1;
		$show{'partition'} = 1; },
	'm|memory' => sub {
		$show{'short'} = 0;
		$show{'memory'} = 1; },
	'M|machine' => sub {
		$show{'short'} = 0;
		$show{'machine'} = 1; },
	'n|network-advanced' => sub {
		$show{'short'} = 0;
		$show{'network'} = 1;
		$show{'network-advanced'} = 1; },
	'N|network' => sub {
		$show{'short'} = 0;
		$show{'network'} = 1; },
	'o|unmounted' => sub {
		$show{'short'} = 0;
		$show{'unmounted'} = 1; },
	'p|partition-full' => sub {
		$show{'short'} = 0;
		$show{'partition'} = 1;
		$show{'partition-full'} = 1; },
	'P|partition' => sub {
		$show{'short'} = 0;
		$show{'partition'} = 1; },
	'r|repos' => sub {
		$show{'short'} = 0;
		$show{'repo'} = 1; },
	'R|raid' => sub {
		$show{'short'} = 0;
		$show{'raid'} = 1;
		$show{'raid-forced'} = 1; },
	's|sensors' => sub {
		$show{'short'} = 0;
		$show{'sensor'} = 1; },
	'S|system' => sub {
		$show{'short'} = 0;
		$show{'system'} = 1; },
	't|processes:s' => sub {
		my ($opt,$arg) = @_;
		$show{'short'} = 0;
		if ( $arg =~ /^([cm]+)([1-9]|1[0-9]|20)?$/ ){
			$show{'process'} = 1;
			if ($arg =~ /c/){
				$show{'ps-cpu'} = 1;
			}
			if ($arg =~ /m/){
				$show{'ps-mem'} = 1;
			}
			if ($arg =~ /([0-9]+)/ ){
				$ps_count = $1;
			}
		}
		else {
			error_handler('bad-arg',$opt,$arg);
		} },
	'u|uuid' => sub {
		$show{'short'} = 0;
		$show{'partition'} = 1;
		$show{'uuid'} = 1; },
	'v|verbosity:i' => sub {
		my ($opt,$arg) = @_;
		$show{'short'} = 0;
		if ( $arg =~ /^[0-7]$/ ){
			if ($arg == 0 ){
				$show{'short'} = 1;
			}
			if ($arg >= 1 ){
				$show{'cpu-basic'} = 1;
				$show{'disk-total'} = 1;
				$show{'graphic'} = 1;
				$show{'info'} = 1;
				$show{'system'} = 1;
			}
			if ($arg >= 2 ){
				$show{'battery'} = 1;
				$show{'disk-basic'} = 1;
				$show{'raid-basic'} = 1;
				$show{'machine'} = 1;
				$show{'network'} = 1;
			}
			if ($arg >= 3 ){
				$show{'network-advanced'} = 1;
				$show{'cpu'} = 1;
				$extra = 1;
			}
			if ($arg >= 4 ){
				$show{'disk'} = 1;
				$show{'partition'} = 1;
			}
			if ($arg >= 5 ){
				$show{'audio'} = 1;
				$show{'memory'} = 1;
				$show{'label'} = 1;
				$show{'memory'} = 1;
				$show{'raid'} = 1;
				$show{'sensor'} = 1;
				$show{'uuid'} = 1;
			}
			if ($arg >= 6 ){
				$show{'optical-full'} = 1;
				$show{'partition-full'} = 1;
				$show{'unmounted'} = 1;
				$extra = 2;
			}
			if ($arg >= 7 ){
				$b_downloader = 1 if ! check_program('dig');
				$show{'ip'} = 1;
				$show{'raid-forced'} = 1;
				$extra = 3;
			}
		}
		else {
			error_handler('bad-arg',$opt,$arg);
		} },
	'w|weather' => sub {
		my ($opt) = @_;
		$show{'short'} = 0;
		$b_downloader = 1;
		if ( $b_weather ){
			$show{'weather'} = 1;
		}
		else {
			error_handler('distro-block', $opt);
		} },
	'W|weather-location:s' => sub {
		my ($opt,$arg) = @_;
		$arg ||= '';
		$show{'short'} = 0;
		$b_downloader = 1;
		if ( $b_weather ){
			if ( $arg){
				$show{'weather'} = 1;
				$show{'weather-location'} = 1;
			}
			else {
				error_handler('bad-arg',$opt,$arg);
			}
		}
		else {
			error_handler('distro-block', $opt);
		} },
	'x|extra:i' => sub {
		my ($opt,$arg) = @_;
		if ($arg > 0){
			$extra = $arg;
		}
		else {
			$extra++;
		} },
	'y|width:i' => sub {
		my ($opt, $arg) = @_;
		if ( $arg =~ /\d/ && $arg >= 80 ){
			set_display_width($arg);
		}
		else {
			error_handler('bad-arg', $opt, $arg);
		} },
	'z|filter' => sub {
		$show{'filter'} = 1; },
	'Z|filter-override' => sub {
		$show{'filter-override'} = 1; },
	
	## Start non data options
	'alt:i' => sub { 
		my ($opt,$arg) = @_;
		if ($arg == 1) {$test[1] = 1}
		elsif ($arg == 2) {$test[2] = 1}
		elsif ($arg == 3) {$test[3] = 1}
		elsif ($arg == 4) {$test[4] = 1}
		elsif ($arg == 5) {$test[5] = 1}
		elsif ($arg == 30) {$b_irc = 0}
		elsif ($arg == 31) {$show{'host'} = 0}
		elsif ($arg == 32) {$show{'host'} = 1}
		elsif ($arg == 33) {$use{'dmidecode-force'}=1}
		elsif ($arg == 34) {$dl{'no-ssl-opt'}=$dl{'no-ssl'}}
		elsif ($arg == 40) {
			$dl{'tiny'} = 0;
			$b_downloader = 1;}
		elsif ($arg == 41) {
			$dl{'curl'} = 0;
			$b_downloader = 1;}
		elsif ($arg == 42) {
			$dl{'fetch'} = 0;
			$b_downloader = 1;}
		elsif ($arg == 43) {
			$dl{'wget'} = 0;
			$b_downloader = 1;}
		elsif ($arg == 44) {
			$dl{'curl'} = 0;
			$dl{'fetch'} = 0;
			$dl{'wget'} = 0;
			$b_downloader = 1;}
		else {
			error_handler('bad-arg', $opt, $arg);
		}},
	'debug:i' => sub { 
		my ($opt,$arg) = @_;
		if ($arg =~ /^[1-3]|[1-2][0-2]$/){
			$debug=$arg;
		}
		else {
			error_handler('bad-arg', $opt, $arg);
		} },
	'display:s' => sub { 
		my ($opt,$arg) = @_;
		if ($arg =~ /^:?([0-9]+)?$/){
			$display=$arg;
			$display ||= ':0';
			$b_display = 1;
			$show{'display-data'} = 2;
			$display_opt = "-display $arg";
		}
		else {
			error_handler('bad-arg', $opt, $arg);
		} },
	'downloader:s' => sub { 
		my ($opt,$arg) = @_;
		$arg = lc($arg);
		if ($arg =~ /^(curl|fetch|ftp|perl|wget)$/){
			# this dumps all the other data and resets %dl for only the
			# desired downloader.
			$arg = set_perl_downloader($arg);
			%dl = ('dl' => $arg, $arg => 1);
			$b_downloader = 1;
		}
		else {
			error_handler('bad-arg', $opt, $arg);
		} },
	'ftp:s'  => sub { 
		my ($opt,$arg) = @_;
		# pattern: ftp.x.x/x
		if ($arg =~ /^ftp\..+\..+\/[^\/]+$/ ){
			$ftp_alt = $arg;
		}
		else {
			error_handler('bad-arg', $opt, $arg);
		}},
	'h|help|?' => sub {
		$help_type = 'standard'; },
	'H|help-full' => sub {
		$help_type = 'full'; },
	'output:s' => sub {
		my ($opt,$arg) = @_;
		if ($arg =~ /^csv|json|screen|xml$/){
			$output_type = $arg;
		}
		else {
			error_handler('bad-arg', $opt, $arg);
		}},
	'recommends' => sub {
		$b_recommends = 1; },
	'U|update:s' => sub { # 1,2,3 OR http://myserver/path/inxi
		my ($opt,$arg) = @_;
		$b_downloader = 1;
		if ( $b_update ){
			$b_updater = 1;
			if ( $arg =~ /^\d$/){
				$download_id = "branch $arg";
				$self_download = get_defaults("inxi-branch-$arg");
			}
			elsif ( $arg =~ /^http/){
				$download_id = 'alt server';
				$self_download = $arg;
			}
			else {
				$download_id = 'pinxi branch';
				$self_download = get_defaults('inxi-pinxi');
			}
# 			else {
# 				$download_id = 'main branch';
# 				$self_download = get_defaults('inxi-main');
# 			}
			if (!$self_download){
				error_handler('bad-arg', $opt, $arg);
			}
		}
		else {
			error_handler('distro-block', $opt);
		} },
	'V|version' => sub { 
		$b_version = 1 },
	'<>' => sub {
		my ($opt) = @_;
		error_handler('unknown-option', "$opt", "" ); }
	) ; #or error_handler('unknown-option', "@ARGV", '');
	## run all these after so that we can change widths, downloaders, etc
	eval $end if $b_log;
	CheckRecommends::run() if $b_recommends;
	set_downloader() if $b_downloader;
	show_version() if $b_version;
	show_options($help_type) if $help_type;
	update_me( $self_download, $download_id ) if $b_updater;
} 

### END MODULE CODE ##

### START TEST CODE ##
