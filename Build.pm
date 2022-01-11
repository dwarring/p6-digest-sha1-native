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
        $proc = shell(%vars<MAKE>);
        if $proc.exitcode && Rakudo::Internals.IS-WIN {
	        note 'retrying with gcc/make (mingw)...';
	        %vars<MAKE> = 'make';
	        %vars<CC> = 'gcc';
	        %vars<CCFLAGS> = '-fPIC -O3 -DNDEBUG --std=gnu99 -Wextra -Wall';
	        %vars<LD> = 'gcc';
	        %vars<LDSHARED> = '-shared';
	        %vars<LDFLAGS> = '-fPIC -O3';
	        %vars<CCOUT> = '-o ';
	        %vars<LDOUT> = '-o ';
	        LibraryMake::process-makefile($folder, %vars);
	        shell(%vars<MAKE>);
	    }
        chdir($goback);
    }
}

