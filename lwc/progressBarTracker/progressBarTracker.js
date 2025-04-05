import { LightningElement, api } from 'lwc';

/**
 * A Custom Progress Bar.
 * @alias ProgressBarTracker
 * @description : Progress Bar which shows the active/done step
 * @author Himanshu Rathore <himrathore@deloitte.com>
 * @example
 * <c-progress-bar-tracker></c-progress-bar-tracker>
 */

export default class ProgressBarTracker extends LightningElement {
    @api steps = [
        {title: 'Getting Started', complete: true},
        {title: 'Review', complete: true},
        {title: 'Complete', complete: ''}
    ];
    get stepClasses() {
        let activeStepIndex = -1;
        const classes = this.steps.map((step, index) => {
            if (step.complete) {
                activeStepIndex = index;
            }
            return {
                title: step.title,
                class: step.complete ? 'stepper__link stepper__link--active' : 'stepper__link'
            };
        });
        if (activeStepIndex > 0) {
            classes[activeStepIndex - 1].status = 'done';
        }
        if (activeStepIndex > 1) {
            classes[activeStepIndex - 2].status = 'done';
        }
        if (activeStepIndex >= 0 && activeStepIndex < classes.length) {
            classes[activeStepIndex].status = 'active';
        }
        return classes;
    }
}