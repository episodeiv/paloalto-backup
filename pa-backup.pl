#!/usr/bin/env perl
use strict;
use lib 'local/lib/perl5';
use Data::Dumper;
use Git::Repository;
use LWP::UserAgent ();
use IO::Socket::SSL qw( SSL_VERIFY_NONE );
use Path::Tiny;
use YAML::Tiny;

my $configfile = 'config.yaml';
if(!-f $configfile) {
	die("config.yaml doesn't exist");
}

my $config = YAML::Tiny->read($configfile)->[0] or die("Invalid config file");

if(!-d $config->{repository}) {
	die("Repository at $config->{repository} doesn't exist");
}

my $repo = Git::Repository->new(work_tree => $config->{repository});

my(@processed, @failed);

my $ua = LWP::UserAgent->new(
	timeout => 10,
	ssl_opts => { SSL_verify_mode => SSL_VERIFY_NONE, verify_hostname => 0},
);

for my $target (@{$config->{targets}}) {
	my $url = "https://".$target."/api/?type=op&cmd=<show><config><running></running></config></show>&key=".$config->{key};

	my $response = $ua->get($url);

	if(!$response->is_success) {
		warn("Error while fetching: ".$response->status_line);
	}
	else {
		my $content = $response->decoded_content;

		$content =~ s/<response status="success"><result>//;
		$content =~ s/<\/result><\/response>//;

		open(my $output, ">", path($config->{repository}, $target.".xml")) or warn("Unable to write output: $!");
		print $output $content;
		close($output);

		print "Successfully processed $target\n";
	}
}
print "Committing changes\n";
$repo->run( add => '.' );
$repo->run( commit => '-m', 'pa-backup run at '.localtime(time));

if($config->{push}) {
	print "Pushing changes\n";
	$repo->run( push => $config->{push})
}
