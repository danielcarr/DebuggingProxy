import org.parosproxy.paros.network.HttpMessage

String bodyForEndpoint(String endpoint) {
    switch (endpoint) {
        case ~$//$:
            return $/\
            /$
        case ~$//$:
            return $/\
            /$
        default:
            return null
    }
}

boolean proxyResponse(HttpMessage msg) {
    url = msg.getRequestHeader().getURI().toString()
    body = bodyForEndpoint(url)?.stripIndent()
    if (body == null) { return true }
    msg.setResponseBody(body)
    msg.getResponseHeader().setContentLength(body.size())
    msg.getResponseHeader().setHeader('PROXY-DEBUG', 'true')
    msg.getResponseHeader().setStatusCode(200)
    msg.getResponseHeader().setReasonPhrase('OK (Fake)')
    return true
}

boolean proxyRequest(HttpMessage msg){true}
