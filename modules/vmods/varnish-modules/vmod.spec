Summary: Collection of Varnish Cache modules (vmods) by Varnish Software
Name: varnish-modules
Version: %{_varnish_version}
Release: %{_release}%{?dist}
License: BSD
Group: System Environment/Daemons
Source0: %{name}-%{_version}.tar.gz
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
Requires: varnish >= %{_varnish_version}
BuildRequires: make
BuildRequires: automake
BuildRequires: autoconf
BuildRequires: libtool
BuildRequires: python-docutils
BuildRequires: varnish >= %{_varnish_version}
BuildRequires: %{_varnish_devel} >= %{_varnish_version}

%description
Collection of Varnish Cache modules (vmods) by Varnish Software

%prep
%setup -q -n %{name}-%{_version}

%build
./%{_autogen}

%configure
# ./configure VARNISHSRC=%{VARNISHSRC} VMOD_DIR="$(PKG_CONFIG_PATH=%{VARNISHSRC} pkg-config --variable=vmoddir varnishapi)" --prefix=/usr/ --docdir='${datarootdir}/doc/%{name}'
# ./configure VARNISHSRC=%{VARNISHSRC} VMOD_DIR="$(PKG_CONFIG_PATH=%{VARNISHSRC} pkg-config --variable=vmoddir varnishapi)" --prefix=/usr/
# ./configure --prefix=/usr/ --docdir='${datarootdir}/doc/%{name}'
make

%check
make %{?_smp_mflags} check

%install
make install DESTDIR=%{buildroot}
mkdir -p %{buildroot}/usr/share/doc/%{name}/

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