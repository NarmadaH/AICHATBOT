import { LightningElement, wire, track } from 'lwc';
import get_access_token from '@salesforce/apex/GoogleAuthService.get_access_token';
 
export default class DialogflowConnector extends LightningElement {
    @track accessToken;
    @track tokenExpiry;
 
    connectedCallback() {
        this.checkAndRefreshToken();
    }
 
    checkAndRefreshToken() {
        // Check if token is expired or about to expire (e.g., within 5 minutes)
        const now = new Date();
        if (!this.tokenExpiry || now.getTime() >= this.tokenExpiry.getTime() - 5 * 60000) {
            this.refreshToken();
        } else {
            // Token is still valid
            console.log('Token is still valid:', this.accessToken);
        }
    }
 
    refreshToken() {
        get_access_token()
            .then(result => {
                this.accessToken = result.accessToken;
                // Assuming result also contains the expiry time in seconds
                this.tokenExpiry = new Date();
                this.tokenExpiry.setSeconds(this.tokenExpiry.getSeconds() + result.expiresIn);
                console.log('New token received:', this.accessToken);
            })
            .catch(error => {
                console.error('Error fetching new access token:', error);
            });
    }
 
    // Example of using the token in an API call
    makeApiCall() {
        this.checkAndRefreshToken();
        // Use this.accessToken for your API call
    }
}
 