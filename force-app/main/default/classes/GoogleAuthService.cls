public with sharing class GoogleAuthService {
    // auth info
    
    private static string key = '113180166933788840574';
    private Static string secert = '-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDAoaFaCtVZHcl8\nvlAE9Ufmb2CctH9h/GXC2c8o/vNHF1eY+F25Nt7/YO1eqLUKNttrUS/WLZb3nryD\nqkznIBUNNRxTh/x1hYJ1lh4wD5f0LOXaVV76JKNIq5BSjGcajkNNq7jc0PV6gE/4\nIBgQf71lQ9bYILpltNHziqOnGzUVbkvUMVlUU391Hptv6SQEiN3yaQp+SioymL8J\n4w0mheuM2uGalQWW+8yCDE75+ShkeWQzFQD3vmnpN9fthKlOmJXXHgEHJhd2pWsC\nbmV27uGEde9ZNk97eiQ5fnBkur4DW62LwzQoqr/bFxgYLJlvEdWmso0bEz1un98k\nEWbqvt/dAgMBAAECggEAYDkc4V6h/hccC90BGcjwdpJSP1UGgIrUxkWI7uCT44Is\ndrQyFQ/sysK/L9a0QHrwliYC8EjrrZu0bUzHh3iGK4fJM4ytNoNPjK9FOxq++/Dl\njG+ytt9QVT+mIyYRZrmDsyvBd0RGK0AnMjnN64fzsr71dha7JYzyh2ZMo2+6z43e\n8870qKq6njnRyOhtKov5WRr9ojA7W+xzFsPvyOql4nXUp7xYErluPOjpbAeg47vx\nmrqstyAVw37UgsOCxvLaWwEnnIbXB7yKr8WlZk3X20DgBetMRVfC/pNPVruGQhfb\nwUXOTx2G/pe97XemKUrUPJRIFHRgKHB0n2aQQ4owfQKBgQD2V9rMyk6YDsTTQd5d\nj7wO4aH+je2Xn4HcbZe9Ftdhjtu3JdpNHWAMThYo4Avxpwwas9QEk4RZjQg7Tcpx\ncF/lNexDtzRDFW9YTsKzLsGE98UERV2tVTBh4AQVsrCtUR566By8J3nBYsyQQS+E\nzz9Z2DHzsQtOkUmhqP/T+cBnrwKBgQDILsHxnUDJVSi+SDCvfUqVvLwDygeO4+LV\n+s4mpfIQvmpWLi+jLFAF8CtuV4oI4ZhhQamC0S7Z3dPSYY8eWR8x2MYuB+F5TgBG\n06rHt3fUQ326IGcIQbxXbOhzh/gmYEEb4+Dm/jqak9u79zG6HgUQ/9GBsNAqIg+o\nQzes1w9IMwKBgHoECAb5ibY9UnZFIOv8vqwsTD22dOFuCzdwPQFWp/XVebScliUu\nEJ3nq4gxeRkHobI0MibWHm7wsQwWutg3TfhNHipoOwWjP1RhJoTz+rxusPItnXm2\nQVGpULyilmoyTMOZ5mm3r9H+qs4ky3Gf6YQJ1qwanDwdMHhXKegHw6pXAoGAQmbY\nKHg8JEyePjgeBiguVGsNhsg+J5TKCqauOT20hP9UsI+Td7HcPYwELA7Xl8iVTjWE\nsAMJYnVlrRR1b+CqK1O3sU8l6KIKD3Ro4uSl2AAnNVVIOAHuIqXamXARzVECZ+j4\nEkdkUyAWtEvz78PDdHcXHMj00/UGco8RacDQrecCgYEAxjCkrG/j6o5IIZN5Od56\nONTqRBqYB4qZDcsVPsmF0lA2kUl7C1/DL85kKyon27bUwzqlOzhqa9YIa5Q27OA4\nRGXYpwZtAqbhyc3debDtyJ5GSUmOHQvOjkgrE1T2nn/pgpI/a8x7MgUFSubewzjn\nEYygSSJS11O+KrBgKKwxUIc=\n-----END PRIVATE KEY-----\n';
    private Static string redirect_uri = 'https://dialogflow.googleapis.com/v2beta1/projects/first-demo-gbto/locations/global/agent/sessions/f8d64d41-5859-b9c1-f147-d1ab7ce31b72:detectIntent';
    private static string authUrl='https://accounts.google.com/o/oauth2/auth';
    private static string scope='https://www.googleapis.com/auth/cloud-platform';
    private static string tokenUrl='https://oauth2.googleapis.com/token';
    
    @AuraEnabled
    public static String createAuthURL() {
        String key = EncodingUtil.urlEncode(key,'UTF-8');
        String uri = EncodingUtil.urlEncode(redirect_uri,'UTF-8');
        String authuri = '';
        authuri = authUrl+'?'+
            'client_id='+key+
            '&response_type=code'+
            '&scope='+scope+
            '&redirect_uri='+uri+
            '&access_type=offline';
        system.debug('authuri - '+ authuri);    
        return authuri;
    }
    
    @AuraEnabled
    public static String getAccessToken(String code)
    {
        //Getting access token from google
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint(tokenUrl);
        req.setHeader('content-type', 'application/x-www-form-urlencoded');
        
        String messageBody ='code='+code+
            '&client_id='+key+
            '&client_secret='+secert+
            '&redirect_uri='+redirect_uri+
            '&grant_type=authorization_code';

        system.debug('messageBody - '+ messageBody);

        req.setHeader('Content-length', String.valueOf(messageBody.length()));
        req.setBody(messageBody);
        req.setTimeout(60*1000);
        
        Http callout = new Http();
        String responseText;
        HttpResponse response = callout.send(req);
        responseText = response.getBody();

        system.debug('responseText - '+responseText);

        Map<String,object> responseMap =(Map<String,object>)JSON.deserializeUntyped(responseText) ;  
        String token =  String.valueOf(responseMap.get('access_token'));

        system.debug('token - '+token);
        
        //Update token in custom metadata 
        //MetadataService.UpdateCustomMetadata(token);

        return token;
    }
    
    // new method
    @AuraEnabled
    public static String get_access_token(){
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint('https://accounts.google.com/o/oauth2/token');
        req.setMethod('POST');
        
        req.setHeader('ContentType','application/x-www-form-urlencoded');
        
        String header = '{"alg":"RS256","typ":"JWT"}';
        String header_encoded = EncodingUtil.base64Encode(blob.valueof(header));
        
        //String claim_set = '{"iss":"try-authentication@bot-demo-1.iam.gserviceaccount.com"';
        String claim_set = '{"iss":"bot-authentication-trial-2@housing-mikp.iam.gserviceaccount.com"';
        
        claim_set += ',"scope":"https://www.googleapis.com/auth/dialogflow"';
        
        claim_set += ',"aud":"https://accounts.google.com/o/oauth2/token"';
        claim_set += ',"exp":"' + datetime.now().addHours(1).getTime()/1000;
        claim_set += '","iat":"' + datetime.now().getTime()/1000 + '"}';
        
        String claim_set_encoded = EncodingUtil.base64Encode(blob.valueof(claim_set));
        
        String signature_encoded = header_encoded + '.' + claim_set_encoded;
        
        //String key = 'MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC5c2ZwTh+ZIaW8vabTqUG+RmGMhkU2TOcER9bUGJedhLYp8gAt0/momSFoPUmThjWr7uvWgikdhoIfvepYCUuJSmfRlviDh6oQXMZzmvb/no29qulqCfCH6GdnGmEkfBH9DhkEuNxzGTl3C7UZUi0c7PY9/at6GOdY4+//M88qrdk3GH4H/InQr1yhl/sMc44JORRgTOT6Gx/Onj3WD//rTHXY7ETmn4X4+CJjwkUrDyhZU4SscTEgybaRBsvfNXMY1ypLqH77H/TJq209TmMnxP1FX3S2zF2zMs1CV19G9rkIBDA0uu2ZIXqu2Wz6vdtLUjUgEPMjfW0vP/clIEMjAgMBAAECggEAOeVZGb6KBtiGUYIzzuiMaca3NZPFj8o6ZQ+4dcanrrl71WSDwcrnqkcEMvLPQYsovmB8qB9CjsErZpV3z7w3JMlh2AD13LpB0ZHlMroyWmM5hPkSndQ0j3lyrrGBmk5Rn1sDXIIJ8LTzR8MT6q/I/brMtVW4bwnPT+T5TAb0qjHMCkB/YD5E0EZ8dRb7Fm9bT6JP496GpdO1TdrHGN7eTPa0433rK2MrbKOMyk8o9YzUyXn0qRhfcUcKR40Fa7uHr3q1AS/SsARMRWaSV1H1blkbfaHSPGTMbfJj+Wc21V728MG5vWb97bDzDaCEIjxl2DKsr07m27JoFpViusmIgQKBgQDdQB/SbbZTOAmyb52Uay21qwalgoMZqMzHIqIX0F2p9VOu39z46qKFJzOHuXDdqc2Eg1OSXcZh0+zPJz7A2j8JEeR5MJWr4emvBgGae0m+ay3JeS1G89HRWtBRUVK5AG49JruA4N0WGQG+i/xSm50n0iszeVcxQzP/c7k0vEqAsQKBgQDWk94skb7RXZkkuF3LtgM1UkPbJRPilf5hD3spITLr9ZvdBFXuuhg+odWAt3tBG8jxYgCSBm8LcDdl2rNPhuCmctLN/DuqgsccQKZfhY4rHTQIUikSTqCMz7dK/wrApNpPVwpkkMRTQ0dQcuWwe9lhYrlWnAU0NI2l3/5cG4GWEwKBgQDAF6CJTn/yGMEyjv29kqCJDggjQwEYEhpY+pTJIDtyCHGzbuGnq++Ws8ZlnHeFvJuW5X51ob1PynPcFzLAtbvs4AAByFDqfqYpM4nI2inYja2fMvpAlAgjQDmFoJm1zc3ogexhpNnPCb8d9OQJxNnZbPvdIQi22KYYsByo0KHOwQKBgQDEZkl3v9rI5QO0AXAQccMT/f0PyysdPK69hh7zcWibYo3LyRkiTYC9awDxNH+DA3xzu4DMJ0liTc7W0ktHIivjDbv3P8QY+GRobqAZVDPhMHScnR7sm70FxWV+JlxgIUOUVRW1IHAhybWvY8rqMyGvql37cQiuVN/FkHTPN3nvswKBgQDbsQXIqj8QxQNn4Do0Vk1uN0xFo20RXzOqK9rJTJBieDgtNcXxLXq7xd5J5KOLJnry9Y1eJRJTZl2Ud7yqfVr6H8jUJQUSwcb0AAJfYdtPeDs++LcY2qKSN4ruPtLGPSqIeterkLkmNhlvXaWfSv4L4xW54VxXmTAbZbK3G2587Q==';
        String key = 'MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCHp8V3uUazPPEIuVDJQjzqMZIURv6LKw6FzoINjawtT8M79XDDISquTXazZ4DF6luAJX1aGDAiNV6BZvJeLvDY2Y3iguOWtnj2GW02jVYrbF+iPrisgB8c4E6KyXE2gttYkBAuHGILs3249HWxQ9W2j2OLsPI9/qZOeiDgB4plIlrSXR/4kmi54f5OJFepteIU02e5nSzJE9TIA3pipXABIwxJyeAWpAm8QakUbRG/Jd6n47XMG4UduUrD7i/nfzAxaTZU3K6No0/EXCTHi0ojBUEsItmJ5JNfRlyIZLSFNV88mTnW2mrVHmDx+bPQc6nOFrdV3zctbi6cGHcO0/SXAgMBAAECggEAGAmtnxpwocAxweb8nr0jCCjCht9RqZ12lFVUjExHbzwMD2rdkWYmJv7JAt9bXTa7Agkinj1dAiLM3Uc9uVy+Bt7+Gl4xL/qjkpBM3vbKhyVMCPbuSHrniHli0YsCibNEZPwaMeGLqiEjLQv8cu3fR9s+u3keY8fk9lED1E7hwivDOonXsPXkVVfxSal0uOazm6v0XYi2zfNHXIQUKdaFH0dgD+VHqBNKM4uRB0MRLB1S9qhoyytqwX8cYGe1SPg4SvRMN1VqcLrfyJXylFfnXkR4P+zr/6k/qy05QhVFpIDpBRYe1l8I8bB1S+k5Zf3dKgpfKDxIXmm/NwiQgxFWAQKBgQC7rVIsdhHk32MzKic5h//GS5+NTA6i61n+4xy8F42u3rFfnJNrnGiIStjOkFJbhxM6ADz3oZSW9S5odlIyzysCua3FGw9RbzlS00rLZ0Y0UFUdd0JDLg/O1oZZa1KA7ypkzwX8dUSLxGryKg3hkWm8OHrafNrWK/fZvWrdI00RlwKBgQC5CkHnCXz7QxbXRg2Cmf9fV+eZ8A6btRMQVoehIW+lUbIrI3j+k7Ha7J69ORXrKlQL+gtotbW7XsvfjuyzE9e7YoM5xUMmtdnlO+RUwyv7sl/uWclgXAYpYJZ4n++qCOzl+JVKpBiFTp1HUEaGzle9qYwNdsc2/v2gFvZE50aVAQKBgFjf0+kgJIsoyjZBgP+6ioIh77WezdOS9jRA4qujz8F+zapEYH92Ov5Hy3HOYGHdjlpKIJT33IC8LLTlSzmqZ2jL+yE7Fj7vF8tEKcg26MT/Qb9JaYScvHmrl0WjEBfkqkPA0cni0ooJgseY6KfoD5VFfdAXjh4cBiwDiiacf/OTAoGAd1u4evFR3zm9aAtV96KiabvoNxH0Olgo/ebzAerxe3AhP1ZYW86lcRQkqOZDzze0ky0tYtOjcEOLup8U68am58Z54y/tSvEOpqFlfY+PtYGwA62DClcR2mrlZNW14LZ1KTqaAlWrQ4IcTb3oYFiFnF/baWvuwPjmXPeyz2tnygECgYEAkxUD09Vw0YKORtNm7jvDEvR9cZ+d0Y1t9z8mNdwOJHOuTlM36AWM4b9tDmszDh5Ia/llF//kK4Iwp0kru+nc/3maaApV4U3nylL6YkC74RmmQEf36LUiwMpaJL97kToepDlErhPgcsmyR9eUFt1gZrZt9Qunq2L8BhkdfZG+Z24=';
 
        blob private_key = EncodingUtil.base64Decode(key);
        signature_encoded = signature_encoded.replaceAll('=','');
        String signature_encoded_url = EncodingUtil.urlEncode(signature_encoded,'UTF-8');
        blob signature_blob =   blob.valueof(signature_encoded_url);
        
        String signature_blob_string = EncodingUtil.base64Encode(Crypto.sign('RSA-SHA256', signature_blob, private_key));
        
        String JWT = signature_encoded + '.' + signature_blob_string;
        
        JWT = JWT.replaceAll('=','');
        
        String grant_string= 'urn:ietf:params:oauth:grant-type:jwt-bearer';
        req.setBody('grant_type=' + EncodingUtil.urlEncode(grant_string, 'UTF-8') + '&assertion=' + EncodingUtil.urlEncode(JWT, 'UTF-8'));
        res = h.send(req);
        String response_debug = res.getBody() +' '+ res.getStatusCode();
        System.debug('Response =' + response_debug );
        if(res.getStatusCode() == 200) {
            JSONParser parser = JSON.createParser(res.getBody());
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'access_token')) {
                    // Move to the value.
                    parser.nextToken();
                    // Return the access_token
                    
                    //return parser.getText();
                    String accessToken = parser.getText();
                    // Debug print the token
                    System.debug('Access Token: ' + accessToken);
                    // Return the access_token
                    return accessToken;
                }
            }
        }
        return 'error';
    }
    
}