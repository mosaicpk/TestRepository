import { LightningElement, api } from 'lwc';
export default class LightningDatatableLWCExample extends LightningElement {
    columns = [{
            label: 'Case Number',
            fieldName: 'CaseNumber',
            type: 'text',
            sortable: true
        },
        {
            label: 'Created Date',
            fieldName: 'CreatedDate',
            type: 'date',
            sortable: true,
            cellAttributes:{
                class:{fieldName:'dateColor'},
                iconName:{fieldName:'iconName'}, iconPosition:'right'
            }
        },
        {
            label: 'Subject',
            fieldName: 'Subject',
            type: 'text',
            sortable: true
        },
        {
            label: 'Priority',
            fieldName: 'Priority',
            type: 'text',
            sortable: true
        },
        {
            label: 'Url',
            fieldName: 'url',
            type: 'url',
        }, {
            label: 'Case Details', type: "button",
            typeAttributes: {
                label: 'View Details',
                name: 'DetailViewCase',
                title: 'View',
                disabled: false,
                value: 'test',
                iconPosition: 'left',
                variant: "brand"
            }
        }
    ];
    @api accList;
    @api rowAction;
    handleRowAction(event) {
        const action = event.detail.action;
        const row = event.detail.row;
        switch (action.name) {
            case 'DetailViewCase':
                alert('Showing Details: ' + JSON.stringify(row));
                break;
  
    }
}
}