# vim:set ft= ts=4 sw=4 et fdm=marker:

use lib 'lib';
use Test::Nginx::Socket;

#worker_connections(1014);
#master_process_enabled(1);
#log_level('warn');

repeat_each(2);

plan tests => blocks() * repeat_each() * 3;

#no_diff();
#no_long_string();

run_tests();

__DATA__

=== TEST 1: set response content-type header
--- config
    location /read {
        content_by_lua '
            ngx.header.content_type = "text/my-plain";
            ngx.say("Hi");
        ';
    }
--- request
GET /read
--- response_headers
Content-Type: text/my-plain
--- response_body
Hi



=== TEST 2: set response content-type header
--- config
    location /read {
        content_by_lua '
            ngx.header.content_length = "text/my-plain";
            ngx.say("Hi");
        ';
    }
--- request
GET /read
--- response_body_like: 500 Internal Server Error
--- response_headers
Content-Type: text/html
--- error_code: 500



=== TEST 3: set response content-type header
--- config
    location /read {
        content_by_lua '
            ngx.header.content_length = 3
            ngx.say("Hello")
        ';
    }
--- request
GET /read
--- response_headers
Content-Length: 3
--- response_body
Hello



=== TEST 4: set response content-type header
--- config
    location /read {
        content_by_lua '
            ngx.status = 302;
            ngx.header["Location"] = "http://www.taobao.com/foo";
        ';
    }
--- request
GET /read
--- response_headers
Location: http://www.taobao.com/foo
--- response_body
--- error_code: 302



=== TEST 5: set response content-type header
--- config
    location /read {
        content_by_lua '
            ngx.header.content_length = 3
            ngx.header.content_length = nil
            ngx.say("Hello")
        ';
    }
--- request
GET /read
--- response_headers
!Content-Length
--- response_body
Hello



=== TEST 6: set multi response content-type header
--- config
    location /read {
        content_by_lua '
            ngx.header["X-Foo"] = {"a", "bc"}
            ngx.say("Hello")
        ';
    }
--- request
GET /read
--- raw_response_headers_like chomp
X-Foo: a\r\n.*?X-Foo: bc$
--- response_body
Hello



=== TEST 7: set response content-type header
--- config
    location /read {
        content_by_lua '
            ngx.header.content_type = {"a", "bc"}
            ngx.say("Hello")
        ';
    }
--- request
GET /read
--- response_headers
Content-Type: bc
--- response_body
Hello



=== TEST 8: set multi response content-type header and clears it
--- config
    location /read {
        content_by_lua '
            ngx.header["X-Foo"] = {"a", "bc"}
            ngx.header["X-Foo"] = {}
            ngx.say("Hello")
        ';
    }
--- request
GET /read
--- response_headers
!X-Foo
--- response_body
Hello



=== TEST 9: set multi response content-type header and clears it
--- config
    location /read {
        content_by_lua '
            ngx.header["X-Foo"] = {"a", "bc"}
            ngx.header["X-Foo"] = nil
            ngx.say("Hello")
        ';
    }
--- request
GET /read
--- response_headers
!X-Foo
--- response_body
Hello



=== TEST 10: set multi response content-type header (multiple times)
--- config
    location /read {
        content_by_lua '
            ngx.header["X-Foo"] = {"a", "bc"}
            ngx.header["X-Foo"] = {"a", "abc"}
            ngx.say("Hello")
        ';
    }
--- request
GET /read
--- raw_response_headers_like chomp
X-Foo: a\r\n.*?X-Foo: abc$
--- response_body
Hello



=== TEST 11: clear first, then add
--- config
    location /lua {
        content_by_lua '
            ngx.header["Foo"] = {}
            ngx.header["Foo"] = {"a", "b"}
            ngx.send_headers()
        ';
    }
--- request
    GET /lua
--- raw_response_headers_like eval
".*Foo: a\r
Foo: b.*"
--- response_body



