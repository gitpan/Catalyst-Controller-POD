
  use inc::Module::Install;
  
  # Define metadata
  name           'Catalyst-Controller-POD';
  all_from       'lib/Catalyst/Controller/POD.pm';
  
  # Specific dependencies
  requires        'Test::More' => 0;
  requires        'Pod::Simple' => 0;
  requires        'File::Find' => 0;
  requires        'File::ShareDir' => 0;
  requires        'File::Slurp' => 0;
  requires        'Pod::Simple' => 0;
  requires        'JSON::XS' => 0;
  requires        'Pod::POM' => 0;
  requires        'LWP::Simple' => 0;
  requires "XML::Simple" => 0;
  requires        'List::MoreUtils' => 0;
  requires        'Class::Accessor::Fast' => 0;
  requires        'Catalyst::Controller' => 0;
  requires	'Pod::POM::View::TOC' => "0.02";
  requires 'Pod::TOC' => "1.08";
  test_requires  'Test::More'  => '0.42';
  test_requires 'Test::WWW::Mechanize::Catalyst' => 0;
  install_share();
  WriteAll;

