@isTest
public class GetProductCategoriesTest {
    @isTest
    public static void testGetProductCategories() {
        List<String> expectedCategories = new List<String>{'Coproduct','Feed','Nitrogen','NPK','Phosphate','Potash','Raw Material','Rock','Salt','Sulphur'};
          
        Test.startTest();
        List<String> actualCategories = PMC_DH_GetProductCategories.getProductCategories(
            'webstoreId',
            'productCategoryId',
            'effectiveAccountId',
            'fields',
            'excludeFields',
            'mediaGroups',
            'excludeMedia'
        );
        Test.stopTest();
        System.assertEquals(expectedCategories, actualCategories);
        
    }
    
}