=== TEST 12: first add, then clear, then add again
--- config
    location /lua {
        content_by_lua '
            ngx.header["Foo"] = {"c", "d"}
            ngx.header["Foo"] = {}
            ngx.header["Foo"] = {"a", "b"}
            ngx.send_headers()
        ';
    }
--- request
    GET /lua
--- raw_response_headers_like eval
".*Foo: a\r
Foo: b.*"
--- response_body



=== TEST 13: names are the same in the beginning (one value per key)
--- config
    location /lua {
        content_by_lua '
            ngx.header["Foox"] = "barx"
            ngx.header["Fooy"] = "bary"
            ngx.send_headers()
        ';
    }
--- request
    GET /lua
--- response_headers
Foox: barx
Fooy: bary



=== TEST 14: names are the same in the beginning (multiple values per key)
--- config
    location /lua {
        content_by_lua '
            ngx.header["Foox"] = {"conx1", "conx2" }
            ngx.header["Fooy"] = {"cony1", "cony2" }
            ngx.send_headers()
        ';
    }
--- request
    GET /lua
--- response_headers
Foox: conx1, conx2
Fooy: cony1, cony2



=== TEST 15: set header after ngx.print
--- config
    location /lua {
        default_type "text/plain";
        content_by_lua '
            ngx.print("hello")
            ngx.header.content_type = "text/foo"
        ';
    }
--- request
    GET /lua
--- response_headers
Content-Type:
--- error_code:
--- response_body:



=== TEST 16: get content-type header after ngx.print
--- config
    location /lua {
        default_type "text/my-plain";
        content_by_lua '
            ngx.print("hello, ")
            ngx.say(ngx.header.content_type)
        ';
    }
--- request
    GET /lua
--- response_headers
Content-Type: text/my-plain
--- response_body
hello, text/my-plain



=== TEST 17: get content-length header
--- config
    location /lua {
        content_by_lua '
            ngx.header.content_length = 2;
            ngx.say(ngx.header.content_length);
        ';
    }
--- request
    GET /lua
--- response_headers
Content-Length: 2
--- response_body
2



=== TEST 18: get content-length header
--- config
    location /lua {
        content_by_lua '
            ngx.header.foo = "bar";
            ngx.say(ngx.header.foo);
        ';
    }
--- request
    GET /lua
--- response_headers
foo: bar
--- response_body
bar



=== TEST 19: get content-length header (proxy)
--- config
    location /main {
        set $footer '';
        proxy_pass http://127.0.0.1:$server_port/echo;
        header_filter_by_lua '
            ngx.var.footer = ngx.header.content_length
        ';
        echo_after_body $footer;
    }
    location /echo {
        content_by_lua 'ngx.print("Hello")';
    }
--- request
    GET /main
--- response_headers
!Content-Length
--- response_body
Hello5



=== TEST 20: set and get content-length header (proxy)
--- config
    location /main {
        set $footer '';
        proxy_pass http://127.0.0.1:$server_port/echo;
        header_filter_by_lua '
            ngx.header.content_length = 27
            ngx.var.footer = ngx.header.content_length
        ';
        echo_after_body $footer;
    }
    location /echo {
        content_by_lua 'ngx.print("Hello")';
    }
--- request
    GET /main
--- response_headers
!Content-Length
--- response_body
Hello27



=== TEST 21: get content-type header (proxy)
--- config
    location /main {
        set $footer '';
        proxy_pass http://127.0.0.1:$server_port/echo;
        header_filter_by_lua '
            ngx.var.footer = ngx.header.content_type
        ';
        echo_after_body $footer;
    }
    location /echo {
        default_type 'abc/foo';
        content_by_lua 'ngx.print("Hello")';
    }
--- request
    GET /main
--- response_headers
Content-Type: abc/foo
--- response_body
Helloabc/foo



=== TEST 22: set and get content-type header (proxy)
--- config
    location /main {
        set $footer '';
        proxy_pass http://127.0.0.1:$server_port/echo;
        header_filter_by_lua '
            ngx.header.content_type = "text/blah"
            ngx.var.footer = ngx.header.content_type
        ';
        echo_after_body $footer;
    }
    location /echo {
        default_type 'abc/foo';
        content_by_lua 'ngx.print("Hello")';
    }
