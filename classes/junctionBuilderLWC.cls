public without sharing class junctionBuilderLWC {

    @AuraEnabled(cacheable=true)
    public static SObject[] records_from_join_object_parent(String join_object, String lookup_field, String filter, String extra_SOQL, Boolean sort_by_name) {
        String parent_object = Utilities.field_info(join_object, lookup_field).getReferenceTo()[0].getDescribe().getName();

        String query = 'SELECT Id, Name FROM ' + parent_object + (String.isNotBlank(filter) ? ' WHERE ' + filter : '') + (String.isNotBlank(extra_SOQL) ? ' ' + extra_SOQL : '') + (sort_by_name ? ' ORDER BY Name' : '');

        return Database.query(query);
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> insert_records(String join_object, List<Map<String, Object>> all_record_data, String primary_object, String primary_lookup_field) {
        SObject[] new_records = new SObject[]{};

        for (Map<String, Object> field_values_by_field_name : all_record_data) {
            SObject new_record = ((SObject)Type.forName('', join_object).newInstance());

            for (String field : field_values_by_field_name.keySet()) {
                Object value = Utilities.field_value_from_string(join_object, field, field_values_by_field_name.get(field));
                new_record.put(field, value);
            }

            new_records.add(new_record);
        }

        insert new_records;

        return new Map<String, Object>{'new_records'       => new_records.size(),
                                       'relationship_name' => Utilities.child_relationship_name(primary_object, join_object, primary_lookup_field)};
    }

}