#!/usr/bin/perl

# This example contains code for both a Server
# application and a Client application. The
# code is in the same file simply for
# convenience. Start a server app with.
#
# perl ipcservice.pl

# The server spawns a single client. You can
# start extra clients either using the button
# in the server app or from the command line:
#
# perl ipcservice.pl client
#
# The Server uses packages:
# MyServerConnection
# MyServer
# MyServerApp
# MyCommonFrame
# MyServiceHelper
#
# The Client uses packages
# MyClientConnection
# MyClient
# MyClientApp
# MyCommonFrame
# MyServiceHelper
# MyCustomEvent

use Wx::IPC;

############################

package MyServiceHelper;

############################

use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = bless {}, $class;
    return $self;
}

sub create_service_name {
    my ( $self, $basename ) = @_;

    # Our service name will be a unix domain socket
    # or an arbitrary DDE name on windows.
    # We also have to end up with the same path
    # on the client and the server, of course.

    # We are going to have 1 instance only
    # but it would be possible to create
    # some form of scheme where multiple
    # instances created some filesystem
    # directory that a client could query
    # for available running instances
    # and their service names.

    my $servicedir;

    if ( $^O =~ /^mswin/i ) {
        require Win32;
        my $FOLDER_LOCAL_APPDATA = 0x001C;
        $servicedir = Win32::GetFolderPath( $FOLDER_LOCAL_APPDATA, 1 );
        $servicedir = Win32::GetShortPathName($servicedir);
        $servicedir =~ s/\\/\//g;
        $servicedir .= '/wxIPC';
    }
    elsif ( $^O =~ /^darwin/i ) {
        $servicedir = $ENV{HOME} . '/Library/Application Support/wxIPC';
    }
    else {
        $servicedir = $ENV{HOME} . '/.wxIPC';
    }

    mkdir( $servicedir, 0700 ) unless -d $servicedir;
    chmod( 0700, $servicedir );
    my $servicename = qq($servicedir/$basename);
    return $servicename;
}

############################

package MyServerConnection;

############################
use strict;
use warnings;
use Wx qw( wxTheApp :ipc );
use base qw( Wx::Connection );
use Storable;

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
    return $self;
}

sub clientid {
    my $self = shift;
    return $self->{_clientid} if defined( $self->{_clientid} );
    $self->{_clientid} = 'clientid_' . Wx::NewId;
    return $self->{_clientid};
}

sub OnExecute {
    my ( $self, $topic, $data, $format ) = @_;
    Wx::LogMessage(qq(Server Received Execute : $topic : $data : $format ));

    # This is only here for 2.8.x compatibility.
    # On 2.9.x and above only override Exec
    # In this example we'll just pass on to Exec in this
    # module. (i.e. NOT SUPER);
    return $self->OnExec( $topic, $data );
}

sub OnExec {
    my ( $self, $topic, $data ) = @_;
    Wx::LogMessage(qq(Server Received Exec : $topic : $data  ));
    return 1;
}

sub OnPoke {
    my ( $self, $topic, $item, $data, $format ) = @_;

    # differ handling based on $item value
    if ( $item eq 'Poke Data' ) {
        my $info = Storable::thaw($data);
        Wx::LogMessage( 'Server Received Poked Data name: %s : clientpid: %s',
                        $info->{name}, $info->{clientpid} );
    }
    else {
        Wx::LogMessage(
                 qq(Server Received Poke : $topic : $item: $data : $format ));
    }
    return 1;
}

sub OnRequest {
    my ( $self, $topic, $item, $format ) = @_;

    # differ handling based on $format
    my $rbuff;
    if ( $format == wxIPC_PRIVATE ) {
        $rbuff = Storable::nfreeze( { name      => 'A Happy Server',
                                      serverpid => $$,
                                    }
        );
        Wx::LogMessage('Server Received Data Request');
    }
    else {
        $rbuff = 'Server wxWidgets Version ' . Wx::wxVERSION;
        Wx::LogMessage(
                     qq(Server Received Request : $topic : $item : $format ));
    }
    return $rbuff;
}

sub OnStartAdvise {
    my ( $self, $topic, $item ) = @_;
    Wx::LogMessage(qq(Server Received Start Advise : $topic : $item));
    wxTheApp->register_advise( $self, $topic, $item );
    return 1;
}

