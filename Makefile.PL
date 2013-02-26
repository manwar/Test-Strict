use ExtUtils::MakeMaker;
use strict;
WriteMakefile(
    NAME	 => "Test::Strict",
    VERSION_FROM => 'lib/Test/Strict.pm',
    PREREQ_PM    => {
      'Test::Simple'  => 0.47,
      'Test::Builder' => 0.01,
      'File::Spec'    => 0.01,
      'FindBin'       => 0.01,
      'File::Find'    => 0.01,
      'Devel::Cover'  => 0.43,
      'File::Temp'    => 0.01,
        },
    LICENSE           => 'perl',
    AUTHOR            => 'Pierre Denis <pdenis@cpan.org>',
    META_MERGE        => {
       resources => {
           repository  =>  'https://github.com/szabgab/Test-Strict',
            license    => 'http://dev.perl.org/licenses/',
       },
       x_contributors => [
            'Gabor Szabo <szabgab@cpan.org>',
            'Peter Vereshagin <veresc@cpan.org>',
            'Graham Knop <haarg@cpan.org>',
       ],
	},
);
