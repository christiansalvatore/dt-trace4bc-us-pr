function mac_ok = checkmac_code(mac_value)

        [~,result] = dos('wmic csproduct get UUID');
        mac = result(41:end-6);
        mac_ok1 = strcmp(mac_value,mac);
        mac_ok = max(mac_ok1);

end