sub OnStopAdvise {
    my ( $self, $topic, $item ) = @_;
    Wx::LogMessage(qq(Server Received Stop Advise : $topic : $item));
    wxTheApp->unregister_advise( $self, $topic, $item );
    return 1;
}

sub OnDisconnect {
    my ($self) = @_;
    Wx::LogMessage(qq(Server Received Disconnect));
    wxTheApp->unregister_connection($self);
    return 1;
}

############################

package MyClientConnection;

############################

use strict;
use warnings;
use Wx qw( wxTheApp :ipc );
use base qw( Wx::Connection );

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
    return $self;
}

sub OnAdvise {
    my ( $self, $topic, $item, $data, $format ) = @_;

    # On Windows DDE alters the data format so we
    # cannot use that.
    if ( $item =~ /Data$/i ) {
        Wx::LogMessage(qq(Client Advised Data : $format : $topic : $item));
        my $windowid = 0;    # the event isn't coming from a window
                             # and our handler accepts events of
                             # the correct type from anywhere

        my $eventid = $MyClientApp::customeventid;
        my $event = MyCustomEvent->new( $eventid, $windowid );
        $event->SetMyCustomData($data);

        # we could direct the event to the App where
        # it will be handled but for examples' sake we
        # are going to get the application top window
        # and add it to that showing that events propagate
        # upwards until thay are handled.
        # If $self was an event hander, we could just add
        # the event to $self.

        my $handler = wxTheApp->GetTopWindow;

        # add event to be handled async
        $handler->GetEventHandler->AddPendingEvent($event);
    }
    else {
        Wx::LogMessage(
                  qq(Client Advised Text : $data : $topic : $item : $format));
    }
    return 1;
}

sub OnDisconnect {
    my ($self) = @_;
    Wx::LogMessage(qq(Client Disconnect));
    return 1;
}

############################

package MyServer;

############################
use strict;
use warnings;
use Wx qw( wxTheApp );
use base qw( Wx::Server );
use Carp;

sub new {
    my ( $class, $servicename ) = @_;
    my $self = $class->SUPER::new();

    my $hlp = MyServiceHelper->new;

    my $sname = $hlp->create_service_name($servicename);

    unlink($sname) if -e $sname;

    unless ( $self->Create($sname) ) {
        croak qq(failed to create service $sname );
    }
    return $self;
}

sub OnAcceptConnection {
    my ( $self, $topic ) = @_;
    my $con = MyServerConnection->new;
    Wx::LogMessage( 'Server accepted connection for topic : %s', $topic );
    wxTheApp->register_connection($con);
    return $con;
}

############################

package MyClient;

############################

use strict;
use warnings;
use Wx;
use base qw( Wx::Client );
use Carp;

sub new {
    my ($class) = @_;
    my $self = $class->SUPER::new();
    return $self;
}

sub MakeConnection {
    my ( $self, $servicename, $topic ) = @_;

    my $host  = 'localhost';
    my $hlp   = MyServiceHelper->new;
    my $sname = $hlp->create_service_name($servicename);
    $self->SUPER::MakeConnection( $host, $sname, $topic );
}

sub OnMakeConnection {
    my ($self) = @_;
    my $con = MyClientConnection->new;
    Wx::LogMessage('Client Connection Created');
    return $con;
}

############################

package MyCommonFrame;

############################
use strict;
use warnings;
use Wx qw( :ipc :id :misc :window :panel :textctrl :sizer wxTheApp );
use base qw( Wx::Frame );
use Wx::Event qw( EVT_BUTTON );

