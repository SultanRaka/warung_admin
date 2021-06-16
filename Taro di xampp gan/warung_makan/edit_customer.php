<?php
    include 'conn.php';

    $id = $_POST['id'];
    $stok = $_POST['stok'];

    $connect->query("UPDATE menu SET stock = '".$stok."' WHERE id = '".$id."'");
?>