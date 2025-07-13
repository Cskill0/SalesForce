import { LightningElement, api, wire } from 'lwc';
import getTaskStats from '@salesforce/apex/TaskController.getTaskStats';

export default class ContactoProgress extends LightningElement {
    @api recordId;
    total = 0;
    completed = 0;

    get percent() {
        return this.total > 0 ? Math.round((this.completed / this.total) * 100) : 0;
    }

    @wire(getTaskStats, { contactId: '$recordId' })
    wiredStats({ data, error }) {
        if (data) {
            this.total = data.total;
            this.completed = data.completed;
        } else if (error) {
            console.error('Error al obtener tareas', error);
        }
    }
}