sub new {
    my $class = shift;
    my $ftype = shift;
    my $self  = $class->SUPER::new(@_);

    # base panel
    my $mp = Wx::Panel->new( $self, wxID_ANY, wxDefaultPosition,
                             wxDefaultSize, wxTAB_TRAVERSAL | wxBORDER_NONE );

    # log target
    my $text = Wx::TextCtrl->new( $mp, wxID_ANY, "", wxDefaultPosition,
                              wxDefaultSize, wxTE_READONLY | wxTE_MULTILINE );

    # button
    my $button;
    if ( $ftype eq 'server' ) {
        $button = Wx::Button->new( $mp, wxID_ANY, 'Start New Client' );
        EVT_BUTTON( $self, $button, \&on_start_client );
    }
    else {
        $button = Wx::Button->new( $mp, wxID_ANY, 'Start Server Advise' );
        EVT_BUTTON( $self, $button, \&on_toggle_advise );

        # lazy kludge for example
        $self->{advisestate} = 0;
    }

    my $log = Wx::LogTextCtrl->new($text);
    $self->{old_log} = Wx::Log::SetActiveTarget($log);

    # layout
    my $fsizer = Wx::BoxSizer->new(wxVERTICAL);
    my $psizer = Wx::BoxSizer->new(wxVERTICAL);

    $psizer->Add( $text,   1, wxALL | wxEXPAND,      5 );
    $psizer->Add( $button, 0, wxALL | wxALIGN_RIGHT, 5 );
    $mp->SetSizer($psizer);

    $fsizer->Add( $mp, 1, wxALL | wxEXPAND, 0 );
    $self->SetSizer($fsizer);

    return $self;
}

# Server Only Event
sub on_start_client {
    my ( $self, $event ) = @_;
    wxTheApp->execute_client_app;
}

# Client Only Event
sub on_toggle_advise {
    my ( $self, $event ) = @_;

    # Register for a data and a text advice

    if ( $self->{advisestate} ) {
        $self->{advisestate} = 0;
        wxTheApp->{service}->StopAdvise('Advise Text');
        wxTheApp->{service}->StopAdvise('Advise Data');
        $event->GetEventObject->SetLabel('Start Server Advise');
    }
    else {
        $self->{advisestate} = 1;
        wxTheApp->{service}->StartAdvise('Advise Text');
        wxTheApp->{service}->StartAdvise('Advise Data');
        $event->GetEventObject->SetLabel('Stop Server Advise');
    }
}

############################

package MyServerApp;

############################
use strict;
use warnings;
use Wx qw( :id :misc :ipc wxEXEC_ASYNC);
use base qw( Wx::App );
use Wx::Event qw( EVT_TIMER );

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    return $self;
}

sub OnInit { 1; }

sub MainLoop {
    my $self = shift;
    my $mwin = MyCommonFrame->new( 'server',
                                   undef,
                                   wxID_ANY,
                                   'Wx::IPC Server Application',
                                   wxDefaultPosition,
                                   [ 500, 300 ]
    );
    $mwin->Show(1);
    $self->SetTopWindow($mwin);
    Wx::LogMessage('Wx::Server Started');
    $self->{service} = MyServer->new('wxIPCTestService');

    # Mock up this application actually doing something
    # so we can advise clients periodically
    {
        my $tid = Wx::NewEventType;
        $self->{mocktimer} = Wx::Timer->new( $self, $tid );
        EVT_TIMER( $self, $tid, \&OnMockTimer );
        $self->{mocktimer}->Start(1200);
    }

    # start a client process
    {
        $self->{_client_command_args} = [ $^X, $0, 'client' ];
        $self->execute_client_app;
    }

    $self->SUPER::MainLoop;
}

sub OnMockTimer {
    my ( $self, $event ) = @_;

    # called every 1200 milliseconds
    # loop through our client advise register
    foreach my $conid ( sort keys( %{ $self->{_advise} } ) ) {
        unless ( exists( $self->{_connections}->{$conid} ) ) {
            delete $self->{_advise}->{$conid};
            next;
        }
        my $conn   = $self->{_connections}->{$conid};
        my $topics = $self->{_advise}->{$conid};
        foreach my $topic ( sort keys(%$topics) ) {
            my $items = $topics->{$topic};
            foreach my $item ( sort keys(%$items) ) {
                my $duration = time() - $items->{$item};
                if ( $item =~ /Data$/i ) {
                    my $mdata = Storable::nfreeze(
                                 { serverpid => $$, duration => $duration } );
                    $conn->Advise( $item, $mdata, wxIPC_PRIVATE );
                }
                elsif ( $item =~ /Text/i ) {
                    $conn->Advise( $item,
                                   qq(ServerPid $$ : Duration $duration),
                                   wxIPC_TEXT );
                }
            }
        }
    }
}

# register / unregister methods
# allow us to push info to interested
# clients on OnMockTimer

