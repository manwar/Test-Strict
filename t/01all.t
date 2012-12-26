#!/usr/bin/perl -w
use strict;
use Test::Strict;
use File::Temp qw( tempdir tempfile );

my $HAS_WIN32 = 0;
if ($^O =~ /Win|Dos/i) { # Load Win32 if we are under Windows and if module is available
  eval q{ use Win32 };
  if ($@) {
    warn "Optional module Win32 missing, consider installing\n";
  }
  else {
    $HAS_WIN32 = 1;
  }
}

##
## This should check all perl files in the distribution
## including this current file, the Makefile.PL etc.
## and check for "use strict;" and syntax ok
##

all_perl_files_ok();

strict_ok( $0, "got strict" );
syntax_ok( $0, "syntax" );
syntax_ok( 'Test::Strict' );
strict_ok( 'Test::Strict' );
warnings_ok( $0 );

my $warning_file1 = make_warning_file1();
warnings_ok( $warning_file1 );

my $warning_file2 = make_warning_file2();
warnings_ok( $warning_file2 );

my $warning_file3 = make_warning_file3();
warnings_ok( $warning_file3 );

my $warning_file4 = make_warning_file4();
warnings_ok( $warning_file4 );

my $warning_file5 = make_warning_file5();
warnings_ok( $warning_file5 );

{
  my ($warnings_files_dir, $file_to_skip) = make_warning_files();
  local $Test::Strict::TEST_WARNINGS = 1;
  local $Test::Strict::TEST_SKIP = [ $file_to_skip ];
  all_perl_files_ok( $warnings_files_dir );
}



sub make_warning_file1 {
  my $tmpdir = tempdir( CLEANUP => 1 );
  my ($fh, $filename) = tempfile( DIR => $tmpdir, SUFFIX => '.pL' );
  print $fh <<'DUMMY';
#!/usr/bin/perl -w

print "hello world";

DUMMY
  return $HAS_WIN32 ? Win32::GetLongPathName($filename) : $filename;
}

sub make_warning_file2 {
  my $tmpdir = tempdir( CLEANUP => 1 );
  my ($fh, $filename) = tempfile( DIR => $tmpdir, SUFFIX => '.pL' );
  print $fh <<'DUMMY';
   use warnings FATAL => 'all' ;
print "Hello world";

DUMMY
  return $HAS_WIN32 ? Win32::GetLongPathName($filename) : $filename;
}

sub make_warning_file3 {
  my $tmpdir = tempdir( CLEANUP => 1 );
  my ($fh, $filename) = tempfile( DIR => $tmpdir, SUFFIX => '.pm' );
  print $fh <<'DUMMY';
  use strict;
   use  warnings::register ;
print "Hello world";

DUMMY
  return $HAS_WIN32 ? Win32::GetLongPathName($filename) : $filename;
}

sub make_warning_file4 {
  my $tmpdir = tempdir( CLEANUP => 1 );
  my ($fh, $filename) = tempfile( DIR => $tmpdir, SUFFIX => '.pm' );
  print $fh <<'DUMMY';
use  Mouse ;
print "Hello world";

DUMMY
  return $HAS_WIN32 ? Win32::GetLongPathName($filename) : $filename;
}


sub make_warning_file5 {
  my $tmpdir = tempdir( CLEANUP => 1 );
  my ($fh, $filename) = tempfile( DIR => $tmpdir, SUFFIX => '.pm' );
  print $fh <<'DUMMY';
use  Moose;
print "Hello world";

DUMMY
  return $HAS_WIN32 ? Win32::GetLongPathName($filename) : $filename;
}


sub make_warning_files {
  my $tmpdir = tempdir( CLEANUP => 1 );
  my ($fh1, $filename1) = tempfile( DIR => $tmpdir, SUFFIX => '.pm' );
  print $fh1 <<'DUMMY';
use strict;
use  warnings::register ;
print "Hello world";

DUMMY

  my ($fh2, $filename2) = tempfile( DIR => $tmpdir, SUFFIX => '.pl' );
  print $fh2 <<'DUMMY';
#!/usr/bin/perl -vw
use strict;
print "Hello world";

DUMMY

  my ($fh3, $filename3) = tempfile( DIR => $tmpdir, SUFFIX => '.pl' );
  print $fh3 <<'DUMMY';
use  strict;
local $^W = 1;
print "Hello world";

DUMMY

  my ($fh4, $filename4) = tempfile( DIR => $tmpdir, SUFFIX => '.pl' );
  print $fh4 <<'DUMMY';
#!/usr/bin/perl -Tw
use strict;
print "Hello world";

DUMMY

  return ($tmpdir, $HAS_WIN32 ? Win32::GetLongPathName($filename3) : $filename3);
}
