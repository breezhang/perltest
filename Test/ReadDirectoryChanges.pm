package Win32::ReadDirectoryChanges;

use 5.006001;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(
    FILE_NOTIFY_CHANGE_FILE_NAME
    FILE_NOTIFY_CHANGE_DIR_NAME
    FILE_NOTIFY_CHANGE_NAME
    FILE_NOTIFY_CHANGE_ATTRIBUTES
    FILE_NOTIFY_CHANGE_SIZE
    FILE_NOTIFY_CHANGE_LAST_WRITE
    FILE_NOTIFY_CHANGE_LAST_ACCESS
    FILE_NOTIFY_CHANGE_CREATION
    FILE_NOTIFY_CHANGE_SECURITY

    FILE_ACTION_ADDED
    FILE_ACTION_REMOVED
    FILE_ACTION_MODIFIED
    FILE_ACTION_RENAMED_OLD_NAME
    FILE_ACTION_RENAMED_NEW_NAME
);

our $VERSION = '0.01';

use Win32::API;

## Exported stuff
sub FILE_NOTIFY_CHANGE_FILE_NAME    {0x00000001}
sub FILE_NOTIFY_CHANGE_DIR_NAME     {0x00000002}
sub FILE_NOTIFY_CHANGE_NAME         {0x00000003}
sub FILE_NOTIFY_CHANGE_ATTRIBUTES   {0x00000004}
sub FILE_NOTIFY_CHANGE_SIZE         {0x00000008}
sub FILE_NOTIFY_CHANGE_LAST_WRITE   {0x00000010}
sub FILE_NOTIFY_CHANGE_LAST_ACCESS  {0x00000020}
sub FILE_NOTIFY_CHANGE_CREATION     {0x00000040}
sub FILE_NOTIFY_CHANGE_EA           {0x00000080}
sub FILE_NOTIFY_CHANGE_SECURITY     {0x00000100}
sub FILE_NOTIFY_CHANGE_STREAM_NAME  {0x00000200}
sub FILE_NOTIFY_CHANGE_STREAM_SIZE  {0x00000400}
sub FILE_NOTIFY_CHANGE_STREAM_WRITE {0x00000800}

sub FILE_ACTION_ADDED                  {0x00000001}
sub FILE_ACTION_REMOVED                {0x00000002}
sub FILE_ACTION_MODIFIED               {0x00000003}
sub FILE_ACTION_RENAMED_OLD_NAME       {0x00000004}
sub FILE_ACTION_RENAMED_NEW_NAME       {0x00000005}
sub FILE_ACTION_ADDED_STREAM           {0x00000006}
sub FILE_ACTION_REMOVED_STREAM         {0x00000007}
sub FILE_ACTION_MODIFIED_STREAM        {0x00000008}
sub FILE_ACTION_REMOVED_BY_DELETE      {0x00000009}
sub FILE_ACTION_ID_NOT_TUNNELLED       {0x0000000A}
sub FILE_ACTION_TUNNELLED_ID_COLLISION {0x0000000B}

## Internal stuff
my ( $CloseHandle, $GetCurrentProcess, $OpenProcessToken,
     $LookupPrivilegeValue, $AdjustTokenPrivileges, $CreateFile,
     $ReadDirectoryChanges );

sub FILE_LIST_DIRECTORY {0x00000001}

sub FILE_SHARE_READ  {0x00000001}
sub FILE_SHARE_WRITE {0x00000002}

sub OPEN_EXISTING {3}

sub FILE_FLAG_BACKUP_SEMANTICS {0x02000000}

sub TOKEN_ADJUST_PRIVILEGES {0x0020}
sub TOKEN_QUERY             {0x0008}

sub SE_BACKUP_NAME        {'SeBackupPrivilege'}
sub SE_RESTORE_NAME       {'SeRestorePrivilege'}
sub SE_CHANGE_NOTIFY_NAME {'SeChangeNotifyPrivilege'}

sub SE_PRIVILEGE_ENABLED {2}

sub DWORD_SIZE {4}

sub _InitializeAPI {
    my $kernel32 = 'kernel32.dll';
    my $advapi32 = 'advapi32.dll';

    $CloseHandle = new Win32::API( $kernel32, 'CloseHandle', 'N', 'I' )
        || die;
    $GetCurrentProcess
        = new Win32::API( $kernel32, 'GetCurrentProcess', '', 'N' ) || die;
    $OpenProcessToken
        = new Win32::API( $advapi32, 'OpenProcessToken', 'NNP', 'I' ) || die;
    $LookupPrivilegeValue
        = new Win32::API( $advapi32, 'LookupPrivilegeValue', 'PPP', 'I' )
        || die;
    $AdjustTokenPrivileges
        = new Win32::API( $advapi32, 'AdjustTokenPrivileges', 'NIPNPP', 'I' )
        || die;
    $CreateFile = new Win32::API( $kernel32, 'CreateFileA', 'PNNPNNN', 'N' )
        or die;
    $ReadDirectoryChanges
        = new Win32::API( $kernel32, 'ReadDirectoryChangesW',
                          'NPNINPPP', 'I' )
        || die;
}

