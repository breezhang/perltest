####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package Calc;
use vars qw ( @ISA );
use strict;

@ISA= qw ( Parse::Yapp::Driver );
use Parse::Yapp::Driver;



sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.05',
                                  yystates =>
[
	{#State 0
		DEFAULT => -1,
		GOTOS => {
			'input' => 1
		}
	},
	{#State 1
		ACTIONS => {
			'NUM' => 6,
			'' => 4,
			"-" => 2,
			"(" => 7,
			'VAR' => 8,
			"\n" => 5,
			'error' => 9
		},
		GOTOS => {
			'exp' => 3,
			'line' => 10
		}
	},
	{#State 2
		ACTIONS => {
			'NUM' => 6,
			"-" => 2,
			"(" => 7,
			'VAR' => 8
		},
		GOTOS => {
			'exp' => 11
		}
	},
	{#State 3
		ACTIONS => {
			"-" => 12,
			"^" => 16,
			"*" => 17,
			"\n" => 14,
			"+" => 13,
			"/" => 15
		}
	},
	{#State 4
		DEFAULT => 0
	},
	{#State 5
		DEFAULT => -3
	},
	{#State 6
		DEFAULT => -6
	},
	{#State 7
		ACTIONS => {
			'NUM' => 6,
			"-" => 2,
			"(" => 7,
			'VAR' => 8
		},
		GOTOS => {
			'exp' => 18
		}
	},
	{#State 8
		ACTIONS => {
			"=" => 19
		},
		DEFAULT => -7
	},
	{#State 9
		ACTIONS => {
			"\n" => 20
		}
	},
	{#State 10
		DEFAULT => -2
	},
	{#State 11
		ACTIONS => {
			"^" => 16
		},
		DEFAULT => -13
	},
	{#State 12
		ACTIONS => {
			'NUM' => 6,
			"-" => 2,
			"(" => 7,
			'VAR' => 8
		},
		GOTOS => {
			'exp' => 21
		}
	},
	{#State 13
		ACTIONS => {
			'NUM' => 6,
			"-" => 2,
			"(" => 7,
			'VAR' => 8
		},
		GOTOS => {
			'exp' => 22
		}
	},
	{#State 14
		DEFAULT => -4
	},
	{#State 15
		ACTIONS => {
			'NUM' => 6,
			"-" => 2,
			"(" => 7,
			'VAR' => 8
		},
		GOTOS => {
			'exp' => 23
		}
	},
	{#State 16
		ACTIONS => {
			'NUM' => 6,
			"-" => 2,
			"(" => 7,
			'VAR' => 8
		},
		GOTOS => {
			'exp' => 24
		}
	},
	{#State 17
		ACTIONS => {
			'NUM' => 6,
			"-" => 2,
			"(" => 7,
			'VAR' => 8
		},
		GOTOS => {
			'exp' => 25
		}
	},
	{#State 18
		ACTIONS => {
			"-" => 12,
			"^" => 16,
			"*" => 17,
			"+" => 13,
			"/" => 15,
			")" => 26
		}
	},
	{#State 19
		ACTIONS => {
			'NUM' => 6,
			"-" => 2,
			"(" => 7,
			'VAR' => 8
		},
		GOTOS => {
			'exp' => 27
		}
	},
	{#State 20
		DEFAULT => -5
	},
	{#State 21
		ACTIONS => {
			"/" => 15,
			"^" => 16,
			"*" => 17
		},
		DEFAULT => -10
	},
	{#State 22
		ACTIONS => {
			"/" => 15,
			"^" => 16,
			"*" => 17
		},
		DEFAULT => -9
	},
	{#State 23
		ACTIONS => {
			"^" => 16
		},
		DEFAULT => -12
	},
	{#State 24
		ACTIONS => {
			"^" => 16
		},
		DEFAULT => -14
	},
	{#State 25
		ACTIONS => {
			"^" => 16
		},
		DEFAULT => -11
	},
	{#State 26
		DEFAULT => -15
	},
	{#State 27
		ACTIONS => {
			"-" => 12,
			"+" => 13,
			"/" => 15,
			"^" => 16,
			"*" => 17
		},
		DEFAULT => -8
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'input', 0, undef
	],
	[#Rule 2
		 'input', 2,
sub
#line 17 "Calc.yp"
{ push(@{$_[1]},$_[2]); $_[1] }
	],
	[#Rule 3
		 'line', 1,
sub
#line 20 "Calc.yp"
{ $_[1] }
	],
	[#Rule 4
		 'line', 2,
sub
#line 21 "Calc.yp"
{ print "$_[1]\n" }
	],
	[#Rule 5
		 'line', 2,
sub
#line 22 "Calc.yp"
{ $_[0]->YYErrok }
	],
	[#Rule 6
		 'exp', 1, undef
	],
	[#Rule 7
		 'exp', 1,
sub
#line 26 "Calc.yp"
{ $_[0]->YYData->{VARS}{$_[1]} }
	],
	[#Rule 8
		 'exp', 3,
sub
#line 27 "Calc.yp"
{ $_[0]->YYData->{VARS}{$_[1]}=$_[3] }
	],
	[#Rule 9
		 'exp', 3,
sub
#line 28 "Calc.yp"
{ $_[1] + $_[3] }
	],
	[#Rule 10
		 'exp', 3,
sub
#line 29 "Calc.yp"
{ $_[1] - $_[3] }
	],
	[#Rule 11
		 'exp', 3,
sub
#line 30 "Calc.yp"
{ $_[1] * $_[3] }
	],
	[#Rule 12
		 'exp', 3,
sub
#line 31 "Calc.yp"
{
                                      $_[3]
                                  and return($_[1] / $_[3]);
                                  $_[0]->YYData->{ERRMSG}
                                    =   "Illegal division by zero.\n";
                                  $_[0]->YYError;
                                  undef
                                }
	],
	[#Rule 13
		 'exp', 2,
sub
#line 39 "Calc.yp"
{ -$_[2] }
	],
	[#Rule 14
		 'exp', 3,
sub
#line 40 "Calc.yp"
{ $_[1] ** $_[3] }
	],
	[#Rule 15
		 'exp', 3,
sub
#line 41 "Calc.yp"
{ $_[2] }
	]
],
                                  @_);
    bless($self,$class);
}

#line 44 "Calc.yp"


sub _Error {
        exists $_[0]->YYData->{ERRMSG}
    and do {
        print $_[0]->YYData->{ERRMSG};
        delete $_[0]->YYData->{ERRMSG};
        return;
    };
    print "Syntax error.\n";
}

sub _Lexer {
    my($parser)=shift;

        $parser->YYData->{INPUT}
    or  $parser->YYData->{INPUT} = <STDIN>
    or  return('',undef);

    $parser->YYData->{INPUT}=~s/^[ \t]//;

    for ($parser->YYData->{INPUT}) {
        s/^([0-9]+(?:\.[0-9]+)?)//
                and return('NUM',$1);
        s/^([A-Za-z][A-Za-z0-9_]*)//
                and return('VAR',$1);
        s/^(.)//s
                and return($1,$1);
    }
}

sub Run {
    my($self)=shift;
    $self->YYParse( yylex => \&_Lexer, yyerror => \&_Error );
}


1;
