#----------------------------------------------------------
package ValueHierarchy;
#----------------------------------------------------------

 #  "So you usually don't XYZ, eh? Why not?"
 #  "Ah. So if you had to give a one-word reason why you would XYZ.. a value,
 #   what would that word be?"
 #   {
 #     "okay. What would have to happen for you to (NOT) XYZ?"
 #      reconjugate (ABC)
 #     "so you would(n't) XYZ if ..." (ABC)
 #     "and what's the value behind that?"
 #     "okay. Given that ABC, could something make you (NOT) XYZ?"
 #     if no then goto end
 #  }
 #  end: "your highest value is. your other values, in descending order, were.."


$inprogress=0;
$status = "";

$vh_init = "Okay. What's something simple that you are capable of,\n" 
         . "but usually don't do? (eg, I usually don't sing in public.)";

sub confirm {

    $_ = shift;
    (/\b(yes|yep|yeah|sure|okay|ok)\b/i && return 1);
    return 0;
}

sub reconjugate {
    @r = ();
    $old = shift;
    foreach (split " ", $old) {
	(/\b(I|me)\b/i && push @r, "you")  ||
        (/\bam\b/i   && push @r, "are")    ||
	(/\bI'm\b/i  && push @r, "you're") ||
        (/\bmy\b/i   && push @r, "your")   ||
        (/\bI'd\b/i  && push @r, "you'd")  ||
        (/\bI've\b/i && push @r, "you've") ||
	(/\byou\b/i  && push @r, "I")      ||
	(/\byou're\b/i && push @r, "I'm")  ||
	(/\byou've\b/i && push @r, "I've") ||
	(/\byou'd\b/i  && push @r, "I'd")  ||
	(/\byour\b/i   && push @r, "my")   ||
        push @r, $_;
    }
    return join " ", @r;
}


#----------------------------------------------------------
sub strat_ValueHierarchy
#----------------------------------------------------------
{ 
    $input = shift; # what they said
    
    # print "status=$status\n";

    # first get permission

    if (! $inprogress ) { 
        $inprogress = 1;
        $status = "cfm_init";
	return "I would like to elicit your value hierarchy. May I do so?";
    }

    # if i have permission, ask first question, else bitch.
    
    if (($status eq "cfm_init")){
	if (confirm($input) ) {
	    $status ="getwhat";
	    return $vh_init;
	} else {
	    $status = "";
	    $inprogress = 0;
	    return "You suck. Next time say yes.";
	}
    }
    
    # get XYZ;
    
    if ($status eq "getwhat") {
	$input =~ s/i usually don\'t//i;
	$input =~ s/\.//g;
	$what = reconjugate($input);
	$status = "getreason";
	$doit = 1;
	return "So you usually don't " . $what . ", eh? \n" 
             . "What would make you " . $what ."?";
    }

    # get the reason;

    if ($status eq "getreason") {
	my $r = "";
	$reason = reconjugate($input);
	$reason =~ s/(.*)if //i;

	if ($reason =~ /nothing/i) {
	    
	    $values = "Your highest value is" . pop (@values) . "\n"
		    . "Your other values, in descending order, were: \n"
		    . join ", ", reverse @values;

	    $inprogress = 0;
	    return $values;

	}

	$doit && ($r = "So you'd") || ($r = "So you wouldn't");
	$r .= " $what if $reason...\n";

	$status = "getvalue";
	$r .= "What's the value behind that?";

	return $r;
    }

    # get the value;

    if ($status eq "getvalue") {

	push @values, $input;

       	$r = "Okay. Given that $reason, what would make you ";
	$doit && ($r .= "not ");
	$r .= "$what?";
	
	if ($doit) { $doit = 0 } else { $doit = 1 };

	$status = "getreason";
	return $r;
    }

    return "";
}


1; # return true value so perl knows everything is okay here :)


