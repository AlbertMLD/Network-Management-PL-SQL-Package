CREATE OR REPLACE PACKAGE network_management AS
    PROCEDURE create_tables_procedure;
    PROCEDURE insert_network_devices;
    PROCEDURE add_device(
        p_administrator_id INT,
        p_device_id INT,
        p_device_name VARCHAR2,
        p_device_ip_address VARCHAR2,
        p_device_type VARCHAR2,
        p_location VARCHAR2,
        p_manufacturer VARCHAR2,
        p_firmware_version VARCHAR2,
        p_status VARCHAR2,
        p_last_seen TIMESTAMP
    );
    PROCEDURE insert_network_interfaces;
    PROCEDURE delete_device(p_device_id INT);
    PROCEDURE setup_audit_triggers(p_table_name VARCHAR2);
    PROCEDURE simulate_traffic_and_alerts;
    PROCEDURE insert_network_logs;
END network_management;
/

CREATE OR REPLACE PROCEDURE create_tables_procedure AS
BEGIN
    BEGIN
        -- Create Table network_devices
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
            DBMS_OUTPUT.PUT_LINE('Error creating network_devices: ' || SQLERRM);
    END;

    BEGIN
        -- Create Table network_interfaces
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
            DBMS_OUTPUT.PUT_LINE('Error creating network_interfaces: ' || SQLERRM);
    END;

    BEGIN
        -- Create Table network_logs
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
            DBMS_OUTPUT.PUT_LINE('Error creating network_logs: ' || SQLERRM);
    END;

    BEGIN
        -- Create Table audit_logs
        EXECUTE IMMEDIATE 'CREATE TABLE audit_logs (
            audit_id INT PRIMARY KEY,
            administrator_id INT,
            timestamp TIMESTAMP,
            action_type VARCHAR2(10),
            table_affected VARCHAR2(50),
            record_id INT,
            details VARCHAR2(4000)
        )';
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error creating audit_logs: ' || SQLERRM);
    END;

    BEGIN
        -- Create Table trafic_interfete
        EXECUTE IMMEDIATE 'CREATE TABLE trafic_interfete (
            interfata_id INT PRIMARY KEY,
            nume_interfata VARCHAR2(50),
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
            DBMS_OUTPUT.PUT_LINE('Error creating trafic_interfete: ' || SQLERRM);
    END;

    BEGIN
        -- Create Table alerte_trafic
        EXECUTE IMMEDIATE 'CREATE TABLE alerte_trafic (
            alerta_id INT PRIMARY KEY,
            interfata_id INT,
            nume_interfata VARCHAR2(50),
            tip_alerta VARCHAR2(50),
            timestamp TIMESTAMP,
            FOREIGN KEY (interfata_id) REFERENCES trafic_interfete(interfata_id)
        )';
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error creating alerte_trafic: ' || SQLERRM);
    END;

    COMMIT; -- Commit the changes
END create_tables_procedure;
/

EXEC create_tables_procedure;

ALTER TABLE network_devices ADD (administrator_id INT);
ALTER TABLE network_interfaces ADD (administrator_id INT);
ALTER TABLE network_logs ADD (administrator_id INT);
ALTER TABLE trafic_interfete ADD (administrator_id INT);
ALTER TABLE alerte_trafic ADD (administrator_id INT);

CREATE SEQUENCE alerta_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE audit_id_seq START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE PACKAGE BODY network_management AS
    PROCEDURE create_tables_procedure AS
		BEGIN
    		network_management.create_tables_procedure;
		END create_tables_procedure;
    
    PROCEDURE insert_network_devices IS
    BEGIN
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
            VALUES (
                i,
                'Device' || i,
                '192.168.' || TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1, 255))) || '.' || TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1, 255))),
                CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN 'Router' ELSE 'Switch' END,
                CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN 'Server Room' ELSE 'Network Closet' END,
                'Manufacturer' || i,
                SUBSTR('v' || TO_CHAR(DBMS_RANDOM.VALUE(1, 10)), 1, 10),
                CASE WHEN DBMS_RANDOM.VALUE < 0.8 THEN 'Active' ELSE 'Inactive' END,
                TO_TIMESTAMP('2023-01-01 09:12', 'YYYY-MM-DD HH24:MI') - DBMS_RANDOM.VALUE(1, 365)
            );
        END LOOP;
        COMMIT;
    END insert_network_devices;

