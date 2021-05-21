<?php
    include 'conn.php';

    $nama = $_POST['nama'];
    $alamat = $_POST['alamat'];
    $detil = $_POST['detil'];
    $total = $_POST['total'];

    $connect->query("INSERT INTO orderonline (nama, alamat, detil, total) VALUES ('".$nama."','".$alamat."','".$detil."','".$total."');");
?>