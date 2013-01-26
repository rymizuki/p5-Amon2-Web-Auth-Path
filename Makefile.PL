use inc::Module::Install;
use Module::Install::AuthorTests;

name 'Amon2-Plugin-Web-Auth-Path';
all_from 'lib/Amon2/Plugin/Web/Auth/Path.pm';

requires 'Plack::Util';
requires 'Router::Simple';

tests 't/*.t';
test_requires 'Test::More';

WriteAll;