sub _EnablePrivileges {
    my $phToken = pack( "L", 0 );

    if ( $OpenProcessToken->Call( $GetCurrentProcess->Call(),
                                  TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY,
                                  $phToken
         )
        )
    {
        my $hToken = unpack( "L", $phToken );

        _SetPrivilege( $hToken, SE_BACKUP_NAME,        1 );
        _SetPrivilege( $hToken, SE_RESTORE_NAME,       1 );
        _SetPrivilege( $hToken, SE_CHANGE_NOTIFY_NAME, 1 );

        $CloseHandle->Call($hToken);
    }

    #print "privileges altered\n";
}

sub _SetPrivilege {
    my ( $hToken, $pszPriv, $bSetFlag ) = @_;

    my $iResult;
    my $pLuid = pack( "Ll", 0, 0 );

    if ( $LookupPrivilegeValue->Call( "\x00\x00", $pszPriv, $pLuid ) ) {
        my $pPrivStruct = pack( "LLlL",
                                1,
                                unpack( "Ll", $pLuid ),
                                ( ($bSetFlag) ? SE_PRIVILEGE_ENABLED : 0 ) );

        $iResult = ( 0 != $AdjustTokenPrivileges->Call(
                          $hToken, 0, $pPrivStruct, length($pPrivStruct), 0, 0
                     )
        );
    }
    return ($iResult);
}

## Methods
sub new {
    my $class = shift;
    $class = ref($class) || $class;
    my $self = {

        # the defaults
        path    => undef,
        subtree => 0,
        filter  => FILE_NOTIFY_CHANGE_NAME,

        # overridden
        @_,
    };
    bless $self, $class;
    return $self if $self->initialize(@_);
    return undef;
}

sub initialize {
    my $self = shift;

    $CloseHandle->Call( $self->{handle} )
        if ( exists( $self->{handle} )
             && $self->{handle} > 0 );
    $self->{handle}
        = $CreateFile->Call( $self->{path}, FILE_LIST_DIRECTORY,
                            FILE_SHARE_READ | FILE_SHARE_WRITE,
                            0, OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, 0 );

    return ( $self->{handle} > 0 ) ? 1 : undef;
}

sub read_changes {
    my $self = shift;

    return undef unless ( exists( $self->{handle} ) && $self->{handle} > 0 );

    my $nBufferLength = 1024;                      #1024 * DWORD_SIZE;
    my $pBuffer       = "\x00" x $nBufferLength;

    my $pBytesReturned = pack( "L", 0 );

    my $iResult =
        $ReadDirectoryChanges->Call( $self->{handle}, $pBuffer,
                                     $nBufferLength,  $self->{subtree},
                                     $self->{filter}, $pBytesReturned,
                                     0,               0
        );
    my $bytesReturned = unpack( "L", $pBytesReturned );
    my @results = ();

    if ( $bytesReturned > 0 ) {
        my ( $NextEntryOffset, $Action, $FileNameLength, $FileName );

        while (1) {
            ( $NextEntryOffset, $Action, $FileNameLength )
                = unpack( "LLL", $pBuffer );
            ( undef, undef, undef, $FileName )
                = unpack( "LLLa$FileNameLength", $pBuffer );

            $FileName = pack "C*", unpack "S*", $FileName;

            push @results, $Action => $FileName;

            last if ( $NextEntryOffset <= 0 );

            $pBuffer = substr( $pBuffer, $NextEntryOffset );
        }

    }
    return @results;
}

DESTROY {
    my $self = shift;

    $CloseHandle->Call( $self->{handle} )
        if ( exists( $self->{handle} )
             && $self->{handle} > 0 );
}

_InitializeAPI;
_EnablePrivileges;

1;

__END__

=head1 NAME

Win32::ReadDirectoryChanges - Quick and dirty ReadDirectoryChangesW Perl wrapper

=head1 SYNOPSIS

	use Win32::ReadDirectoryChanges;

	$rdc = new Win32::ReadDirectoryChanges(path    => $path,
	                                       subtree => 1,
	                                       filter  => $filter);

	@results = $rdc->read_changes;

	while (scalar @results) {
	  my ($action, $filename) = splice(@results, 0, 2);

	}

=head1 DESCRIPTION

Using Win32::API, this module allows the user to use the Win32
ReadDirectoryChangesW API call in order to monitor events relating to files and
directory trees.

See MSDN for a complete description of the features.

=head2 Methods

=over 4

=item $rdc = new Win32::ReadDirectoryChanges( %options )

This method constructs a new C<Win32::ReadDirectoryChanges> object and returns
it. Key/value pair arguments may be provided to set up the initial state.
The following options correspond to attribute methods described below:

   KEY       DEFAULT                
   -------   -----------------------
   path      undef
   subtree   0
   filter    FILE_NOTIFY_CHANGE_NAME

=item @results = $rdc->read_changes;

This method waits until modifications occured to monitored directory tree.
The returned array contains type of change codes and related file name relative
to directory tree.

=head1 SEE ALSO

See L<"Win32::API">, L<"Win32::ChangeNotify">.

=head1 REMARKS

This module is a rework of several things found on the Net. It's more a proof
of concept than something really usuable.

=head1 AUTHOR

D. Faure, E<lt>dfaure@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004 by D. Faure

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.3 or,
at your option, any later version of Perl 5 you may have available.


=cut
