CREATE OR REPLACE PACKAGE network_management AS
    PROCEDURE create_tables_procedure;
END network_management;
/

CREATE OR REPLACE PACKAGE BODY network_management AS
    PROCEDURE create_tables_procedure AS
        BEGIN
            -- Create Table network_devices
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
            END;

            -- Create Table network_interfaces
            BEGIN
                EXECUTE IMMEDIATE 'CREATE TABLE network_interfaces (
                    interface_id INT PRIMARY KEY,
                    device_id INT,
                    interface_name VARCHAR2(50),
                    interface_type VARCHAR2(20),
                    speed_mbps INT,
                    mac_address VARCHAR2(12)
                )';
            END;

            -- Create Table network_logs
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
            END;

            -- Create Table audit_logs
            BEGIN
                EXECUTE IMMEDIATE 'CREATE TABLE audit_logs (
                    audit_id INT PRIMARY KEY,
                    administrator_id INT,
                    timestamp TIMESTAMP,
                    action_type VARCHAR2(10),
                    table_affected VARCHAR2(50),
                    record_id INT,
                    details VARCHAR2(4000)
                )';
            END;

            -- Create Table trafic_interfete
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
            END;

            -- Create Table alerte_trafic
            BEGIN
                EXECUTE IMMEDIATE 'CREATE TABLE alerte_trafic (
                    alerta_id INT PRIMARY KEY,
                    interfata_id INT,
                    nume_interfata VARCHAR(50),
                    tip_alerta VARCHAR(50),
                    timestamp TIMESTAMP,
                    FOREIGN KEY (interfata_id) REFERENCES trafic_interfete(interfata_id)
                )';
            END;

            COMMIT; -- Commit the changes
        END create_tables_procedure;
END network_management;
/
