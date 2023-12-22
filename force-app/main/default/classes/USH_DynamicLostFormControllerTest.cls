/**
 * Created By - Pragam Kaistha
 * Created Date - 16 August 2023
 * Updated Date - 25 August 2023
 * Class Name - USH_DynamicLostFormController
 * Description - It is the test class for USH_DynamicLostFormController.
 * Update - Added Asserts
**/
@isTest
private class USH_DynamicLostFormControllerTest {

    @isTest
    static void testGetFields() {
    
        Test.startTest();
        List<String> result = USH_DynamicLostFormController.getFields('Cellphone');
        Test.stopTest();
		System.assertNotEquals(null, result, 'result is null');
    }

    @isTest
    static void testGetFieldsException() {
        Test.startTest();
        List<String> result = USH_DynamicLostFormController.getFields('NonExistentRecordType');
        Test.stopTest();
		System.assertEquals(0, result.size(), 'result is not empty');
    }
}