sub register_connection {
    my ( $self, $con ) = @_;
    my $id = $con->clientid;
    $self->{_connections}->{$id} = $con;
}

sub unregister_connection {
    my ( $self, $con ) = @_;
    my $id = $con->clientid;
    delete $self->{_connections}->{$id};
}

sub register_advise {
    my ( $self, $con, $topic, $item ) = @_;
    my $id = $con->clientid;
    $self->{_advise}->{$id}->{$topic}->{$item} = time();
}

sub unregister_advise {
    my ( $self, $con, $topic, $item ) = @_;
    my $id = $con->clientid;
    delete $self->{_advise}->{$id}->{$topic}->{$item};
}

# start a client application
sub execute_client_app {
    my $self = shift;
    Wx::ExecuteArgs( $self->{_client_command_args}, wxEXEC_ASYNC );
}

############################

package MyCustomEvent;

############################
use strict;
use warnings;
use Wx;
use base qw( Wx::PlCommandEvent );
use Storable;

# This demonstrates using an event
# to allow none blocking response
# to ICP messages. In this example
# used in client app OnAdvise

# We use storable, but we don't have
# to. We just have to copy our
# custom data in the mandatory
# Clone method.

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new(@_);
    $self->{_customdata} = undef;
    return $self;
}

sub GetMyCustomData {
    my $self = shift;
    return Storable::thaw( $self->{_customdata} );
}

sub SetMyCustomData {
    my ( $self, $data ) = @_;
    $self->{_customdata} = $data;
}

sub Clone {
    my $self = shift;
    my $clone = ref($self)->new( $self->GetEventType, $self->GetId );

    # we can't use GetMyCustomData as that 'thaws'
    $clone->SetMyCustomData( $self->{_customdata} );
    return $clone;
}

############################

package MyClientApp;

############################
use strict;
use warnings;
use Wx qw( :id :ipc :misc );
use base qw( Wx::App );
use Storable;
use Wx::Event qw( EVT_COMMAND );

our $customeventid = Wx::NewEventType;

sub new {
    my $class = shift;
    my $self  = $class->SUPER::new();
    EVT_COMMAND( $self, wxID_ANY, $customeventid, \&OnEvtAdvise );
    return $self;
}

sub OnInit { 1; }

sub OnEvtAdvise {
    my ( $self, $event ) = @_;
    my $data = $event->GetMyCustomData;

    Wx::LogMessage( 'Server pid %s advising for %s seconds',
                    $data->{serverpid}, $data->{duration} );
}

sub MainLoop {
    my $self = shift;
    my $mwin = MyCommonFrame->new( 'client',
                                   undef,
                                   wxID_ANY,
                                   'Wx::IPC Client Application',
                                   wxDefaultPosition,
                                   [ 500, 300 ]
    );
    $mwin->Centre;
    $mwin->Show(1);
    $self->SetTopWindow($mwin);
    Wx::LogMessage('Wx::Client Started');

    # connect to server
    $self->{client} = MyClient->new();
    my $svc = $self->{client}
        ->MakeConnection( 'wxIPCTestService', 'DefaultTopic' );

    # Request
    my $result = $svc->Request('Request Item Name');
    Wx::LogMessage(qq(Request Text Result : $result));

    # Data Request
    {
        $result = $svc->Request( 'Request Item Name', wxIPC_PRIVATE );
        my $info = Storable::thaw($result);
        Wx::LogMessage( 'Request Data Result : name = %s : serverpid = %s',
                        $info->{name}, $info->{serverpid} );
    }

    # Execute
    my $ebuffer = 'Execute Command Buffer Text';
    $svc->Execute($ebuffer);

    # Poke
    my $pbuffer = 'Poke Command Buffer Text';
    $svc->Poke( 'Poke Item Name', $pbuffer );

    # Poke Data
    {
        my $info = { name      => 'A Happy Client',
                     clientpid => $$,
        };
        my $databuf = Storable::nfreeze($info);
        $svc->Poke( 'Poke Data', $databuf );
    }

    # See button event in frame for Start/Stop Advise

    $self->{service} = $svc;
    $self->SUPER::MainLoop;
}

############################

package main;

############################

my $app
    = ( $ARGV[0] && $ARGV[0] eq 'client' )
    ? MyClientApp->new
    : MyServerApp->new;

$app->MainLoop;

