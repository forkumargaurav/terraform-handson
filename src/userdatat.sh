#!/bin/bash
sudo apt update
sudo apt install -y apache2


cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hello, World!</title>
</head>
<body>

    <h1>Hello, World!</h1>
    <p>This is a simple "Hello, World!" webpage.</p>

</body>
</html>
EOF


systemctl start apache2
systemctl enable apache2

