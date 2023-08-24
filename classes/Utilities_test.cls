@isTest
public class Utilities_test extends Utilities {

   @isTest static void test_random_string() {
      Integer desired_length = 10;
      String random_string = Utilities.random_string(desired_length);
      Assert.areEqual(desired_length, random_string.length());
   }

   @isTest static void test_picklist_values() {
      String[] values = Utilities.picklist_values('Opportunity', 'StageName');
      System.assert(!values.isEmpty());
   }
   @isTest static void test_first_picklist_value() {
      System.assertNotEquals(null, Utilities.first_picklist_value('Opportunity', 'StageName'));
   }
   @isTest static void test_picklist_labels() {
      String[] values = Utilities.picklist_values('Opportunity', 'StageName');
      System.assert(!values.isEmpty());
   }

   @isTest static void test_field_info() {
      Assert.areEqual('STRING', String.valueOf(Utilities.field_info('Account', 'Name').getType()));
   }

   @isTest static void test_field_value_from_string() {
      String   date_string       = '1979-02-20';
      Date     expected_date     = Date.newInstance(1979, 2, 20);
      String   datetime_string   = '1979-02-20T22:20:00.000Z';
      Datetime expected_datetime = Datetime.newInstance(1979, 2, 20, 22, 20, 0);

      System.assertEquals(expected_date,     Utilities.field_value_from_string('Account', 'LastActivityDate', date_string));
      System.assertEquals(expected_datetime, Utilities.field_value_from_string('Account', 'CreatedDate',      datetime_string));

      System.assertEquals(66.66, Utilities.field_value_from_string('Account', 'AnnualRevenue', '66.66'));
      System.assertEquals(true, Utilities.field_value_from_string('Account', 'IsDeleted', 'true'));

      System.assertEquals('Test', Utilities.field_value_from_string('Account', 'Name', 'Test'));

      // Non-Strings sent to the method should simply come back with their original value.
      System.assertEquals(666, Utilities.field_value_from_string(null, null, 666));
   }

   @isTest static void test_child_relationship_name() {
      System.assertEquals('Opportunities', Utilities.child_relationship_name('Account', 'Opportunity', 'AccountId'));
   }

}