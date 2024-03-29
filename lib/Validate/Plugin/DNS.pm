package Validate::Plugin::DNS;

# Called by dns_ipv4, dns_ipv6, dsn_ds, and so forth.
use Net::DNS::Resolver;
use Socket;
use Socket6;

use strict;

sub new {
    my $classname = shift;
    my $self      = {};
    bless( $self, $classname );
    $self->{validate}=shift;
        return $self;
}

sub check {
  my $self = shift;
  my($name,$resolver,@expect) = @_;
  my %expect = map  { $_ => 1 } @expect;
  my @expect;
  $DB::single=1;
  push(@expect,sprintf("%s %s %s",$name,"A",$self->{validate}->{config}->{load}->{ipv4})) if ($expect{"A"});
  push(@expect,sprintf("%s %s %s",$name,"AAAA",$self->{validate}->{config}->{load}->{ipv6})) if ($expect{"AAAA"});
  my $expect = join("\n",@expect);
  my $res = new Net::DNS::Resolver( nameservers => [$resolver], recurse => 1 );
  my $validate = $self->{validate};
       
  my @found;
  
  
  foreach my $type (qw(A AAAA)) {
    my $query = $res->query( $name, $type );
    if ($query) {
         my @answer = $query->answer;
         @answer = grep ( $_->type eq $type, @answer );
         if (@answer) {
           foreach my $answer (@answer) {
             my $address = $answer->address;
             my $p = ($address =~ /:/) ? AF_INET6 : AF_INET;
             my $i = inet_pton($p,$address);
             $address = inet_ntop($p,$i);
              push(@found,sprintf("%s %s %s",$name,$type,$address));
           }
         }
    }    
    if ($res->errorstring ne "NOERROR") {
      push(@found,sprintf("%s %s %s",$name,$type,$res->errorstring));
    }
  }  
  my $found = join("\n", @found);
  $found = "<no A or AAAA>" unless ($found);
  
  my $found_i = $validate->indent($found);
  my $expect_i = $validate->indent($expect);
  
  
  if ($found eq $expect) {
    return (
        status=>"ok",
        expect=>$expect_i,
        found=>$found_i);
  } else {
  my $notes = <<"EOF";
Unexpected results found when querying $resolver .

* Make sure that DNS matches your <code>/site/config.js</code>
* Make sure you have the right types of DNS for this name
* https://github.com/falling-sky/source/wiki/InstallDNS
EOF
    return ( 
       status =>"bad",
       expect => $expect_i,
       found=>$found_i,
       notes => $notes );
  }
}

1;
