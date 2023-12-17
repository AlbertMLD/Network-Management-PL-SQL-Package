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
    );
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

-- Inserarea datelor în tabela network_interfaces
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
    PROCEDURE create_foreign_key_constraints;

    -- Additional procedures for network_interfaces, network_logs, bandwidth_data, network_security_events, network_device_configurations
    PROCEDURE add_interface(
        p_interface_id INT,
        p_device_id INT,
        p_interface_name VARCHAR2,
        p_interface_type VARCHAR2,
        p_speed_mbps INT,
        p_mac_address VARCHAR2
    );
    PROCEDURE add_log(
        p_log_id INT,
        p_device_id INT,
        p_interface_id INT,
        p_timestamp TIMESTAMP,
        p_log_message VARCHAR2,
        p_log_level VARCHAR2,
        p_source_ip VARCHAR2
    );
    PROCEDURE add_bandwidth_data(
        p_bandwidth_id INT,
        p_interface_id INT,
        p_timestamp TIMESTAMP,
        p_incoming_bandwidth INT,
        p_outgoing_bandwidth INT
    );
    PROCEDURE add_security_event(
        p_event_id INT,
        p_device_id INT,
        p_interface_id INT,
        p_timestamp TIMESTAMP,
        p_event_type VARCHAR2,
        p_description VARCHAR2,
        p_status VARCHAR2,
        p_resolved_at TIMESTAMP,
        p_threat_level INT,
        p_source_ip VARCHAR2,
        p_destination_ip VARCHAR2
    );
    PROCEDURE add_device_configuration(
        p_configuration_id INT,
        p_device_id INT,
        p_timestamp TIMESTAMP,
        p_administrator_id INT,
        p_configuration_changes VARCHAR2
    );
END network_management;
/

CREATE OR REPLACE PACKAGE BODY network_management AS
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
                NULL; -- Table already exists, ignore the error
        END;
    END;

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
        USING p_device_id, p_device_name, p_device_ip_address, p_device_type,
              p_location, p_manufacturer, p_firmware_version, p_status, p_last_seen;
    END;

    PROCEDURE delete_device(p_device_id INT) AS
    BEGIN
        EXECUTE IMMEDIATE 'DELETE FROM network_devices WHERE device_id = :1' USING p_device_id;
    END;

    PROCEDURE insert_data AS
    BEGIN
        -- Add data insertion logic
    END;

    PROCEDURE simulate_traffic_and_alerts AS
    BEGIN
        -- Add traffic simulation logic
    END;

    PROCEDURE create_foreign_key_constraints AS
    BEGIN
        -- Add foreign key constraints
    END;

    -- Additional procedures for network_interfaces, network_logs, bandwidth_data, network_security_events, network_device_configurations
    PROCEDURE add_interface(
        p_interface_id INT,
        p_device_id INT,
        p_interface_name VARCHAR2(50),
        p_interface_type VARCHAR2(20),
        p_speed_mbps INT,
        p_mac_address VARCHAR2(12)
    ) AS
    BEGIN
        -- Add logic for inserting data into network_interfaces table
    END;

    PROCEDURE add_log(
        p_log_id INT,
        p_device_id INT,
        p_interface_id INT,
        p_timestamp TIMESTAMP,
        p_log_message VARCHAR2(255),
        p_log_level VARCHAR2(10),
        p_source_ip VARCHAR2(15)
    ) AS
    BEGIN
        -- Add logic for inserting data into network_logs table
    END;

    PROCEDURE add_bandwidth_data(
        p_bandwidth_id INT,
        p_interface_id INT,
        p_timestamp TIMESTAMP,
        p_incoming_bandwidth INT,
        p_outgoing_bandwidth INT
    ) AS
    BEGIN
        -- Add logic for inserting data into bandwidth_data table
    END;

    PROCEDURE add_security_event(
        p_event_id INT,
        p_device_id INT,
        p_interface_id INT,
        p_timestamp TIMESTAMP,
        p_event_type VARCHAR2(50),
        p_description VARCHAR2(255),
        p_status VARCHAR2(10),
        p_resolved_at TIMESTAMP,
        p_threat_level INT,
        p_source_ip VARCHAR2(15),
        p_destination_ip VARCHAR2(15)
    ) AS
    BEGIN
        -- Add logic for inserting data into network_security_events table
    END;

    PROCEDURE add_device_configuration(
        p_configuration_id INT,
        p_device_id INT,
        p_timestamp TIMESTAMP,
        p_administrator_id INT,
        p_configuration_changes VARCHAR2(4000)
    ) AS
    BEGIN
        -- Add logic for inserting data into network_device_configurations table
    END;
END network_management;
/