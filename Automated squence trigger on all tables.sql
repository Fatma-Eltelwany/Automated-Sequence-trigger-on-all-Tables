set serveroutput on 10000

DECLARE
        seq_name varchar2 (1000) ;
        seq_ck number;
        mx_value number ;
        CURSOR seq_trigg1 IS 
              SELECT col.table_name , col.column_name , const.constraint_type --, utc.Data_type 
                FROM user_cons_columns col JOIN user_constraints const
              ON col.constraint_name = const.constraint_name 
                          JOIN user_tab_columns utc
              ON col.table_name = utc.table_name AND col.column_name = utc.column_name
              WHERE  const.constraint_type = 'P' AND utc.Data_type = 'NUMBER' order by utc.table_name  ;
BEGIN  
    FOR seq_rec in seq_trigg1 LOOP
            EXECUTE IMMEDIATE 'SELECT MAX ('|| seq_rec.column_name||') FROM  '|| seq_rec.table_name into mx_value ;
         
               IF mx_value is Null Then           
                mx_value := 0 ;
               End if ; 
              
       seq_name := seq_rec.table_name||'_seq' ;
       
               SELECT count(sequence_name)  Into seq_ck
                FROM user_sequences 
                Where sequence_name = UPPER(seq_name);
                            
                If seq_ck = 1 then
                    Execute Immediate 'Drop sequence '||seq_name ;
                 End if ;
                    
            EXECUTE IMMEDIATE 'CREATE SEQUENCE '||seq_rec.table_name||'_seq start with ' ||to_char(mx_value+1)||' increment by 1' ;
-------------------------         
            EXECUTE IMMEDIATE 'CREATE OR REPLACE TRIGGER seq_trig_'||seq_rec.table_name||
          ' BEFORE INSERT ON '||seq_rec.table_name||
           ' FOR EACH ROW
           BEGIN
                 :new.'||seq_rec.column_name||' := '||seq_rec.table_name||'_seq.nextval ;   
           END ;' ;       
                                
   End loop ;  
   
END ;          

show errors ;


