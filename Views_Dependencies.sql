select distinct schema_name(v.schema_id) as schema_name,
       v.name as view_name,
       schema_name(o.schema_id) as referenced_schema_name,
       o.name as referenced_entity_name,
       o.type_desc as entity_type
from sys.views v
inner join sys.sql_expression_dependencies d
     on d.referencing_id = v.object_id
     and d.referenced_id is not null
inner join sys.objects o
     on o.object_id = d.referenced_id​
where referenced_schema_name = '<table/view schema name>' and referenced_entity_name = '<table/view name>'​
