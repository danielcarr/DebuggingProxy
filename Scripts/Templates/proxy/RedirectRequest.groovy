import org.parosproxy.paros.network.HttpMessage
import org.apache.commons.httpclient.URI

boolean proxyRequest(HttpMessage msg){
    URL_COMPONENT_TO_REPLACE = ''
    REPLACEMENT = ''

    url = msg.getRequestHeader().getURI().toString()
    if (url ==~ /.*$URL_COMPONENT_TO_REPLACE.*/) {
        redirectUrl = url.replace(URL_COMPONENT_TO_REPLACE, REPLACEMENT)
        msg.getRequestHeader().setURI(new URI(redirectUrl, true))
    }
    true
}

boolean proxyResponse(HttpMessage msg){true}
