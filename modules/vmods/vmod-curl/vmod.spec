Summary: CURL support for Varnish VCL
Name: vmod-curl
Version: %{_varnish_version}
Release: %{_release}%{?dist}
License: BSD
Group: System Environment/Daemons
Source0: %{name}-%{_version}.tar.gz
# BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: varnish >= %{_varnish_version}
Requires: curl > 7.19.0
BuildRequires: make
BuildRequires: automake
BuildRequires: autoconf
BuildRequires: libtool
BuildRequires: python-docutils
BuildRequires: varnish >= %{_varnish_version}
BuildRequires: %{_varnish_devel} >= %{_varnish_version}
BuildRequires: curl-devel > 7.19.0

%description
CURL support for Varnish VCL

%prep
%setup -q -n %{name}-%{_version}

%build
./autogen.sh
./configure --prefix=/usr/ --docdir='${datarootdir}/doc/%{name}'
make

%check
make check

%install
make install DESTDIR=%{buildroot}
mkdir -p %{buildroot}/usr/share/doc/%{name}/
cp README.rst %{buildroot}/usr/share/doc/%{name}/
cp LICENSE %{buildroot}/usr/share/doc/%{name}/

%clean
rm -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{_libdir}/varnish/vmods/
%doc /usr/share/doc/%{name}/*
%{_mandir}/man?/*

%changelog
* Sat Sep 8 2018 Waldek Kozba <100assc@gmail.com> 
- Initial version.