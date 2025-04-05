import { LightningElement, track } from 'lwc';
import CustomRichTextCell from 'c/customRichTextCell';

export default class Rc_exportData extends LightningElement {
    @track conatctData = [
    { id: "id1", firstName: "firstname1", lastName: "lastname1", email: "email@email.com" },
    { id: "id2", firstName: "firstname2", lastName: "lastname2", email: "email@emai2.com" },
    { id: "id3", firstName: "firstname3", lastName: "lastnamelastnamelastname3", email: "email@emai3.com" },
    { id: "id4", firstName: "firstname4", lastName: "lastname4", email: "email@emai4.com" },
    { id: "id5", firstName: "firstname5", lastName: "lastname5", email: "email@emai5.com" },
  ];
  columnHeader = [
    { label: 'Id', fieldName: 'id', type: 'text' },
    { label: 'First Name', fieldName: 'firstName', type: 'text' },
    { label: 'Last Name', fieldName: 'lastName', type: 'text' },
    { label: 'Email', fieldName: 'email', type: 'text' }
    // Add more columns as needed
  ];
  // columnHeader = ['id', 'firstName', 'lastName', 'email'];

  exportContactDataExcel() {
    // Prepare a html table
    let doc = '<table>';
    // Add styles for the table
    doc += '<style>';
    doc += 'table, th, td {';
    doc += '    border: 1px solid black;';
    doc += '    border-collapse: collapse;';
    doc += '    font-weight: normal';
    doc += '}';
    doc += '</style>';
    // Add all the Table Headers
    doc += '<tr>';
    this.columnHeader.forEach(element => {
      doc += '<th>' + element.label + '</th>'
    });
    doc += '</tr>';
    // Add the data rows
    this.conatctData.forEach(record => {
      doc += '<tr>';
      doc += '<th>' + record.id + '</th>';
      doc += '<th>' + record.firstName + '</th>';
      doc += '<th>' + record.lastName + '</th>';
      doc += '<th>' + record.email + '</th>';
      doc += '</tr>';
    });
    doc += '</table>';
    let element = 'data:application/vnd.ms-excel,' + encodeURIComponent(doc);
    // var element = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,' + encodeURIComponent(doc);
    // var element = 'application/application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,' + encodeURIComponent(doc);
    let downloadElement = document.createElement('a');
    downloadElement.href = element;
    downloadElement.target = '_self';
    // use .csv as extension on below line if you want to export data as csv
    downloadElement.download = 'Contact Data.xls';
    document.body.appendChild(downloadElement);
    downloadElement.click();
  }

  exportContactDataCsv() {
    let doc = '';
    // Add the data coloums
    this.columnHeader.forEach(column => {
      doc += column.label + ','
    });
    doc += '\n';
    // Add the data rows
    this.conatctData.forEach(row => {
      // doc += ”;
      doc += row.id + ',';
      doc += row.firstName + ',';
      doc += row.lastName + ',';
      doc += row.email + ',';
      doc += '\n';
    });
    let element = 'data:text/csv;charset=utf-8,' + encodeURIComponent(doc);
    let downloadElement = document.createElement('a');
    downloadElement.href = element;
    downloadElement.target = '_self';
    // if you want to export data as csv, use .csv as extension on below line
    downloadElement.download = 'Contact Data.csv';
    document.body.appendChild(downloadElement);
    downloadElement.click();
  }


  @track data = [
    {
      id: '1',
      richText: '<p>This is a rich text cell</p>',
      age: 30
    },
    {
      id: '2',
      richText: '<p>This is a rich text cell</p>',
      age: 25
    }
  ];

  @track columns = [
    {
      label: 'Rich Text',
      fieldName: 'richText',
      type: 'customRichText',
      typeAttributes: { cellValue: {fieldName: 'richText'}}
    },
    { label: 'Age', fieldName: 'age', type: 'number' }
  ];

  get columns2() {
    return [
      {
        label: 'Rich Text',
        fieldName: 'richText',
        type: 'text',
        cellAttributes: {
          class: 'slds-rich-text-editor__output',
          customAttributes: { cellValue: { fieldName: 'richText' }}
        },
        typeAttributes: {
          cellValue: { fieldName: 'richText'}
        }
      },
      {
        lable: 'Age',
        fieldName: 'age',
        type: 'number'
      }
    ]
  }

}