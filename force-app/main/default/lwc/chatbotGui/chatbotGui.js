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
        const accessToken = "ya29.c.c0AY_VpZjcTC0bv8vJBGZzMaKfj21I69RlBhRGVr-nnGZInPdfi4MWkIDWf5R69nXdBTgX1o5AT1nisFLZStBouViF2tg52AVVF3r81dlEgptK3wQJDMN3wNyxfpq0IxT3ZPkjCZMbfCCnCLrWT43hSBpZhSOuXmM_WN7Eu_dxgBio4OIOv1rvDW0-WPncrSEw4Po0EhAMQZpmqah1tWSoCGNFg6R0yh-8XmhOOaurmibMsZWx5fPMwj1GBnsR0uG6SmAAGbNh1EPUN_s6bX_X4iYt1-gcaDUSWE1XVzcDm4__jMJgpfAzanua2Iqn20rxd3D60SadTaJMigW_igf9tYur8t7noUpAntlSk9GjCNnVpRDT6vvqtZG0N385DIcmg75OaJ1sXetYMtZ-Q3VXgY98BW2mOnuiMtWQnbxXQw79QO_RJtulaonkkarUX2bln6j2fxW-sBZ25eOQ8OjakqyX0Q2kkJFjjxXdfw95inla4W0acRBXYYspFhgVI8s6z51iRXqZjimseOOR0QZ9IMlcWvpJ9fcWpJRgnJ7fR48IBbW11lBeBu26g4qISkJa1nwsnYes9WszhlO8pg2g1qngV6vO4BxSeWo8I0krwF6-5SFRtWjsw6W5qnOk5344auFBm4BBip_dnagp4XO518SnlShqqYWw6eZzrso-Qa9abnogspxpzi7hQpctf_vVao505sanVzo-MasWI_ozg54fV27ku9xUhlx9eZq4z4quj2sfgBYRie0b4jFV4viYiltp90cOa9Vwf_nJrc9vwqO3j5-SSMX8yFxq9J2JMIJVrSt8ru7ywqab-7og_ufiz7pZ-vFVrjWs1s5kusbW6ljOr7UuqYnm66ORa5titfflR0JhBMhfWi_9f8riYaacBJf---UMOOa5RpbfRf9IU6wahhretaXV1xakSqwRy001ukkrzw9jUI2woZoxoeWg29my5Yl5gh5vaQx7xZeMtdnJ9l4qyaQR4RrzZ_vR97w0wzMqo092F-q"; // Replace with your actual access token

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
