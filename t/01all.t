#!/usr/bin/perl -w
use strict;
use Test::More;
use Test::Strict;
use File::Temp qw( tempdir tempfile );

my $HAS_WIN32 = 0;
if ($^O =~ /MSWin/i) { # Load Win32 if we are under Windows and if module is available
  eval q{ use Win32 };
  if ($@) {
    warn "Optional module Win32 missing, consider installing\n";
  }
  else {
    $HAS_WIN32 = 1;
  }
}
plan  tests => 39;

##
## This should check all perl files in the distribution
## including this current file, the Makefile.PL etc.
## and check for "use strict;" and syntax ok
##

diag "First all_perl_files_ok starting";
my $res = all_perl_files_ok();
is $res, '', 'returned empty string??';
diag "First all_perl_files_ok done";

strict_ok( $0, "got strict" );
syntax_ok( $0, "syntax" );
syntax_ok( 'Test::Strict' );
strict_ok( 'Test::Strict' );
warnings_ok( $0 );

diag 'Start creating files';
my $modern_perl_file1 = make_modern_perl_file1();
diag $modern_perl_file1;
warnings_ok( $modern_perl_file1, 'warn modern_perl1' );
strict_ok( $modern_perl_file1, 'strict modern_perl1' );


# let's make sure that a file that is not recognized as "Perl file"
# still lets the syntax_ok test work
my $extensionless_file = make_extensionless_perl_file1();
diag $extensionless_file;
ok ! Test::Strict::_is_perl_module($extensionless_file), "_is_perl_module $extensionless_file";
ok ! Test::Strict::_is_perl_script($extensionless_file), "_is_perl_script $extensionless_file";
warnings_ok( $extensionless_file, 'warn extensionless_file' );
strict_ok( $extensionless_file, 'strict extensionless_file' );
syntax_ok( $extensionless_file, 'syntax extensionless_file' );

my $warning_file1 = make_warning_file1();
diag "File1: $warning_file1";
warnings_ok( $warning_file1, 'file1' );

my $warning_file2 = make_warning_file2();
diag "File2: $warning_file2";
warnings_ok( $warning_file2, 'file2' );

# TODO: does warnings::register turn on warnings?
#my $warning_file3 = make_warning_file3();
#diag "File3: $warning_file3";
#warnings_ok( $warning_file3, 'file3' );

my $warning_file4 = make_warning_file4();
diag "File4: $warning_file4";
warnings_ok( $warning_file4, 'file4' );

my $warning_file5 = make_warning_file5();
diag "File5: $warning_file5";
warnings_ok( $warning_file5, 'file5' );

{
  my ($warnings_files_dir, $files, $file_to_skip) = make_warning_files();
  diag explain $files;
  diag "File to skip: $file_to_skip";
  local $Test::Strict::TEST_WARNINGS = 1;
  local $Test::Strict::TEST_SKIP = [ $file_to_skip ];
  all_perl_files_ok( $warnings_files_dir );
}
exit;

sub make_modern_perl_file1 {
  my $tmpdir = tempdir( CLEANUP => 1 );
  my ($fh, $filename) = tempfile( DIR => $tmpdir, SUFFIX => '.pL' );
  print $fh <<'DUMMY';
#!/usr/bin/perl
use Modern::Perl;

print "hello world";

DUMMY
  return $HAS_WIN32 ? Win32::GetLongPathName($filename) : $filename;
}
sub make_extensionless_perl_file1 {
  my $tmpdir = tempdir( CLEANUP => 1 );
  my ($fh, $filename) = tempfile( DIR => $tmpdir, SUFFIX => '' );
  print $fh <<'DUMMY';
use strict;
use warnings;

print "hello world";

DUMMY
  return $HAS_WIN32 ? Win32::GetLongPathName($filename) : $filename;
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

  my @files;
# TODO: does warnings::register turn on warnings?
#  my ($fh1, $filename1) = tempfile( DIR => $tmpdir, SUFFIX => '.pm' );
#  print $fh1 <<'DUMMY';
#use strict;
#use  warnings::register ;
#print "Hello world";
#
#DUMMY
#  push @files, $filename1;

  my ($fh2, $filename2) = tempfile( DIR => $tmpdir, SUFFIX => '.pl' );
  print $fh2 <<'DUMMY';
#!/usr/bin/perl -vw
use strict;
print "Hello world";

DUMMY
  push @files, $filename2;

  my ($fh3, $filename3) = tempfile( DIR => $tmpdir, SUFFIX => '.pl' );
  print $fh3 <<'DUMMY';
use  strict;
local $^W = 1;
print "Hello world";

DUMMY
  push @files, $filename3;

  my ($fh4, $filename4) = tempfile( DIR => $tmpdir, SUFFIX => '.pl' );
  print $fh4 <<'DUMMY';
#!/usr/bin/perl -Tw
use strict;
print "Hello world";

DUMMY
  push @files, $filename4;

  return ($tmpdir, \@files, $filename3);
}
