<?php
    include 'conn.php';

    $id = $_POST['id'];
    $nama = $_POST['nama'];
    $detil = $_POST['detil'];
    $harga = $_POST['harga'];
    $hai2 = $_POST['url'];
    $stok = $_POST['stok'];

    $connect->query("INSERT INTO menu (id, nama, detil, harga, url, stock) VALUES ('".$id."','".$nama."','".$detil."','".$harga."', '".$hai2."', '".$stok."')");
?>