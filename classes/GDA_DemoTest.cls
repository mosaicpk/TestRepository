/**
 * @description       : 
 * @author            : siddharth.pradhan@mosaicco.com | Digital Hub
 * @group             : 
 * @last modified on  : 07-24-2023
 * @last modified by  : siddharth.pradhan@mosaicco.com | Digital Hub
**/
@isTest
private class GDA_DemoTest {

    @isTest
    static void testMySampleMethod() {
        // Call the method to be tested
        String result = GDA_Demo.mySampleMethod();

        // Assert that the result matches the expected output
        System.assertEquals('Hello World', result);
    }
}