import { LightningElement, api } from 'lwc';
import { RefreshEvent }          from 'lightning/refresh';
import { NavigationMixin }       from 'lightning/navigation';
import { ShowToastEvent }        from 'lightning/platformShowToastEvent';
import getRecords                from '@salesforce/apex/junctionBuilderLWC.records_from_join_object_parent';
import insertRecords             from '@salesforce/apex/junctionBuilderLWC.insert_records';

export default class JunctionBuilder extends NavigationMixin(LightningElement) {
    @api objectApiName;
    @api recordId;

    @api title;
    @api buttonLabel;
    @api joinObject;
    @api primaryLookupField;
    @api secondaryLookupField;
    @api navigateToFullList

    @api inputFields;
    @api soqlFilter;
    @api extraSOQL;
    @api sortByName;

    get safeButtonLabel() { return this.buttonLabel ? this.buttonLabel : 'Create Junction Records'; }

    isLoading = true;
    fields;
    allRecords;

    connectedCallback() {
        this.fields = (this.inputFields ? this.inputFields?.replace(/\s+/g, '').split(',') : []);

        getRecords({ join_object: this.joinObject, lookup_field: this.secondaryLookupField, filter: this.soqlFilter, extra_SOQL: this.extraSOQL, sort_by_name: this.sortByName })
            .then(records => {
                console.log(records);
                this.allRecords = records;
            })
            .catch(error => { this.popToast(this, 'Failure!', error.body.message, 'error'); })
            .finally(()  => { this.isLoading = false; });
    }

    createJunctionRecords() {
        let recordData = this.recordData();

        if (recordData.length) {
            this.isLoading = true;

            insertRecords({ join_object: this.joinObject, all_record_data: recordData, primary_object: this.objectApiName, primary_lookup_field: this.primaryLookupField })
                .then((result) => {
                    this.popToast(this, 'Success!', result.new_records + ' new ' + (result.new_records == 1 ? 'record has' : 'records have') + ' been created.', 'success');
                    if (this.navigateToFullList) {this.navigateToRelatedList(result.relationship_name);}
                    else                         {this.dispatchEvent(new RefreshEvent());}
                })
                .catch(error => { this.popToast(this, 'Failure!', error.message, 'error'); })
                .finally(()  => { this.isLoading = false; });
        } else { this.popToast(this, 'No Items Selected', null, 'warning'); }
    }
        recordData() {
            let data = [];
            let allRecordData = this.template.querySelectorAll('.input-line');

            console.log(allRecordData);
            allRecordData.forEach(singleRecordData => {
                let checkbox = singleRecordData.querySelector('lightning-input.checkbox-button');

                if (checkbox.checked) {
                    let record = { [this.primaryLookupField]: this.recordId, [this.secondaryLookupField]: checkbox.value };

                    if (this.fields.length) {
                        let inputs = singleRecordData.querySelectorAll('lightning-input-field');
                        inputs.forEach(input => {
                            record[input.dataset.fieldname] = input.value;
                        });
                    }

                    data.push(record);
                }
            });

            return data;
        }

    navigateToRelatedList(relationship_name) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordRelationshipPage',
            attributes: {
                objectApiName: this.objectApiName,
                recordId: this.recordId,
                relationshipApiName: relationship_name,
                actionName: 'view'
            }
        });
    }

    popToast(element, title, message, variant) {
        element.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }
}