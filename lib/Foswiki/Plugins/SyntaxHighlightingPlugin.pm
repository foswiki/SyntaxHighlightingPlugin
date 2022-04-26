# Plugin for Foswiki - The Free and Open Source Wiki, http://foswiki.org/
#
# Copyright (C) 2021 - 2022 Foswiki Contributors
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
# =========================
#
# This was the Syntax Highlighting TWiki plugin, now forked for Foswiki
# originally written by
# Nicolas Tisserand (tisser_n@epita.fr), Nicolas Burrus (burrus_n@epita.fr)
# and Perceval Anichini (anichi_p@epita.fr)
# Current version by Andrew Jones (andrewjones86@gmail.com)
#
# It uses enscript as syntax highlighter.
#
# Use it in your by writing %CODE{"language"}% ... %ENDCODE%
# with language = ada asm awk bash c changelog c++ csh delphi diff diffs diffu elisp fortran fortran_pp haskell html idl inf java javascript
# ksh m4 mail makefile maple matlab modula_2 nested nroff objc outline pascal perl postscript python rfc scheme sh skill sql states synopsys
# tcl tcsh tex vba verilog vhdl vrml wmlscript zsh

package Foswiki::Plugins::SyntaxHighlightingPlugin;

use strict;
use warnings;

our $VERSION = '2.00';
our $RELEASE = '26 Apr 2022';
our $SHORTDESCRIPTION = 'Highlights code fragments for many languages using ==enscript==.';
our $NO_PREFS_IN_TOPIC = 1;
our $pluginName = 'SyntaxHighlightingPlugin';
our $core;

sub initPlugin {
  return 1;
}

sub getCore {

  unless (defined $core) {
    require Foswiki::Plugins::SyntaxHighlightingPlugin::Core;
    $core = Foswiki::Plugins::SyntaxHighlightingPlugin::Core->new(@_);
  }

  return $core;
}

sub finishPlugin {
  undef $core;
}

sub commonTagsHandler {
  $_[0] =~ s/%CODE(?:_ENSCRIPT)?{(.*?)}%\s*(.*?)%ENDCODE%/&_handleTag($1, $2)/egs;
}

sub _handleTag {
  return getCore()->handleTag(@_);
}

1;
