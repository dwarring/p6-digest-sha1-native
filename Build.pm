use v6;
use LibraryMake;
use Shell::Command;

class Build {
    method build($dir) {
        my %vars = get-vars($dir);
        %vars<sha1> = $*VM.platform-library-name('sha1'.IO);
        mkdir "$dir/resources" unless "$dir/resources".IO.e;
        mkdir "$dir/resources/libraries" unless "$dir/resources/libraries".IO.e;
        process-makefile($dir, %vars);
        my $goback = $*CWD;
        chdir($dir);
        my $proc = shell(%vars<MAKE>);
	chdir($goback);
        if $proc.exitcode && Rakudo::Internals.IS-WIN {
            # try again with vanilla GCC compilation and using
            # either `make` or `gmake`.  Hopefully works with
            # choco make + mingw or Strawberry Perl
	    %vars<CC> = 'gcc';
	    %vars<CCFLAGS> = '-fPIC -O3 -DNDEBUG --std=gnu99 -Wextra -Wall';
	    %vars<LD> = 'gcc';
	    %vars<LDSHARED> = '-shared';
	    %vars<LDFLAGS> = '-fPIC -O3';
	    %vars<LIBS> = '';
	    %vars<CCOUT> = '-o ';
	    %vars<LDOUT> = '-o ';
            for <make gmake> -> $maker {
	        process-makefile($dir, %vars);
	        chdir($dir);
	        shell(%vars<MAKE>);
	        chdir($goback);
            }
	}
    }
}

