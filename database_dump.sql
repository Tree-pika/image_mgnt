-- MySQL dump 10.13  Distrib 8.0.44, for Linux (x86_64)
--
-- Host: localhost    Database: imagedb
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `auth_group`
--

DROP TABLE IF EXISTS `auth_group`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group`
--

LOCK TABLES `auth_group` WRITE;
/*!40000 ALTER TABLE `auth_group` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_group_permissions`
--

DROP TABLE IF EXISTS `auth_group_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_group_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_group_permissions_group_id_permission_id_0cd325b0_uniq` (`group_id`,`permission_id`),
  KEY `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` (`permission_id`),
  CONSTRAINT `auth_group_permissio_permission_id_84c5c92e_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `auth_group_permissions_group_id_b120cbf9_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_group_permissions`
--

LOCK TABLES `auth_group_permissions` WRITE;
/*!40000 ALTER TABLE `auth_group_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `auth_group_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `auth_permission`
--

DROP TABLE IF EXISTS `auth_permission`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `auth_permission` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `content_type_id` int NOT NULL,
  `codename` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `auth_permission_content_type_id_codename_01ab375a_uniq` (`content_type_id`,`codename`),
  CONSTRAINT `auth_permission_content_type_id_2f476e4b_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `auth_permission`
--

LOCK TABLES `auth_permission` WRITE;
/*!40000 ALTER TABLE `auth_permission` DISABLE KEYS */;
INSERT INTO `auth_permission` VALUES (1,'Can add log entry',1,'add_logentry'),(2,'Can change log entry',1,'change_logentry'),(3,'Can delete log entry',1,'delete_logentry'),(4,'Can view log entry',1,'view_logentry'),(5,'Can add permission',2,'add_permission'),(6,'Can change permission',2,'change_permission'),(7,'Can delete permission',2,'delete_permission'),(8,'Can view permission',2,'view_permission'),(9,'Can add group',3,'add_group'),(10,'Can change group',3,'change_group'),(11,'Can delete group',3,'delete_group'),(12,'Can view group',3,'view_group'),(13,'Can add content type',4,'add_contenttype'),(14,'Can change content type',4,'change_contenttype'),(15,'Can delete content type',4,'delete_contenttype'),(16,'Can view content type',4,'view_contenttype'),(17,'Can add session',5,'add_session'),(18,'Can change session',5,'change_session'),(19,'Can delete session',5,'delete_session'),(20,'Can view session',5,'view_session'),(21,'Can add user',6,'add_user'),(22,'Can change user',6,'change_user'),(23,'Can delete user',6,'delete_user'),(24,'Can view user',6,'view_user'),(25,'Can add image',7,'add_image'),(26,'Can change image',7,'change_image'),(27,'Can delete image',7,'delete_image'),(28,'Can view image',7,'view_image'),(29,'Can add email verification',8,'add_emailverification'),(30,'Can change email verification',8,'change_emailverification'),(31,'Can delete email verification',8,'delete_emailverification'),(32,'Can view email verification',8,'view_emailverification');
/*!40000 ALTER TABLE `auth_permission` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_emailverification`
--

DROP TABLE IF EXISTS `core_emailverification`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_emailverification` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `email` varchar(254) NOT NULL,
  `code` varchar(6) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_emailverification`
--

LOCK TABLES `core_emailverification` WRITE;
/*!40000 ALTER TABLE `core_emailverification` DISABLE KEYS */;
/*!40000 ALTER TABLE `core_emailverification` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_image`
--

DROP TABLE IF EXISTS `core_image`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_image` (
  `id` char(32) NOT NULL,
  `file` varchar(100) NOT NULL,
  `title` varchar(100) NOT NULL,
  `exif_data` json NOT NULL,
  `shot_time` datetime(6) DEFAULT NULL,
  `location` varchar(255) NOT NULL,
  `width` int NOT NULL,
  `height` int NOT NULL,
  `tags` json NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `owner_id` bigint NOT NULL,
  `size` int NOT NULL,
  `thumbnail` varchar(100) DEFAULT NULL,
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `core_image_owner_id_f830af9b_fk_core_user_id` (`owner_id`),
  KEY `core_image_deleted_at_3820c4e0` (`deleted_at`),
  CONSTRAINT `core_image_owner_id_f830af9b_fk_core_user_id` FOREIGN KEY (`owner_id`) REFERENCES `core_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_image`
--

LOCK TABLES `core_image` WRITE;
/*!40000 ALTER TABLE `core_image` DISABLE KEYS */;
INSERT INTO `core_image` VALUES ('05d2cb326dff4b2a8d9d8493ee14ae77','uploads/2026/01/5zS3z3e2HOYa48z_qFZL4hZ.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg','{}',NULL,'',400,865,'[]','2026-01-03 05:38:19.567442',6,109480,'thumbnails/2026/01/thumb_5zS3z3e2HOYa48z_7Al9Fd3.thumb.400_0.jpg',NULL),('1f5be1ac1f924a3689e367fda202f22c','uploads/2025/12/27400a9a6567d6a2fd7b4b3f50113bf8_yKMlWAP.jpg','27400a9a6567d6a2fd7b4b3f50113bf8.jpg','{}',NULL,'',1280,1707,'[\"wok\", \"hot pot\", \"plate\"]','2025-12-21 12:15:57.581608',2,236117,'thumbnails/2025/12/thumb_27400a9a6567d6a2fd7b4b3f50113bf8_Q6e6gHa.jpg',NULL),('2499a4c99fee459ab8a61fb0b866d74e','uploads/2025/12/ee304b77585ec2a1a0f7df49787ebe7f.jpg','ee304b77585ec2a1a0f7df49787ebe7f.jpg','{}',NULL,'',1707,1280,'[\"shopping cart\", \"bannister\", \"walk\"]','2025-12-21 12:16:51.612169',2,394032,'thumbnails/2025/12/thumb_ee304b77585ec2a1a0f7df49787ebe7f.jpg',NULL),('29f4d2726428471988c45d41fd5943a6','uploads/2026/01/tree_p5QwFm1.jpg','tree.jpg','{}',NULL,'',1618,1080,'[]','2026-01-03 03:54:37.814960',5,132266,'thumbnails/2026/01/thumb_tree_T5tYwVb.jpg',NULL),('2d91e5862e5a4c59b85cbefdf3dd29a0','uploads/2026/01/tree_jDyHv42.jpg','tree.jpg','{}',NULL,'',1618,1080,'[]','2026-01-03 05:38:22.629816',6,132266,'thumbnails/2026/01/thumb_tree_KsLchBe.jpg',NULL),('31026b930cef4350ba052e24fdce23ba','uploads/2026/01/5zS3z3e2HOYa48z.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg','{}',NULL,'',400,865,'[\"comic book\", \"menu\", \"jigsaw puzzle\"]','2026-01-03 00:54:56.675196',2,109480,'thumbnails/2026/01/thumb_5zS3z3e2HOYa48z.thumb.400_0.jpg',NULL),('325f3d879da0492fbc9cafcedda40827','uploads/2026/01/rev_5b867988_5zS3z3e2HOYa48z_cL0bNCJ.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg','{}',NULL,'',185,400,'[\"plate rack\", \"comic book\", \"bonnet\"]','2026-01-03 03:58:36.702538',5,37944,'thumbnails/2026/01/thumb_rev_5b867988_5zS3z3e2HOYa48z_cL0bNCJ.thumb.400_0.jpg','2026-01-03 05:50:06.326295'),('392f7ec388a9469395546f6922f372e8','uploads/2026/01/rev_696831cb_2YSpZ9JnI6XqyGz_kzc0iaP.thumb.1000_0.jpg','2YSpZ9JnI6XqyGz.thumb.1000_0.jpg (历史版本)','{}',NULL,'',420,820,'[\"handkerchief\", \"envelope\", \"bath towel\"]','2026-01-03 05:51:33.257101',5,76338,'thumbnails/2026/01/thumb_rev_696831cb_2YSpZ9JnI6XqyGz_kzc0iaP.thumb.1000_0.jpg','2026-01-03 05:51:58.765181'),('3a41bec7351d45dd8d62fa96eb228a61','uploads/2026/01/5zS3z3e2HOYa48z_gprpWXP.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg','{}',NULL,'',400,865,'[]','2026-01-03 05:37:44.126237',6,109480,'thumbnails/2026/01/thumb_5zS3z3e2HOYa48z_l1obiX2.thumb.400_0.jpg',NULL),('3ddac13e5f144990942bde816ab5603b','uploads/2026/01/5zS3z3e2HOYa48z_fRimBAe.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg','{}',NULL,'',400,865,'[]','2026-01-03 03:54:43.240058',5,109480,'thumbnails/2026/01/thumb_5zS3z3e2HOYa48z_pfXySrd.thumb.400_0.jpg',NULL),('3eb587694096457e9c975829d0c30dd9','uploads/2025/12/5zS3z3e2HOYa48z_8WZptqn.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg (历史版本)','{}',NULL,'',400,865,'[]','2025-12-21 12:11:30.659294',2,109480,'thumbnails/2025/12/thumb_5zS3z3e2HOYa48z_7pJEJUz.thumb.400_0.jpg','2025-12-21 12:14:43.706567'),('45590351f6604b71ad245390ebb3021b','uploads/2026/01/tree_YHnn4KJ.jpg','tree.jpg','{}',NULL,'',1618,1080,'[\"lakeside\", \"alp\", \"valley\"]','2026-01-03 05:48:01.757407',5,132266,'thumbnails/2026/01/thumb_tree_gtYyqS0.jpg',NULL),('4dc8776a0d8f4ffc9e7a497c2b376eef','uploads/2026/01/2YSpZ9JnI6XqyGz_YJqFQJD.thumb.1000_0.jpg','2YSpZ9JnI6XqyGz.thumb.1000_0.jpg','{}',NULL,'',820,1600,'[]','2026-01-03 05:37:51.372542',6,214423,'thumbnails/2026/01/thumb_2YSpZ9JnI6XqyGz_5LWaO7w.thumb.1000_0.jpg',NULL),('55b9cc2276dc4ef9876e8e2e38e9bad8','uploads/2026/01/5zS3z3e2HOYa48z_OHSalVO.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg','{}',NULL,'',400,865,'[]','2026-01-03 03:54:26.815507',5,109480,'thumbnails/2026/01/thumb_5zS3z3e2HOYa48z_g3dX8R8.thumb.400_0.jpg',NULL),('5d8a66609c7a4bfba16ffb00b4abeacc','uploads/2025/12/rev_bcb03399_rev_1f383431_2YSpZ9JnI6XqyGz_72WRy8n.thumb.1000_0.jpg','2YSpZ9JnI6XqyGz.thumb.1000_0.jpg','{}',NULL,'',525,1024,'[\"yellow\"]','2025-12-21 12:14:31.193516',2,113555,'thumbnails/2025/12/thumb_rev_bcb03399_rev_1f383431_2YSpZ9JnI6XqyGz_72WRy8n.thumb.1000_0.jpg',NULL),('60b23e383e304f7ab5fd3d437640a317','uploads/2026/01/5zS3z3e2HOYa48z_QQftoB0.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg','{}',NULL,'',400,865,'[]','2026-01-03 03:54:29.578730',5,109480,'thumbnails/2026/01/thumb_5zS3z3e2HOYa48z_aaeET3a.thumb.400_0.jpg',NULL),('610cadd4a1764cb0aa947a49529f988e','uploads/2026/01/tree_pxPjz1S.jpg','tree.jpg','{}',NULL,'',1618,1080,'[\"tree\", \"valley\", \"lakeside\", \"alp\"]','2026-01-03 03:54:39.820903',5,132266,'thumbnails/2026/01/thumb_tree_88kjv5F.jpg',NULL),('621aa55a5f4f4de7a268ada5feb702b1','uploads/2026/01/tree_2gzqU1j.jpg','tree.jpg','{}',NULL,'',1618,1080,'[]','2026-01-03 05:38:27.991360',6,132266,'thumbnails/2026/01/thumb_tree_cWgwngl.jpg',NULL),('6329cf0458b34c12a8f3ccfeb2b50a01','uploads/2026/01/rev_c3147056_rev_696831cb_2YSpZ9JnI6XqyGz_kzc0iaP.thumb.1000_0.jpg','2YSpZ9JnI6XqyGz.thumb.1000_0.jpg','{}',NULL,'',336,656,'[\"handkerchief\", \"envelope\", \"bath towel\"]','2026-01-03 05:51:58.744796',5,57492,'thumbnails/2026/01/thumb_rev_c3147056_rev_696831cb_2YSpZ9JnI6XqyGz_kzc0iaP.thumb.1000_0.jpg',NULL),('6a9eb412a8244e36b30b652d7c7779fc','uploads/2025/12/5zS3z3e2HOYa48z_bkeLiEN.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg','{}',NULL,'',400,865,'[]','2025-12-21 12:11:12.444057',2,109480,'thumbnails/2025/12/thumb_5zS3z3e2HOYa48z_ZLNRnTd.thumb.400_0.jpg','2025-12-21 12:12:23.889327'),('7be1701a7a6b4da3ae4d37dccf0317cf','uploads/2026/01/2YSpZ9JnI6XqyGz_VhekDzI.thumb.1000_0.jpg','2YSpZ9JnI6XqyGz.thumb.1000_0.jpg','{}',NULL,'',820,1600,'[]','2026-01-03 05:37:48.717148',6,214423,'thumbnails/2026/01/thumb_2YSpZ9JnI6XqyGz_1n0P7ra.thumb.1000_0.jpg',NULL),('7d4c289b98014400af15e8f81c596563','uploads/2026/01/2YSpZ9JnI6XqyGz_oLb5oSY.thumb.1000_0.jpg','2YSpZ9JnI6XqyGz.thumb.1000_0.jpg','{}',NULL,'',820,1600,'[]','2026-01-03 03:54:33.452925',5,214423,'thumbnails/2026/01/thumb_2YSpZ9JnI6XqyGz_fAQ4t7F.thumb.1000_0.jpg',NULL),('7e2a82489e4048dbb5ffbd67769253f7','uploads/2025/12/b9d6b853f1261d489b0ae3474a65e48a_prAr8d7.jpg','b9d6b853f1261d489b0ae3474a65e48a.jpg','{}',NULL,'',1280,2276,'[\"comic book\", \"eggnog\", \"hamper\"]','2025-12-21 12:16:00.769866',2,268086,'thumbnails/2025/12/thumb_b9d6b853f1261d489b0ae3474a65e48a_MIjkEEI.jpg',NULL),('9cd972ae2760468681d6e5afc5830c5d','uploads/2026/01/5zS3z3e2HOYa48z_QnjL4pR.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg','{}',NULL,'',400,865,'[\"jigsaw puzzle\", \"comic book\", \"menu\"]','2026-01-03 03:54:35.526756',5,109480,'thumbnails/2026/01/thumb_5zS3z3e2HOYa48z_ZGRVv2u.thumb.400_0.jpg',NULL),('9d385d5297a34904a11c3dcbc8f2a142','uploads/2026/01/2YSpZ9JnI6XqyGz_vEORuVE.thumb.1000_0.jpg','2YSpZ9JnI6XqyGz.thumb.1000_0.jpg','{}',NULL,'',820,1600,'[]','2026-01-03 05:38:07.611239',6,214423,'thumbnails/2026/01/thumb_2YSpZ9JnI6XqyGz_p1j6ETI.thumb.1000_0.jpg',NULL),('a7ae8c7a96b348c398d89bc205bfbeec','uploads/2026/01/5zS3z3e2HOYa48z_XoVGHHM.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg','{}',NULL,'',400,865,'[]','2026-01-03 03:54:24.186726',5,109480,'thumbnails/2026/01/thumb_5zS3z3e2HOYa48z_7CRKLKh.thumb.400_0.jpg',NULL),('a7bc5e2f2c66404ab87b2f39c209aa36','uploads/2026/01/5zS3z3e2HOYa48z_ovBx7aW.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg','{}',NULL,'',400,865,'[]','2026-01-03 05:37:29.064598',6,109480,'thumbnails/2026/01/thumb_5zS3z3e2HOYa48z_Hz0XIVx.thumb.400_0.jpg',NULL),('adca9256aac1425a83d5eec12cae4ccd','uploads/2025/12/53ee2332ba9eb8735ba451584adfd4e5.jpg','53ee2332ba9eb8735ba451584adfd4e5.jpg','{}',NULL,'',1280,1280,'[\"caldron\", \"wok\", \"mixing bowl\"]','2025-12-21 12:16:48.503272',2,56227,'thumbnails/2025/12/thumb_53ee2332ba9eb8735ba451584adfd4e5.jpg',NULL),('b5d8ac6297074770bc7353305000fa59','uploads/2026/01/2YSpZ9JnI6XqyGz_kzc0iaP.thumb.1000_0.jpg','2YSpZ9JnI6XqyGz.thumb.1000_0.jpg (历史版本)','{}',NULL,'',820,1600,'[\"handkerchief\", \"envelope\", \"bath towel\"]','2026-01-03 03:54:45.430677',5,214423,'thumbnails/2026/01/thumb_2YSpZ9JnI6XqyGz_0DSvgb6.thumb.1000_0.jpg','2026-01-03 05:51:33.280982'),('ba15bc6deeaa45058aa9014fcf6f8231','uploads/2026/01/5zS3z3e2HOYa48z_Efgxd0E.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg','{}',NULL,'',400,865,'[]','2026-01-03 03:54:18.747781',5,109480,'thumbnails/2026/01/thumb_5zS3z3e2HOYa48z_kYgp2yH.thumb.400_0.jpg',NULL),('c295510aaa50408597925c5c022ca0ce','uploads/2026/01/2YSpZ9JnI6XqyGz_nD7F239.thumb.1000_0.jpg','2YSpZ9JnI6XqyGz.thumb.1000_0.jpg','{}',NULL,'',820,1600,'[]','2026-01-03 05:38:12.168484',6,214423,'thumbnails/2026/01/thumb_2YSpZ9JnI6XqyGz_UGNCewg.thumb.1000_0.jpg',NULL),('cde0abd08ad54b4a9a81df6a507242b7','uploads/2026/01/tree_4pQRquh.jpg','tree.jpg','{}',NULL,'',1618,1080,'[]','2026-01-03 05:38:25.312718',6,132266,'thumbnails/2026/01/thumb_tree_VC7rnnG.jpg',NULL),('ce6c8581430c485f989e09eb0ba3cd9d','uploads/2025/12/ae90cd817fd83f811a3cb9a18715719c.jpg','ae90cd817fd83f811a3cb9a18715719c.jpg','{}',NULL,'',1280,1707,'[\"scoreboard\", \"street sign\", \"traffic light\"]','2025-12-21 12:16:52.306062',2,332247,'thumbnails/2025/12/thumb_ae90cd817fd83f811a3cb9a18715719c.jpg',NULL),('d0a8beb68fba43a0ab8aaf013d97185f','uploads/2025/12/121560162_1543459849969.jpg','121560162_1543459849969.jpg','{}',NULL,'',1618,1080,'[]','2025-12-21 12:17:49.211311',2,132266,'thumbnails/2025/12/thumb_121560162_1543459849969.jpg','2025-12-21 12:18:33.219293'),('d671cfc84d124249954717a804ae7774','uploads/2026/01/tree_NK8NEQP.jpg','tree.jpg','{}',NULL,'',1618,1080,'[]','2026-01-03 05:37:19.062979',6,132266,'thumbnails/2026/01/thumb_tree_YLjwPMw.jpg',NULL),('e1622d330347455b8c27994734697a9c','uploads/2025/12/2YSpZ9JnI6XqyGz_72WRy8n.thumb.1000_0.jpg','2YSpZ9JnI6XqyGz.thumb.1000_0.jpg','{}',NULL,'',820,1600,'[\"bath towel\", \"handkerchief\", \"envelope\"]','2025-12-21 12:11:06.236701',2,214423,'thumbnails/2025/12/thumb_2YSpZ9JnI6XqyGz_8ZsE4QZ.thumb.1000_0.jpg',NULL),('e272c43314ca4e02ab2497eff1f8ef90','uploads/2025/12/rev_727befd5_5zS3z3e2HOYa48z_8WZptqn.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg','{}',NULL,'',320,692,'[\"jigsaw puzzle\", \"comic book\", \"menu\"]','2025-12-21 12:14:43.686531',2,94746,'thumbnails/2025/12/thumb_rev_727befd5_5zS3z3e2HOYa48z_8WZptqn.thumb.400_0.jpg',NULL),('e3eab72820c74c2ab541ed2cf8aec886','uploads/2026/01/5zS3z3e2HOYa48z_hMDQgQ7.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg','{}',NULL,'',400,865,'[]','2026-01-03 03:54:22.040528',5,109480,'thumbnails/2026/01/thumb_5zS3z3e2HOYa48z_THTC6L5.thumb.400_0.jpg',NULL),('e498171f68c345eba128edb82146ac8f','uploads/2026/01/2YSpZ9JnI6XqyGz_9udnFS7.thumb.1000_0.jpg','2YSpZ9JnI6XqyGz.thumb.1000_0.jpg','{}',NULL,'',820,1600,'[\"test2\", \"envelope\", \"t\", \"bath towel\", \"handkerchief\"]','2026-01-03 05:38:33.495305',6,214423,'thumbnails/2026/01/thumb_2YSpZ9JnI6XqyGz_vSkuqut.thumb.1000_0.jpg',NULL),('e543b35a61d848169538d64145ad50dc','uploads/2026/01/2YSpZ9JnI6XqyGz.thumb.1000_0.jpg','2YSpZ9JnI6XqyGz.thumb.1000_0.jpg','{}',NULL,'',820,1600,'[]','2026-01-03 03:54:14.975497',5,214423,'thumbnails/2026/01/thumb_2YSpZ9JnI6XqyGz.thumb.1000_0.jpg',NULL),('e5cb60e1faa84127b83047642220a23d','uploads/2026/01/5zS3z3e2HOYa48z_mbYKnVQ.thumb.400_0.jpg','5zS3z3e2HOYa48z.thumb.400_0.jpg','{}',NULL,'',400,865,'[]','2026-01-03 05:38:39.450403',6,109480,'thumbnails/2026/01/thumb_5zS3z3e2HOYa48z_AZoOlxV.thumb.400_0.jpg',NULL),('ef4cbc7db8aa4c52bc9674974be42204','uploads/2026/01/2YSpZ9JnI6XqyGz_4jD3bvy.thumb.1000_0.jpg','2YSpZ9JnI6XqyGz.thumb.1000_0.jpg','{}',NULL,'',820,1600,'[]','2026-01-03 05:38:31.161013',6,214423,'thumbnails/2026/01/thumb_2YSpZ9JnI6XqyGz_mMHCy21.thumb.1000_0.jpg',NULL),('f0c4ebb6a55c45bfb3e98bf3029576b0','uploads/2026/01/tree.jpg','tree.jpg','{}',NULL,'',1618,1080,'[]','2026-01-03 03:52:21.601186',5,132266,'thumbnails/2026/01/thumb_tree.jpg',NULL),('f87c27cecb1d499a99fa028c786c69cd','uploads/2025/12/121560162_1543459849969_TdXhUBv.jpg','121560162_1543459849969.jpg','{}',NULL,'',1618,1080,'[]','2025-12-21 12:18:12.047191',2,132266,'thumbnails/2025/12/thumb_121560162_1543459849969_r1Bk7b5.jpg','2025-12-21 12:18:33.219293'),('f8e61034fc564965973ab5cb9b2626bb','uploads/2026/01/2YSpZ9JnI6XqyGz_wumKpAZ.thumb.1000_0.jpg','2YSpZ9JnI6XqyGz.thumb.1000_0.jpg','{}',NULL,'',820,1600,'[\"envelope\", \"bath towel\", \"handkerchief\"]','2026-01-03 05:47:53.762486',5,214423,'thumbnails/2026/01/thumb_2YSpZ9JnI6XqyGz_Eh5ctyl.thumb.1000_0.jpg','2026-01-03 05:50:06.326295'),('ff23e17414a44f54a263a480373bf169','uploads/2025/12/tree.jpg','tree.jpg','{}',NULL,'',1618,1080,'[\"lakeside\", \"alp\", \"valley\"]','2025-12-21 12:18:20.818373',2,132266,'thumbnails/2025/12/thumb_tree.jpg',NULL);
/*!40000 ALTER TABLE `core_image` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_user`
--

DROP TABLE IF EXISTS `core_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `password` varchar(128) NOT NULL,
  `last_login` datetime(6) DEFAULT NULL,
  `is_superuser` tinyint(1) NOT NULL,
  `username` varchar(150) NOT NULL,
  `first_name` varchar(150) NOT NULL,
  `last_name` varchar(150) NOT NULL,
  `is_staff` tinyint(1) NOT NULL,
  `is_active` tinyint(1) NOT NULL,
  `date_joined` datetime(6) NOT NULL,
  `email` varchar(254) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`username`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_user`
--

LOCK TABLES `core_user` WRITE;
/*!40000 ALTER TABLE `core_user` DISABLE KEYS */;
INSERT INTO `core_user` VALUES (1,'pbkdf2_sha256$1000000$n0nWKGZkm2nGRadGv7ndhe$APe0IjsZFlSUQ9ac2DdYQ0DfyGqDtimqG2AOurwI1M8=',NULL,1,'admin','','',1,1,'2025-12-21 11:54:48.742752','admin@bs.com'),(2,'pbkdf2_sha256$1000000$nk9X2jTE05Jiyax0XA2xQ5$1EXTSY0D7cTcZJGqi3QMQUHixUlF3DgR98icnaTGoec=','2026-01-03 00:52:04.789936',0,'fish','','',0,1,'2025-12-21 12:10:46.845773','fish@bs.com'),(3,'pbkdf2_sha256$1000000$FNZT4yP7ZO4Mi1bzb7GTuO$x9Rp/wbl6/IKLDZJdrYZQLYiegwWGleKwhje6d0Q7/A=','2026-01-03 00:49:44.043685',1,'administrator','','',1,1,'2025-12-21 14:01:35.655150','administrator@bs.com'),(4,'pbkdf2_sha256$1000000$VLfblKiZgBVAfmZPEUsz41$4LsZZgiPJPPre3IdHDBvIxEj76nyE4crYpxu1YOZd1A=','2026-01-03 03:42:15.717195',0,'zzy','','',0,1,'2026-01-03 03:34:28.089792','3101879188@qq.com'),(5,'pbkdf2_sha256$1000000$hYYWLCqtRVqjSFCbZsxixp$PZqHA/UIxIghIqVgIp1Pw1E8uTImkdnit19eRAMACCs=','2026-01-03 05:47:42.719412',0,'treeflow','','',0,1,'2026-01-03 03:50:52.492778','zzish7@gmail.com'),(6,'pbkdf2_sha256$1000000$Z7nEqZAMw15suOhJbt7MKe$kP5jlsXY6dPX3kIM+q2fcwD3HFe4dSYODsq/cnHzLPA=','2026-01-03 05:37:00.134232',0,'bstest','','',0,1,'2026-01-03 05:36:58.065706','liuleo233@gmail.com'),(7,'pbkdf2_sha256$1000000$fxE5mvUASu6wCadoyBeIm5$ZpIqQHLEoE64CTkeKgrFYhm2hXkt6GVCbFbyXoGX9Bg=','2026-01-03 05:47:35.280420',0,'test2','','',0,1,'2026-01-03 05:47:33.387129','mizrahieitan809@gmail.com');
/*!40000 ALTER TABLE `core_user` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_user_groups`
--

DROP TABLE IF EXISTS `core_user_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_user_groups` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `group_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `core_user_groups_user_id_group_id_c82fcad1_uniq` (`user_id`,`group_id`),
  KEY `core_user_groups_group_id_fe8c697f_fk_auth_group_id` (`group_id`),
  CONSTRAINT `core_user_groups_group_id_fe8c697f_fk_auth_group_id` FOREIGN KEY (`group_id`) REFERENCES `auth_group` (`id`),
  CONSTRAINT `core_user_groups_user_id_70b4d9b8_fk_core_user_id` FOREIGN KEY (`user_id`) REFERENCES `core_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_user_groups`
--

LOCK TABLES `core_user_groups` WRITE;
/*!40000 ALTER TABLE `core_user_groups` DISABLE KEYS */;
/*!40000 ALTER TABLE `core_user_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `core_user_user_permissions`
--

DROP TABLE IF EXISTS `core_user_user_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_user_user_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `permission_id` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `core_user_user_permissions_user_id_permission_id_73ea0daa_uniq` (`user_id`,`permission_id`),
  KEY `core_user_user_permi_permission_id_35ccf601_fk_auth_perm` (`permission_id`),
  CONSTRAINT `core_user_user_permi_permission_id_35ccf601_fk_auth_perm` FOREIGN KEY (`permission_id`) REFERENCES `auth_permission` (`id`),
  CONSTRAINT `core_user_user_permissions_user_id_085123d3_fk_core_user_id` FOREIGN KEY (`user_id`) REFERENCES `core_user` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `core_user_user_permissions`
--

LOCK TABLES `core_user_user_permissions` WRITE;
/*!40000 ALTER TABLE `core_user_user_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `core_user_user_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_admin_log`
--

DROP TABLE IF EXISTS `django_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action_time` datetime(6) NOT NULL,
  `object_id` longtext,
  `object_repr` varchar(200) NOT NULL,
  `action_flag` smallint unsigned NOT NULL,
  `change_message` longtext NOT NULL,
  `content_type_id` int DEFAULT NULL,
  `user_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `django_admin_log_content_type_id_c4bce8eb_fk_django_co` (`content_type_id`),
  KEY `django_admin_log_user_id_c564eba6_fk_core_user_id` (`user_id`),
  CONSTRAINT `django_admin_log_content_type_id_c4bce8eb_fk_django_co` FOREIGN KEY (`content_type_id`) REFERENCES `django_content_type` (`id`),
  CONSTRAINT `django_admin_log_user_id_c564eba6_fk_core_user_id` FOREIGN KEY (`user_id`) REFERENCES `core_user` (`id`),
  CONSTRAINT `django_admin_log_chk_1` CHECK ((`action_flag` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_admin_log`
--

LOCK TABLES `django_admin_log` WRITE;
/*!40000 ALTER TABLE `django_admin_log` DISABLE KEYS */;
/*!40000 ALTER TABLE `django_admin_log` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_content_type`
--

DROP TABLE IF EXISTS `django_content_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_content_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `app_label` varchar(100) NOT NULL,
  `model` varchar(100) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `django_content_type_app_label_model_76bd3d3b_uniq` (`app_label`,`model`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_content_type`
--

LOCK TABLES `django_content_type` WRITE;
/*!40000 ALTER TABLE `django_content_type` DISABLE KEYS */;
INSERT INTO `django_content_type` VALUES (1,'admin','logentry'),(3,'auth','group'),(2,'auth','permission'),(4,'contenttypes','contenttype'),(8,'core','emailverification'),(7,'core','image'),(6,'core','user'),(5,'sessions','session');
/*!40000 ALTER TABLE `django_content_type` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_migrations`
--

DROP TABLE IF EXISTS `django_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_migrations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `app` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `applied` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_migrations`
--

LOCK TABLES `django_migrations` WRITE;
/*!40000 ALTER TABLE `django_migrations` DISABLE KEYS */;
INSERT INTO `django_migrations` VALUES (1,'contenttypes','0001_initial','2025-12-21 11:54:09.286409'),(2,'contenttypes','0002_remove_content_type_name','2025-12-21 11:54:09.406391'),(3,'auth','0001_initial','2025-12-21 11:54:09.790386'),(4,'auth','0002_alter_permission_name_max_length','2025-12-21 11:54:09.875945'),(5,'auth','0003_alter_user_email_max_length','2025-12-21 11:54:09.882581'),(6,'auth','0004_alter_user_username_opts','2025-12-21 11:54:09.888423'),(7,'auth','0005_alter_user_last_login_null','2025-12-21 11:54:09.893302'),(8,'auth','0006_require_contenttypes_0002','2025-12-21 11:54:09.901863'),(9,'auth','0007_alter_validators_add_error_messages','2025-12-21 11:54:09.910841'),(10,'auth','0008_alter_user_username_max_length','2025-12-21 11:54:09.921885'),(11,'auth','0009_alter_user_last_name_max_length','2025-12-21 11:54:09.930008'),(12,'auth','0010_alter_group_name_max_length','2025-12-21 11:54:09.950295'),(13,'auth','0011_update_proxy_permissions','2025-12-21 11:54:09.957501'),(14,'auth','0012_alter_user_first_name_max_length','2025-12-21 11:54:09.965388'),(15,'core','0001_initial','2025-12-21 11:54:10.595210'),(16,'admin','0001_initial','2025-12-21 11:54:10.775966'),(17,'admin','0002_logentry_remove_auto_add','2025-12-21 11:54:10.784538'),(18,'admin','0003_logentry_add_action_flag_choices','2025-12-21 11:54:10.792888'),(19,'core','0002_alter_user_options_image_size_image_thumbnail','2025-12-21 11:54:10.925271'),(20,'core','0003_image_deleted_at','2025-12-21 11:54:11.011341'),(21,'sessions','0001_initial','2025-12-21 11:54:11.079229'),(22,'core','0004_emailverification','2026-01-03 03:08:59.244225');
/*!40000 ALTER TABLE `django_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `django_session`
--

DROP TABLE IF EXISTS `django_session`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `django_session` (
  `session_key` varchar(40) NOT NULL,
  `session_data` longtext NOT NULL,
  `expire_date` datetime(6) NOT NULL,
  PRIMARY KEY (`session_key`),
  KEY `django_session_expire_date_a5c62663` (`expire_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `django_session`
--

LOCK TABLES `django_session` WRITE;
/*!40000 ALTER TABLE `django_session` DISABLE KEYS */;
INSERT INTO `django_session` VALUES ('ceb130g1rbv67zcgtvwmkjnizz0xk93u','.eJxVjDsOwyAQBe9CHSH-hpTpfQa0sEtwEmHJ2FWUu0dILpLyvRnNm0U49hqPTltckF2ZZZffL0F-UhsAH9DuK89r27cl8aHwk3Y-r0iv2-n-BSr0OrJOqskJUATgsg5oXLIk85hmylajDkqAL8WA9yIELC54DYYsFSEl-3wB4js32g:1vbuUI:oHMRMhGhDkOGkjJ_yopggmXP_4USjg95B1MZVXdnY8E','2026-01-17 05:47:42.724044'),('ji2emt8fdqtdai2p7rarnnhqn11j4455','.eJxVjDsOwjAQBe_iGlmJP7sOJT1nsNa7NgkgR4qTCnF3iJQC2jcz76UibesYt5aXOIk6K1Cn3y0RP3Ldgdyp3mbNc12XKeld0Qdt-jpLfl4O9-9gpDZ-aw8gxXVgMwWg3qfBI1tBKDTIwDZDwM4bNpYLi3VYTDAIgiKuYA_q_QHg4zfH:1vbuJw:qCrfjhqwOzeSCKNqACjKfTuoLM990gSETO32ztFoWqk','2026-01-17 05:37:00.138774');
/*!40000 ALTER TABLE `django_session` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-01-03  6:32:14