PROCEDURE add_device(
    p_administrator_id INT,
    p_device_id INT,
    p_device_name VARCHAR2,
    p_device_ip_address VARCHAR2,
    p_device_type VARCHAR2,
    p_location VARCHAR2,
    p_manufacturer VARCHAR2,
    p_firmware_version VARCHAR2,
    p_status VARCHAR2,
    p_last_seen TIMESTAMP
) AS 
BEGIN
    BEGIN
        EXECUTE IMMEDIATE '
            INSERT INTO network_devices VALUES (:1, :2, :3, :4, :5, :6, :7, :8, :9, :10)
        ' USING p_device_id,
            SUBSTR(p_device_name, 1, 50),
            SUBSTR(p_device_ip_address, 1, 15),
            SUBSTR(p_device_type, 1, 20),
            SUBSTR(p_location, 1, 50),
            SUBSTR(p_manufacturer, 1, 50),
            SUBSTR(p_firmware_version, 1, 10),
            SUBSTR(p_status, 1, 10),
            p_last_seen,
            p_administrator_id;
    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            DBMS_OUTPUT.PUT_LINE('Error: Duplicate device_id ' || p_device_id);
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
            -- Handle other specific exceptions if needed
    END;
END add_device;

    PROCEDURE insert_network_interfaces IS
    BEGIN
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
    END insert_network_interfaces;

    PROCEDURE delete_device(p_device_id INT) IS
    BEGIN
        EXECUTE IMMEDIATE 'DELETE FROM network_devices WHERE device_id = :1' USING p_device_id;
    END delete_device;

    PROCEDURE setup_audit_triggers(p_table_name VARCHAR2) IS
    BEGIN
    -- Create sequence if not exists
        BEGIN
            EXECUTE IMMEDIATE 'CREATE SEQUENCE audit_id_seq START WITH 1 INCREMENT BY 1';
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Sequence already exists, ignore the error
        END;

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
                :admin_id,
                SYSTIMESTAMP,
                ''Insert'',
                ''' || p_table_name || ''',
                :rec_id,
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

    PROCEDURE simulate_traffic_and_alerts IS
    BEGIN
        -- Create sequence if not exists
        BEGIN
            EXECUTE IMMEDIATE 'CREATE SEQUENCE alerta_seq START WITH 1 INCREMENT BY 1';
        EXCEPTION
            WHEN OTHERS THEN
                NULL; -- Sequence already exists, ignore the error
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
                alerta_seq.NEXTVAL,
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

        -- Add two 10G interfaces with 0 Mbps traffic
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
                v_trafic_in := GREATEST(c.trafic_in_10G, GREATEST(c.trafic_in_40G, c.trafic_in_100G));
                v_trafic_out := GREATEST(c.trafic_out_10G, GREATEST(c.trafic_out_40G, c.trafic_out_100G));

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

    PROCEDURE insert_network_logs IS
    BEGIN
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
                SYSTIMESTAMP - DBMS_RANDOM.VALUE(1, 365), -- timestamp
                'Log Message ' || ROWNUM, -- log_message
                CASE
                    WHEN DBMS_RANDOM.VALUE < 0.3 THEN 'ERROR'
                    WHEN DBMS_RANDOM.VALUE < 0.7 THEN 'WARNING'
                    ELSE 'INFO'
                END, -- log_level
                '192.168.' || TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1, 255))) || '.' || TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1, 255))) -- source_ip
            FROM DUAL
            CONNECT BY LEVEL <= 10;
        END LOOP;
    END insert_network_logs;
END network_management;
/

-- Create Tables Procedure
EXEC create_tables_procedure;

-- Insert sample data into network_devices table
EXEC network_management.insert_network_devices;

-- Insert sample data into network_interfaces table
EXEC network_management.insert_network_interfaces;

