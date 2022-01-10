function output = crypting(input, direction, isdate)


secretKey = "DTm9ai3fjtMI87vg297ChS";
algorithm = "SHA-256";
aes = AES(secretKey, algorithm);

if direction == 1
    if isdate
        input = char(input);
    end
    output = aes.encrypt(input);
else
    output = aes.decrypt(input);
    if isdate
        output = datetime(output);
    end
end
