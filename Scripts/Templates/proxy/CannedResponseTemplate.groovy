import org.parosproxy.paros.network.HttpMessage

/*
The response of the endpoint that ends in `pattern` will be replaced with `body`. 
*/

boolean proxyResponse(HttpMessage msg) {
    pattern = ''
    url = msg.getRequestHeader().getURI().toString()
    if (url ~== $/.*/${pattern}/$) {
        body = $/\

        /$.stripIndent()
        msg.setResponseBody(body)
        msg.getResponseHeader().setContentLength(body.size())
        msg.getResponseHeader().setHeader('PROXY-DEBUG', 'true')
        msg.getResponseHeader().setStatusCode(200)
        msg.getResponseHeader().setReasonPhrase('OK (Fake)')
    }
    return true
}

boolean proxyRequest(HttpMessage msg){true}
