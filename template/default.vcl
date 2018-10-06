#
# This is an example VCL file for testing Varnish modules.
# Modify it when adding new modules to the stack.
#
vcl 4.0;

import std;
import uuid;
import vsthrottle;
import curl;
import querystring;
import directors;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "backend";
    .port = "80";
}

# Backends for testing vmod-curl
backend curl_backend1 {
    .host = "curl-backend-1";
    .port = "8080";
}
backend curl_backend2 {
    .host = "curl-backend-2";
    .port = "8080";
}

sub vcl_init {
    new curl_backend = directors.round_robin();
    curl_backend.add_backend(curl_backend1);
    curl_backend.add_backend(curl_backend2);
}

sub vcl_recv {
    # test vmod-vsthrottle
    if (vsthrottle.is_denied(client.identity, 15000, 1s, 1s)) {
        # Client has exceeded 15000 reqs per 1s.
        # When this happens, block altogether for the next 1s.
        return (synth(429, "Too Many Requests"));
    }

    # testing the vmod-querystring
    set req.url = querystring.sort(req.url);

    if (req.url ~ "curl") {
        # this is the self-call using vmod-curl
        set req.backend_hint = curl_backend.backend();
    }
}

sub vcl_backend_fetch {
}

sub vcl_backend_response {
}

sub vcl_deliver {
    set resp.http.X-TEST-UID=uuid.uuid();
    # decorate the main response with the response from vmod-curl.
    if (!(req.url ~ "curl")) {
        curl.get("http://" + server.ip + ":" + std.getenv("VARNISH_LISTEN_PORT") + "/curl/" + std.real2integer(std.random(1, 10), 1));
        set resp.http.X-CURL-RESP = curl.status() + ": " + curl.body();
        curl.free();
    } 
}
