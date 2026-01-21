import org.parosproxy.paros.network.HttpMessage
import org.apache.commons.httpclient.URI

/**
 * Set this value to the endpoint you want to redirect.
 * Don't include a leading slash, it is assumed by the matcher.
 * Leaving it blank will redirect all calls.
 */
PATH_TO_MATCH = ''

/**
 * To customise the location of the mock server, set the top three constants accordingly.
 */
class Mock {
    static SERVER_PORT = 9999
    static SERVER_HOST = 'localhost'
    static SERVER_SCHEME = 'http'

    static BASE_URI = new URI(SERVER_SCHEME, null, SERVER_HOST, SERVER_PORT)

    static def redirectForUri(URI uri) {
        new URI(BASE_URI, uri.getPathQuery(), true)
    }
}

boolean proxyRequest(HttpMessage msg){
    uri = msg.getRequestHeader().getURI()
    if (uri.toString() ==~ /.+\/$PATH_TO_MATCH.*/) {
        redirectURI = Mock.redirectForUri(uri)
        msg.getRequestHeader().setURI(redirectURI)
    }
    true
}

boolean proxyResponse(HttpMessage msg){true}
