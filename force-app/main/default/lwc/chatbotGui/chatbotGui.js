import { LightningElement, track } from 'lwc';
import { openTab } from 'lightning/platformWorkspaceApi';
import get_access_token from '@salesforce/apex/GoogleAuthService.get_access_token';

export default class ChatbotComponent extends LightningElement {
    @track message = '';
    @track messages = [];
    @track isLoading = false;
    @track isChatVisible = false;
    @track buttonMessages = [];

    handleInputChange(event) {
        this.message = event.target.value;
    }

    toggleChat() {
        this.isChatVisible = !this.isChatVisible;
    }

    toggleChat() {
        this.isChatVisible = !this.isChatVisible;
    
        if (this.isChatVisible && this.messages.length === 0) {
            this.sendDefaultMessage();
        }
    }
    
    async sendDefaultMessage() {
        const defaultMessage = 'howdy';
    
        try {
            this.isLoading = true;
            
            const messages = await this.sendDialogflowRequest(defaultMessage);
            
            messages.forEach(msg => {
                if (msg.type === 'text') {
                    this.addToMessages(`${msg.content}`, false);
                } else if (msg.type === 'link') {
                    this.addToMessages(msg.text, false, true, msg.url);
                } else if (msg.type === 'button') {
                    this.addToMessages(msg.text, false, false, '', true);
                }
            });
        } catch (error) {
            this.addToMessages('Error in getting response from the bot.', false);
        } finally {
            this.isLoading = false;
        }
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

    get isSendInputDisabled() {
        return true;
    }

    handleButtonClick(event) {
        this.message = event.target.textContent;
        this.handleSendMessage();
    }


    async handleSendMessage() {
        try {
            this.isLoading = true;
            this.buttonMessages = [];
            this.addToMessages(`${this.message}`, true);
    
            const messages = await this.sendDialogflowRequest(this.message);
    
            messages.forEach(msg => {
                if (msg.type === 'text') {
                    this.addToMessages(`${msg.content}`, false);
                } else if (msg.type === 'link') {
                    this.addToMessages(msg.text, false, true, msg.url);
                } else if (msg.type === 'button') {
                    this.addToMessages(msg.text, false, false, '', true);
                }
            });
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

    
    addToMessages(messageText, isUserMessage, isLink = false, url = '', isButton = false) {
        let cssClass = isUserMessage ? 'message user-message' : 'message bot-message';
        if (isLink) {
            cssClass = 'message link-message';
        } else if (isButton) {
            cssClass = 'message button-message';
        }
        const formattedMessageText = messageText.replace(/\n/g, '<br>');
        this.messages = [...this.messages, { id: this.messages.length + 1, text: formattedMessageText, cssClass, isLink, url, isButton }];
    }
    
    renderedCallback() {
        this.messages.forEach((message) => {
            if (!message.isButton && !message.isLink) {
                const messageElement = this.template.querySelector(`[data-id="${message.id}"]`);
                if (messageElement) {
                    messageElement.innerHTML = message.text;
                }
            }
        });
    }    
    

    async sendDialogflowRequest(userMessage) {
        const url = "https://dialogflow.googleapis.com/v2beta1/projects/ymca-ahc9/locations/global/agent/sessions/12345:detectIntent";
        const accessToken = await get_access_token();
        
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
            let messages = [];
            let buttonMessages = [];

            if (data.queryResult && data.queryResult.fulfillmentMessages) {
                data.queryResult.fulfillmentMessages.forEach(message => {
                    if (message.text && message.text.text) {
                        messages.push({ type: 'text', content: message.text.text[0] });
                    } else if (message.payload && message.payload.richContent) {
                        message.payload.richContent[0].forEach(content => {
                            if (content.options) {
                                content.options.forEach(option => {
                                    if (option.link) {
                                        messages.push({ type: 'link', text: option.text, url: option.link });
                                    } else {
                                    const isButtonExist = buttonMessages.find(button => button.text === option.text);
                                        if (!isButtonExist) {
                                            buttonMessages.push({ text: option.text });
                                        }
                                    }
                                });
                            }
                        });
                    }
                });
            }

            this.buttonMessages = buttonMessages;
            return messages;
        } catch (error) {
            console.error('Error:', error);
            throw error;
        }
    }

    handleLink(event) {
        event.preventDefault();
        const url = event.currentTarget.getAttribute('href');        
        window.open(url, "_blank");
    }
    
}
