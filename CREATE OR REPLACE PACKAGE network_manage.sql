CREATE OR REPLACE PACKAGE network_management AS
    PROCEDURE create_network_devices_table AS
        BEGIN
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
                    NULL; -- Tabela deja existentă, ignorăm eroarea
            END;
        END;
    CREATE OR REPLACE PROCEDURE add_device(
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
        /
    CREATE OR REPLACE PROCEDURE create_and_insert_network_interfaces AS
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
        /
    PROCEDURE delete_device(p_device_id INT) AS
    	BEGIN
       		EXECUTE IMMEDIATE 'DELETE FROM network_devices WHERE device_id = :1' USING p_device_id;
   	 	END;
    PROCEDURE insert_data AS
        BEGIN
        -- Adăugarea datelor aleatorii în pachetul network_management

        -- Inserarea datelor în tabela network_devices
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

        -- Inserarea datelor în tabela network_logs
            INSERT INTO network_logs (log_id, device_id, interface_id, timestamp, log_message, log_level, source_ip)
            SELECT
                LEVEL,
                TRUNC(DBMS_RANDOM.VALUE(1, 10)), -- device_id
                TRUNC(DBMS_RANDOM.VALUE(1, 10)), -- interface_id
                TO_TIMESTAMP('2023-01-01 08:05:00', 'YYYY-MM-DD HH24:MI:SS') + DBMS_RANDOM.VALUE(1, 365), -- timestamp
                'Log Message ' || LEVEL,
                CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN 'Info' ELSE 'Error' END,
                '192.168.' || TO_CHAR(DBMS_RANDOM.VALUE(1, 255)) || '.' || TO_CHAR(DBMS_RANDOM.VALUE(1, 255)) -- source_ip
            FROM DUAL
            CONNECT BY LEVEL <= 10;

        -- Inserarea datelor în tabela bandwidth_data
            INSERT INTO bandwidth_data (bandwidth_id, interface_id, timestamp, incoming_bandwidth, outgoing_bandwidth)
            SELECT
                LEVEL,
                TRUNC(DBMS_RANDOM.VALUE(1, 10)), -- interface_id
                TO_TIMESTAMP('2023-01-01 08:10:00', 'YYYY-MM-DD HH24:MI:SS') + DBMS_RANDOM.VALUE(1, 365), -- timestamp
                TO_NUMBER(DBMS_RANDOM.VALUE(1, 10000)), -- incoming_bandwidth
                TO_NUMBER(DBMS_RANDOM.VALUE(1, 10000)) -- outgoing_bandwidth
            FROM DUAL
            CONNECT BY LEVEL <= 10;

        -- Inserarea datelor în tabela network_security_events
            INSERT INTO network_security_events (event_id, device_id, interface_id, timestamp, event_type, description, status, resolved_at, threat_level, source_ip, destination_ip)
            SELECT
                LEVEL,
                TRUNC(DBMS_RANDOM.VALUE(1, 10)), -- device_id
                TRUNC(DBMS_RANDOM.VALUE(1, 10)), -- interface_id
                TO_TIMESTAMP('2023-01-01 08:20:00', 'YYYY-MM-DD HH24:MI:SS') + DBMS_RANDOM.VALUE(1, 365), -- timestamp
                'Event Type ' || LEVEL,
                'Description ' || LEVEL,
                CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN 'Open' ELSE 'Closed' END,
                CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN TO_TIMESTAMP('2023-01-01 08:22:00', 'YYYY-MM-DD HH24:MI:SS') + DBMS_RANDOM.VALUE(1, 365) ELSE NULL END,
                TRUNC(DBMS_RANDOM.VALUE(1, 5)), -- threat_level
                '192.168.' || TO_CHAR(DBMS_RANDOM.VALUE(1, 255)) || '.' || TO_CHAR(DBMS_RANDOM.VALUE(1, 255)), -- source_ip
                '192.168.' || TO_CHAR(DBMS_RANDOM.VALUE(1, 255)) || '.' || TO_CHAR(DBMS_RANDOM.VALUE(1, 255)) -- destination_ip
            FROM DUAL
            CONNECT BY LEVEL <= 10;

        -- Inserarea datelor în tabela network_device_configurations
            INSERT INTO network_device_configurations (configuration_id, device_id, timestamp, administrator_id, configuration_changes)
            SELECT
                LEVEL,
                TRUNC(DBMS_RANDOM.VALUE(1, 10)), -- device_id
                TO_TIMESTAMP('2023-01-01 09:40:00', 'YYYY-MM-DD HH24:MI:SS') + DBMS_RANDOM.VALUE(1, 365), -- timestamp
                TRUNC(DBMS_RANDOM.VALUE(1, 5)), -- administrator_id
                '{"setting1": "value' || LEVEL || '", "setting2": "value' || LEVEL || '"}' -- configuration_changes
            FROM DUAL
            CONNECT BY LEVEL <= 10;

        -- Inserarea datelor în tabela audit_logs
            INSERT INTO audit_logs (audit_id, administrator_id, timestamp, action_type, table_affected, record_id, details)
            SELECT
                LEVEL,
                TRUNC(DBMS_RANDOM.VALUE(1, 5)), -- administrator_id
                TO_TIMESTAMP('2023-01-01 08:15:00', 'YYYY-MM-DD HH24:MI:SS') + DBMS_RANDOM.VALUE(1, 365), -- timestamp
                CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN 'Create' ELSE 'Update' END,
                CASE WHEN DBMS_RANDOM.VALUE < 0.5 THEN 'network_devices' ELSE 'network_interfaces' END,
                TRUNC(DBMS_RANDOM.VALUE(1, 10)), -- record_id
                '{"detail1": "value' || LEVEL || '", "detail2": "value' || LEVEL || '"}' -- details
            FROM DUAL
            CONNECT BY LEVEL <= 10;
    PROCEDURE simulate_traffic_and_alerts;
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
        END;
    PROCEDURE create_foreign_key_constraints AS
        BEGIN
        -- Adding Foreign Key Constraints
            EXECUTE IMMEDIATE 'ALTER TABLE network_interfaces
                ADD CONSTRAINT fk_network_interfaces_device
                FOREIGN KEY (device_id) REFERENCES network_devices(device_id)';

            EXECUTE IMMEDIATE 'ALTER TABLE network_logs
                ADD CONSTRAINT fk_network_logs_device
                FOREIGN KEY (device_id) REFERENCES network_devices(device_id)';

            EXECUTE IMMEDIATE 'ALTER TABLE network_logs
                ADD CONSTRAINT fk_network_logs_interface
                FOREIGN KEY (interface_id) REFERENCES network_interfaces(interface_id)';

            EXECUTE IMMEDIATE 'ALTER TABLE bandwidth_data
                ADD CONSTRAINT fk_bandwidth_data_interface
                FOREIGN KEY (interface_id) REFERENCES network_interfaces(interface_id)';

            EXECUTE IMMEDIATE 'ALTER TABLE network_security_events
                ADD CONSTRAINT fk_network_security_events_device
                FOREIGN KEY (device_id) REFERENCES network_devices(device_id)';

            EXECUTE IMMEDIATE 'ALTER TABLE network_security_events
                ADD CONSTRAINT fk_network_security_events_interface
                FOREIGN KEY (interface_id) REFERENCES network_interfaces(interface_id)';

            EXECUTE IMMEDIATE 'ALTER TABLE network_device_configurations
                ADD CONSTRAINT fk_network_device_configurations_device
                FOREIGN KEY (device_id) REFERENCES network_devices(device_id)';
        END;
END network_management;
/