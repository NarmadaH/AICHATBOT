public with sharing class GoogleAuthService {    
	private static String currentToken;
    private static DateTime tokenExpirationTime;
     
    
    // new method
    @AuraEnabled
    public static String get_access_token(){
        if (currentToken != null){
            System.debug('Current token exist' + currentToken);
        }
        else
        {
            System.debug('Current token exist is null');
        }
        
        // Check if the current token is valid
        if(currentToken != null && DateTime.now() < tokenExpirationTime) {
            System.debug('Current token is still valid!!');
            System.debug('Returning current token'+ currentToken);
            return currentToken;
        }
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setEndpoint('https://accounts.google.com/o/oauth2/token');
        req.setMethod('POST');
        
        req.setHeader('ContentType','application/x-www-form-urlencoded');
        
        String header = '{"alg":"RS256","typ":"JWT"}';
        String header_encoded = EncodingUtil.base64Encode(blob.valueof(header));
        
        //String claim_set = '{"iss":"try-authentication@bot-demo-1.iam.gserviceaccount.com"';
        //String claim_set = '{"iss":"bot-authentication-trial-2@housing-mikp.iam.gserviceaccount.com"';
        //String claim_set = '{"iss":"housing-bot@housing-uavv.iam.gserviceaccount.com"';
        //String claim_set = '{"iss":"ymcatrial@ymca-ahc9.iam.gserviceaccount.com"';
        String claim_set = '{"iss":"chatbotwevalue@testagent-shxr.iam.gserviceaccount.com"';
        
        claim_set += ',"scope":"https://www.googleapis.com/auth/dialogflow"';
        
        claim_set += ',"aud":"https://accounts.google.com/o/oauth2/token"';
        claim_set += ',"exp":"' + datetime.now().addHours(1).getTime()/1000;
        claim_set += '","iat":"' + datetime.now().getTime()/1000 + '"}';
        
        String claim_set_encoded = EncodingUtil.base64Encode(blob.valueof(claim_set));
        
        String signature_encoded = header_encoded + '.' + claim_set_encoded;
        
        //String key = 'MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC5c2ZwTh+ZIaW8vabTqUG+RmGMhkU2TOcER9bUGJedhLYp8gAt0/momSFoPUmThjWr7uvWgikdhoIfvepYCUuJSmfRlviDh6oQXMZzmvb/no29qulqCfCH6GdnGmEkfBH9DhkEuNxzGTl3C7UZUi0c7PY9/at6GOdY4+//M88qrdk3GH4H/InQr1yhl/sMc44JORRgTOT6Gx/Onj3WD//rTHXY7ETmn4X4+CJjwkUrDyhZU4SscTEgybaRBsvfNXMY1ypLqH77H/TJq209TmMnxP1FX3S2zF2zMs1CV19G9rkIBDA0uu2ZIXqu2Wz6vdtLUjUgEPMjfW0vP/clIEMjAgMBAAECggEAOeVZGb6KBtiGUYIzzuiMaca3NZPFj8o6ZQ+4dcanrrl71WSDwcrnqkcEMvLPQYsovmB8qB9CjsErZpV3z7w3JMlh2AD13LpB0ZHlMroyWmM5hPkSndQ0j3lyrrGBmk5Rn1sDXIIJ8LTzR8MT6q/I/brMtVW4bwnPT+T5TAb0qjHMCkB/YD5E0EZ8dRb7Fm9bT6JP496GpdO1TdrHGN7eTPa0433rK2MrbKOMyk8o9YzUyXn0qRhfcUcKR40Fa7uHr3q1AS/SsARMRWaSV1H1blkbfaHSPGTMbfJj+Wc21V728MG5vWb97bDzDaCEIjxl2DKsr07m27JoFpViusmIgQKBgQDdQB/SbbZTOAmyb52Uay21qwalgoMZqMzHIqIX0F2p9VOu39z46qKFJzOHuXDdqc2Eg1OSXcZh0+zPJz7A2j8JEeR5MJWr4emvBgGae0m+ay3JeS1G89HRWtBRUVK5AG49JruA4N0WGQG+i/xSm50n0iszeVcxQzP/c7k0vEqAsQKBgQDWk94skb7RXZkkuF3LtgM1UkPbJRPilf5hD3spITLr9ZvdBFXuuhg+odWAt3tBG8jxYgCSBm8LcDdl2rNPhuCmctLN/DuqgsccQKZfhY4rHTQIUikSTqCMz7dK/wrApNpPVwpkkMRTQ0dQcuWwe9lhYrlWnAU0NI2l3/5cG4GWEwKBgQDAF6CJTn/yGMEyjv29kqCJDggjQwEYEhpY+pTJIDtyCHGzbuGnq++Ws8ZlnHeFvJuW5X51ob1PynPcFzLAtbvs4AAByFDqfqYpM4nI2inYja2fMvpAlAgjQDmFoJm1zc3ogexhpNnPCb8d9OQJxNnZbPvdIQi22KYYsByo0KHOwQKBgQDEZkl3v9rI5QO0AXAQccMT/f0PyysdPK69hh7zcWibYo3LyRkiTYC9awDxNH+DA3xzu4DMJ0liTc7W0ktHIivjDbv3P8QY+GRobqAZVDPhMHScnR7sm70FxWV+JlxgIUOUVRW1IHAhybWvY8rqMyGvql37cQiuVN/FkHTPN3nvswKBgQDbsQXIqj8QxQNn4Do0Vk1uN0xFo20RXzOqK9rJTJBieDgtNcXxLXq7xd5J5KOLJnry9Y1eJRJTZl2Ud7yqfVr6H8jUJQUSwcb0AAJfYdtPeDs++LcY2qKSN4ruPtLGPSqIeterkLkmNhlvXaWfSv4L4xW54VxXmTAbZbK3G2587Q==';
        //String key = 'MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCHp8V3uUazPPEIuVDJQjzqMZIURv6LKw6FzoINjawtT8M79XDDISquTXazZ4DF6luAJX1aGDAiNV6BZvJeLvDY2Y3iguOWtnj2GW02jVYrbF+iPrisgB8c4E6KyXE2gttYkBAuHGILs3249HWxQ9W2j2OLsPI9/qZOeiDgB4plIlrSXR/4kmi54f5OJFepteIU02e5nSzJE9TIA3pipXABIwxJyeAWpAm8QakUbRG/Jd6n47XMG4UduUrD7i/nfzAxaTZU3K6No0/EXCTHi0ojBUEsItmJ5JNfRlyIZLSFNV88mTnW2mrVHmDx+bPQc6nOFrdV3zctbi6cGHcO0/SXAgMBAAECggEAGAmtnxpwocAxweb8nr0jCCjCht9RqZ12lFVUjExHbzwMD2rdkWYmJv7JAt9bXTa7Agkinj1dAiLM3Uc9uVy+Bt7+Gl4xL/qjkpBM3vbKhyVMCPbuSHrniHli0YsCibNEZPwaMeGLqiEjLQv8cu3fR9s+u3keY8fk9lED1E7hwivDOonXsPXkVVfxSal0uOazm6v0XYi2zfNHXIQUKdaFH0dgD+VHqBNKM4uRB0MRLB1S9qhoyytqwX8cYGe1SPg4SvRMN1VqcLrfyJXylFfnXkR4P+zr/6k/qy05QhVFpIDpBRYe1l8I8bB1S+k5Zf3dKgpfKDxIXmm/NwiQgxFWAQKBgQC7rVIsdhHk32MzKic5h//GS5+NTA6i61n+4xy8F42u3rFfnJNrnGiIStjOkFJbhxM6ADz3oZSW9S5odlIyzysCua3FGw9RbzlS00rLZ0Y0UFUdd0JDLg/O1oZZa1KA7ypkzwX8dUSLxGryKg3hkWm8OHrafNrWK/fZvWrdI00RlwKBgQC5CkHnCXz7QxbXRg2Cmf9fV+eZ8A6btRMQVoehIW+lUbIrI3j+k7Ha7J69ORXrKlQL+gtotbW7XsvfjuyzE9e7YoM5xUMmtdnlO+RUwyv7sl/uWclgXAYpYJZ4n++qCOzl+JVKpBiFTp1HUEaGzle9qYwNdsc2/v2gFvZE50aVAQKBgFjf0+kgJIsoyjZBgP+6ioIh77WezdOS9jRA4qujz8F+zapEYH92Ov5Hy3HOYGHdjlpKIJT33IC8LLTlSzmqZ2jL+yE7Fj7vF8tEKcg26MT/Qb9JaYScvHmrl0WjEBfkqkPA0cni0ooJgseY6KfoD5VFfdAXjh4cBiwDiiacf/OTAoGAd1u4evFR3zm9aAtV96KiabvoNxH0Olgo/ebzAerxe3AhP1ZYW86lcRQkqOZDzze0ky0tYtOjcEOLup8U68am58Z54y/tSvEOpqFlfY+PtYGwA62DClcR2mrlZNW14LZ1KTqaAlWrQ4IcTb3oYFiFnF/baWvuwPjmXPeyz2tnygECgYEAkxUD09Vw0YKORtNm7jvDEvR9cZ+d0Y1t9z8mNdwOJHOuTlM36AWM4b9tDmszDh5Ia/llF//kK4Iwp0kru+nc/3maaApV4U3nylL6YkC74RmmQEf36LUiwMpaJL97kToepDlErhPgcsmyR9eUFt1gZrZt9Qunq2L8BhkdfZG+Z24=';
 		//String key = 'MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCmLMhZ1Rx2U65+PjPWLoN/2Zz58tJob2bOXl1yceGmYxhbp1b45olcUNtqXbetFafcy9TY/v5gVM8mXGuO9iLmcXZGzy6LdrEZKp6seCXRW4YBmbmliG4jm3R0n+/bMDG1dAOGMHw0ULhEmTHpUvX2rtW5S985E2CW3E6lpTOxNrA9S3qP7VpGfd3naBh5Sebfr5GdqrO2G4ceIVOU8DU10siibI8d1X2KK/04UB+ajY6NukFD5nKaSbryZR7YIzxbuTfYIgB50Qeovzvq1HOTA3HS0ospXIABEgjG5Tj1uH0K6ox154YA7XQbwTqj+q7/3vsQg9RbVQ3T5H4QBA5DAgMBAAECggEABIf7nJYjsMb3+HbynNYjH5uDXOjCxDZ0Go+9S9f2yKQhkatLj/1yF+FcJo7qPvRJyEJXReV9T+BFeeRXDllVfygiivCdg2Uo6Urdpxri7nATe+84ud6gVBPDyogNhi/oZ1sl7ECzEcm5BJP5NvApE/I3gYDfsew6Pg6WjXtq5Jd8n/C0pHf2hqF2gwld3M8WRiym8uEc3WAx7z4C4aN5l/Ad/NiHY35yhUdpkuZ40fLIRuecz/YtlvIerC8KU/6mXaxsTeSkLKq4MazTzsj8hQVKqq6u6phk5USxrO4En8YxWfjnuB6sp3N2dF1n2VUL5+M7Rh7GW6lxmOfNZAwzqQKBgQDkq/ZCeP1zGYrc9CnBNCpJR8VplsBYjlIg5uB8ilGyf4IHwOjZ9BDPQM+CPrDTA0FSC0n4+IxPxtIUujmWUK9P0L9E6nEDovyy/3XeSvQy4mk5NwvIcmU7hyGpCzf5291UG3R5WlPhzt/cHnm82jdHh+sxJaunR3iRjaLvSyth6QKBgQC6CMdVRPbCy3FGs2ENL+3Z/XktkjsbXuly04+XzoVP9wRd3ABpB6PV1w3ThgE6xt4NGVlNTqJM1s3JECcMOipjQRebEYDOba1Lddm5tN5LUXwcZCJUMAiEP7jRh+QqzZDoV6Hg0mm28Z/f4UJ5uU3VtRLRfiykUS23ZxhDR/kHSwKBgQCo8Kq1HXISMRK4fuLCTGnZTd75TVi5lBv1Ft1O5VnKSA2m8MyXCYvJspYcIXi9zK/bj1+NQwNWhQr8KUEWXnHGw/ArWBE6oJWVIMrR+gpD9aXLkXFxG6LSwdkKbLFkNR1lYAtDBIroTtBwbUt/TLB+dlo6KxyQL2tSDZQMujpI0QKBgB6z1DH+b7s2WDuS3zGN93NCof0jZR3fTCfnQouLSfUoj0/uPyMWX7OrCl0egJVyvLLsvBBGKgMEcHH+eHNMJjK7S2oMOXXYJAGQMZ60evtzN0h4PjImu0EYQyhRhRaLVp8B13WDRG8s8XXBd3cfXfknKTPp3vQ/cYwTN63i8vaBAoGAdw75Rp65l+hmDukBgyqqs/+NHK5LEJMVNE6LkBArW3FierVn3R0MgYOwTunY6paxNDRBsWx6/+D2UpIuXKmPMhCnXduvgEuwh7DACqS92aWqYQGK4+wwb0LV98ZxIEEk3ayqlLedJljG3Cn3xmEat5g5f06Yyg+yxU3eABbAq/0=';
 		//String key = 'MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCWhfoCZcMg6/XZleHcem8vTfwoyMXoPqMCYnKM1Up0LNoNOSH4Br3rZQbYO0yhqsDTAOcm398qhKE+T7v6DRMZrH4Vj6S3bLlBJpqZD3VMabsAl8w3VwX23e6aRMHxWVlIM38u9UqPM17xynzoIPvyjCqsHOHA/NMwB+Xb8Rh2PMvXgcjP2OCP6VFpY3Eiuq9Z6mVEY7KwLpR5Gn0FK6iiwnyYxAK4h07nXMP+ufr5enobDIGXXoAKYvZ1Qu2zjhX0ubl8VIFSL2BQZXpKXIE/bMCI/E7E/uG0vA1isN1MO2+KPIrrfKowBG+wTPorObsbdbtg5866WqXtJFe2huWhAgMBAAECggEAO5DIJ1O63JfTweeYqiW/QwKC42bUPnwvCL4Jo6ayIHgxT+NIiHyugm0HwODyidVnGfj1AEK+bvZuUpi+BA1Rfiru+DxQTA/X3arXqfNekT8T8/+eHlYvM4qOpfjIoOghNzu9vEjwWOvUyi09saR/33NNXa/OPI8wSYUOlrN5YSxBYVC/qW0SmTEQrakMlRR1b0C/UBNCz7WR/0Cn27Ev1gaejx9R7YPnAcW+iJ0zfsMyaG1ok+eBEOWwIBYZK5owEVuukrqQxDWoYLl+gvbIRs83zuiJnu/VAt4aYi7Sam1AC0lC9q8aVRcrIZ5O3hnfq6/Cz/93jcp0f9KFooxQIwKBgQDNDPAl0ghuLYBkRmoSCAvLV/2LQSp6GCkuFrZzQjv0MTUP4wb+sNHiPcMlU7sf+EoIzEN2SswStpL95frYC4UO/uo6pNZFLDnOXlvNRMEnY2bzegVEo9ZzpuTMjbqfdisa6g+saOTEvLDK8Bf6RC5d6iW48OJfyn1QzdVGtWM16wKBgQC77J4iNRwBGhpfvy+KkKgBZr23gpu65EBQJtAOPU6UdFTh8hYFsevbpUYqyx5SvtRTFh4bjHTYCf6P2uV177SI1TB0SmAocqwyq+kPR0kkjNPXtUI4z1FYhf1h7TVAkqw1htQSatzdbapq4lEjGTntinkkXyEP0780CrFpbalzowKBgQCBsalDgrFqXsVSp2b3uLcdCq6HodQoHZgOWrdT95TMQ0N4pPQLq/NU0hPYTDmTYwwQvIH/FBg3zdrzVL9wXvjuHzYvmYsdfXeim/QcxVwWebzoS0mBvM8rn2ggKZTcv3VMNLdtKXtpJJ/9/BZuaSmapTru2w2T4ROaRFadvqTduQKBgCwFaaWpuz2m17bGGmTjLffmEVsDhWdqQIaGEQbE5btw5NFo3C/JVe7F8IHlwtyvRx2PeM4LQPO6o58fL9FIrYnAJvGW2p+e/SeBjb6+fCvLsXQ+SZz1M6EBAjIGVwshUKXZR6Ro1AQqxFj1WvxV1HQIlAgpIJ2MhKW0O4ru3VrxAoGAXpj/MWuJJfZhw9w/ul0nRWeTtIWUE2HXGiwbMbAPcJjB8nDjkEl5FeCnDVJJR6gWIK7oyTyKVqizdDJvzeYCKizd3M58l00od9g7M0qtQr2XN77JbMnMlmMH4NFRAxmTJpYgk9pAkVwAjRIIlAO2Ok4gE4z5FeQT1ODB9vXECLM=';
 		String key = 'MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCgCWHZFHcWGYoER3QRUIAppIcSx6xjB7AE8N2ksvGaOKFVm19mIerOymVHg217h7bzam7+rmL/nAQxrWEVojlZpa3OEJQeRViaYjOH863zq3anVRMWGRJtKmi0pM38aBIV4U57T8dycixFenmJCspjKvhh1/ScNKXJaFI9AaDBAPPdgehPwaB3X5He4V080ttu501HNHEmtaDDC9hqcJQ8IlW47WOP8JDM7xQpceiZY/0HFYuuW992dop76+58GMCPL0dtzJsXwJZqDA5V6vPDyr+mrpo1MoKiLsy2jwWgoOv1UbAIQ5MrFT8PFjGzrlsZEgiOdpHFs2DOWGM50EJZAgMBAAECggEAPYx+MlPZnQlDeHPWotYYBGv/euyKUyfgvXW5eJ9NpieDfP4diZUfzlou63sTfz/pz+IuQArnjjD9t/FbdkuGzQCYQLlFjgLTmcSM1wuT6jQWlTJ1/bi0yoFV9auwgROxaPLXETvUlCJu/mWlGlypC8y57D93FyB0ZmqVvlrC7ZcJbDCyFCapxbpF/L7Z/TKm+H8SiX1jsCB0s5+POf013wNTG/mbKplQWCc7ELl9nAqcFZfltxk+wAqn16LG5gWGBOzOwwglNOiBwkpoNFmK/l+61O34On769jC9cwCS9jWJZhZb0QbmzhVjWFuSUxOVHYJxzZMa98dJ0NoyNaw69QKBgQDROUgf+ZqIEE0dYF7Be2ydR89XGsyCJ8B466RFsCcSF+tRspmnHouvT7SGhjab3fUkWUgZq0PEm+n2DtwtdYU4T0Qk++jAccTSRu1krGArduBNgiOXqPbeG0v29tsv036c5gO8CZC/c4kf4AywvweRYt/WpJXX0ydj4IMbTKStywKBgQDD0OyZVTNa8gkqIGO5e9HCkw8dYgDz7UX5b0FGEcMyh+asw+zl3r8dGBzfhYHn5BFaQZfTLnGEGDylyoHWxfR6R5asq1PEvWMvahp2hpM6tN9iFApVOpdXz75DqEKzK0q3Wk3c2AZOiDmqTYdHDkm67C743PWc+085eMbgy+cL6wKBgQDIX9C4dsdNmjcQdFQrfvYlpzlmlY7Y9BM8e4knCK5SgL/ozWCkkfd7XZ1p3K3+FtOJDUyk8MYFTMED23V4v/1nUVrVBMEDVbIHJNCEQyYTWlU1Rfaqb7KGQqQ9EGwY4Ld4sj1PX+XVxWPFOEFPIJSx43y2R4gOW/Z0i/dkNMHegwKBgAQx6Z+vT5ZXMRMR9pD2shu1AtHiU5rmLmWVmJRjtQbUGoEBAYY7K2T4K0YumgXZwPVqClKf4BawXjw/BmEPhJlKB1RTp0vDsuhFIaQAZg8P6Ok0/LOuuadL8AuLA0LLXqJm8NwWVKxCBto7JvbCu5mhjbAPK8PdLmlQyRHvzFdZAoGBAMOCHPwKEqP2naMrZcvn/OnxBwXv8Ip1yGb7VYg+zdO4M5oFJMnY1aC9Skxjb0IQxpIJdCD+2YZ5HMxW0nMnTz9v6bEIlA1Eeri6/x8uE5ie3CYTMho9uQ+Y4Dxf4wi1xC+rlwfVbvQ2+66XKKBC5gyT7lxMzFyOe7Tn6IAGwvV+';
            
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
                    
                    // Store the token and set its expiration time
                    currentToken = accessToken;
                    tokenExpirationTime = DateTime.now().addMinutes(10); // Assuming the token expires in 1 hour                    
                    
                    // Return the access_token
                    return accessToken;
                }
            }
        }
        return 'error';
    }
    
}