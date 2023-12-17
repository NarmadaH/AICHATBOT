public with sharing class DialogflowConnector {
    private static final String ENDPOINT_URL = 'https://dialogflow.googleapis.com/v2/';
    private static final String PROJECT_ID = 'first-xdemo-gbto';
    private static final String ACCESS_TOKEN = 'ya29.c.c0AY_VpZjpnYCBDm9fooeVFG1hImQtirmOYT9BqPYJo-eruVccACwVduX_rmGjhUQoqZvbk-YX-5xu8QSpTANM3oJFGGFyk_BtdClr0KGjcr4vvyJ_C8spOiHi9DmY2FHx1r6bLVskeKBO6Jz7cihQgkL6wplJupqu7dmK7amIEx6ez0HMp3xnVMytR5SDxs16pPPLRIrBmIr6ujbLsEnObTRxKYdcH0NSczQF-MNfSBC5Cj9f8ylfmaYMz-3K91-lhFEbQS-MgDfmNtw5-P8DI3kbWw4sNxtm3aF_s86TOifdxoP7CYW1qfl43d0mnj-tn1t0eJcNV9zCmNHWNldnMRwXchZB756TljSpZAEIoY1rpVdFKOdBRednH385Aty4aQ8MyyxffnUcFgytUO-dFcQV3SwnywxsXjz-n7iOcmbMYjagYhlYJ33-mdwfbbs2_YZO1J5FVWfetb__s-dX5Q0ih6O1OhfmuVZhpuy9cMm64pswZ9cp97-dV6YwUi7IX4a1h_6fbSzw4wRwUqyfQfUMMWfe4Yjpdcsht1az85qShWJQXV4Zmtr7XwJ3wnjbaOXMJnjtsW8oZxlhOach3Oxym2fSfRpWq07gXjjjbvBihtVnJhUdcxSl_fmV58Fvc8JZJR1UYWtktoaoinBtkgFXbha0ypar_M2ZXqzFnfUrc_afntShunYkOxZhZc5We-wjeywXUpwzJ0_0xd3ROMY8_0weekFk7_vpWBtXak599fu-UF7gnegBUQSldiapk3h4jUX8xXg6-xX7gQzuqeOOeQ2ZaBx_22i74hOI8_zUkpsF5hxyB0I3M8RIsVX8xJWSrxJ-yef2hhFnQwail67XeWXYhlJ1WlqjdISxJhahaUJw2xz01kV8furM6wYfospkUI9Xe3hoJknrXUOdJ8FkzjSmped6l8tJdtX3_4OUwV3tdc_IqUolYrBQt9WmYO7lJkldsq_MjvJ2cXn1VcmIW215uf4Bljd5cVUm5IZacWVFrVehgZ-';

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
