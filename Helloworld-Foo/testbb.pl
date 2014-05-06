use Win32::GUI();
 
$text = defined($ARGV[0]) ? $ARGV[0] : "Hello, world";
 
$main = Win32::GUI::Window->new(
            -name => 'Main',
            -text => 'Perl',
    );
$font = Win32::GUI::Font->new(
            -name => "Comic Sans MS",
            -size => 24,
    );
$label = $main->AddLabel(
            -text => $text,
            -font => $font,
            -foreground => [255, 0, 0],
    );
 
$ncw = $main->Width() -  $main->ScaleWidth();
$nch = $main->Height() - $main->ScaleHeight();
$w = $label->Width()  + $ncw;
$h = $label->Height() + $nch;
 
$desk = Win32::GUI::GetDesktopWindow();
$dw = Win32::GUI::Width($desk);
$dh = Win32::GUI::Height($desk);
$x = ($dw - $w) / 2;
$y = ($dh - $h) / 2;
 
$main->Change(-minsize => [$w, $h]);
$main->Resize($w, $h);
$main->Move($x, $y);
$main->Show();
 
Win32::GUI::Dialog();
 
sub Main_Terminate {
    -1;
}
 
sub Main_Resize {
    my $mw = $main->ScaleWidth();
    my $mh = $main->ScaleHeight();
    my $lw = $label->Width();
    my $lh = $label->Height();
 
    $label->Left(int(($mw - $lw) / 2));
    $label->Top(int(($mh - $lh) / 2));
}
