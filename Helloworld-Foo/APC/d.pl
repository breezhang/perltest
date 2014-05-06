#!perl -w
use Win32::CLR;
use Data::Dumper::Concise;

$a = Win32::CLR->create_instance(
    "System.DateTime, mscorlib, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089",
    2007, 8, 9, 10, 11, 12
);

print $a;
