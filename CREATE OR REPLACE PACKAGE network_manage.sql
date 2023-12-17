CREATE OR REPLACE PACKAGE network_management AS
    PROCEDURE create_and_insert_network_devices;
    PROCEDURE add_device;
    PROCEDURE create_and_insert_network_interfaces;
    PROCEDURE delete_device(p_device_id INT);
    PROCEDURE setup_audit_triggers(p_table_name VARCHAR2);
    PROCEDURE simulate_traffic_and_alerts;
    PROCEDURE create_and_insert_network_logs;
    PROCEDURE create_foreign_keys;
END network_management;
/
CREATE OR REPLACE PACKAGE BODY network_management AS
    PROCEDURE create_and_insert_network_devices AS
        BEGIN
            -- Create Table
            BEGIN
                EXECUTE IMMEDIATE 'CREATE TABLE network_devices (
                    device_id INT PRIMARY KEY,
                    device_name VARCHAR2(50),
                    device_ip_address VARCHAR2(15),
                    device_type VARCHAR2(20),
                    location VARCHAR2(50),
                    manufacturer VARCHAR2(50),
                    firmware_version VARCHAR2(10),
                    status VARCHAR2(10),
                    last_seen TIMESTAMP
                )';
            EXCEPTION
                WHEN OTHERS THEN
                    NULL; -- Table already exists, ignore the error
            END;
            -- Insert Sample Data
            FOR i IN 1..10 LOOP
                INSERT INTO network_devices (
                    device_id,
                    device_name,
                    device_ip_address,
                    device_type,
                    location,
                    manufacturer,
                    firmware_version,
                    status,
                    last_seen
                )
                SELECT
                    LEVEL,
                    'Device' || LEVEL,
                    '192.168.' || TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1, 255))) || '.' || TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1, 255))),
                    CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN 'Router' ELSE 'Switch' END,
                    CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN 'Server Room' ELSE 'Network Closet' END,
                    'Manufacturer' || LEVEL,
                    SUBSTR('v' || TO_CHAR(DBMS_RANDOM.VALUE(1, 10)), 1, 10), -- Ensure firmware_version does not exceed 10 characters
                    CASE WHEN DBMS_RANDOM.VALUE < 0.8 THEN 'Active' ELSE 'Inactive' END,
                    TO_TIMESTAMP('2023-01-01 09:12', 'YYYY-MM-DD HH24:MI') - DBMS_RANDOM.VALUE(1, 365)
                FROM DUAL
                CONNECT BY LEVEL <= 10;
            END LOOP;
            COMMIT; -- Commit the changes
        END create_and_insert_network_devices;
    PROCEDURE add_device(
            p_device_id INT,
            p_device_name VARCHAR2(50),
            p_device_ip_address VARCHAR2(15),
            p_device_type VARCHAR2(20),
            p_location VARCHAR2(50),
            p_manufacturer VARCHAR2(50),
            p_firmware_version VARCHAR2(10),
            p_status VARCHAR2(10),
            p_last_seen TIMESTAMP
        ) AS 
        BEGIN
            EXECUTE IMMEDIATE 'INSERT INTO network_devices VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9)'
            USING p_device_id,
                SUBSTR(p_device_name, 1, 50),
                SUBSTR(p_device_ip_address, 1, 15),
                SUBSTR(p_device_type, 1, 20),
                SUBSTR(p_location, 1, 50),
                SUBSTR(p_manufacturer, 1, 50),
                SUBSTR(p_firmware_version, 1, 10),
                SUBSTR(p_status, 1, 10),
                p_last_seen;
        END add_device;
    PROCEDURE create_and_insert_network_interfaces AS
        BEGIN
            -- Create network_interfaces table
            BEGIN
                EXECUTE IMMEDIATE 'CREATE TABLE network_interfaces (
                    interface_id INT PRIMARY KEY,
                    device_id INT,
                    interface_name VARCHAR2(50),
                    interface_type VARCHAR2(20),
                    speed_mbps INT,
                    mac_address VARCHAR2(12)
                )';
            EXCEPTION
                WHEN OTHERS THEN
                    NULL; -- Table already exists, ignore the error
            END;

            -- Insert data into network_interfaces table
            INSERT INTO network_interfaces (interface_id, device_id, interface_name, interface_type, speed_mbps, mac_address)
            SELECT
                LEVEL,
                TRUNC(DBMS_RANDOM.VALUE(1, 10)), -- device_id
                'Interface' || LEVEL,
                CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN 'Ethernet' ELSE 'Fiber' END,
                CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN TO_NUMBER(DBMS_RANDOM.VALUE(100, 10000)) ELSE NULL END, -- speed_mbps
                DBMS_RANDOM.STRING('X', 12) -- mac_address
            FROM DUAL
            CONNECT BY LEVEL <= 10;
        END create_and_insert_network_interfaces;
    PROCEDURE delete_device(p_device_id INT) AS
    	BEGIN
       		EXECUTE IMMEDIATE 'DELETE FROM network_devices WHERE device_id = :1' USING p_device_id;
   	 	END;
    PROCEDURE setup_audit_triggers(p_table_name VARCHAR2) AS
        BEGIN
            -- Create the audit_logs table
            EXECUTE IMMEDIATE '
                CREATE TABLE audit_logs (
                    audit_id INT PRIMARY KEY,
                    administrator_id INT,
                    timestamp TIMESTAMP,
                    action_type VARCHAR2(10),
                    table_affected VARCHAR2(50),
                    record_id INT,
                    details VARCHAR2(4000)
                )';

            -- Create a sequence for audit_id
            EXECUTE IMMEDIATE '
                CREATE SEQUENCE audit_id_seq START WITH 1 INCREMENT BY 1';

            -- Create a trigger to log inserts
            EXECUTE IMMEDIATE '
                CREATE OR REPLACE TRIGGER audit_logs_insert_trigger
                AFTER INSERT ON ' || p_table_name || '
                FOR EACH ROW
                BEGIN
                    INSERT INTO audit_logs (
                        audit_id,
                        administrator_id,
                        timestamp,
                        action_type,
                        table_affected,
                        record_id,
                        details
                    ) VALUES (
                        audit_id_seq.NEXTVAL,
                        :new.administrator_id,
                        SYSTIMESTAMP,
                        ''Insert'',
                        ''' || p_table_name || ''',
                        :new.record_id,
                        ''{"action": "Insert"}''
                    );
                END';

            -- Create a trigger to log updates
            EXECUTE IMMEDIATE '
                CREATE OR REPLACE TRIGGER audit_logs_update_trigger
                AFTER UPDATE ON ' || p_table_name || '
                FOR EACH ROW
                BEGIN
                    INSERT INTO audit_logs (
                        audit_id,
                        administrator_id,
                        timestamp,
                        action_type,
                        table_affected,
                        record_id,
                        details
                    ) VALUES (
                        audit_id_seq.NEXTVAL,
                        :new.administrator_id,
                        SYSTIMESTAMP,
                        ''Update'',
                        ''' || p_table_name || ''',
                        :new.record_id,
                        ''{"action": "Update"}''
                    );
                END';

            -- Create a trigger to log deletes
            EXECUTE IMMEDIATE '
                CREATE OR REPLACE TRIGGER audit_logs_delete_trigger
                BEFORE DELETE ON ' || p_table_name || '
                FOR EACH ROW
                BEGIN
                    INSERT INTO audit_logs (
                        audit_id,
                        administrator_id,
                        timestamp,
                        action_type,
                        table_affected,
                        record_id,
                        details
                    ) VALUES (
                        audit_id_seq.NEXTVAL,
                        :old.administrator_id,
                        SYSTIMESTAMP,
                        ''Delete'',
                        ''' || p_table_name || ''',
                        :old.record_id,
                        ''{"action": "Delete"}''
                    );
                END';
        END setup_audit_triggers;
    PROCEDURE simulate_traffic_and_alerts AS
        BEGIN
            BEGIN
                EXECUTE IMMEDIATE 'CREATE SEQUENCE alerta_seq';
            EXCEPTION
                WHEN OTHERS THEN
                    NULL; -- Secvența deja existentă, ignorăm eroarea
            END;

            BEGIN
                EXECUTE IMMEDIATE 'CREATE TABLE trafic_interfete (
                    interfata_id INT PRIMARY KEY,
                    nume_interfata VARCHAR(50),
                    trafic_in_10G INT,
                    trafic_out_10G INT,
                    trafic_in_40G INT,
                    trafic_out_40G INT,
                    trafic_in_100G INT,
                    trafic_out_100G INT,
                    timestamp TIMESTAMP
                )';
            EXCEPTION
                WHEN OTHERS THEN
                    NULL; -- Tabela deja existentă, ignorăm eroarea
            END;

            BEGIN
                EXECUTE IMMEDIATE 'CREATE TABLE alerte_trafic (
                    alerta_id INT PRIMARY KEY,
                    interfata_id INT,
                    nume_interfata VARCHAR(50),
                    tip_alerta VARCHAR(50),
                    timestamp TIMESTAMP,
                    FOREIGN KEY (interfata_id) REFERENCES trafic_interfete(interfata_id)
                )';
            EXCEPTION
                WHEN OTHERS THEN
                    NULL; -- Tabela deja existentă, ignorăm eroarea
            END;

            FOR i IN 1..20 LOOP
                INSERT INTO trafic_interfete (
                    interfata_id,
                    nume_interfata,
                    trafic_in_10G,
                    trafic_out_10G,
                    trafic_in_40G,
                    trafic_out_40G,
                    trafic_in_100G,
                    trafic_out_100G,
                    timestamp
                )
                VALUES (
                    i,
                    'TenGigE 0/0/0/' || i,
                    ROUND(DBMS_RANDOM.VALUE(5000, 8000)),
                    ROUND(DBMS_RANDOM.VALUE(5000, 8000)),
                    0,
                    0,
                    0,
                    0,
                    SYSTIMESTAMP
                );
            END LOOP;

            -- Adaugăm două interfețe de 10G cu trafic 0 Mbps
            INSERT INTO trafic_interfete (
                interfata_id,
                nume_interfata,
                trafic_in_10G,
                trafic_out_10G,
                trafic_in_40G,
                trafic_out_40G,
                trafic_in_100G,
                trafic_out_100G,
                timestamp
            )
            VALUES (
                21,
                'TenGigE 0/0/0/21',
                0,
                0,
                0,
                0,
                0,
                0,
                SYSTIMESTAMP
            );

            INSERT INTO trafic_interfete (
                interfata_id,
                nume_interfata,
                trafic_in_10G,
                trafic_out_10G,
                trafic_in_40G,
                trafic_out_40G,
                trafic_in_100G,
                trafic_out_100G,
                timestamp
            )
            VALUES (
                22,
                'TenGigE 0/0/0/22',
                0,
                0,
                0,
                0,
                0,
                0,
                SYSTIMESTAMP
            );

            FOR i IN 23..26 LOOP
                INSERT INTO trafic_interfete (
                    interfata_id,
                    nume_interfata,
                    trafic_in_10G,
                    trafic_out_10G,
                    trafic_in_40G,
                    trafic_out_40G,
                    trafic_in_100G,
                    trafic_out_100G,
                    timestamp
                )
                VALUES (
                    i,
                    'FortyGigE 0/0/0/' || (i - 22),
                    0,
                    0,
                    ROUND(DBMS_RANDOM.VALUE(20000, 30000)),
                    ROUND(DBMS_RANDOM.VALUE(20000, 30000)),
                    0,
                    0,
                    SYSTIMESTAMP
                );
            END LOOP;

            FOR i IN 27..28 LOOP
                INSERT INTO trafic_interfete (
                    interfata_id,
                    nume_interfata,
                    trafic_in_10G,
                    trafic_out_10G,
                    trafic_in_40G,
                    trafic_out_40G,
                    trafic_in_100G,
                    trafic_out_100G,
                    timestamp
                )
                VALUES (
                    i,
                    'HundredGigE 0/0/0/' || (i - 26),
                    0,
                    0,
                    0,
                    0,
                    ROUND(DBMS_RANDOM.VALUE(60000, 70000)),
                    ROUND(DBMS_RANDOM.VALUE(60000, 70000)),
                    SYSTIMESTAMP
                );
            END LOOP;

            FOR c IN (SELECT * FROM trafic_interfete) LOOP
                DECLARE
                    v_interfata_id INT;
                    v_nume_interfata VARCHAR(50);
                    v_trafic_in INT;
                    v_trafic_out INT;
                    v_tip_alerta VARCHAR(50);
                BEGIN
                    v_interfata_id := c.interfata_id;
                    v_nume_interfata := c.nume_interfata;
                    v_trafic_in := GREATEST(c.trafic_in_10G, c.trafic_in_40G, c.trafic_in_100G);
                    v_trafic_out := GREATEST(c.trafic_out_10G, c.trafic_out_40G, c.trafic_out_100G);

                    IF v_trafic_in = 0 OR v_trafic_out = 0 THEN
                        v_tip_alerta := 'Trafic 0';
                        INSERT INTO alerte_trafic (
                            alerta_id,
                            interfata_id,
                            nume_interfata,
                            tip_alerta,
                            timestamp
                        )
                        VALUES (
                            alerta_seq.NEXTVAL,
                            v_interfata_id,
                            v_nume_interfata,
                            v_tip_alerta,
                            SYSTIMESTAMP
                        );

                        DBMS_OUTPUT.PUT_LINE('Alertă: Trafic 0 pe interfața ' || v_nume_interfata);
                    END IF;
                END;
            END LOOP;
        END simulate_traffic_and_alerts;
    PROCEDURE create_and_insert_network_logs AS
        BEGIN
            -- Create Table
            BEGIN
                EXECUTE IMMEDIATE 'CREATE TABLE network_logs (
                    log_id INT PRIMARY KEY,
                    device_id INT,
                    interface_id INT,
                    timestamp TIMESTAMP,
                    log_message VARCHAR2(255),
                    log_level VARCHAR2(10),
                    source_ip VARCHAR2(15)
                )';
            EXCEPTION
                WHEN OTHERS THEN
                    NULL; -- Table already exists, ignore the error
            END;

            -- Insert Sample Data
            FOR i IN 1..10 LOOP
                INSERT INTO network_logs (
                    log_id,
                    device_id,
                    interface_id,
                    timestamp,
                    log_message,
                    log_level,
                    source_ip
                )
                SELECT
                    ROWNUM + (i - 1) * 10, -- Generate unique log_id
                    TRUNC(DBMS_RANDOM.VALUE(1, 10)), -- device_id
                    TRUNC(DBMS_RANDOM.VALUE(1, 10)), -- interface_id
                    TO_TIMESTAMP('2023-01-01 08:05:00', 'YYYY-MM-DD HH24:MI:SS') + DBMS_RANDOM.VALUE(1, 365), -- timestamp
                    'Log Message ' || ROWNUM + (i - 1) * 10,
                    CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN 'Info' ELSE 'Error' END,
                    '192.168.' || TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1, 255))) || '.' || TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1, 255))) -- source_ip
                FROM DUAL
                CONNECT BY LEVEL <= 10;
            END LOOP;
            COMMIT; -- Commit the changes
        END create_and_insert_network_logs;
    PROCEDURE create_foreign_keys AS
        BEGIN
            -- Create foreign key between network_interfaces and network_devices
            EXECUTE IMMEDIATE '
                ALTER TABLE network_interfaces
                ADD CONSTRAINT fk_device_id
                FOREIGN KEY (device_id)
                REFERENCES network_devices(device_id)
                ON DELETE CASCADE
            ';

            -- Create foreign key between network_logs and network_devices
            EXECUTE IMMEDIATE '
                ALTER TABLE network_logs
                ADD CONSTRAINT fk_device_id_logs
                FOREIGN KEY (device_id)
                REFERENCES network_devices(device_id)
                ON DELETE CASCADE
            ';

            -- Create foreign key between network_logs and network_interfaces
            EXECUTE IMMEDIATE '
                ALTER TABLE network_logs
                ADD CONSTRAINT fk_interface_id
                FOREIGN KEY (interface_id)
                REFERENCES network_interfaces(interface_id)
                ON DELETE CASCADE
            ';

            -- Create foreign key between alerte_trafic and trafic_interfete
            EXECUTE IMMEDIATE '
                ALTER TABLE alerte_trafic
                ADD CONSTRAINT fk_interfata_id
                FOREIGN KEY (interfata_id)
                REFERENCES trafic_interfete(interfata_id)
                ON DELETE CASCADE
            ';

            -- Additional foreign keys can be added for other tables as needed.
            -- For example, you can extend the procedure to add foreign keys for network_logs, network_logs, etc.
        END create_foreign_keys;
END network_management;
/