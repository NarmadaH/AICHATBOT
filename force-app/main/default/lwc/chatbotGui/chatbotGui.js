import { LightningElement, track } from 'lwc';

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
        const url = "https://dialogflow.googleapis.com/v2beta1/projects/first-demo-gbto/locations/global/agent/sessions/f8d64d41-5859-b9c1-f147-d1ab7ce31b72:detectIntent";
        const accessToken = "ya29.c.c0AY_VpZjQhsweHl5HDObclV7qCel8Q7QmJd1u6TMqR-Zpgre_rDbz9hM3w-k5BOTu_aNudElpdUvTuQxO2HrBS2g__iZvZlzC-lTC9cvVJq10MdP2jyY2LtwMlA9btOLBijYhGUFl_cd3Qf8v0qyD5wsW1myEhGnLfHtyC_9R2NzRcmCorb2men4Nxfr68Mwc7Fp8W94yWP5sSWP3GgW3VGyHGzL11PgHQhEIrGWZNN0-rdBq8QxM_-IHT_3IK2ixstVA0Sa2MJC_hxtcjC6ZraCuCKFwM7baYXbAf-GDz72NKHXOEu1w3zZBeHPQkkUZYztNGZga1g8jRg8qIP2A_IpQziPl8eA7jQkW2-g4qcWm-CxeJKc5UOaNG385D-YwIOrimx-6s_Ic0Iq_64I8ie1wRnsgr2OW-6fp69JcxisUab2eM6_tfSgkxmbu-FjIOB298nJ1zR-Fva73V8I_7Mn-rdjr-61frVOiYVi8JtsYmu4Y8yZk0z28qF3khJ_46p7_BQ7c5oMW3f7OWvqrox5afibw6vbk754YYoqpgX8ihRipM_2SpRbM8e4fBZR0yqY2_sQS-q4hMFIp8jM2kI4e4mvQpzlU3foxFdxl4iJzrdpzvVW6fllicFlUaz3gd18fygSOjkh_jR4bFgt-Uhp2qSbpo5Ij25M57fwtUbRZ-j6lO46gJJWORQtZrii8kvpprZRgMdq8zUeeIabcW1o-RasMgd48Vp1p6SOXxyd-eM0X3YJe_gm1deX-w0esIlxcQSxsQ8Q4r4B5WVhx6Xhy2Z2nsZuzZQ06ty4wcShMJsUFObFQYBOm3ugv3V4n_BWtftQsxZI2X1kVk8F3lds2RpZeQy4bs_wJae9cJOVJybiX3a9MoufXcjfBtSbdz5beItoY71IsmZ_jRlaksymrzWmUcvla2Qweim_S3Qpg3xa6JorjBYkyrQaipz-6mix4rIWIV5gmqhagmoOp39-g1RRQ6MdWzQIahstJOajXr626IYX5u6p"; // Replace with your actual access token

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

            // Return the fulfillment text from Dialogflow's response
            return data.queryResult && data.queryResult.fulfillmentText
                ? data.queryResult.fulfillmentText
                : 'No response received from Dialogflow.';
        } catch (error) {
            console.error('Error:', error);
            throw error; // Rethrow the error to be caught by the caller
        }
    }
}
