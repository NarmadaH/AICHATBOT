import { LightningElement, track } from 'lwc';
import get_access_token from '@salesforce/apex/GoogleAuthService.get_access_token';

export default class ChatbotComponent extends LightningElement {
    @track message = '';
    @track messages = [];
    @track isLoading = false;
    @track isChatVisible = false;

    handleInputChange(event) {
        this.message = event.target.value;
    }

    toggleChat() {
        this.isChatVisible = !this.isChatVisible;
    }

    handleKeyPress(event) {
        if (event.key === 'Enter' && this.message.trim() !== '') {
            event.preventDefault();
            this.handleSendMessage();
        }
    }

    get isSendDisabled() {
        return this.message.trim() === '';
    }

    async handleSendMessage() {
        try {
            this.isLoading = true;
            this.addToMessages(`You: ${this.message}`, true);

            const responseText = await this.sendDialogflowRequest(this.message);

            this.addToMessages(`Agent: ${responseText}`, false);
        } catch (error) {
            console.error('Error in sending message:', error);
            this.addToMessages('Error in getting response from the bot.', false);
        } finally {
            this.isLoading = false;
            this.resetInputField();
            this.scrollToEnd(); 
        }
    }

    scrollToEnd() {
        this.template.querySelector('.chatbot-body').scrollTop = this.template.querySelector('.chatbot-body').scrollHeight;
    }

    resetInputField() {
        this.message = '';
        this.template.querySelector('input[type="text"]').value = '';
    }

    addToMessages(messageText, isUserMessage) {
        let cssClass = isUserMessage ? 'message user-message' : 'message bot-message';
        this.messages = [...this.messages, { id: this.messages.length + 1, text: messageText, cssClass }];
    }

    async sendDialogflowRequest(userMessage) {
        const url = "https://dialogflow.googleapis.com/v2beta1/projects/housing-uavv/locations/global/agent/sessions/12345:detectIntent";
        const accessToken = await get_access_token();
        // console.log('Test 1000');
        // console.log(accessToken);

        const headers = {
            "Content-Type": "application/json; charset=utf-8",
            "Authorization": `Bearer ${accessToken}`
        };

        const body = {
            queryInput: {
                text: {
                    text: userMessage,
                    languageCode: "en"
                }
            },
            queryParams: {
                source: "DIALOGFLOW_CONSOLE",
                timeZone: "America/Toronto",
                sentimentAnalysisRequestConfig: {
                    analyzeQueryTextSentiment: true
                }
            }
        };

        try {
            const response = await fetch(url, {
                method: 'POST',
                headers: headers,
                body: JSON.stringify(body)
            });

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const data = await response.json();

            return data.queryResult && data.queryResult.fulfillmentText
                ? data.queryResult.fulfillmentText
                : 'No response received from Dialogflow.';
        } catch (error) {
            console.error('Error:', error);
            throw error;
        }
    }
}
