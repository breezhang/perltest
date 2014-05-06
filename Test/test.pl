require 'ReadDirectoryChanges.pm';
use Data::Dumper::Concise;
use feature ":5.14";

#use Win32::ReadDirectoryChanges;

my $Events
    = FILE_NOTIFY_CHANGE_FILE_NAME | FILE_NOTIFY_CHANGE_DIR_NAME
    | FILE_NOTIFY_CHANGE_NAME | FILE_NOTIFY_CHANGE_ATTRIBUTES
    | FILE_NOTIFY_CHANGE_SIZE | FILE_NOTIFY_CHANGE_LAST_WRITE
    | FILE_NOTIFY_CHANGE_LAST_ACCESS | FILE_NOTIFY_CHANGE_CREATION
    | FILE_NOTIFY_CHANGE_SECURITY;

my ($path, $subtree) = ( "C:\\", 1 );

my $rdc =
    new Win32::ReadDirectoryChanges( path    => $path,
                                     subtree => 1, );

my @results = $rdc->read_changes;

say Dumper @results;
#
#while ( scalar @results ) {
#    my ( $action, $filename ) = splice( @results, 0, 2 );
#    say Dumper $filename;
#    say Dumper $action;
#}
#
