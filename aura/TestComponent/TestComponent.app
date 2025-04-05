<aura:application extends="force:slds">
    Custom Lookup with Filter 1 
    <c:customLookupField objectName="Account" fieldName="Name" label="Account Search" placeholder="search Account" iconName="standard:account" ></c:customLookupField>
    
    Custom Lookup with Filter 2 
    <c:customLookupWithFilter objName="Order" iconName="standard:account"></c:customLookupWithFilter>
    
    <c:pmc_ss_customLookupWithFilter></c:pmc_ss_customLookupWithFilter>
        <c:pmc_ss_customFileUploader></c:pmc_ss_customFileUploader>

</aura:application>