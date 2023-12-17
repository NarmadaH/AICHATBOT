import { LightningElement, track } from 'lwc';

export default class ChatbotComponent extends LightningElement {
    @track message = '';
    @track messages = [];

    handleInputChange(event) {
        this.message = event.target.value;
    }

    async handleSendMessage() {
        try {
            // Add user's message to the messages array
            this.addToMessages(`You: ${this.message}`);

            // Send message to Dialogflow and process the response
            const responseText = await this.sendDialogflowRequest(this.message);

            // Add Dialogflow's response to the messages array
            this.addToMessages(`Bot: ${responseText}`);
        } catch (error) {
            console.error('Error in sending message:', error);
            this.addToMessages('Error in getting response from the bot.');
        } finally {
            // Reset the input field
            this.resetInputField();
        }
    }

    resetInputField() {
        this.message = '';
        this.template.querySelector('input[type="text"]').value = '';
    }

    addToMessages(text) {
        this.messages = [...this.messages, { id: this.messages.length + 1, text }];
    }

    async sendDialogflowRequest(userMessage) {
        const url = "https://dialogflow.googleapis.com/v2beta1/projects/first-demo-gbto/locations/global/agent/sessions/f8d64d41-5859-b9c1-f147-d1ab7ce31b72:detectIntent";
        const accessToken = "ya29.c.c0AY_VpZglK2PowP9VqRUsHLHxWs8fHB3GWI6MUAeiP_trwxSHfogc6cvr5bwcNR38DMZ9ZZbzNA7hOy4BncECS3CdfRk7UIjn5ckrzH-qoBsJpEfPZWJW33JC9UMaUGIL08_3LVoQX3RZtE0b9Ad_2H8JMSeEJ8WvoJB3qinYRdzKXk8dFkNzu5R_NEhFdOxEIhp2ERpl4godwYgFzv6BdKKn4hg8oSwIWJboTRKvz5bXAbOmKRtfKVB2TyiacCWB1OPfpDuOfSkPbpNrgEdqpbSUC-a54RVGf7gSQ2D1jP5X8a79y09SFakvYy64CAR5uxjxKvAXP_88dTvMiMLusMofrh3qOMliU-qT3NajpM2GqJc3bU-dJd8T384PVg2IYXjgrc6VMQyu78kibMjRR5ixUz3vka7bmccQlWelz2sOF2YrlkRbBsRB5WWsBQiobVa5IJypUBnso9ZZd5gU7SIi_V_8uOOe5t6JjsOqQRBk_sZIWlenSejuZ9zeZUwehwxe1kFcvZ0gbcF24OxM5BB9Ml9t42p4tXrWj0t7ur10agriXcuY8cadzBd6vXmxlsjSizSVhk7Vj7OZZlXa0Wxg9Qqrbh9IcwMV0XjSpop8nzUV6hvhOv03l7ujz8l0SMUd8kMJ68pgruzU_oembp0aaOI5ubclngRiQij9RV46fXMUFu7tY_QhFx5FgI0gYsJ-UfMrm4BUh67hsxFo8R2VM2XX_mnQ0uwOebBuXjc5zv2lRmw5djvkYpOBXVjnS1Vqhv-m6bdB8Rps2tsZ1xmo0X9Rv1rt91hJQuvFrYb82VaZgQMa6tabxXUhQUizosooJaYe2a2OmO8fMXXbQ-RrildXB8FnjWhsx_dU5n3badYteWM32m4geVq93u-0niXySgSXsXIIZuuxhZs5suScb1Ib6WXhMMS-geUoXQdyvB47S0p-_l8WY3dfX4v8gFj4vl6w3V2SdlyV3jQY5uBri1_wWlWZtJOuilW3RR9haBaugJOBr-2"; // Replace with your actual access token

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
