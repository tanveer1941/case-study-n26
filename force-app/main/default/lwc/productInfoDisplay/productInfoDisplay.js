import { LightningElement, api, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import CONTACT_PRODUCT_FIELD from '@salesforce/schema/Case.ContactId';
import getContactProductInfo from '@salesforce/apex/ProductInformationController.getContactProductInfo';

export default class ProductInfoDisplay extends LightningElement {
    @api recordId; // Case record ID
    
    contactId;
    contactProductInfo;
    isLoading = true;
    error;

    // Wire service to get Contact ID from Case
    @wire(getRecord, { recordId: '$recordId', fields: [CONTACT_PRODUCT_FIELD] })
    wiredCase({ error, data }) {
        if (data) {
            this.contactId = getFieldValue(data, CONTACT_PRODUCT_FIELD);
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.contactId = undefined;
            this.isLoading = false;
        }
    }

    // Wire service to get Contact Product information when contactId changes
    @wire(getContactProductInfo, { contactId: '$contactId' })
    wiredContactProductInfo({ error, data }) {
        this.isLoading = false;
        
        if (data) {
            this.contactProductInfo = data;
            console.log('Contact Product Info:', JSON.stringify(data));
            console.log('Product Info:', JSON.stringify(data?.Product_Information__r));
            this.error = undefined;
        } else if (error) {
            console.error('Error loading product info:', error);
            this.error = error;
            this.contactProductInfo = null;
        }
    }

    // Getter to check if product info is available
    get hasProductInfo() {
        return this.contactProductInfo && this.contactProductInfo.Product_Information__r && !this.isLoading;
    }

    // Getter to check if there's an error
    get hasError() {
        return this.error && !this.isLoading;
    }

    // Getter for product information from the junction object
    get productInfo() {
        return this.contactProductInfo?.Product_Information__r;
    }

    // Getter for junction object details
    get contactProductDetails() {
        return this.contactProductInfo;
    }

    // Getter to format monthly cost for display
    get formattedMonthlyCost() {
        if (!this.productInfo?.Monthly_Cost__c && this.productInfo?.Monthly_Cost__c !== 0) return 'N/A';
        
        const currencySymbol = this.productInfo.Country_Code__c === 'UK' ? '£' : '€';
        const cost = this.productInfo.Monthly_Cost__c;
        return cost === 0 ? `${currencySymbol} 0` : `${currencySymbol} ${cost}`;
    }

    // Getter to format card replacement cost for display
    get formattedCardReplacementCost() {
        if (!this.productInfo?.Card_Replacement_Cost__c && this.productInfo?.Card_Replacement_Cost__c !== 0) return 'N/A';
        
        const currencySymbol = this.productInfo.Country_Code__c === 'UK' ? '£' : '€';
        return `${currencySymbol} ${this.productInfo.Card_Replacement_Cost__c}`;
    }

    // Getter to format ATM fee for display
    get formattedATMFee() {
        // If no product info or ATM fee is null/undefined, show "Free"
        if (!this.productInfo || this.productInfo.ATM_Fee__c === null || this.productInfo.ATM_Fee__c === undefined) {
            return 'Free';
        }
        
        const atmFee = this.productInfo.ATM_Fee__c;
        
        // If ATM fee is 0 (0%), show "Free"
        if (atmFee === 0) {
            return 'Free';
        }
        
        // For percentage fields, the value is stored as a decimal (e.g., 1.7% is stored as 1.7)
        return `${atmFee}%`;
    }

    // Getter to check if special discount exists
    get hasSpecialDiscount() {
        return this.contactProductDetails?.Special_Discount__c > 0;
    }

    // Getter to format special discount
    get formattedSpecialDiscount() {
        if (!this.hasSpecialDiscount) return 'N/A';
        return `${this.contactProductDetails.Special_Discount__c}%`;
    }

    // Getter for contract term
    get formattedContractTerm() {
        if (!this.contactProductDetails?.Contract_Term_Months__c) return 'N/A';
        return `${this.contactProductDetails.Contract_Term_Months__c} months`;
    }
}