--- request
    GET /main
--- response_headers
Content-Type: text/blah
--- response_body
Hellotext/blah



=== TEST 23: get user header (proxy)
--- config
    location /main {
        set $footer '';
        proxy_pass http://127.0.0.1:$server_port/echo;
        header_filter_by_lua '
            ngx.var.footer = ngx.header.baz
        ';
        echo_after_body $footer;
    }
    location /echo {
        content_by_lua '
            ngx.header.baz = "bah"
            ngx.print("Hello")
        ';
    }
--- request
    GET /main
--- response_headers
baz: bah
--- response_body
Hellobah



=== TEST 24: set and get user header (proxy)
--- config
    location /main {
        set $footer '';
        proxy_pass http://127.0.0.1:$server_port/echo;
        header_filter_by_lua '
            ngx.header.baz = "foo"
            ngx.var.footer = ngx.header.baz
        ';
        echo_after_body $footer;
    }
    location /echo {
        content_by_lua '
            ngx.header.baz = "bah"
            ngx.print("Hello")
        ';
    }
--- request
    GET /main
--- response_headers
baz: foo
--- response_body
Hellofoo



=== TEST 25: get multiple user header (proxy)
--- config
    location /main {
        set $footer '';
        proxy_pass http://127.0.0.1:$server_port/echo;
        header_filter_by_lua '
            ngx.var.footer = table.concat(ngx.header.baz, ", ")
        ';
        echo_after_body $footer;
    }
    location /echo {
        content_by_lua '
            ngx.header.baz = {"bah", "blah"}
            ngx.print("Hello")
        ';
    }
--- request
    GET /main
--- raw_response_headers_like eval
"baz: bah\r
.*?baz: blah"
--- response_body
Hellobah, blah



=== TEST 26: set and get multiple user header (proxy)
--- config
    location /main {
        set $footer '';
        proxy_pass http://127.0.0.1:$server_port/echo;
        header_filter_by_lua '
            ngx.header.baz = {"foo", "baz"}
            ngx.var.footer = table.concat(ngx.header.baz, ", ")
        ';
        echo_after_body $footer;
    }
    location /echo {
        content_by_lua '
            ngx.header.baz = {"bah", "hah"}
            ngx.print("Hello")
        ';
    }
--- request
    GET /main
--- raw_response_headers_like eval
"baz: foo\r
.*?baz: baz"
--- response_body
Hellofoo, baz



=== TEST 27: get non-existant header
--- config
    location /lua {
        content_by_lua '
            ngx.say(ngx.header.foo);
        ';
    }
--- request
    GET /lua
--- response_headers
!foo
--- response_body
nil



=== TEST 28: get non-existant header
--- config
    location /lua {
        content_by_lua '
            ngx.header.foo = {"bah", "baz", "blah"}
            ngx.header.foo = nil
            ngx.say(ngx.header.foo);
        ';
    }
--- request
    GET /lua
--- response_headers
!foo
--- response_body
nil



=== TEST 29: override domains in the cookie
--- config
    location /foo {
        echo hello;
        add_header Set-Cookie 'foo=bar; Domain=backend.int';
        add_header Set-Cookie 'baz=bah; Domain=backend.int';
    }

    location /main {
        proxy_pass http://127.0.0.1:$server_port/foo;
        header_filter_by_lua '
            local cookies = ngx.header.set_cookie
            if not cookies then return end
            if type(cookies) ~= "table" then cookies = {cookies} end
            local newcookies = {}
            for i, val in ipairs(cookies) do
                local newval = string.gsub(val, "([dD]omain)=[%w_-\\\\.]+",
                          "%1=external.domain.com")
                table.insert(newcookies, newval)
            end
            ngx.header.set_cookie = newcookies
        ';
    }
--- request
    GET /main
--- response_headers
Set-Cookie: foo=bar; Domain=external.domain.com, baz=bah; Domain=external.domain.com
--- response_body
hello

