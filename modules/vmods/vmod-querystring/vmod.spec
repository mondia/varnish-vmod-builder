# -D MUST pass in _version and _release, and SHOULD pass in dist.

Summary: QueryString module for Varnish Cache
Name: vmod-querystring
Version: %{_varnish_version}
Release: %{_release}%{?dist}
License: GPLv3+
Group: System Environment/Daemons
URL: https://github.com/Dridi/libvmod-querystring
Source0: %{name}-%{_version}.tar.gz

# varnish from varnish60 at packagecloud
Requires: varnish >= %{_varnish_version}
Requires: uuid

BuildRequires: %{_varnish_devel} >= %{_varnish_version}
BuildRequires: pkgconfig
BuildRequires: make
BuildRequires: gcc
BuildRequires: python-docutils >= 0.6
BuildRequires: automake
BuildRequires: autoconf
BuildRequires: libtool

Provides: vmod-querystring, vmod-querystring-debuginfo

%description
The purpose of this module is to give you a fine-grained control over a URL's
query-string in Varnish Cache. It's possible to remove the query-string, clean
it, sort its parameters or filter it to only keep a subset of them.

This can greatly improve your hit ratio and efficiency with Varnish, because
by default two URLs with the same path but different query-strings are also
different. This is what the RFCs mandate but probably not what you usually
want for your web site or application.

A query-string is just a character string starting after a question mark in a
URL. But in a web context, it is usually a structured key/values store encoded
with the `application/x-www-form-urlencoded' media type. This module deals
with this kind of query-strings.

%prep
%setup -q -n %{name}-%{_version}


%build
./%{_autogen}
%make_build


%install
%make_install
find %{buildroot} -type f -name '*.la' -exec rm -f {} ';'


%check
%make_build check VERBOSE=1

%files
%defattr(-,root,root,-)
%{_libdir}/varnish/vmods/
%doc /usr/share/doc/%{name}/*
%{_mandir}/man?/*

%changelog
* Sat Sep 8 2018 Waldek Kozba <100assc@gmail.com> 
- Initial version.