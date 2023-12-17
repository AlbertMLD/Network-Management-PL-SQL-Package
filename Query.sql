--Create and Insert Network Devices:
EXEC network_management.create_and_insert_network_devices;

--Add a New Device:
EXEC network_management.add_device(11, 'NewDevice', '192.168.1.1', 'Router', 'Server Room', 'NewManufacturer', 'v1.0', 'Active', TO_TIMESTAMP('2023-01-01 09:30', 'YYYY-MM-DD HH24:MI'));

--Create and Insert Network Interfaces:
EXEC network_management.create_and_insert_network_interfaces;

--Delete Device by ID:
EXEC network_management.delete_device(1);

--Setup Audit Triggers for Network Devices:
EXEC network_management.setup_audit_triggers('network_devices');

--Simulate Traffic and Alerts:
EXEC network_management.simulate_traffic_and_alerts;

--Create and Insert Network Logs:
EXEC network_management.create_and_insert_network_logs;

--Create Foreign Keys:
EXEC network_management.create_foreign_keys;

--Setup Audit Triggers for Network Interfaces:
EXEC network_management.setup_audit_triggers('network_interfaces');

--Delete Device by ID (for Audit Testing):
EXEC network_management.delete_device(2);

--Simulate Additional Traffic and Alerts:
EXEC network_management.simulate_traffic_and_alerts;

--Create and Insert More Network Logs:
EXEC network_management.create_and_insert_network_logs;

--Setup Audit Triggers for Network Logs:
EXEC network_management.setup_audit_triggers('network_logs');

--Delete Device by ID (for More Audit Testing):
EXEC network_management.delete_device(3);

--Simulate Traffic and Alerts Again:
EXEC network_management.simulate_traffic_and_alerts;

--Create and Insert Even More Network Logs:
EXEC network_management.create_and_insert_network_logs;

--Setup Audit Triggers for Alert Traffic:
EXEC network_management.setup_audit_triggers('alerte_trafic');

--Delete Device by ID (for Further Audit Testing):
EXEC network_management.delete_device(4);

--Create and Insert Final Network Logs:
EXEC network_management.create_and_insert_network_logs;

--Setup Audit Triggers for Final Audit Testing:
EXEC network_management.setup_audit_triggers('network_logs');