-- Delete the sample device added earlier
EXEC network_management.delete_device(p_device_id => 11);

-- Simulate traffic and generate alerts
EXEC network_management.simulate_traffic_and_alerts;

-- Insert sample data into network_logs table
EXEC network_management.insert_network_logs;

-- Display table structures
DESC network_devices;
DESC network_interfaces;
DESC network_logs;
DESC trafic_interfete;
DESC alerte_trafic;
DESC audit_logs;

-- Display sample data
SELECT * FROM network_devices;
SELECT * FROM network_interfaces;
SELECT * FROM network_logs;
SELECT * FROM trafic_interfete;
SELECT * FROM alerte_trafic;

-- Anonymous PL/SQL block to call the procedure
BEGIN
    network_management.add_device(
        p_administrator_id => 1, -- Replace with the actual administrator_id
        p_device_id => 101,
        p_device_name => 'New Device',
        p_device_ip_address => '192.168.100.100',
        p_device_type => 'Router',
        p_location => 'Data Center',
        p_manufacturer => 'New Manufacturer',
        p_firmware_version => 'v1.0',
        p_status => 'Active',
        p_last_seen => TO_TIMESTAMP(SYSTIMESTAMP)
    );
END;
/
    
SELECT * FROM USER_TRIGGERS WHERE TABLE_NAME = 'NETWORK_DEVICES';
SELECT * FROM USER_ERRORS WHERE NAME = 'AUDIT_LOGS_INSERT_TRIGGER';
SELECT * FROM audit_logs;

--20 logic and complex queries that you can use to demonstrate that the code is working:

--List all active devices in the "Server Room" location:
SELECT * FROM network_devices WHERE status = 'Active' AND location = 'Server Room';

--Find devices with the highest firmware version:
SELECT * FROM network_devices WHERE firmware_version = (SELECT MAX(firmware_version) FROM network_devices);

--List devices with their total traffic across all interfaces:
SELECT
    d.device_id, 
    d.device_name, 
    d.device_ip_address, 
    d.device_type, 
    d.location, 
    d.manufacturer, 
    d.firmware_version, 
    d.status, 
    d.last_seen,
    SUM(t.trafic_in_10G + t.trafic_out_10G + t.trafic_in_40G + t.trafic_out_40G + t.trafic_in_100G + t.trafic_out_100G) AS total_traffic
FROM
    network_devices d
LEFT JOIN
    trafic_interfete t ON d.device_id = t.interfata_id
GROUP BY
    d.device_id, 
    d.device_name, 
    d.device_ip_address, 
    d.device_type, 
    d.location, 
    d.manufacturer, 
    d.firmware_version, 
    d.status, 
    d.last_seen
ORDER BY
    total_traffic DESC;

--Show devices that have not been seen in the last 30 days:
SELECT * FROM network_devices WHERE last_seen < SYSTIMESTAMP - INTERVAL '30' DAY;

--Display interfaces with a speed greater than 5000 Mbps:
SELECT * FROM network_interfaces WHERE speed_mbps > 5000;

--List devices and their logs with the highest log level:
SELECT d.*, l.*
FROM network_devices d
JOIN network_logs l ON d.device_id = l.device_id
WHERE l.log_level = (SELECT MAX(log_level) FROM network_logs);

--Retrieve devices with no associated logs:
SELECT * FROM network_devices WHERE device_id NOT IN (SELECT DISTINCT device_id FROM network_logs);

--Display the latest log for each device:
SELECT d.*, l.*
FROM network_devices d
JOIN network_logs l ON d.device_id = l.device_id
WHERE (l.device_id, l.timestamp) IN (
    SELECT device_id, MAX(timestamp)
    FROM network_logs
    GROUP BY device_id
);

--Find devices and their logs with a specific source IP:
SELECT d.*, l.*
FROM network_devices d
JOIN network_logs l ON d.device_id = l.device_id
WHERE l.source_ip = '192.168.54.205';

