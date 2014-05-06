use feature ":5.14";
use Data::Dumper::Concise;
use Win32::ChangeNotify;

my $Events
    = FILE_NOTIFY_CHANGE_ATTRIBUTES | FILE_NOTIFY_CHANGE_DIR_NAME
    | FILE_NOTIFY_CHANGE_FILE_NAME | FILE_NOTIFY_CHANGE_LAST_WRITE
    | FILE_NOTIFY_CHANGE_SECURITY | FILE_NOTIFY_CHANGE_SIZE;

my $notify = Win32::ChangeNotify->new( "c:\\", 1, $Events );
$notify->wait or warn "Something failed: $!\n";

say Dumper $notify;
