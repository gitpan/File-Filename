use ExtUtils::MakeMaker;
WriteMakefile(
	NAME => 'File::Filename',
	VERSION_FROM => 'lib/File/Filename.pm',
	PREREQ_PM => {
		'Smart::Comments' => 0,
		'YAML' => 0,
		'Carp' => 0,
	}
);
