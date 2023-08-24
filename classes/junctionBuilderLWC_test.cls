@isTest
public class junctionBuilderLWC_test {

    @testSetup static void setup() {
        Account included1 = TestData.account('A Name has more AnnualRevenue, so it comes last');
        included1.AnnualRevenue = 999;
        Account included2 = TestData.account('Z Name has less AnnualRevenue, so it comes first');
        included2.AnnualRevenue = 101;
        Account excluded = TestData.account('Excluded');

        insert new Account[]{included1, included2, excluded};

        Contact account1_contact  = new Contact(AccountId = included1.Id, FirstName = 'Test', LastName = 'A Contact');
        Contact account2_contact1 = new Contact(AccountId = included2.Id, FirstName = 'Test', LastName = 'Z Contact 1');
        Contact account2_contact2 = new Contact(AccountId = included2.Id, FirstName = 'Test', LastName = 'Z Contact 2');
        insert new Contact[]{account1_contact, account2_contact1, account2_contact2};
    }

    @isTest static void test_records_from_join_object_parent() {
        // Confirm there are two Accounts with AnnualRevenue and that the one that is alphabetically first should be last when sorting by AnnualRevenue.
            System.assertEquals(3, [SELECT COUNT() FROM Account]);
            System.assertEquals(2, [SELECT COUNT() FROM Account WHERE AnnualRevenue > 100]);
            Account[] accounts_that_should_be_found = [SELECT Name, AnnualRevenue FROM Account WHERE AnnualRevenue > 100 ORDER BY Name];
            System.assert(accounts_that_should_be_found[0].Name.startsWith('A'));
            System.assert(accounts_that_should_be_found[1].Name.startsWith('Z'));
            System.assert(accounts_that_should_be_found[0].AnnualRevenue > accounts_that_should_be_found[1].AnnualRevenue);

        // Setup the inputs for the test.
            String  join_object  = 'AccountContactRole';
            String  lookup_field = 'AccountId';
            String  filter       = 'AnnualRevenue > 100';
            String  extra_SOQL   = 'ORDER BY AnnualRevenue ASC';
            Boolean sort_by_name = false;

        // Confirm the method returns the expected records in the expected order.
            Account[] accounts = junctionBuilderLWC.records_from_join_object_parent(join_object, lookup_field, filter, extra_SOQL, sort_by_name);

            System.assertEquals(2, accounts.size());
            System.assert(accounts[0].Name.startsWith('Z'));
            System.assert(accounts[1].Name.startsWith('A'));
    }

    @isTest static void test_insert_records() {
        String join_object          = 'AccountContactRole';
        String primary_object       = 'Account';
        String primary_lookup_field = 'AccountId';

        Account   first_account                = [SELECT Id FROM Account WHERE Name LIKE 'A%'];
        Contact[] contacts_from_second_account = [SELECT Id FROM Contact WHERE LastName LIKE 'Z Contact%'];

        List<Map<String, Object>> all_record_data = new List<Map<String, Object>>{
            new Map<String, Object>{'AccountId' => first_account.Id, 'ContactId' => contacts_from_second_account[0].Id, 'Role' => Utilities.first_picklist_value('AccountContactRole', 'Role')},
            new Map<String, Object>{'AccountId' => first_account.Id, 'ContactId' => contacts_from_second_account[1].Id, 'Role' => Utilities.first_picklist_value('AccountContactRole', 'Role')}
        };

        Integer account_contact_roles_before = [SELECT COUNT() FROM AccountContactRole];

        Map<String, Object> result = junctionBuilderLWC.insert_records(join_object, all_record_data, primary_object, primary_lookup_field);
        System.assertEquals(account_contact_roles_before + 2, [SELECT COUNT() FROM AccountContactRole]);

        System.assertEquals(2,                     result.get('new_records'));
        System.assertEquals('AccountContactRoles', result.get('relationship_name'));
    }
}