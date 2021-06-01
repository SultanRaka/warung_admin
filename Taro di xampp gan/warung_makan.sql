-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 01, 2021 at 06:03 PM
-- Server version: 10.4.14-MariaDB
-- PHP Version: 7.4.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `warung_makan`
--

-- --------------------------------------------------------

--
-- Table structure for table `menu`
--

CREATE TABLE `menu` (
  `id` varchar(6) NOT NULL,
  `nama` varchar(50) DEFAULT NULL,
  `detil` varchar(50) DEFAULT NULL,
  `harga` int(11) DEFAULT NULL,
  `url` varchar(64) NOT NULL,
  `stock` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `menu`
--

INSERT INTO `menu` (`id`, `nama`, `detil`, `harga`, `url`, `stock`) VALUES
('BVG001', 'Air Mineral', 'k e s e g a r a n', 5000, 'img/air.png', 100),
('BVG002', 'Coca Cola', 'minuman berdosa, eh, bersoda', 7000, 'img/cola.jpg', 100),
('BVG003', 'Kopi', 'ngopi dulu bossq', 7000, 'img/kopi.png', 100),
('MKN001', 'Burger', 'Burger dengan daging sapi', 15000, 'img/burger.jpg', 100),
('MKN002', 'French Fries', 'kentang goreng enak', 10000, 'img/kentang.jpg', 100),
('MKN003', 'Hotdog', 'Ini bukan anjing panas, tapi roti sosis', 15000, 'img/hotdog.jpg', 100);

-- --------------------------------------------------------

--
-- Table structure for table `orderonline`
--

CREATE TABLE `orderonline` (
  `nama` text DEFAULT NULL,
  `alamat` text DEFAULT NULL,
  `detil` text DEFAULT NULL,
  `total` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `orderonline`
--

INSERT INTO `orderonline` (`nama`, `alamat`, `detil`, `total`) VALUES
('Suryadi', 'nomaden', 'Air Mineral 1 pcs \n', 5000),
('Gawd Gura', 'A', 'Air Mineral 3 pcs \n', 15000),
('Maman Kesbor', 'Gedung F Telyu', 'Air Mineral 4 pcs \nCoca Cola 4 pcs \n', 48000),
('asdasdasd', 'dasdasdasdasd', 'Air Mineral 1 pcs \n', 5000),
('But Dade', 'nomaden', 'Kopi 3 pcs \nBurger 2 pcs \n', 51000);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `menu`
--
ALTER TABLE `menu`
  ADD PRIMARY KEY (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
