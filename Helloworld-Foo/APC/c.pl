use Win32::API;
use Win32::API::Callback;
warn "usually fatally errors on Cygwin" if $^O eq 'cygwin';
# do not do a "use" or "require" on Win32::API::Callback::IATPatch
# IATPatch comes with Win32::API::Callback
my $LoadLibraryExA;
my $callback = Win32::API::Callback->new(
  sub {
    my $libname = unpack('p', pack('J', $_[0]));
    print "got $libname\n";
    return $LoadLibraryExA->Call($libname, $_[1], $_[2]);
  },
  'NNI',
  'N'
);
my $patch = Win32::API::Callback::IATPatch->new(
  $callback, "perl514.dll", 'kernel32.dll', 'LoadLibraryExA');
die "failed to create IATPatch Obj $^E" if ! defined $patch;
$LoadLibraryExA = Win32::API::More->new( undef, $patch->GetOriginalFunctionPtr(), '
HMODULE
WINAPI
LoadLibraryExA(
  LPCSTR lpLibFileName,
  HANDLE hFile,
  DWORD dwFlags
  );
');
die "failed to make old function object" if ! defined $LoadLibraryExA;
require Encode;
