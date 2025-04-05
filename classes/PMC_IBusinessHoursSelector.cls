/**
* @description This is a interface, will be used to declare PMC_BusinessHoursSelector method
* @author Sayali Shinde
*/

public interface PMC_IBusinessHoursSelector extends fflib_ISObjectSelector {
    BusinessHours getDefaultBusinessHour();
}