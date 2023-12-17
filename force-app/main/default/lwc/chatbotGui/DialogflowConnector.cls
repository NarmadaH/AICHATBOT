public with sharing class DialogflowConnector {
    private static final String ENDPOINT_URL = 'https://api.dialogflow.com/v2/';
    private static final String PROJECT_ID = 'first-demo-gbto';
    private static final String ACCESS_TOKEN = 'ya29.c.c0AY_VpZg-Hqa0iJbegJxTic1xr-Z5AFOuiDNdtTU1g2Pvlkm75XBEC6TtnvA8jruqjTZezdrjxkx0DsGTxxjcDy6ZFc_JldYXWpDMIdcT68Z-Y-Ex-wj_5OAv8ZtJFcNneOr7Vd1Bgcc1ymcLUJM95wGwRkkkXzDU_otA5lXw-MzqZ1JXV13K8Q2yj5PjZaxFlzyMCs65-rABSAQkbd4MJfkW2pTaTlqO49-um1ovGk90sq2td47NNpmvWfq_S9XNNMITg-4y3avfNq4OwrazjXNHNnrkeq7mi6ciNAl_7lk9_nfyilflZZpU_gq8uFKCG6EL-SjumxCgP5JbQfRf6v-t8hwZ2a3ocAQklb2XRdqABjDLgDemsRiDUebjkRVFgUsAEWcH400Dp95lUXZ4IsfnmihfWmu046JqZfIj6gld7Bmpc7yS9_wJe5z32sFmbcozeQ0qrYxMiSbzaaUlymkFiYOo8ybwRzVdFRIO9uB2sacxa8rWb9BIrI-wWkSmSrSyyyM3OdudrBYy5Bh__mgJZSm0lYpowg6QQlpzOuxwXX236egQsy1Mz9nMegSyy1sy3Ujz6jo8r4O7XVVde7p12zRV6laitlmO5YS1xvtZ1zMFXRlFyZipQvuqk-JSy273t-_2gm_peg8dzvOOyp2Fiutfwvm4gqmaQZmd9tFIsfhUQq2SgusRFsjZIb8_BoOOx3psqhueZ65zS0IroFF4iSc2McBlnb1UqaQ1UY_OeQkFj8IpV4waJl1QFn39urtsw39JslSbUY1hlOepZhReu_-5qR7SnzasRWO_zIkJ04V-RpO-VjSjxtUoakaWkyuQs47_n_UjhnwkbjRBxFjMyQ-nm4gb2copM6BJSisi65r_oQ2QcaMSkiy2Wbg5-63M-aqqvsRjId_ykJ8tZ5cSBiyZcJB6dRvXRw-lF1w80B5-vd2WUXs29czYaae_e_8YMBq8qxy-0zwIbU9ScRdsjrWnev1JRX-OR_i2WhRUi9Whuo5p6V1';

    @AuraEnabled(cacheable=false)
    public static String sendMessageToDialogflow(String sessionId, String message) {
        String url = ENDPOINT_URL + 'projects/' + PROJECT_ID + '/agent/sessions/' + sessionId + ':detectIntent';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('POST');
        req.setHeader('Authorization', 'Bearer ' + ACCESS_TOKEN);
        req.setHeader('Content-Type', 'application/json;charset=UTF-8');

        // Create the JSON body
        Map<String, Object> textInput = new Map<String, Object>{ 'text' => message, 'languageCode' => 'en' };
        Map<String, Object> queryInput = new Map<String, Object>{ 'text' => textInput };
        Map<String, Object> body = new Map<String, Object>{ 'queryInput' => queryInput };

        req.setBody(JSON.serialize(body));

        Http http = new Http();
        HttpResponse res = http.send(req);
        if (res.getStatusCode() == 200) {
            return res.getBody();
        } else {
            // Handle errors
            System.debug('Dialogflow API Error: ' + res.getBody());
            return null;
        }
    }
}
