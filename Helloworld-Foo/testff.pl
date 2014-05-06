use Wx;
use Wx::Event;
use Wx::Event qw/EVT_TIMER/;
Wx::EventFilter;
Wx::CommandEvent;
Wx::PlEvent;
my $tid = Wx::NewEventType;

my $f =Wx::Frame->new(undef,-1,"helloworld");
$timer = Wx::Timer->new($f, $tid);
EVT_TIMER($f, $tid, sub{
     print "................";
    });
$timer->Start(1200);

$f->Show;
my $app = Wx::SimpleApp->new;
$app->EventFilter;
$app->MainLoop;
