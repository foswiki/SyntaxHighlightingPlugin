# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# Copyright (C) 2021-2022 Foswiki Contributors
# Copyright (C) 2008 - 2009 Andrew Jones, andrewjones86@gmail.com
# Copyright (C) 2000-2001 Andrea Sterbini, a.sterbini@flashnet.it
# Copyright (C) 2001 Peter Thoeny, Peter@Thoeny.com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details, published at
# http://www.gnu.org/copyleft/gpl.html
#
# This was the Syntax Highlighting TWiki plugin, now forked for Foswiki
# originally written by
# Nicolas Tisserand (tisser_n@epita.fr), Nicolas Burrus (burrus_n@epita.fr)
# and Perceval Anichini (anichi_p@epita.fr)

package Foswiki::Plugins::SyntaxHighlightingPlugin::Core;

use strict;
use warnings;

use Foswiki::Func ();
use Foswiki::Sandbox ();
use File::Temp ();
use Error qw(:try);

our %LANGS = (
  "ada" => "ada",
  "asm" => "asm",
  "awk" => "awk",
  "bash" => "bash",
  "c" => "c",
  "changelog" => "changelog",
  "cpp" => "cpp",
  "csh" => "csh",
  "delphi" => "delphi",
  "diff" => "diff",
  "diffs" => "diffs",
  "diffu" => "diffu",
  "dylan" => "dylan",
  "eiffel" => "eiffel",
  "elisp" => "elisp",
  "Name:" => "Name:",
  "f90" => "f90",
  "forth" => "forth",
  "fortran" => "fortran",
  "fortran_pp" => "fortran_pp",
  "haskell" => "haskell",
  "html" => "html",
  "icon" => "icon",
  "idl" => "idl",
  "inf" => "inf",
  "java" => "java",
  "javascript" => "javascript",
  "ksh" => "ksh",
  "lua" => "lua",
  "m4" => "m4",
  "mail" => "mail",
  "makefile" => "makefile",
  "matlab" => "matlab",
  "nroff" => "nroff",
  "oberon2" => "oberon2",
  "objc" => "objc",
  "octave" => "octave",
  "outline" => "outline",
  "oz" => "oz",
  "pascal" => "pascal",
  "perl" => "perl",
  "postscript" => "postscript",
  "pyrex" => "pyrex",
  "python" => "python",
  "rfc" => "rfc",
  "ruby" => "ruby",
  "scheme" => "scheme",
  "sh" => "sh",
  "skill" => "skill",
  "Smalltalk" => "Smalltalk",
  "sml" => "sml",
  "sql" => "sql",
  "states" => "states",
  "synopsys" => "synopsys",
  "tcl" => "tcl",
  "tcsh" => "tcsh",
  "tex" => "tex",
  "vba" => "vba",
  "verilog" => "verilog",
  "vhdl" => "vhdl",
  "vrml" => "vrml",
  "wmlscript" => "wmlscript",
  "zsh" => "zsh",
);

sub new {
  my $class = shift;

  my $this = bless({
      debug => $Foswiki::cfg{Plugins}{SyntaxHighlightingPlugin}{Debug} // 0,
      enscriptCommand => $Foswiki::cfg{Plugins}{SyntaxHighlightingPlugin}{EnscriptCommand},
      @_
    },
    $class
  );

  return $this;
}

sub handleTag {
  my ($this, $attrs, $code) = @_;

  $this->writeDebug("called handleTag, code=$code");

  my %params = Foswiki::Func::extractParameters($attrs);
  my $lang = $params{lang} || $params{_DEFAULT};
  my $result;
  my $error;

  try {
    $result = $this->highlight($code, $lang);
  } otherwise {
    $error = shift;
    $this->writeDebug("Error: $error");
    $error =~ s/ at .*$//;
  };

  return _inlineError($error) if $error;

  my $num = lc($params{num} || $params{number} || $params{numbered} || 0);
  if ($num) {
    $this->writeDebug("adding line numbers");
    $result =~ s/(^.*)/sprintf("<b class='rowNum'>%5d<\/b>\t%s", $num++, $1)/mge;
  }

  $this->writeDebug("result=$result");
  return "<pre class='syntaxHighlightingPlugin'>$result</pre>";
}

# runs enscript to highlight the code
sub highlight {
  my ($this, $code, $lang) = @_;

  $lang = lc($lang);

  throw Error::Simple("unknown language $lang") unless exists $LANGS{$lang};
  $lang = $LANGS{$lang};

  $this->writeDebug("lang=$lang");
  my $cmdTemplate = $this->{enscriptCommand};
  throw Error::Simple("plugin not configured correctly") unless $cmdTemplate;

  $this->writeDebug("cmdTemplate=$cmdTemplate");

  my $tmpFile = File::Temp->new(UNLINK => $this->{debug} ? 0 : 1);
  binmode($tmpFile, "::encoding(UTF-8)");
  print $tmpFile $code;

  $this->writeDebug("tmpFile=".$tmpFile->filename);
  # FIXME: Should we use Foswiki::Sandbox instead?
  my ($stdout, $exit, $stderr) = Foswiki::Sandbox::sysCommand(
    undef, $cmdTemplate,
    FILENAME => $tmpFile->filename,
    LANG => $lang
  );

  $this->writeDebug("stderr=$stderr");
  $this->writeDebug("exit=$exit");
  $this->writeDebug("stdout=$stdout");

  throw Error::Simple($stderr) if $stderr;

  throw Error::Simple('Internal error. Notify you administrator.')
    unless $stdout =~ s/.*\<PRE\>\n(.*?)\n?\<\/PRE\>.*/$1/s;

  return $stdout;
}

sub writeDebug {
  my ($this, $text) = @_;
  return unless $this->{debug};
  print STDERR "SyntaxHighlightingPlugin - $text\n";
  #Foswiki::Func::writeDebug("SyntaxHighlightingPlugin - $text");
}

sub _inlineError {
  my $msg = shift;
  $msg =~ s/^\s+//;
  $msg =~ s/\s+$//;
  return "<span class='foswikiAlert'>$msg</span>";
}


1;

