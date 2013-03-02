package ChatBot::ShopBot::IRCBot;
#---------------------------------------------------
# IRCBot : a ShopBot that uses dsirc to chat on IRC
#---------------------------------------------------
use IPC::Open2;
# use ChatBot::ShopBot;

@ISA = qw(ChatBot::ShopBot); # IRCBot is a ShopBot


$server = "irc.freenode.net";
#$server = "irc.emory.edu";
#$server = "portal.tamu.edu";
#$server = "irc.primenet.com";
#$server = "irc-w.primenet.com";

$name   = "sabrina98";
$fullname = "Sabrina Grandler";
$channel = "#lpmc";


#----------------------------------------------------------------
sub listen {
#----------------------------------------------------------------
    my $self=shift;
    $_ = <IRC>;

    # dump anything IRC says to the screen:
    print;

    # for a normal message, respond to it...
    /^<.*$name.*>/ || (/^<(.*)>(.*)/ && $self->hear($1, $2) );

    # quit if disconnected
    /^\*E\*/ && die "IRC Error: ($&)";
    /^\*{3}/ && /You\'re not connected/ && die "IRC Error: disconnected ";
	
    1; # always return true
}

#----------------------------------------------------------------
sub say { 
#----------------------------------------------------------------
# override this method for other interfaces
#----------------------------------------------------------------
    my $self = shift;
    print SABRINA @_, "\n";
}


#----------------------------------------------------------------
sub run { 
#----------------------------------------------------------------
    my $self = shift;
    
    # open a link between IRC and the bot:
    
    $pid = open2('IRC', 'SABRINA', 
				 "./dsirc -i \"$fullname\" $name $server");
    
    # sit around doing nothing until we connect:
	
    while (<IRC>) {
		print $_;
		/mode change/i && last;
		/^\*.?E.?\*/i && die "couldn't connect to irc"; 
    }
	
    print "connected\n";
    print "attempting /join $channel\n";
	
    $self->say("/join $channel");
    $self->say("Hello, all! I'm ", $self->{name});

# for debugging:
#
#    while (<IRC>) {
#	print;
#	/sabren/ && /runtest/i && last;
#    }
#
#    print "sabren said runtest!\n";

    while ($self->listen()){
		# just keep on looping until someone kills me...
    }
}


1; # return true so perl knows we loaded right

__END__
