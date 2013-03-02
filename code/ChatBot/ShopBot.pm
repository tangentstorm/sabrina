package ChatBot::ShopBot;

use ChatBot::ChatShop::Nerpl;
use ChatBot::ChatShop::MetaModel;
use ChatBot::ChatShop::ChatStack;
use ChatBot::ChatShop::ValueHierarchy;

#----------------------------------------------------------------
sub new { # ( [class,] name )
#----------------------------------------------------------------
# create a new ShopBot (or descendant) and open the logfile
#----------------------------------------------------------------
    my $class = shift;
    my $self = {
	name => shift
	};
    
    # validate the new bot:
    $self->{name} || die "Your $class needs a name";
    
    # add in the stack
    $self->{stack} = new ChatBot::ChatShop::ChatStack;

    # bless makes $self an object of class $class
    bless $self, $class;
    
    # pass extra paremeters to descendents
    $self->init(@_);
    
    return $self;
}

#----------------------------------------------------------------
sub init{
#----------------------------------------------------------------
# override this method if you want extra initialization stuff.
#----------------------------------------------------------------
}

#----------------------------------------------------------------
sub say { 
#----------------------------------------------------------------
# override this method for other interfaces
#----------------------------------------------------------------
    my $self = shift;
    print shift, "\n";
}

sub strat_test{  return ("i heard " . shift ) };

#----------------------------------------------------------------
sub hear {
#----------------------------------------------------------------
    my $self = shift;
    my $client = shift;
    my $message = shift;

    if ($message =~ /\bdie\b/) {
	$self->say( "$client killed me.." );
	die "$client killed me";
    }

    # generate some responses and add them to the stack
    # eventually, this will happen for each strategy
    # available to the bot.   

    push @chatstack, Nerpl::strat_Nerpl($message);
#    push @chatstack, MetaModel::strat_MetaModel($message);
#    push @chatstack, ValueHierarchy::strat_ValueHierarchy($message);


    # say one of them
    $self->say( shift @chatstack );
}

#----------------------------------------------------------------
sub listen {
#----------------------------------------------------------------
    my $self = shift;
    my $message = <>;
    chomp($message);

    # there's only one client: you. :)
    $self->hear('you', $message);
}


#----------------------------------------------------------------
sub run { 
#----------------------------------------------------------------
    my $self = shift;

    print 'Hello, I am ', $self->{name}, ".\n> ";

    while ($self->listen){
	print '> ';
    }
}

#----------------------------------------------------------------
sub AUTOLOAD {         # gets called if a method doesn't exist..
#----------------------------------------------------------------
# I copied this from perltoot on www.perl.com, or someplace..
# I'll probably adapt it later.
#----------------------------------------------------------------
    my $self = shift;
    my $type = ref($self)
	or die "$self is not an object";
    
    my $name = $AUTOLOAD;
    $name =~ s/.*://;   # strip fully-qualified portion
    
    unless (exists $self->{_permitted}->{$name} ) {
	die "Can't access `$name' field in class $type";
    }

    if (@_) {    return $self->{$name} = shift;} else {
	return $self->{$name};}

}

1;
