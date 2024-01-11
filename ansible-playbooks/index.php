<!DOCTYPE html>
<html>
<head>
<style>
table, th, td {
  border:1px solid black;
}
</style>
<title>PostgreSQL Data Display</title>
</head>
<body>
<h1>Data from PostgreSQL</h1>
<?php
    $host = "host=localhost";
    $port = "port=5432";
    $dbname = "dbname=appuser";
    $credentials = "user=appuser password=app";
 
    $db = pg_connect("$host $port $dbname $credentials");
    if(!$db) {
        echo "Error : Unable to open database\n";
    } else {
        echo "Opened database successfully\n";
 
    }
 
    $result = pg_query($db, "SELECT * FROM public.users");
    if (!$result) {
        echo "An error occurred.\n";
        exit;
    } ?>
    <table>
        <tr><th>Username</th><th>Email</th></tr>
    <?php while ($row = pg_fetch_assoc($result)) {  ?>
        <tr><td><?php echo $row['username']; ?></td><td><?php echo $row['email']; ?></td></tr>
 <?php
    }
 
    pg_close($db);
    ?>
    </table>
 
</body>
</html>