--Show devices and their total traffic (in + out) for the last 7 days:
SELECT
    d.device_id,
    d.device_name,
    d.device_ip_address,
    d.device_type,
    d.location,
    d.manufacturer,
    d.firmware_version,
    d.status,
    d.last_seen,
    SUM(t.trafic_in_10G + t.trafic_out_10G + t.trafic_in_40G + t.trafic_out_40G + t.trafic_in_100G + t.trafic_out_100G) AS total_traffic
FROM
    network_devices d
JOIN
    trafic_interfete t ON d.device_id = t.interfata_id
WHERE
    t.timestamp >= SYSTIMESTAMP - INTERVAL '7' DAY
GROUP BY
    d.device_id,
    d.device_name,
    d.device_ip_address,
    d.device_type,
    d.location,
    d.manufacturer,
    d.firmware_version,
    d.status,
    d.last_seen
ORDER BY
    total_traffic DESC;

--Find interfaces with the highest traffic in the last hour:
SELECT t.*, d.device_name, d.location
FROM trafic_interfete t
JOIN network_devices d ON t.interfata_id = d.device_id
WHERE t.timestamp >= SYSTIMESTAMP - INTERVAL '1' HOUR
ORDER BY GREATEST(t.trafic_in_10G, t.trafic_out_10G, t.trafic_in_40G, t.trafic_out_40G, t.trafic_in_100G, t.trafic_out_100G) DESC;

--Display devices and their logs with details containing "Error":
SELECT d.*, l.*
FROM network_devices d
JOIN network_logs l ON d.device_id = l.device_id
WHERE l.log_message LIKE '%1%';

--Show devices with no associated logs in the last 30 days:
SELECT * FROM network_devices d
WHERE NOT EXISTS (
    SELECT 1
    FROM network_logs l
    WHERE l.device_id = d.device_id
    AND l.timestamp >= SYSTIMESTAMP - INTERVAL '30' DAY
);

--Retrieve interfaces with their alerts:
SELECT a.*, t.nume_interfata
FROM alerte_trafic a
JOIN trafic_interfete t ON a.interfata_id = t.interfata_id;

--Show devices and their administrators:
SELECT d.*, a.administrator_id
FROM network_devices d
LEFT JOIN alerte_trafic a ON d.device_id = a.interfata_id;

--Display interfaces with the highest speed for each device:
SELECT device_id, MAX(speed_mbps) AS max_speed
FROM network_interfaces
GROUP BY device_id;

--List interfaces with traffic in the last hour, ordered by the highest traffic:
SELECT t.*, d.device_name
FROM trafic_interfete t
JOIN network_devices d ON t.interfata_id = d.device_id
WHERE t.timestamp >= SYSTIMESTAMP - INTERVAL '1' HOUR
ORDER BY GREATEST(t.trafic_in_10G, t.trafic_out_10G, t.trafic_in_40G, t.trafic_out_40G, t.trafic_in_100G, t.trafic_out_100G) DESC;

--Find devices with firmware version starting with 'v1':
SELECT *
FROM network_devices
WHERE firmware_version LIKE 'v1%';

--Retrieve interfaces with the highest percentage of traffic increase from the previous hour:
SELECT
    t.*,
    CASE
        WHEN prev.prev_traffic = 0 THEN NULL
        ELSE ROUND(((t.trafic_in_10G + t.trafic_out_10G + t.trafic_in_40G + t.trafic_out_40G + t.trafic_in_100G + t.trafic_out_100G) - prev.prev_traffic) / prev.prev_traffic * 100, 2)
    END AS traffic_increase_percentage
FROM
    trafic_interfete t
JOIN (
    SELECT
        interfata_id,
        MAX(timestamp) AS prev_timestamp,
        SUM(trafic_in_10G + trafic_out_10G + trafic_in_40G + trafic_out_40G + trafic_in_100G + trafic_out_100G) AS prev_traffic
    FROM
        trafic_interfete
    WHERE
        timestamp >= SYSTIMESTAMP - INTERVAL '1' HOUR
    GROUP BY
        interfata_id
) prev ON t.interfata_id = prev.interfata_id AND t.timestamp = prev.prev_timestamp;
