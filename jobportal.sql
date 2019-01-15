-- phpMyAdmin SQL Dump
-- version 4.7.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 15, 2019 at 02:47 PM
-- Server version: 10.1.25-MariaDB
-- PHP Version: 5.6.31

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `jobportal`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `count_active_opened_jobs` ()  BEGIN
		SELECT COUNT(ID) as total
	FROM `pp_post_jobs` AS pj
	WHERE pj.sts='active' AND CURRENT_DATE < pj.last_date;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `count_active_opened_jobs_by_company_id` (IN `comp_id` INT(11))  BEGIN
		SELECT COUNT(ID) as total
	FROM `pp_post_jobs` AS pj
	WHERE pj.company_ID=comp_id AND pj.sts='active';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `count_active_records_by_city_front_end` (IN `city` VARCHAR(40))  BEGIN
		SELECT COUNT(pj.ID) AS total
	FROM `pp_post_jobs` AS pj
	INNER JOIN pp_companies AS pc ON pj.company_ID=pc.ID
	WHERE pj.city=city AND pj.sts='active' AND pc.sts = 'active';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `count_active_records_by_industry_front_end` (IN `industry_id` INT(11))  BEGIN
	SELECT COUNT(pj.ID) AS total
	FROM `pp_post_jobs` AS pj
	INNER JOIN pp_companies AS pc ON pj.company_ID=pc.ID
	INNER JOIN pp_job_industries AS ji ON pj.industry_ID=ji.ID
	WHERE pj.industry_ID=industry_id AND pj.sts='active' AND pc.sts = 'active';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `count_all_posted_jobs_by_company_id_frontend` (IN `comp_id` INT(11))  BEGIN
		SELECT COUNT(pj.ID) AS total
	FROM `pp_post_jobs` AS pj
	INNER JOIN pp_companies AS pc ON pj.company_ID=pc.ID
	WHERE pj.company_ID=comp_id AND pj.sts='active' AND pc.sts = 'active';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `count_applied_jobs_by_employer_id` (IN `employer_id` INT(11))  BEGIN
	SELECT COUNT(pp_seeker_applied_for_job.ID) AS total
	FROM `pp_seeker_applied_for_job`
	INNER JOIN pp_post_jobs ON pp_post_jobs.ID=pp_seeker_applied_for_job.job_ID
	INNER JOIN pp_job_seekers ON pp_job_seekers.ID=pp_seeker_applied_for_job.seeker_ID
	WHERE pp_post_jobs.employer_ID=employer_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `count_applied_jobs_by_jobseeker_id` (IN `jobseeker_id` INT(11))  BEGIN
	SELECT COUNT(pp_seeker_applied_for_job.ID) AS total
	FROM `pp_seeker_applied_for_job`
	WHERE pp_seeker_applied_for_job.seeker_ID=jobseeker_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `count_ft_job_search_filter_3` (IN `param_city` VARCHAR(255), `param_company_slug` VARCHAR(255), `param_title` VARCHAR(255))  BEGIN
	SELECT COUNT(pj.ID) as total
	FROM pp_post_jobs pj
	INNER JOIN pp_companies pc ON pc.ID = pj.company_ID 
	WHERE (pj.job_title like CONCAT("%",param,"%") OR pj.job_description like CONCAT("%",param,"%") OR pj.required_skills like CONCAT("%",param,"%"))
AND pc.company_slug = param_company_slug AND pj.city = param_city AND pj.sts = 'active' AND pc.sts = 'active';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `count_ft_search_job` (IN `param` VARCHAR(255), `param2` VARCHAR(255))  BEGIN
	SELECT COUNT(pc.ID) as total
	FROM `pp_post_jobs` pj 
	INNER JOIN pp_companies AS pc ON pj.company_ID=pc.ID
	WHERE pj.sts = 'active' AND pc.sts = 'active'
AND (pj.job_title like CONCAT("%",param,"%") OR pj.job_description like CONCAT("%",param,"%") OR pj.required_skills like CONCAT("%",param,"%"))
AND pj.city like CONCAT("%",param2,"%");
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `count_ft_search_resume` (IN `param` VARCHAR(255))  BEGIN
	SELECT COUNT(DISTINCT ss.ID) as total
	FROM `pp_job_seekers` js 
	INNER JOIN pp_seeker_skills AS ss ON js.ID=ss.seeker_ID
	WHERE js.sts = 'active' 
AND ss.skill_name like CONCAT('%',param,'%');
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `count_search_posted_jobs` (IN `where_condition` VARCHAR(255))  BEGIN
	SET @query = "SELECT COUNT(pj.ID) as total
	FROM `pp_post_jobs` pj 
	LEFT JOIN pp_companies AS pc ON pj.company_ID=pc.ID 
	WHERE
";

SET @where_clause = CONCAT(where_condition);
SET @query = CONCAT(@query, @where_clause);

PREPARE stmt FROM @query;
EXECUTE stmt;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ft_job_search_filter_3` (IN `param_city` VARCHAR(255), `param_company_slug` VARCHAR(255), `param_title` VARCHAR(255), `from_limit` INT(5), `to_limit` INT(5))  BEGIN
	SELECT pj.ID, pj.job_title, pj.job_slug, pj.employer_ID, pj.company_ID, pj.job_description, pj.city, pj.dated, pj.last_date, pj.is_featured, pj.sts, pc.company_name, pc.company_logo, pc.company_slug, MATCH(pj.job_title, pj.job_description) AGAINST( param_title ) AS score
	FROM pp_post_jobs pj
	INNER JOIN pp_companies pc ON pc.ID = pj.company_ID 
	WHERE (pj.job_title like CONCAT("%",param_title,"%") OR pj.job_description like CONCAT("%",param_title,"%") OR pj.required_skills like CONCAT("%",param_title,"%")) 
AND pc.company_slug = param_company_slug AND pj.city = param_city AND pj.sts = 'active' AND pc.sts = 'active'

ORDER BY score DESC
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ft_search_job` (IN `param` VARCHAR(255), `param2` VARCHAR(255), `from_limit` INT(5), `to_limit` INT(5))  BEGIN

	SELECT pj.ID, pj.job_title, pj.job_slug, pj.employer_ID, pj.company_ID, pj.job_description, pj.city, pj.dated, pj.last_date, pj.is_featured, pj.sts, pc.company_name, pc.company_logo, pc.company_slug, MATCH(pj.job_title, pj.job_description) AGAINST(param) AS score
	FROM `pp_post_jobs` pj 
	INNER JOIN pp_companies AS pc ON pj.company_ID=pc.ID
	WHERE pj.sts = 'active' AND pc.sts = 'active' 
	AND (
			pj.job_title like CONCAT("%",param,"%") 
			OR pj.job_description like CONCAT("%",param,"%") 
			OR pj.required_skills like CONCAT("%",param,"%") 
			OR pj.pay like CONCAT("%",REPLACE(param,' ','-'),"%")
			OR pj.city like CONCAT("%",param,"%")
		)
		AND (pj.city) like CONCAT("%",param2,"%")
ORDER BY pj.ID DESC
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ft_search_jobs_group_by_city` (IN `param` VARCHAR(255))  BEGIN
	SELECT city, COUNT(city) as score
	FROM `pp_post_jobs` pj 
	WHERE pj.sts = 'active' 
AND (
			pj.job_title like CONCAT("%",param,"%") 
			OR pj.job_description like CONCAT("%",param,"%") 
			OR pj.required_skills like CONCAT("%",param,"%") 
			OR pj.pay like CONCAT("%",REPLACE(param,' ','-'),"%")
			OR pj.city like CONCAT("%",param,"%")
		)
	GROUP BY city
	ORDER BY score DESC
	LIMIT 0,5;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ft_search_jobs_group_by_company` (IN `param` VARCHAR(255))  BEGIN
	SELECT  pc.company_name,pc.company_slug, COUNT(pc.company_name) as score
	FROM `pp_post_jobs` pj 
	INNER JOIN pp_companies AS pc ON pj.company_ID=pc.ID
	WHERE pj.sts = 'active' AND pc.sts = 'active' 
AND (
			pj.job_title like CONCAT("%",param,"%") 
			OR pj.job_description like CONCAT("%",param,"%") 
			OR pj.required_skills like CONCAT("%",param,"%") 
			OR pj.pay like CONCAT("%",REPLACE(param,' ','-'),"%")
			OR pj.city like CONCAT("%",param,"%")
		)
	GROUP BY pc.company_name
	ORDER BY score DESC
	LIMIT 0,5;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ft_search_jobs_group_by_salary_range` (IN `param` VARCHAR(255))  BEGIN
	SELECT pay, COUNT(pay) as score
	FROM `pp_post_jobs` pj 
	WHERE pj.sts = 'active' 
AND (
			pj.job_title like CONCAT("%",param,"%") 
			OR pj.job_description like CONCAT("%",param,"%") 
			OR pj.required_skills like CONCAT("%",param,"%") 
			OR pj.pay like CONCAT("%",REPLACE(param,' ','-'),"%")
			OR pj.city like CONCAT("%",param,"%")
		)
	GROUP BY pay
	ORDER BY score DESC
	LIMIT 0,5;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ft_search_jobs_group_by_title` (IN `param` VARCHAR(255))  BEGIN
	SELECT job_title, COUNT(job_title) as score
	FROM `pp_post_jobs` pj 
	WHERE pj.sts = 'active' 
AND (
			pj.job_title like CONCAT("%",param,"%") 
			OR pj.job_description like CONCAT("%",param,"%") 
			OR pj.required_skills like CONCAT("%",param,"%") 
			OR pj.pay like CONCAT("%",REPLACE(param,' ','-'),"%")
			OR pj.city like CONCAT("%",param,"%")
		)

	GROUP BY job_title
	ORDER BY score DESC
	LIMIT 0,5;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ft_search_resume` (IN `param` VARCHAR(255), `from_limit` INT(5), `to_limit` INT(5))  BEGIN
  SELECT js.ID, js.first_name, js.gender, js.dob, js.city, js.photo
	FROM pp_job_seekers AS js
	INNER JOIN pp_seeker_skills AS ss ON js.ID=ss.seeker_ID
	WHERE js.sts = 'active' AND ss.skill_name like CONCAT("%",param,"%")
  GROUP BY ss.seeker_ID
	ORDER BY js.ID DESC
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_active_deactive_posted_job_by_company_id` (IN `comp_id` INT(11), `from_limit` INT(4), `to_limit` INT(4))  BEGIN
		SELECT pj.ID, pj.job_title, pj.job_slug, pj.job_description, pj.employer_ID, pj.last_date, pj.dated, pj.city, pj.is_featured, pj.sts, pc.company_name, pc.company_logo
	FROM `pp_post_jobs` AS pj
	INNER JOIN pp_companies AS pc ON pj.company_ID=pc.ID
	WHERE pj.company_ID=comp_id AND pj.sts IN ('active', 'inactive', 'pending') AND pc.sts = 'active'
	ORDER BY ID DESC
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_active_featured_job` (IN `from_limit` INT(5), `to_limit` INT(5))  BEGIN
	SELECT pj.ID, pj.job_title, pj.job_slug, pj.employer_ID, pj.company_ID, pj.city, pj.dated, pj.last_date, pj.is_featured, pj.sts, pc.company_name, pc.company_logo, pc.company_slug 
	FROM `pp_post_jobs` pj 
	LEFT JOIN pp_companies AS pc ON pj.company_ID=pc.ID 
	WHERE pj.is_featured='yes' AND pj.sts='active' AND pc.sts = 'active'
	ORDER BY ID DESC 
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_active_posted_job_by_company_id` (IN `comp_id` INT(11), `from_limit` INT(4), `to_limit` INT(4))  BEGIN
		SELECT pj.ID, pj.job_title, pj.job_slug, pj.job_description, pj.employer_ID, pj.last_date, pj.dated, pj.city, pj.is_featured, pj.sts, pc.company_name, pc.company_logo
	FROM `pp_post_jobs` AS pj
	INNER JOIN pp_companies AS pc ON pj.company_ID=pc.ID
	WHERE pj.company_ID=comp_id AND pj.sts='active' AND pc.sts = 'active'
	ORDER BY ID DESC
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_active_posted_job_by_id` (IN `job_id` INT(11))  BEGIN
	SELECT pp_post_jobs.*, pc.ID AS CID, emp.first_name, emp.email AS employer_email, pp_job_industries.industry_name, pc.company_name, pc.company_email, pc.company_ceo, pc.company_description, pc.company_logo, pc.company_phone, pc.company_website, pc.company_fax,pc.no_of_offices, pc.no_of_employees, pc.established_in, pc.industry_ID AS cat_ID, pc.company_location, pc.company_slug
,emp.city as emp_city, emp.country as emp_country	
FROM `pp_post_jobs` 
	INNER JOIN pp_companies AS pc ON pp_post_jobs.company_ID=pc.ID
	INNER JOIN pp_employers AS emp ON pc.ID=emp.company_ID
	INNER JOIN pp_job_industries ON pp_post_jobs.industry_ID=pp_job_industries.ID
	WHERE pp_post_jobs.ID=job_id AND pp_post_jobs.sts='active' AND pc.sts = 'active';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_active_employers` (IN `from_limit` INT(5), `to_limit` INT(5))  BEGIN
	SELECT pc.ID AS CID, pc.company_name, pc.company_logo, pc.company_slug
	FROM `pp_employers` emp 
	INNER JOIN pp_companies AS pc ON emp.company_ID=pc.ID
	WHERE emp.sts = 'active'
	ORDER BY emp.ID DESC 
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_active_top_employers` (IN `from_limit` INT(5), `to_limit` INT(5))  BEGIN
	SELECT pc.ID AS CID, pc.company_name, pc.company_logo, pc.company_slug
	FROM `pp_employers` emp 
	INNER JOIN pp_companies AS pc ON emp.company_ID=pc.ID
	WHERE emp.sts = 'active' AND emp.top_employer = 'yes'
	ORDER BY emp.ID DESC 
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_opened_jobs` (IN `from_limit` INT(5), `to_limit` INT(5))  BEGIN
	SELECT pj.ID, pj.job_title, pj.job_slug, pj.employer_ID, pj.company_ID, pj.job_description, pj.city, pj.dated, pj.last_date, pj.is_featured, pj.sts, pc.company_name, pc.company_logo, pc.company_slug, ji.industry_name 
	FROM `pp_post_jobs` pj 
	INNER JOIN pp_companies AS pc ON pj.company_ID=pc.ID
	INNER JOIN pp_job_industries AS ji ON pj.industry_ID=ji.ID
	WHERE pj.sts = 'active' AND pc.sts='active'
	ORDER BY pj.ID DESC 
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_posted_jobs` (IN `from_limit` INT(5), `to_limit` INT(5))  BEGIN
		SELECT pj.ID, pj.job_title, pj.job_slug, pj.employer_ID, pj.company_ID, pj.job_description, pj.city, pj.dated, pj.last_date, pj.is_featured, pj.sts, pc.company_name, pc.company_logo, pc.company_slug, pj.ip_address 
	FROM `pp_post_jobs` pj 
	INNER JOIN pp_companies AS pc ON pj.company_ID=pc.ID 
	ORDER BY ID DESC 
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_posted_jobs_by_company_id_frontend` (IN `comp_id` INT(11), `from_limit` INT(4), `to_limit` INT(4))  BEGIN
		SELECT pj.ID, pj.job_title, pj.job_slug, pj.job_description, pj.employer_ID, pj.last_date, pj.dated, pj.city, pj.is_featured, pj.sts, pc.company_name, pc.company_logo
	FROM `pp_post_jobs` AS pj
	INNER JOIN pp_companies AS pc ON pj.company_ID=pc.ID
	WHERE pj.company_ID=comp_id AND pj.sts='active' AND pc.sts = 'active'
	ORDER BY ID DESC
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_posted_jobs_by_status` (IN `job_status` VARCHAR(10), `from_limit` INT(5), `to_limit` INT(5))  BEGIN
		SELECT pj.ID, pj.job_title, pj.job_slug, pj.employer_ID, pj.company_ID, pj.job_description, pj.city, pj.dated, pj.last_date, pj.is_featured, pj.sts, pc.company_name, pc.company_logo, pc.company_slug 
	FROM `pp_post_jobs` pj 
	INNER JOIN pp_companies AS pc ON pj.company_ID=pc.ID
	WHERE pj.sts = job_status
	ORDER BY ID DESC 
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_applied_jobs_by_employer_id` (IN `employer_id` INT(11), `from_limit` INT(5), `to_limit` INT(5))  BEGIN
	SELECT pp_seeker_applied_for_job.dated AS applied_date, pp_post_jobs.ID, pp_post_jobs.job_title, pp_job_seekers.ID AS job_seeker_ID, pp_post_jobs.job_slug, pp_job_seekers.first_name, pp_job_seekers.last_name, pp_job_seekers.slug
	FROM `pp_seeker_applied_for_job`
	INNER JOIN pp_post_jobs ON pp_post_jobs.ID=pp_seeker_applied_for_job.job_ID
	INNER JOIN pp_job_seekers ON pp_job_seekers.ID=pp_seeker_applied_for_job.seeker_ID
	WHERE pp_post_jobs.employer_ID=employer_id 
	ORDER BY pp_seeker_applied_for_job.ID DESC 
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_applied_jobs_by_jobseeker_id` (IN `jobseeker_id` INT(11), `from_limit` INT(5), `to_limit` INT(5))  BEGIN
	SELECT pp_seeker_applied_for_job.ID as applied_id, pp_seeker_applied_for_job.dated AS applied_date, pp_post_jobs.ID, pp_post_jobs.job_title, pp_post_jobs.job_slug, pp_companies.company_name, pp_companies.company_slug, pp_companies.company_logo 
	FROM `pp_seeker_applied_for_job`
	INNER JOIN pp_post_jobs ON pp_post_jobs.ID=pp_seeker_applied_for_job.job_ID
	INNER JOIN pp_employers ON pp_employers.ID=pp_post_jobs.employer_ID
	INNER JOIN pp_companies ON pp_companies.ID=pp_employers.company_ID
	WHERE pp_seeker_applied_for_job.seeker_ID=jobseeker_id 
	ORDER BY pp_seeker_applied_for_job.ID DESC 
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_applied_jobs_by_seeker_id` (IN `applicant_id` INT(11), `from_limit` INT(5), `to_limit` INT(5))  BEGIN
		SELECT aj.*, pp_post_jobs.ID AS posted_job_id, pp_post_jobs.employer_ID, pp_post_jobs.job_title, pp_post_jobs.job_slug, pp_post_jobs.city, pp_post_jobs.is_featured, pp_post_jobs.sts, pp_companies.company_name, pp_companies.company_logo, pp_job_seekers.first_name, pp_job_seekers.last_name, pp_job_seekers.photo
	FROM `pp_seeker_applied_for_job` aj
	INNER JOIN pp_job_seekers ON aj.seeker_ID=pp_job_seekers.ID
	INNER JOIN pp_post_jobs ON aj.job_ID=pp_post_jobs.ID
	INNER JOIN pp_companies ON pp_post_jobs.company_ID=pp_companies.ID
	WHERE aj.seeker_ID=applicant_id
	ORDER BY ID DESC
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_company_by_slug` (IN `slug` VARCHAR(70))  BEGIN
	SELECT emp.ID AS empID, pc.ID, emp.country, emp.city, pc.company_name, pc.company_description, pc.company_location, pc.company_website, pc.no_of_employees, pc.established_in, pc.company_logo, pc.company_slug
	FROM `pp_employers` AS emp 
	INNER JOIN pp_companies AS pc ON emp.company_ID=pc.ID
	WHERE pc.company_slug=slug AND emp.sts='active';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_experience_by_jobseeker_id` (IN `jobseeker_id` INT(11))  BEGIN
	SELECT pp_seeker_experience.* 
	FROM `pp_seeker_experience`
	WHERE pp_seeker_experience.seeker_ID=jobseeker_id 
	ORDER BY pp_seeker_experience.start_date DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_featured_job` (IN `from_limit` INT(5), `to_limit` INT(5))  BEGIN
		SELECT pj.ID, pj.job_title, pj.job_slug, pj.employer_ID, pj.company_ID, pj.city, pj.dated, pj.last_date, pj.is_featured, pj.sts, pc.company_name, pc.company_logo, pc.company_slug 
	FROM `pp_post_jobs` pj 
	LEFT JOIN pp_companies AS pc ON pj.company_ID=pc.ID 
	WHERE pj.is_featured='yes'
	ORDER BY ID DESC 
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_latest_posted_job_by_employer_ID` (IN `emp_id` INT(11), `from_limit` INT(4), `to_limit` INT(4))  BEGIN
		SELECT pp_post_jobs.ID, pp_post_jobs.job_title, pp_post_jobs.job_slug, pp_post_jobs.employer_ID, pp_post_jobs.last_date, pp_post_jobs.dated, pp_post_jobs.city, pp_post_jobs.is_featured, pp_post_jobs.sts, pp_job_industries.industry_name, pc.company_name, pc.company_logo
	FROM `pp_post_jobs` 
	INNER JOIN pp_companies AS pc ON pp_post_jobs.company_ID=pc.ID
	INNER JOIN pp_employers AS emp ON pp_post_jobs.employer_ID=emp.ID
	INNER JOIN pp_job_industries ON pp_post_jobs.industry_ID=pp_job_industries.ID
	WHERE pp_post_jobs.employer_ID=emp_id
	ORDER BY ID DESC
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_opened_jobs_home_page` (IN `from_limit` INT(5), `to_limit` INT(5))  BEGIN
set @prev := 0, @rownum := '';
SELECT ID, job_title, job_slug, employer_ID, company_ID, job_description, city, dated, last_date, is_featured, sts, company_name, company_logo, company_slug, industry_name 
FROM (
  SELECT ID, job_title, job_slug, employer_ID, company_ID, job_description, city, dated, last_date, is_featured, sts, company_name, company_logo, company_slug, industry_name, 
         IF( @prev <> company_ID, 
             @rownum := 1, 
             @rownum := @rownum+1 
         ) AS rank, @prev := company_ID, 
         @rownum  
			FROM (
					SELECT pj.ID, pj.job_title, pj.job_slug, pj.employer_ID, pj.company_ID, pj.job_description, pj.city, pj.dated, pj.last_date, pj.is_featured, pj.sts, company_name, company_logo, company_slug, industry_name 
					FROM pp_post_jobs AS pj
					INNER JOIN pp_companies AS pc ON pj.company_ID=pc.ID
					INNER JOIN pp_job_industries AS ji ON pj.industry_ID=ji.ID	
					WHERE pj.sts = 'active' AND pc.sts='active'
					ORDER BY company_ID DESC, ID DESC
			) pj
) jobs_ranked 
WHERE jobs_ranked.rank <= 2
ORDER BY jobs_ranked.ID DESC 
LIMIT from_limit,to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_posted_job_by_company_id` (IN `comp_id` INT(11), `from_limit` INT(4), `to_limit` INT(4))  BEGIN
		SELECT pp_post_jobs.ID, pp_post_jobs.job_title, pp_post_jobs.job_slug, pp_post_jobs.employer_ID, pp_post_jobs.last_date, pp_post_jobs.dated, pp_post_jobs.city, pp_post_jobs.job_description, pp_post_jobs.is_featured, pp_post_jobs.sts, pp_job_industries.industry_name, pc.company_name, pc.company_logo
	FROM `pp_post_jobs` 
	INNER JOIN pp_companies AS pc ON pp_post_jobs.company_ID=pc.ID
	INNER JOIN pp_job_industries ON pp_post_jobs.industry_ID=pp_job_industries.ID
	WHERE pp_post_jobs.company_ID=comp_id
	ORDER BY ID DESC
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_posted_job_by_employer_id` (IN `emp_id` INT(11), `from_limit` INT(4), `to_limit` INT(4))  BEGIN
		SELECT pp_post_jobs.ID, pp_post_jobs.job_title, pp_post_jobs.job_slug, pp_post_jobs.job_description, pp_post_jobs.contact_person, pp_post_jobs.contact_email, pp_post_jobs.contact_phone, pp_post_jobs.employer_ID, pp_post_jobs.last_date, pp_post_jobs.dated, pp_post_jobs.city, pp_post_jobs.is_featured, pp_post_jobs.sts, pp_job_industries.industry_name, pc.company_name, pc.company_logo
	FROM `pp_post_jobs` 
	INNER JOIN pp_companies AS pc ON pp_post_jobs.company_ID=pc.ID
	INNER JOIN pp_employers AS emp ON pp_post_jobs.employer_ID=emp.ID
	INNER JOIN pp_job_industries ON pp_post_jobs.industry_ID=pp_job_industries.ID
	WHERE pp_post_jobs.employer_ID=emp_id
	ORDER BY ID DESC
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_posted_job_by_id` (IN `job_id` INT(11))  BEGIN
		SELECT pp_post_jobs.*, pc.ID AS CID, pp_job_industries.industry_name, pc.company_name, pc.company_email, pc.company_ceo, pc.company_description, pc.company_logo, pc.company_phone, pc.company_website, pc.company_fax,pc.no_of_offices, pc.no_of_employees, pc.established_in, pc.industry_ID AS cat_ID, pc.company_location, pc.company_slug
,em.city as emp_city, em.country as emp_country
	FROM `pp_post_jobs` 
	INNER JOIN pp_companies AS pc ON pp_post_jobs.company_ID=pc.ID
  INNER JOIN pp_employers AS em ON pc.ID=em.company_ID
	INNER JOIN pp_job_industries ON pp_post_jobs.industry_ID=pp_job_industries.ID
	WHERE pp_post_jobs.ID=job_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_posted_job_by_id_employer_id` (IN `job_id` INT(11), `emp_id` INT(11))  BEGIN
	SELECT pp_post_jobs.*, pc.ID AS CID, pp_job_industries.industry_name, pc.company_name, pc.company_email, pc.company_ceo, pc.company_description, pc.company_logo, pc.company_phone, pc.company_website, pc.company_fax,pc.no_of_offices, pc.no_of_employees, pc.established_in, pc.industry_ID AS cat_ID, pc.company_location, pc.company_slug
	FROM `pp_post_jobs` 
	INNER JOIN pp_companies AS pc ON pp_post_jobs.company_ID=pc.ID
	INNER JOIN pp_employers AS emp ON pp_post_jobs.employer_ID=emp.ID
	INNER JOIN pp_job_industries ON pp_post_jobs.industry_ID=pp_job_industries.ID
	WHERE pp_post_jobs.ID=job_id AND pp_post_jobs.employer_ID=emp_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_qualification_by_jobseeker_id` (IN `jobseeker_id` INT(11))  BEGIN
	SELECT pp_seeker_academic.* 
	FROM `pp_seeker_academic`
	WHERE pp_seeker_academic.seeker_ID=jobseeker_id 
	ORDER BY pp_seeker_academic.completion_year DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `job_search_by_city` (IN `param_city` VARCHAR(255), `from_limit` INT(5), `to_limit` INT(5))  BEGIN
	SELECT pj.ID, pj.job_title, pj.job_slug, pj.employer_ID, pj.company_ID, pj.job_description, pj.city, pj.dated, pj.last_date, pj.is_featured, pj.sts, pc.company_name, pc.company_logo, pc.company_slug
	FROM pp_post_jobs pj
	INNER JOIN pp_companies pc ON pc.ID = pj.company_ID 
	WHERE pj.city = param_city AND pj.sts = 'active' AND pc.sts = 'active'
	ORDER BY pj.dated DESC
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `job_search_by_industry` (IN `param` VARCHAR(255), `from_limit` INT(5), `to_limit` INT(5))  BEGIN
	SELECT pj.ID, pj.job_title, pj.job_slug, pj.employer_ID, pj.company_ID, pj.job_description, pj.city, pj.dated, pj.last_date, pj.is_featured, pj.sts, pc.company_name, pc.company_logo, pc.company_slug
	FROM pp_post_jobs pj
	INNER JOIN pp_companies pc ON pc.ID = pj.company_ID 
	WHERE pj.industry_ID = param AND pj.sts = 'active' AND pc.sts = 'active'
	ORDER BY pj.dated DESC
	LIMIT from_limit, to_limit;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `search_posted_jobs` (IN `where_condition` VARCHAR(255), `from_limit` INT(11), `to_limit` INT(11))  BEGIN
	SET @query = "SELECT pj.ID, pj.job_title,  pj.job_slug, pj.employer_ID, pj.company_ID, pj.city, pj.dated, pj.last_date, pj.is_featured, pj.sts, pc.company_name, pc.company_logo 
	FROM `pp_post_jobs` pj 
	LEFT JOIN pp_companies AS pc ON pj.company_ID=pc.ID 
	WHERE
";

SET @where_clause = CONCAT(where_condition);
SET @after_where_clause = CONCAT("ORDER BY ID DESC LIMIT ",from_limit,", ",to_limit,"");
SET @full_search_clause = CONCAT(@where_clause, @after_where_clause);
SET @query = CONCAT(@query, @full_search_clause);

PREPARE stmt FROM @query;
EXECUTE stmt;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `pp_admin`
--

CREATE TABLE `pp_admin` (
  `id` int(8) NOT NULL,
  `admin_username` varchar(80) DEFAULT NULL,
  `admin_password` varchar(100) DEFAULT NULL,
  `type` tinyint(1) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_admin`
--

INSERT INTO `pp_admin` (`id`, `admin_username`, `admin_password`, `type`) VALUES
(1, 'demo', 'demo123456', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pp_ad_codes`
--

CREATE TABLE `pp_ad_codes` (
  `ID` int(4) NOT NULL,
  `bottom` text,
  `right_side_1` text,
  `right_side_2` text,
  `google_analytics` text
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_ad_codes`
--

INSERT INTO `pp_ad_codes` (`ID`, `bottom`, `right_side_1`, `right_side_2`, `google_analytics`) VALUES
(1, '<a href=\"#\"><img src=\"data:image/jpeg;base64,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\" /></a>', '<a href=\"#\"><img src=\"http://thefbdirectory.com/facebookadsmagic/images/Facebook-Affiliate%20Banner-160x600.png\" /></a>', '<a href=\"#\"><img src=\"http://thefbdirectory.com/facebookadsmagic/images/Facebook-Affiliate%20Banner-160x600.png\" /></a>', '');

-- --------------------------------------------------------

--
-- Table structure for table `pp_cities`
--

CREATE TABLE `pp_cities` (
  `ID` int(11) NOT NULL,
  `show` tinyint(1) NOT NULL DEFAULT '1',
  `city_slug` varchar(150) NOT NULL,
  `city_name` varchar(150) DEFAULT NULL,
  `sort_order` int(3) NOT NULL DEFAULT '998',
  `country_ID` int(11) NOT NULL,
  `is_popular` enum('yes','no') NOT NULL DEFAULT 'no'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_cities`
--

INSERT INTO `pp_cities` (`ID`, `show`, `city_slug`, `city_name`, `sort_order`, `country_ID`, `is_popular`) VALUES
(27, 1, '', 'Sunyani', 998, 0, 'no'),
(28, 1, '', 'Wa', 998, 0, 'no'),
(29, 1, '', 'Cape Coast', 998, 0, 'no'),
(21, 1, '', 'Kumasi', 998, 0, 'no'),
(22, 1, '', 'Takoradi', 998, 0, 'no'),
(26, 1, '', 'Tamale', 998, 0, 'no'),
(23, 1, '', 'Tema', 998, 0, 'no'),
(24, 1, '', 'Ho', 998, 0, 'no'),
(25, 1, '', 'Bolgatanga', 998, 0, 'no'),
(20, 1, '', 'Accra', 998, 0, 'no');

-- --------------------------------------------------------

--
-- Table structure for table `pp_cms`
--

CREATE TABLE `pp_cms` (
  `pageID` int(11) NOT NULL,
  `pageTitle` varchar(100) DEFAULT NULL,
  `pageSlug` varchar(100) DEFAULT NULL,
  `pageContent` text,
  `pageImage` varchar(100) DEFAULT NULL,
  `pageParentPageID` int(11) DEFAULT '0',
  `dated` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `pageStatus` enum('Inactive','Published') DEFAULT 'Inactive',
  `seoMetaTitle` varchar(100) DEFAULT NULL,
  `seoMetaKeyword` varchar(255) DEFAULT NULL,
  `seoMetaDescription` varchar(255) DEFAULT NULL,
  `seoAllowCrawler` tinyint(1) DEFAULT '1',
  `pageCss` text,
  `pageScript` text,
  `menuTop` tinyint(4) DEFAULT '0',
  `menuBottom` tinyint(4) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_cms`
--

INSERT INTO `pp_cms` (`pageID`, `pageTitle`, `pageSlug`, `pageContent`, `pageImage`, `pageParentPageID`, `dated`, `pageStatus`, `seoMetaTitle`, `seoMetaKeyword`, `seoMetaDescription`, `seoAllowCrawler`, `pageCss`, `pageScript`, `menuTop`, `menuBottom`) VALUES
(7, 'About Dela', 'about-us.html', 'My name is Dela', 'about-company1.jpg', 0, '2019-01-14 13:39:41', 'Published', 'About Us', 'About Job Portal, Jobs, IT', 'The leading online job portal', 1, NULL, NULL, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `pp_cms_previous`
--

CREATE TABLE `pp_cms_previous` (
  `ID` int(11) NOT NULL,
  `page` varchar(60) DEFAULT NULL,
  `heading` varchar(155) DEFAULT NULL,
  `content` text,
  `page_slug` varchar(100) DEFAULT NULL,
  `sts` enum('blocked','active') DEFAULT 'active',
  `dated` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_cms_previous`
--

INSERT INTO `pp_cms_previous` (`ID`, `page`, `heading`, `content`, `page_slug`, `sts`, `dated`) VALUES
(4, NULL, 'About Us', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi a velit sed risus pulvinar faucibus. Nulla facilisi. Nullam vehicula nec ligula eu vulputate. Nunc id ultrices mi, ac tristique lectus. Suspendisse porta ultrices ultricies. Sed quis nisi vel magna maximus aliquam a vel nisl. Cras non rutrum diam. Nulla sed ipsum a felis posuere pharetra ut sit amet augue. Sed id nisl sodales, vulputate mi eu, viverra neque. Fusce fermentum, est ut accumsan accumsan, risus ante varius diam, non venenatis eros ligula fermentum leo. Etiam consectetur imperdiet volutpat. Donec ut pharetra nisi, eget pellentesque tortor. Integer eleifend dolor eu ex lobortis, ac gravida augue tristique. Proin placerat consectetur tincidunt. Nullam sollicitudin, neque eget iaculis ultricies, est justo pulvinar turpis, vulputate convallis leo orci at sapien.\n<br /><br />\nQuisque ac scelerisque libero, nec blandit neque. Nullam felis nisl, elementum eu sapien ut, convallis interdum felis. In turpis odio, fermentum non pulvinar gravida, posuere quis magna. Ut mollis eget neque at euismod. Interdum et malesuada fames ac ante ipsum primis in faucibus. Integer faucibus orci a pulvinar malesuada. Aenean at felis vitae lorem venenatis consequat. Nam non nunc euismod, consequat ligula non, tristique odio. Ut leo sapien, aliquet sed ultricies et, scelerisque quis nulla. Aenean non sapien maximus, convallis eros vitae, iaculis massa. In fringilla hendrerit nisi, eu pellentesque massa faucibus molestie. Etiam laoreet eros quis faucibus rutrum. Quisque eleifend purus justo, eget tempus quam interdum non.\n<br /><br />\nNullam enim ex, vulputate at ultricies bibendum, interdum sit amet tortor. Fusce semper augue ac ipsum ultricies interdum. Cras maximus faucibus sapien, et lacinia leo efficitur id. Nullam laoreet pulvinar nibh et ullamcorper. Etiam a lorem rhoncus, rutrum felis sed, blandit orci. Nulla vel tellus gravida, pretium neque a, fringilla lectus. Morbi et leo mi. Aliquam interdum ex ipsum. Vivamus eu ultrices ante, eget volutpat massa. Nulla nisi purus, sollicitudin euismod eleifend pulvinar, dictum rutrum lacus. Nam hendrerit sed arcu a pellentesque. Vestibulum maximus ligula tellus, a euismod dui feugiat et. Aliquam viverra blandit est nec ultricies.\n<br /><br />\nNullam et sem a dui accumsan ornare. Praesent faucibus ultricies orci. Maecenas hendrerit tincidunt rutrum. Phasellus eget libero eget ante interdum venenatis. Cras sodales finibus vulputate. Aenean aliquet velit eget felis pellentesque, et blandit ex facilisis. Vivamus sit amet euismod diam, at rhoncus ex. Nullam consectetur, erat ut maximus dignissim, ex eros pellentesque ex, at dictum odio dui in urna. Nulla rutrum nisi eget risus accumsan, sit amet iaculis risus interdum. Curabitur accumsan eu purus nec condimentum. Fusce pulvinar ex id sagittis sodales. Donec hendrerit scelerisque est, in viverra nibh lobortis et.\n<br /><br />\n<ul>\n<li>Quisque facilisis purus vel sem laoreet posuere.</li>\n<li>Proin eleifend velit ut elit sollicitudin scelerisque.</li>\n<li>Nulla aliquet urna in magna congue, ac hendrerit velit lacinia.</li>\n<li>Aliquam id urna ut lorem porta vulputate.</li>\n<li>Sed ultrices sem quis risus tincidunt, ut lacinia nunc aliquet.</li>\n<li>Phasellus in est suscipit, feugiat tortor ac, iaculis enim.</li>\n</ul>', 'about_us.html', 'active', '2014-05-16 13:47:11'),
(12, NULL, 'First Day of New Job', '<strong>Lorem Ipsum</strong> is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry&#39;s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.<br />\r\n<br />\r\n<strong>Lorem Ipsum</strong> is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry&#39;s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.<br />\r\n<br />\r\n<strong>Lorem Ipsum</strong> is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry&#39;s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.<br />\r\n&nbsp;', 'first_day_job.html', 'active', '2014-05-16 14:46:14'),
(13, NULL, 'Privacy Policy', '<strong>Lorem Ipsum</strong>&nbsp;is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry&#39;s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.<br />\n<br />\n<strong>Lorem Ipsum</strong>&nbsp;is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry&#39;s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.<br />\n<br />\n<strong>Lorem Ipsum</strong>&nbsp;is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry&#39;s standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.', 'privacy-policy.html', 'active', '2015-05-20 23:38:56'),
(15, NULL, 'Why Job', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi a velit sed risus pulvinar faucibus. Nulla facilisi. Nullam vehicula nec ligula eu vulputate. Nunc id ultrices mi, ac tristique lectus. Suspendisse porta ultrices ultricies. Sed quis nisi vel magna maximus aliquam a vel nisl. Cras non rutrum diam. Nulla sed ipsum a felis posuere pharetra ut sit amet augue. Sed id nisl sodales, vulputate mi eu, viverra neque. Fusce fermentum, est ut accumsan accumsan, risus ante varius diam, non venenatis eros ligula fermentum leo. Etiam consectetur imperdiet volutpat. Donec ut pharetra nisi, eget pellentesque tortor. Integer eleifend dolor eu ex lobortis, ac gravida augue tristique. Proin placerat consectetur tincidunt. Nullam sollicitudin, neque eget iaculis ultricies, est justo pulvinar turpis, vulputate convallis leo orci at sapien.<br />\n<br />\nQuisque ac scelerisque libero, nec blandit neque. Nullam felis nisl, elementum eu sapien ut, convallis interdum felis. In turpis odio, fermentum non pulvinar gravida, posuere quis magna. Ut mollis eget neque at euismod. Interdum et malesuada fames ac ante ipsum primis in faucibus. Integer faucibus orci a pulvinar malesuada. Aenean at felis vitae lorem venenatis consequat. Nam non nunc euismod, consequat ligula non, tristique odio. Ut leo sapien, aliquet sed ultricies et, scelerisque quis nulla. Aenean non sapien maximus, convallis eros vitae, iaculis massa. In fringilla hendrerit nisi, eu pellentesque massa faucibus molestie. Etiam laoreet eros quis faucibus rutrum. Quisque eleifend purus justo, eget tempus quam interdum non.<br />\n<br />\nNullam enim ex, vulputate at ultricies bibendum, interdum sit amet tortor. Fusce semper augue ac ipsum ultricies interdum. Cras maximus faucibus sapien, et lacinia leo efficitur id. Nullam laoreet pulvinar nibh et ullamcorper. Etiam a lorem rhoncus, rutrum felis sed, blandit orci. Nulla vel tellus gravida, pretium neque a, fringilla lectus. Morbi et leo mi. Aliquam interdum ex ipsum. Vivamus eu ultrices ante, eget volutpat massa. Nulla nisi purus, sollicitudin euismod eleifend pulvinar, dictum rutrum lacus. Nam hendrerit sed arcu a pellentesque. Vestibulum maximus ligula tellus, a euismod dui feugiat et. Aliquam viverra blandit est nec ultricies.<br />\n<br />\nNullam et sem a dui accumsan ornare. Praesent faucibus ultricies orci. Maecenas hendrerit tincidunt rutrum. Phasellus eget libero eget ante interdum venenatis. Cras sodales finibus vulputate. Aenean aliquet velit eget felis pellentesque, et blandit ex facilisis. Vivamus sit amet euismod diam, at rhoncus ex. Nullam consectetur, erat ut maximus dignissim, ex eros pellentesque ex, at dictum odio dui in urna. Nulla rutrum nisi eget risus accumsan, sit amet iaculis risus interdum. Curabitur accumsan eu purus nec condimentum. Fusce pulvinar ex id sagittis sodales. Donec hendrerit scelerisque est, in viverra nibh lobortis et.', 'why_job.html', 'active', '2016-03-12 16:12:11'),
(16, NULL, 'Preparing for Interview', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi a velit sed risus pulvinar faucibus. Nulla facilisi. Nullam vehicula nec ligula eu vulputate. Nunc id ultrices mi, ac tristique lectus. Suspendisse porta ultrices ultricies. Sed quis nisi vel magna maximus aliquam a vel nisl. Cras non rutrum diam. Nulla sed ipsum a felis posuere pharetra ut sit amet augue. Sed id nisl sodales, vulputate mi eu, viverra neque. Fusce fermentum, est ut accumsan accumsan, risus ante varius diam, non venenatis eros ligula fermentum leo. Etiam consectetur imperdiet volutpat. Donec ut pharetra nisi, eget pellentesque tortor. Integer eleifend dolor eu ex lobortis, ac gravida augue tristique. Proin placerat consectetur tincidunt. Nullam sollicitudin, neque eget iaculis ultricies, est justo pulvinar turpis, vulputate convallis leo orci at sapien.\n<br /><br />\nQuisque ac scelerisque libero, nec blandit neque. Nullam felis nisl, elementum eu sapien ut, convallis interdum felis. In turpis odio, fermentum non pulvinar gravida, posuere quis magna. Ut mollis eget neque at euismod. Interdum et malesuada fames ac ante ipsum primis in faucibus. Integer faucibus orci a pulvinar malesuada. Aenean at felis vitae lorem venenatis consequat. Nam non nunc euismod, consequat ligula non, tristique odio. Ut leo sapien, aliquet sed ultricies et, scelerisque quis nulla. Aenean non sapien maximus, convallis eros vitae, iaculis massa. In fringilla hendrerit nisi, eu pellentesque massa faucibus molestie. Etiam laoreet eros quis faucibus rutrum. Quisque eleifend purus justo, eget tempus quam interdum non.\n<br /><br />\nNullam enim ex, vulputate at ultricies bibendum, interdum sit amet tortor. Fusce semper augue ac ipsum ultricies interdum. Cras maximus faucibus sapien, et lacinia leo efficitur id. Nullam laoreet pulvinar nibh et ullamcorper. Etiam a lorem rhoncus, rutrum felis sed, blandit orci. Nulla vel tellus gravida, pretium neque a, fringilla lectus. Morbi et leo mi. Aliquam interdum ex ipsum. Vivamus eu ultrices ante, eget volutpat massa. Nulla nisi purus, sollicitudin euismod eleifend pulvinar, dictum rutrum lacus. Nam hendrerit sed arcu a pellentesque. Vestibulum maximus ligula tellus, a euismod dui feugiat et. Aliquam viverra blandit est nec ultricies.\n<br /><br />\nNullam et sem a dui accumsan ornare. Praesent faucibus ultricies orci. Maecenas hendrerit tincidunt rutrum. Phasellus eget libero eget ante interdum venenatis. Cras sodales finibus vulputate. Aenean aliquet velit eget felis pellentesque, et blandit ex facilisis. Vivamus sit amet euismod diam, at rhoncus ex. Nullam consectetur, erat ut maximus dignissim, ex eros pellentesque ex, at dictum odio dui in urna. Nulla rutrum nisi eget risus accumsan, sit amet iaculis risus interdum. Curabitur accumsan eu purus nec condimentum. Fusce pulvinar ex id sagittis sodales. Donec hendrerit scelerisque est, in viverra nibh lobortis et.\n<br /><br />\n<ul>\n<li>Quisque facilisis purus vel sem laoreet posuere.</li>\n<li>Proin eleifend velit ut elit sollicitudin scelerisque.</li>\n<li>Nulla aliquet urna in magna congue, ac hendrerit velit lacinia.</li>\n<li>Aliquam id urna ut lorem porta vulputate.</li>\n<li>Sed ultrices sem quis risus tincidunt, ut lacinia nunc aliquet.</li>\n<li>Phasellus in est suscipit, feugiat tortor ac, iaculis enim.</li>\n</ul>', 'interview.html', 'active', '2016-03-12 16:17:56'),
(17, NULL, 'CV Writing Tips', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi a velit sed risus pulvinar faucibus. Nulla facilisi. Nullam vehicula nec ligula eu vulputate. Nunc id ultrices mi, ac tristique lectus. Suspendisse porta ultrices ultricies. Sed quis nisi vel magna maximus aliquam a vel nisl. Cras non rutrum diam. Nulla sed ipsum a felis posuere pharetra ut sit amet augue. Sed id nisl sodales, vulputate mi eu, viverra neque. Fusce fermentum, est ut accumsan accumsan, risus ante varius diam, non venenatis eros ligula fermentum leo. Etiam consectetur imperdiet volutpat. Donec ut pharetra nisi, eget pellentesque tortor. Integer eleifend dolor eu ex lobortis, ac gravida augue tristique. Proin placerat consectetur tincidunt. Nullam sollicitudin, neque eget iaculis ultricies, est justo pulvinar turpis, vulputate convallis leo orci at sapien.\n<br /><br />\nQuisque ac scelerisque libero, nec blandit neque. Nullam felis nisl, elementum eu sapien ut, convallis interdum felis. In turpis odio, fermentum non pulvinar gravida, posuere quis magna. Ut mollis eget neque at euismod. Interdum et malesuada fames ac ante ipsum primis in faucibus. Integer faucibus orci a pulvinar malesuada. Aenean at felis vitae lorem venenatis consequat. Nam non nunc euismod, consequat ligula non, tristique odio. Ut leo sapien, aliquet sed ultricies et, scelerisque quis nulla. Aenean non sapien maximus, convallis eros vitae, iaculis massa. In fringilla hendrerit nisi, eu pellentesque massa faucibus molestie. Etiam laoreet eros quis faucibus rutrum. Quisque eleifend purus justo, eget tempus quam interdum non.\n<br /><br />\nNullam enim ex, vulputate at ultricies bibendum, interdum sit amet tortor. Fusce semper augue ac ipsum ultricies interdum. Cras maximus faucibus sapien, et lacinia leo efficitur id. Nullam laoreet pulvinar nibh et ullamcorper. Etiam a lorem rhoncus, rutrum felis sed, blandit orci. Nulla vel tellus gravida, pretium neque a, fringilla lectus. Morbi et leo mi. Aliquam interdum ex ipsum. Vivamus eu ultrices ante, eget volutpat massa. Nulla nisi purus, sollicitudin euismod eleifend pulvinar, dictum rutrum lacus. Nam hendrerit sed arcu a pellentesque. Vestibulum maximus ligula tellus, a euismod dui feugiat et. Aliquam viverra blandit est nec ultricies.\n<br /><br />\nNullam et sem a dui accumsan ornare. Praesent faucibus ultricies orci. Maecenas hendrerit tincidunt rutrum. Phasellus eget libero eget ante interdum venenatis. Cras sodales finibus vulputate. Aenean aliquet velit eget felis pellentesque, et blandit ex facilisis. Vivamus sit amet euismod diam, at rhoncus ex. Nullam consectetur, erat ut maximus dignissim, ex eros pellentesque ex, at dictum odio dui in urna. Nulla rutrum nisi eget risus accumsan, sit amet iaculis risus interdum. Curabitur accumsan eu purus nec condimentum. Fusce pulvinar ex id sagittis sodales. Donec hendrerit scelerisque est, in viverra nibh lobortis et.\n<br /><br />\n<ul>\n<li>Quisque facilisis purus vel sem laoreet posuere.</li>\n<li>Proin eleifend velit ut elit sollicitudin scelerisque.</li>\n<li>Nulla aliquet urna in magna congue, ac hendrerit velit lacinia.</li>\n<li>Aliquam id urna ut lorem porta vulputate.</li>\n<li>Sed ultrices sem quis risus tincidunt, ut lacinia nunc aliquet.</li>\n<li>Phasellus in est suscipit, feugiat tortor ac, iaculis enim.</li>\n</ul>', 'cv_tips.html', 'active', '2016-03-12 16:19:17'),
(18, NULL, 'How to get Job', 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi a velit sed risus pulvinar faucibus. Nulla facilisi. Nullam vehicula nec ligula eu vulputate. Nunc id ultrices mi, ac tristique lectus. Suspendisse porta ultrices ultricies. Sed quis nisi vel magna maximus aliquam a vel nisl. Cras non rutrum diam. Nulla sed ipsum a felis posuere pharetra ut sit amet augue. Sed id nisl sodales, vulputate mi eu, viverra neque. Fusce fermentum, est ut accumsan accumsan, risus ante varius diam, non venenatis eros ligula fermentum leo. Etiam consectetur imperdiet volutpat. Donec ut pharetra nisi, eget pellentesque tortor. Integer eleifend dolor eu ex lobortis, ac gravida augue tristique. Proin placerat consectetur tincidunt. Nullam sollicitudin, neque eget iaculis ultricies, est justo pulvinar turpis, vulputate convallis leo orci at sapien.<br />\n<br />\nQuisque ac scelerisque libero, nec blandit neque. Nullam felis nisl, elementum eu sapien ut, convallis interdum felis. In turpis odio, fermentum non pulvinar gravida, posuere quis magna. Ut mollis eget neque at euismod. Interdum et malesuada fames ac ante ipsum primis in faucibus. Integer faucibus orci a pulvinar malesuada. Aenean at felis vitae lorem venenatis consequat. Nam non nunc euismod, consequat ligula non, tristique odio. Ut leo sapien, aliquet sed ultricies et, scelerisque quis nulla. Aenean non sapien maximus, convallis eros vitae, iaculis massa. In fringilla hendrerit nisi, eu pellentesque massa faucibus molestie. Etiam laoreet eros quis faucibus rutrum. Quisque eleifend purus justo, eget tempus quam interdum non.<br />\n<br />\nNullam enim ex, vulputate at ultricies bibendum, interdum sit amet tortor. Fusce semper augue ac ipsum ultricies interdum. Cras maximus faucibus sapien, et lacinia leo efficitur id. Nullam laoreet pulvinar nibh et ullamcorper. Etiam a lorem rhoncus, rutrum felis sed, blandit orci. Nulla vel tellus gravida, pretium neque a, fringilla lectus. Morbi et leo mi. Aliquam interdum ex ipsum. Vivamus eu ultrices ante, eget volutpat massa. Nulla nisi purus, sollicitudin euismod eleifend pulvinar, dictum rutrum lacus. Nam hendrerit sed arcu a pellentesque. Vestibulum maximus ligula tellus, a euismod dui feugiat et. Aliquam viverra blandit est nec ultricies.<br />\n<br />\nNullam et sem a dui accumsan ornare. Praesent faucibus ultricies orci. Maecenas hendrerit tincidunt rutrum. Phasellus eget libero eget ante interdum venenatis. Cras sodales finibus vulputate. Aenean aliquet velit eget felis pellentesque, et blandit ex facilisis. Vivamus sit amet euismod diam, at rhoncus ex. Nullam consectetur, erat ut maximus dignissim, ex eros pellentesque ex, at dictum odio dui in urna. Nulla rutrum nisi eget risus accumsan, sit amet iaculis risus interdum. Curabitur accumsan eu purus nec condimentum. Fusce pulvinar ex id sagittis sodales. Donec hendrerit scelerisque est, in viverra nibh lobortis et.<br />\n<br />\nQuisque facilisis purus vel sem laoreet posuere.<br />\nProin eleifend velit ut elit sollicitudin scelerisque.<br />\nNulla aliquet urna in magna congue, ac hendrerit velit lacinia.<br />\nAliquam id urna ut lorem porta vulputate.<br />\nSed ultrices sem quis risus tincidunt, ut lacinia nunc aliquet.<br />\nPhasellus in est suscipit, feugiat tortor ac, iaculis enim.', 'how_to_get_job.html', 'active', '2016-03-12 16:21:26');

-- --------------------------------------------------------

--
-- Table structure for table `pp_companies`
--

CREATE TABLE `pp_companies` (
  `ID` int(11) NOT NULL,
  `company_name` varchar(155) DEFAULT NULL,
  `company_email` varchar(100) DEFAULT NULL,
  `company_ceo` varchar(60) DEFAULT NULL,
  `industry_ID` int(5) DEFAULT NULL,
  `ownership_type` enum('NGO','Private','Public') DEFAULT 'Private',
  `company_description` text,
  `company_location` varchar(155) DEFAULT NULL,
  `no_of_offices` int(11) DEFAULT NULL,
  `company_website` varchar(155) DEFAULT NULL,
  `no_of_employees` varchar(15) DEFAULT NULL,
  `established_in` varchar(12) DEFAULT NULL,
  `company_type` varchar(60) DEFAULT NULL,
  `company_fax` varchar(30) DEFAULT NULL,
  `company_phone` varchar(30) DEFAULT NULL,
  `company_logo` varchar(155) DEFAULT NULL,
  `company_folder` varchar(155) DEFAULT NULL,
  `company_country` varchar(80) DEFAULT NULL,
  `sts` enum('blocked','pending','active') DEFAULT 'active',
  `company_city` varchar(80) DEFAULT NULL,
  `company_slug` varchar(155) DEFAULT NULL,
  `old_company_id` int(11) DEFAULT NULL,
  `old_employerlogin` varchar(100) DEFAULT NULL,
  `flag` varchar(5) DEFAULT NULL,
  `ownership_type` varchar(20) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pp_countries`
--

CREATE TABLE `pp_countries` (
  `ID` int(11) NOT NULL,
  `country_name` varchar(150) NOT NULL DEFAULT '',
  `country_citizen` varchar(150) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pp_email_content`
--

CREATE TABLE `pp_email_content` (
  `ID` int(11) NOT NULL,
  `email_name` varchar(155) DEFAULT NULL,
  `from_name` varchar(155) DEFAULT NULL,
  `content` text,
  `from_email` varchar(90) DEFAULT NULL,
  `subject` varchar(155) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_email_content`
--

INSERT INTO `pp_email_content` (`ID`, `email_name`, `from_name`, `content`, `from_email`, `subject`) VALUES
(1, 'Forgot Password', 'MNO Jobs', '<style type=\"text/css\">\n				.txt {\n						font-family: Arial, Helvetica, sans-serif;\n						font-size: 13px; color:#000000;\n					}\n				</style>\n<p class=\"txt\">Thank you  for contacting Member Support. Your account information is listed below: </p>\n<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" width=\"600\" class=\"txt\">\n  <tr>\n    <td width=\"17\" height=\"19\"><p>&nbsp;</p></td>\n    <td width=\"159\" height=\"25\" align=\"right\"><strong>Login Page:&nbsp;&nbsp;</strong></td>\n    <td width=\"424\" align=\"left\"><a href=\"{SITE_URL}/login\">{SITE_URL}/login</a></td>\n  </tr>\n  <tr>\n    <td height=\"19\">&nbsp;</td>\n    <td height=\"25\" align=\"right\"><strong>Your Username:&nbsp;&nbsp;</strong></td>\n    <td align=\"left\">{USERNAME}</td>\n  </tr>\n  <tr>\n    <td height=\"19\"><p>&nbsp;</p></td>\n    <td height=\"25\" align=\"right\"><strong>Your Password:&nbsp;&nbsp;</strong></td>\n    <td align=\"left\">{PASSWORD}</td>\n  </tr>\n</table>\n\n<p class=\"txt\">Thank you,</p>', 'service@jobportalbeta.com', 'Password Recovery'),
(2, 'Jobseeker Signup', 'Jobseeker Signup Successful', '<style type=\"text/css\">p {font-family: Arial, Helvetica, sans-serif; font-size: 13px; color:#000000;}</style>\n\n  <p>{JOBSEEKER_NAME}:</p>\n  <p>Thank you for joining us. Please note your profile details for future record.</p>\n  <p>Username: {USERNAME}<br>\n    Password: {PASSWORD}</p>\n  \n  <p>Regards</p>', 'service@jobportalbeta.com', 'Jobs website'),
(3, 'Employer signs up', 'Employer Signup Successful', '<style type=\"text/css\">p {font-family: Arial, Helvetica, sans-serif; font-size: 13px; color:#000000;}</style>\n\n  <p>{EMPLOYER_NAME}</p>\n  <p>Thank you for joining us. Please note your profile details for future record.</p>\n  <p>Username: {USERNAME}<br>\n    Password: {PASSWORD}</p>\n  <p>Regards</p>', 'service@jobportalbeta.com', 'Jobs website'),
(4, 'New job is posted by Employer', 'New Job Posted', '<style type=\"text/css\">p {font-family: Arial, Helvetica, sans-serif; font-size: 13px; color:#000000;}</style>\n\n  <p>{JOBSEEKER_NAME},</p>\n  <p>We would like to inform  that a new job has been posted on our website that may be of your interest.</p>\n  <p>Please visit the  following link to review and apply:</p>\n <p>{JOB_LINK}</p>\n  <p>Regards,</p>', 'service@jobportalbeta.com', 'New {JOB_CATEGORY}'),
(5, 'Apply Job', 'Job Application', '<style type=\"text/css\">p {font-family: Arial, Helvetica, sans-serif; font-size: 13px; color:#000000;}</style>\n  <p>{EMPLOYER_NAME}:</p>\n  <p>A new candidate has applied for the post of {JOB_TITLE}.</p>\n  <p>Please visit the following link to review the applicant profile.<br>\n    {CANDIDATE_PROFILE_LINK}</p>\n  <p>Regards,</p>', 'service@jobportalbeta.com', 'New Job CV {JOB_TITLE}'),
(6, 'Job Activation Email', 'Job Activated', '<style type=\"text/css\">p {font-family: Arial, Helvetica, sans-serif; font-size: 13px; color:#000000;}</style>\n  <p>{EMPLOYER_NAME}:</p>\n  <p>You had recently posted a job: {JOB_TITLE} on our website.</p>\n  <p>Your recent job has been approved and should be displaying on our website.</p>\n  <p>Thank you for using our website.</p>\n  <p>Regards,</p>', 'service@jobportalbeta.com', '{JOB_TITLE}  is now active'),
(7, 'Send Message To Candidate', '{EMPLOYER_NAME}', '<style type=\"text/css\">p {font-family: Arial, Helvetica, sans-serif; font-size: 13px; color:#000000;}</style>\r\n  <p>Hi {JOBSEEKER_NAME}:</p>\r\n  <p>A new message has been posted for you by :  {COMPANY_NAME}.</p>\r\n  <p>Message:</p>\r\n  <p>{MESSAGE}</p>\r\n  <p>You may review this company by going to: {COMPANY_PROFILE_LINK} to company profile.</p>\r\n  \r\n  <p>Regards,</p>', '{EMPLOYER_EMAIL}', 'New message for you'),
(8, 'Scam Alert', '{JOBSEEKER_NAME}', 'bla bla bla', '{JOBSEEKER_EMAIL}', 'Company reported');

-- --------------------------------------------------------

--
-- Table structure for table `pp_employers`
--

CREATE TABLE `pp_employers` (
  `ID` int(11) NOT NULL,
  `company_ID` int(6) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `pass_code` varchar(100) DEFAULT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `country` varchar(100) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `mobile_phone` varchar(30) NOT NULL DEFAULT '',
  `gender` enum('female','male') DEFAULT NULL,
  `dated` date NOT NULL,
  `sts` enum('blocked','pending','active') NOT NULL DEFAULT 'active',
  `dob` date DEFAULT NULL,
  `home_phone` varchar(30) DEFAULT NULL,
  `verification_code` varchar(155) DEFAULT NULL,
  `first_login_date` datetime DEFAULT NULL,
  `last_login_date` datetime DEFAULT NULL,
  `ip_address` varchar(40) DEFAULT NULL,
  `old_emp_id` int(11) DEFAULT NULL,
  `flag` varchar(10) DEFAULT NULL,
  `present_address` varchar(155) DEFAULT NULL,
  `top_employer` enum('no','yes') DEFAULT 'no'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pp_favourite_candidates`
--

CREATE TABLE `pp_favourite_candidates` (
  `employer_id` int(11) NOT NULL,
  `seekerid` int(11) DEFAULT NULL,
  `employerlogin` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pp_favourite_companies`
--

CREATE TABLE `pp_favourite_companies` (
  `seekerid` int(11) NOT NULL,
  `companyid` int(11) DEFAULT NULL,
  `seekerlogin` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pp_institute`
--

CREATE TABLE `pp_institute` (
  `ID` int(11) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `sts` enum('blocked','active') DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pp_job_alert`
--

CREATE TABLE `pp_job_alert` (
  `ID` int(11) NOT NULL,
  `job_ID` int(11) DEFAULT NULL,
  `dated` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pp_job_alert_queue`
--

CREATE TABLE `pp_job_alert_queue` (
  `ID` int(11) NOT NULL,
  `seeker_ID` int(11) DEFAULT NULL,
  `job_ID` int(11) DEFAULT NULL,
  `dated` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pp_job_functional_areas`
--

CREATE TABLE `pp_job_functional_areas` (
  `ID` int(7) NOT NULL,
  `industry_ID` int(7) DEFAULT NULL,
  `functional_area` varchar(155) DEFAULT NULL,
  `sts` enum('suspended','active') DEFAULT 'active'
) ENGINE=MyISAM DEFAULT CHARSET=latin1 PACK_KEYS=0;

-- --------------------------------------------------------

--
-- Table structure for table `pp_job_industries`
--

CREATE TABLE `pp_job_industries` (
  `ID` int(11) NOT NULL,
  `industry_name` varchar(155) DEFAULT NULL,
  `slug` varchar(155) DEFAULT NULL,
  `sts` enum('suspended','active') DEFAULT 'active',
  `top_category` enum('no','yes') DEFAULT 'no'
) ENGINE=MyISAM DEFAULT CHARSET=latin1 PACK_KEYS=0;

--
-- Dumping data for table `pp_job_industries`
--

INSERT INTO `pp_job_industries` (`ID`, `industry_name`, `slug`, `sts`, `top_category`) VALUES
(3, 'Accounts', 'accounts', 'active', 'yes'),
(5, 'Advertising', 'advertising', 'active', 'yes'),
(7, 'Banking', 'banking', 'active', 'yes'),
(10, 'Customer Service', 'customer-service', 'active', 'yes'),
(16, 'Graphic / Web Design', 'graphic-web-design', 'active', 'yes'),
(18, 'HR / Industrial Relations', 'hr-industrial-relations', 'active', 'yes'),
(22, 'IT - Software', 'it-software', 'active', 'yes'),
(35, 'Teaching / Education', 'teaching-education', 'active', 'yes'),
(40, 'IT - Hardware', 'it-hardware', 'active', 'yes');

-- --------------------------------------------------------

--
-- Table structure for table `pp_job_seekers`
--

CREATE TABLE `pp_job_seekers` (
  `ID` int(11) NOT NULL,
  `first_name` varchar(30) DEFAULT NULL,
  `last_name` varchar(30) DEFAULT NULL,
  `email` varchar(155) DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL,
  `present_address` varchar(255) DEFAULT NULL,
  `permanent_address` varchar(255) DEFAULT NULL,
  `dated` datetime NOT NULL,
  `country` varchar(50) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `gender` enum('female','male') DEFAULT NULL,
  `dob` date DEFAULT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `photo` varchar(100) DEFAULT NULL,
  `default_cv_id` int(11) NOT NULL,
  `mobile` varchar(30) DEFAULT NULL,
  `home_phone` varchar(25) DEFAULT NULL,
  `cnic` varchar(255) DEFAULT NULL,
  `nationality` varchar(50) DEFAULT NULL,
  `career_objective` text,
  `sts` enum('active','blocked','pending') NOT NULL DEFAULT 'active',
  `verification_code` varchar(155) DEFAULT NULL,
  `first_login_date` datetime DEFAULT NULL,
  `last_login_date` datetime DEFAULT NULL,
  `slug` varchar(155) DEFAULT NULL,
  `ip_address` varchar(40) DEFAULT NULL,
  `old_id` int(11) DEFAULT NULL,
  `flag` varchar(10) DEFAULT NULL,
  `queue_email_sts` tinyint(1) DEFAULT NULL,
  `send_job_alert` enum('no','yes') DEFAULT 'yes'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pp_job_titles`
--

CREATE TABLE `pp_job_titles` (
  `ID` int(11) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `text` varchar(255) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_job_titles`
--

INSERT INTO `pp_job_titles` (`ID`, `value`, `text`) VALUES
(1, 'Web Designer', 'Web Designer'),
(2, 'Web Developer', 'Web Developer'),
(3, 'Graphic Designer', 'Graphic Designer'),
(4, 'Project Manager', 'Project Manager'),
(5, 'Network Administrator', 'Network Administrator'),
(6, 'Network Engineer', 'Network Engineer'),
(7, 'Software Engineer', 'Software Engineer'),
(8, 'System Administrator', 'System Administrator'),
(9, 'System Analyst', 'System Analyst');

-- --------------------------------------------------------

--
-- Table structure for table `pp_newsletter`
--

CREATE TABLE `pp_newsletter` (
  `ID` int(11) NOT NULL,
  `email_name` varchar(50) DEFAULT NULL,
  `from_name` varchar(60) DEFAULT NULL,
  `from_email` varchar(120) DEFAULT NULL,
  `email_subject` varchar(100) DEFAULT NULL,
  `email_body` text,
  `email_interval` int(4) DEFAULT NULL,
  `status` enum('inactive','active') DEFAULT 'active',
  `dated` datetime DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pp_post_jobs`
--

CREATE TABLE `pp_post_jobs` (
  `ID` int(11) NOT NULL,
  `employer_ID` int(11) NOT NULL,
  `job_title` varchar(255) NOT NULL,
  `company_ID` int(11) NOT NULL,
  `industry_ID` int(11) NOT NULL,
  `pay` varchar(60) NOT NULL,
  `dated` date NOT NULL,
  `sts` enum('inactive','pending','blocked','active') NOT NULL DEFAULT 'pending',
  `is_featured` enum('no','yes') NOT NULL DEFAULT 'no',
  `country` varchar(100) NOT NULL,
  `last_date` date NOT NULL,
  `age_required` varchar(50) NOT NULL,
  `qualification` varchar(60) NOT NULL,
  `experience` varchar(50) NOT NULL,
  `city` varchar(100) NOT NULL,
  `job_mode` enum('Home Based','Part Time','Full Time') NOT NULL DEFAULT 'Full Time',
  `vacancies` int(3) NOT NULL,
  `job_description` longtext NOT NULL,
  `contact_person` varchar(100) NOT NULL,
  `contact_email` varchar(100) NOT NULL,
  `contact_phone` varchar(30) NOT NULL,
  `viewer_count` int(11) NOT NULL DEFAULT '0',
  `job_slug` varchar(255) DEFAULT NULL,
  `ip_address` varchar(40) DEFAULT NULL,
  `flag` varchar(10) DEFAULT NULL,
  `old_id` int(11) DEFAULT NULL,
  `required_skills` varchar(255) DEFAULT NULL,
  `email_queued` tinyint(1) DEFAULT '0'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pp_prohibited_keywords`
--

CREATE TABLE `pp_prohibited_keywords` (
  `ID` int(11) NOT NULL,
  `keyword` varchar(150) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_prohibited_keywords`
--

INSERT INTO `pp_prohibited_keywords` (`ID`, `keyword`) VALUES
(8, 'idiot'),
(9, 'fuck'),
(10, 'bitch');

-- --------------------------------------------------------

--
-- Table structure for table `pp_qualifications`
--

CREATE TABLE `pp_qualifications` (
  `ID` int(5) NOT NULL,
  `val` varchar(25) DEFAULT NULL,
  `text` varchar(25) DEFAULT NULL,
  `display_order` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_qualifications`
--

INSERT INTO `pp_qualifications` (`ID`, `val`, `text`, `display_order`) VALUES
(1, 'BA', 'BA', NULL),
(2, 'BE', 'BE', NULL),
(3, 'BS', 'BS', NULL),
(4, 'CA', 'CA', NULL),
(5, 'Certification', 'Certification', NULL),
(6, 'Diploma', 'Diploma', NULL),
(7, 'HSSC', 'HSSC', NULL),
(8, 'MA', 'MA', NULL),
(9, 'MBA', 'MBA', NULL),
(10, 'MS', 'MS', NULL),
(11, 'PhD', 'PhD', NULL),
(12, 'SSC', 'SSC', NULL),
(13, 'ACMA', 'ACMA', NULL),
(14, 'MCS', 'MCS', NULL),
(15, 'Does not matter', 'Does not matter', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pp_salaries`
--

CREATE TABLE `pp_salaries` (
  `ID` int(5) NOT NULL,
  `val` varchar(25) DEFAULT NULL,
  `text` varchar(25) DEFAULT NULL,
  `display_order` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_salaries`
--

INSERT INTO `pp_salaries` (`ID`, `val`, `text`, `display_order`) VALUES
(1, 'Trainee Stipend', 'Trainee Stipend', 0),
(2, '5000-10000', '5-10', NULL),
(3, '11000-15000', '11-15', NULL),
(4, '16000-20000', '16-20', NULL),
(5, '21000-25000', '21-25', NULL),
(6, '26000-30000', '26-30', NULL),
(7, '31000-35000', '31-35', NULL),
(8, '36000-40000', '36-40', NULL),
(9, '41000-50000', '41-50', NULL),
(10, '51000-60000', '51-60', NULL),
(11, '61000-70000', '61-70', NULL),
(12, '71000-80000', '71-80', NULL),
(13, '81000-100000', '81-100', NULL),
(14, '100000-120000', '101-120', NULL),
(15, '120000-140000', '121-140', NULL),
(16, '140000-160000', '141-160', NULL),
(17, '160000-200000', '161-200', NULL),
(18, '200000-240000', '201-240', NULL),
(19, '240000-280000', '241-280', NULL),
(20, '281000-350000', '281-350', NULL),
(21, '350000-450000', '351-450', NULL),
(22, '450000 or above', '450 or above', NULL),
(23, 'Discuss', 'Discuss', NULL),
(24, 'Depends', 'Depends', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pp_scam`
--

CREATE TABLE `pp_scam` (
  `ID` int(11) NOT NULL,
  `user_ID` int(11) DEFAULT NULL,
  `job_ID` int(11) DEFAULT NULL,
  `reason` text,
  `dated` datetime DEFAULT NULL,
  `ip_address` varchar(60) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pp_seeker_academic`
--

CREATE TABLE `pp_seeker_academic` (
  `ID` int(11) NOT NULL,
  `seeker_ID` int(11) DEFAULT NULL,
  `degree_level` varchar(30) DEFAULT NULL,
  `degree_title` varchar(100) DEFAULT NULL,
  `major` varchar(155) DEFAULT NULL,
  `institude` varchar(155) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `completion_year` int(5) DEFAULT NULL,
  `dated` datetime DEFAULT NULL,
  `flag` varchar(10) DEFAULT NULL,
  `old_id` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `pp_seeker_additional_info`
--

CREATE TABLE `pp_seeker_additional_info` (
  `ID` int(11) NOT NULL,
  `seeker_ID` int(11) DEFAULT NULL,
  `languages` varchar(255) DEFAULT NULL COMMENT 'JSON data',
  `interest` varchar(155) DEFAULT NULL,
  `awards` varchar(100) DEFAULT NULL,
  `additional_qualities` varchar(155) DEFAULT NULL,
  `convicted_crime` enum('no','yes') DEFAULT 'no',
  `crime_details` text,
  `summary` text,
  `bad_habits` varchar(255) DEFAULT NULL,
  `salary` varchar(50) DEFAULT NULL,
  `keywords` varchar(255) DEFAULT NULL,
  `description` text
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_seeker_additional_info`
--

INSERT INTO `pp_seeker_additional_info` (`ID`, `seeker_ID`, `languages`, `interest`, `awards`, `additional_qualities`, `convicted_crime`, `crime_details`, `summary`, `bad_habits`, `salary`, `keywords`, `description`) VALUES
(51, 69, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(52, 70, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(53, 71, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(54, 74, NULL, NULL, 'ghgfhg', NULL, 'no', NULL, 'fgfdfd', NULL, NULL, NULL, 'hghg'),
(55, 75, NULL, NULL, 'Best Employee of the Year', NULL, 'no', NULL, '1	Around 6+ Years of Experience in Manual testing (Printer Domain).\n2	Expertise in Software testing process.\n3	Proficient with Software Development Life cycle.\n4	Black Box testing, Integration Testing, System testing, Boundary testing and Regression testing process of a given software application for different software releases and builds.\n5	Development of test procedure, test cases and test reporting documents.\n6	Review Test Cases on Fixed Defects by Onsite Team on different freezes and different Products.', NULL, NULL, NULL, 'To be a part of an Organization which provides a high quality of work life through challenging opportunities, a meaningful career growth and professional development'),
(56, 76, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(57, 78, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(58, 79, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(59, 80, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(60, 81, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(61, 82, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(62, 83, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(63, 84, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(64, 85, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(65, 86, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(66, 87, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(67, 88, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(68, 89, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(69, 90, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(70, 91, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(71, 92, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(72, 93, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(73, 94, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(74, 95, NULL, NULL, NULL, NULL, 'no', NULL, 'test at test.com and testing test from test date to test updat and original test update.', NULL, NULL, NULL, NULL),
(75, 97, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(76, 98, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(77, 99, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(78, 100, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(79, 102, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(80, 103, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(81, 105, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(82, 106, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(83, 107, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(84, 108, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(85, 109, NULL, NULL, NULL, NULL, 'no', NULL, 'hello pro', NULL, NULL, NULL, NULL),
(86, 110, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(87, 111, NULL, NULL, NULL, NULL, 'no', NULL, 'You\'ve ventured too far out into the desert! Time to head back.\n\nWe couldn\'t find any results for your search. Use more generic words or double check your spelling.You\'ve ventured too far out into the desert! Time to head back.\n\nWe couldn\'t find any results for your search. Use more generic words or double check your spelling.You\'ve ventured too far out into the desert! Time to head back.\n\nWe couldn\'t find any results for your search. Use more generic words or double check your spelling.', NULL, NULL, NULL, NULL),
(88, 113, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(89, 114, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(90, 115, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(91, 116, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(92, 117, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(93, 118, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(94, 119, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(95, 121, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(96, 122, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(97, 123, NULL, NULL, NULL, NULL, 'no', NULL, 'sfsdfds fsd fsdf sdfsdfsdfsdfsdf', NULL, NULL, NULL, NULL),
(98, 124, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(99, 125, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(100, 126, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(101, 127, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(102, 128, NULL, NULL, 'vcvc', NULL, 'no', NULL, 'vbvbvbv', NULL, NULL, NULL, 'vcvc'),
(103, 129, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(104, 130, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(105, 132, NULL, NULL, 'dadasdas', NULL, 'no', NULL, 'sdasdsad', NULL, NULL, NULL, 'sdsadsadad'),
(106, 133, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(107, 134, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(108, 135, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(109, 136, NULL, NULL, 'was class prefect', NULL, 'no', NULL, 'advance welding and inspection pro', NULL, NULL, NULL, 'to help employers succeed'),
(110, 137, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(111, 138, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(112, 139, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(113, 142, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL),
(114, 143, NULL, NULL, NULL, NULL, 'no', NULL, NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pp_seeker_applied_for_job`
--

CREATE TABLE `pp_seeker_applied_for_job` (
  `ID` int(11) NOT NULL,
  `seeker_ID` int(11) NOT NULL,
  `job_ID` int(11) NOT NULL,
  `cover_letter` text,
  `expected_salary` varchar(20) DEFAULT NULL,
  `dated` datetime NOT NULL DEFAULT '0000-00-00 00:00:00',
  `ip_address` varchar(40) DEFAULT NULL,
  `employer_ID` int(11) DEFAULT NULL,
  `flag` varchar(10) DEFAULT NULL,
  `old_id` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_seeker_applied_for_job`
--

INSERT INTO `pp_seeker_applied_for_job` (`ID`, `seeker_ID`, `job_ID`, `cover_letter`, `expected_salary`, `dated`, `ip_address`, `employer_ID`, `flag`, `old_id`) VALUES
(26, 48, 3, 'fsdfsdf', '26000-30000', '2016-04-03 15:33:36', NULL, 2, NULL, NULL),
(27, 36, 15, 'Thanks', '16000-20000', '2016-04-03 17:39:50', NULL, 14, NULL, NULL),
(28, 49, 15, 'benimben44627', '16000-20000', '2016-04-03 20:17:39', NULL, 14, NULL, NULL),
(29, 51, 15, 'Test Letter', '5000-10000', '2016-04-04 21:08:49', NULL, 14, NULL, NULL),
(30, 52, 15, 'fd', '5000-10000', '2016-04-05 13:58:50', NULL, 14, NULL, NULL),
(31, 55, 15, '3123', '11000-15000', '2016-04-06 18:23:31', NULL, 14, NULL, NULL),
(32, 59, 12, 'dhggggggggg', '26000-30000', '2016-04-08 16:07:49', NULL, 11, NULL, NULL),
(33, 58, 15, 'dfghdg', 'Trainee Stipend', '2016-04-08 16:23:41', NULL, 14, NULL, NULL),
(34, 61, 2, 'oooo', '5000-10000', '2016-04-10 00:23:33', NULL, 1, NULL, NULL),
(35, 65, 7, 'sfdadsa', '16000-20000', '2016-04-11 17:21:27', NULL, 6, NULL, NULL),
(36, 66, 15, 'SDS', '5000-10000', '2016-04-12 01:34:51', NULL, 14, NULL, NULL),
(37, 67, 12, 'hola', '11000-15000', '2016-04-12 10:35:49', NULL, 11, NULL, NULL),
(38, 69, 12, 'orem ipsum dolor sit amet, consectetur adipiscing elit. Fusce venenatis arcu est. Phasellus vel dignissim tellus. Aenean fermentum fermentum convallis. Maecenas vitae ipsum sed risus viverra volutpat non ac sapien. Donec viverra massa at dolor imperdiet hendrerit. Nullam quis est vitae dui placerat posuere. Phasellus eget erat sit amet lacus semper consectetur. Sed a nisi nisi. Pellentesque hendrerit est id quam facilisis au', '281000-350000', '2016-04-13 18:36:52', NULL, 11, NULL, NULL),
(39, 70, 3, 'Just testing', '71000-80000', '2016-04-13 21:43:07', NULL, 2, NULL, NULL),
(40, 70, 12, 'lol', '5000-10000', '2016-04-13 22:25:07', NULL, 11, NULL, NULL),
(41, 74, 2, 'fhgh', '16000-20000', '2016-04-15 11:44:15', NULL, 1, NULL, NULL),
(42, 75, 3, 'test', '36000-40000', '2016-04-15 15:29:26', NULL, 2, NULL, NULL),
(43, 76, 12, 'fghfghfghgfh', '5000-10000', '2016-04-15 17:37:18', NULL, 11, NULL, NULL),
(44, 78, 15, 'denemeee', '11000-15000', '2016-04-16 12:06:39', NULL, 14, NULL, NULL),
(45, 80, 4, 'test', '41000-50000', '2016-04-17 23:23:48', NULL, 3, NULL, NULL),
(46, 81, 3, 'ok', 'Trainee Stipend', '2016-04-18 15:36:42', NULL, 2, NULL, NULL),
(47, 81, 13, 'Test', '11000-15000', '2016-04-19 18:55:11', NULL, 12, NULL, NULL),
(48, 83, 13, 'rtytrryty', '31000-35000', '2016-04-20 08:56:47', NULL, 12, NULL, NULL),
(49, 84, 12, 'dfgdfgdfgd', '5000-10000', '2016-04-22 03:43:30', NULL, 11, NULL, NULL),
(51, 95, 14, 'test', '450000 or above', '2016-05-04 18:51:57', NULL, 13, NULL, NULL),
(52, 97, 15, 'as', '26000-30000', '2016-05-05 15:55:09', NULL, 14, NULL, NULL),
(53, 99, 15, 'wdeasdasd', '450000 or above', '2016-05-06 01:03:12', NULL, 14, NULL, NULL),
(54, 92, 12, 'hello', '5000-10000', '2016-05-07 17:30:16', NULL, 11, NULL, NULL),
(55, 102, 2, 'test', '350000-450000', '2016-05-07 22:41:28', NULL, 1, NULL, NULL),
(56, 105, 7, 'Test cover letter', '5000-10000', '2016-05-10 03:11:06', NULL, 6, NULL, NULL),
(57, 107, 14, 'nada', '11000-15000', '2016-05-12 07:35:53', NULL, 13, NULL, NULL),
(58, 108, 13, 'jhgbhbhj', '51000-60000', '2016-05-12 23:32:26', NULL, 12, NULL, NULL),
(59, 92, 15, 'hhh', '21000-25000', '2016-05-13 13:18:09', NULL, 14, NULL, NULL),
(60, 111, 2, 'this is testing....', 'Discuss', '2016-05-15 01:23:49', NULL, 1, NULL, NULL),
(61, 115, 15, 'testset', '11000-15000', '2016-05-16 17:18:04', NULL, 14, NULL, NULL),
(62, 116, 12, 'As Web designers plan, create and code web pages, using both non-technical and technical skills to produce websites that fit the customer\'s requirements.\nThey are involved in the technical and graphical aspects of pages, producing not just the look of the website, but determining how it works as well. Web designers might also be responsible for the maintenance of an existing site.\nThe term web developer is sometimes used interchangeably with web designer, but this can be confusing. Web developing is a more specialist role, focusing on the back-end development of a website and will incorporate, among other things, the creation of highly complex search functions.\nThe recent growth in touchscreen phones and tablet devices has dictated a new way of designing websites, with the web designer needing to ensure that web pages are responsive no matter what type of device a viewer is using. Therefore the need to test websites at different stages of design, on a variety of different devices, has become an important aspect of the job.', 'Trainee Stipend', '2016-05-16 17:25:54', NULL, 11, NULL, NULL),
(63, 117, 15, 'cascsacs', '5000-10000', '2016-05-16 22:52:56', NULL, 14, NULL, NULL),
(64, 41, 15, 'tes cover letter', 'Trainee Stipend', '2016-05-21 19:30:17', NULL, 14, NULL, NULL),
(65, 123, 14, '\'t\'g(', '5000-10000', '2016-05-22 12:41:41', NULL, 13, NULL, NULL),
(66, 123, 15, '(--g-g', '5000-10000', '2016-05-22 12:42:01', NULL, 14, NULL, NULL),
(68, 125, 15, 'sfsqafa', '5000-10000', '2016-05-24 17:36:38', NULL, 14, NULL, NULL),
(69, 126, 10, 'fff', '61000-70000', '2016-05-25 00:34:56', NULL, 9, NULL, NULL),
(70, 126, 4, 'rwy3', '16000-20000', '2016-05-25 00:37:00', NULL, 3, NULL, NULL),
(71, 41, 14, 'test', '5000-10000', '2016-05-25 15:18:35', NULL, 13, NULL, NULL),
(72, 128, 7, 'gfgfg', '11000-15000', '2016-05-26 00:23:22', NULL, 6, NULL, NULL),
(73, 129, 2, 'asd', '5000-10000', '2016-05-27 19:06:06', NULL, 1, NULL, NULL),
(74, 129, 1, 'php mysql c# flash', '11000-15000', '2016-05-27 19:06:59', NULL, 1, NULL, NULL),
(75, 130, 10, 'Hello', '16000-20000', '2016-05-28 23:03:02', NULL, 9, NULL, NULL),
(76, 132, 7, 'ssss', 'Trainee Stipend', '2016-06-01 03:42:04', NULL, 6, NULL, NULL),
(77, 132, 10, 'sadsadasd', '5000-10000', '2016-06-01 03:46:57', NULL, 9, NULL, NULL),
(78, 133, 14, 'gg', '36000-40000', '2016-06-02 13:03:45', NULL, 13, NULL, NULL),
(79, 133, 13, 'ggggggggg', 'Trainee Stipend', '2016-06-02 13:09:53', NULL, 12, NULL, NULL),
(80, 117, 7, 'qdwdwd', 'Trainee Stipend', '2016-06-02 16:07:45', NULL, 6, NULL, NULL),
(81, 92, 7, 'ggg', '11000-15000', '2016-06-03 12:43:32', NULL, 6, NULL, NULL),
(82, 142, 3, 'ufd', 'Trainee Stipend', '2016-06-15 14:13:27', NULL, 2, NULL, NULL),
(83, 143, 15, 'jbk,b', 'Trainee Stipend', '2018-11-29 08:57:14', NULL, 14, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pp_seeker_experience`
--

CREATE TABLE `pp_seeker_experience` (
  `ID` int(11) NOT NULL,
  `seeker_ID` int(11) DEFAULT NULL,
  `job_title` varchar(155) DEFAULT NULL,
  `company_name` varchar(155) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `city` varchar(40) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `responsibilities` text,
  `dated` datetime DEFAULT NULL,
  `flag` varchar(10) DEFAULT NULL,
  `old_id` int(11) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_seeker_experience`
--

INSERT INTO `pp_seeker_experience` (`ID`, `seeker_ID`, `job_title`, `company_name`, `start_date`, `end_date`, `city`, `country`, `responsibilities`, `dated`, `flag`, `old_id`) VALUES
(1, 9, 'test', 'testete', '2012-02-16', NULL, 'New york', 'United States of America', NULL, '2016-03-12 02:10:41', NULL, NULL),
(2, 15, 'Edmar Paz Fotográfias', 'Fotos & Vídeos', '1970-01-01', NULL, 'Tamandaré', 'Brazil', NULL, '2016-03-28 18:44:09', NULL, NULL),
(3, 18, 'dedededededde', 'deddededededdeded', '2016-03-28', '2016-03-31', 'lima', 'Bahamas', NULL, '2016-03-28 20:02:38', NULL, NULL),
(4, 15, 'Informática', 'Provedor Web', '2011-05-11', NULL, 'Tamandaré', 'Brazil', NULL, '2016-03-28 23:48:52', NULL, NULL),
(5, 15, 'Locutor', 'Rádio Estrela do Mar FM', '2013-06-05', NULL, 'Tamandaré', 'Brazil', NULL, '2016-03-28 23:49:34', NULL, NULL),
(6, 25, 'dfdf', 'fdfvd', '2016-03-09', NULL, 'columbus', 'United States of America', NULL, '2016-03-29 13:42:28', NULL, NULL),
(7, 25, 'zxcvzs', 'asfasdf', '2016-03-23', NULL, 'yfutu', 'United States of America', NULL, '2016-03-29 13:44:11', NULL, NULL),
(8, 32, 'Test123113', 'Softrait Technologies', '2016-04-01', '2016-04-01', 'palakkad', 'India', NULL, '2016-03-31 23:37:21', NULL, NULL),
(9, 36, 'Web Designer', 'Master Tech', '2016-04-11', NULL, 'Dhaka', 'Bangladesh', NULL, '2016-04-02 03:21:27', NULL, NULL),
(10, 36, 'Web Designer Sr', 'Master Tech Ltd', '2016-04-11', '2016-04-04', 'Dhaka', 'Bangladesh', NULL, '2016-04-02 03:22:09', NULL, NULL),
(11, 41, 'job 11', 'company  job', '2016-04-13', '2016-04-20', 'sksksks', 'Angola', NULL, '2016-04-03 02:55:23', NULL, NULL),
(12, 41, 'test', 's2m', '2016-02-02', '2016-04-13', 'casa', 'Antigua & Barbuda', NULL, '2016-04-03 02:55:50', NULL, NULL),
(13, 59, 'PHP developer', 'abc', '2015-06-02', NULL, 'mangalore', 'Afganistan', NULL, '2016-04-08 16:05:27', NULL, NULL),
(14, 74, 'gfdfg', 'fdtyytr', '2016-03-10', NULL, 'fdf', 'Croatia', NULL, '2016-04-15 11:41:43', NULL, NULL),
(15, 75, 'Sr Test Engineer', 'Aadithya Visuals Pvt Ltd', '2011-11-01', '2015-12-16', 'Bangalore', 'India', NULL, '2016-04-15 15:25:12', NULL, NULL),
(16, 75, 'Sr Test Engineer', 'Samsung India Software Operations', '2006-07-07', '2011-10-05', 'Bangalore', 'India', NULL, '2016-04-15 15:26:04', NULL, NULL),
(17, 92, 'test', 'the testing company', '2016-05-03', NULL, 'cairo', 'Egypt', NULL, '2016-05-02 11:56:32', NULL, NULL),
(18, 95, 'anything else', 'home', '2016-05-10', NULL, 'karachi', 'Afganistan', NULL, '2016-05-04 18:50:51', NULL, NULL),
(19, 109, 'dsfsd', 'dsfds', '2016-05-05', NULL, 'paris', 'Afganistan', NULL, '2016-05-13 20:28:58', NULL, NULL),
(20, 128, 'vbbvb', 'bvbvbv', '2016-05-03', '2016-05-01', 'bbb', 'Afganistan', NULL, '2016-05-26 00:22:05', NULL, NULL),
(21, 128, 'bvbvb', 'bbvbv', '2016-05-04', NULL, 'bvbvb', 'Afganistan', NULL, '2016-05-26 00:22:26', NULL, NULL),
(22, 132, 'dsadasd', 'sadsads', '2016-05-10', '2016-05-11', 'lima', 'Peru', NULL, '2016-06-01 03:45:22', NULL, NULL),
(23, 136, 'IT specialist', 'koko', '2016-06-01', '2016-07-25', 'wari', 'American Samoa', NULL, '2016-06-09 19:19:49', NULL, NULL),
(24, 142, 'dgh', 'dgh', '2016-06-15', NULL, 'dgh', 'Afganistan', NULL, '2016-06-15 14:09:28', NULL, NULL),
(25, 123, 'designer', 'avb', '2016-06-01', '2016-06-07', 'bairoot', 'Algeria', NULL, '2016-06-17 02:40:41', NULL, NULL),
(26, 143, 'scdsc', 'zxcx', '2018-11-14', NULL, 'cdc', 'Ghana', NULL, '2018-11-29 08:56:45', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pp_seeker_resumes`
--

CREATE TABLE `pp_seeker_resumes` (
  `ID` int(11) NOT NULL,
  `seeker_ID` int(11) DEFAULT NULL,
  `is_uploaded_resume` enum('no','yes') DEFAULT 'no',
  `file_name` varchar(155) DEFAULT NULL,
  `resume_name` varchar(40) DEFAULT NULL,
  `dated` datetime DEFAULT NULL,
  `is_default_resume` enum('no','yes') DEFAULT 'no'
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_seeker_resumes`
--

INSERT INTO `pp_seeker_resumes` (`ID`, `seeker_ID`, `is_uploaded_resume`, `file_name`, `resume_name`, `dated`, `is_default_resume`) VALUES
(53, 70, 'yes', 'habib-jiwan-70.docx', NULL, '2016-04-13 21:39:42', 'no'),
(54, 71, 'yes', 'salih-karadeniz-71.pdf', NULL, '2016-04-14 15:13:54', 'no'),
(55, 74, 'yes', 'std-74.pdf', NULL, '2016-04-15 11:39:43', 'no'),
(56, 75, 'yes', 'arjun-kumar-75.doc', NULL, '2016-04-15 15:22:03', 'no'),
(57, 76, 'yes', 'nagendra-yadav-76.doc', NULL, '2016-04-15 17:31:45', 'no'),
(58, 78, 'yes', 'deneme-deneme-78.txt', NULL, '2016-04-16 12:05:57', 'no'),
(59, 79, 'yes', 'md-mahabub-alam-rubel-79.pdf', NULL, '2016-04-17 08:31:40', 'no'),
(60, 80, 'yes', 'alex-kehr-80.pdf', NULL, '2016-04-17 23:21:48', 'no'),
(61, 81, 'yes', 'gouse-81.docx', NULL, '2016-04-18 15:25:15', 'no'),
(62, 82, 'yes', 'doan-82.pdf', NULL, '2016-04-19 12:05:13', 'no'),
(63, 83, 'yes', 'tiago-83.doc', NULL, '2016-04-20 08:54:24', 'no'),
(64, 84, 'yes', 'vehbi-84.jpg', NULL, '2016-04-22 03:42:30', 'no'),
(65, 85, 'yes', 'vipin-agarwal-85.docx', NULL, '2016-04-22 18:40:13', 'no'),
(66, 86, 'yes', 'sergey-86.docx', NULL, '2016-04-23 03:06:40', 'no'),
(67, 87, 'yes', 'deli-atoia-abuda-87.pdf', NULL, '2016-04-24 22:26:40', 'no'),
(69, 89, 'yes', 'max-azarcon-89.pdf', NULL, '2016-04-26 01:55:22', 'no'),
(70, 90, 'yes', 'abcd-zyx-90.jpg', NULL, '2016-04-28 15:03:00', 'no'),
(71, 91, 'yes', 'stanislas-bellot-91.pdf', NULL, '2016-05-02 06:45:03', 'no'),
(72, 92, 'yes', 'testat-92.pdf', NULL, '2016-05-02 11:53:02', 'no'),
(73, 93, 'yes', 'qartes-93.jpg', NULL, '2016-05-03 05:54:41', 'no'),
(74, 94, 'yes', 'sayali-94.jpg', NULL, '2016-05-03 10:35:10', 'no'),
(75, 95, 'yes', 'john-doe-95.pdf', NULL, '2016-05-04 16:39:17', 'no'),
(76, 97, 'yes', 'jj-97.docx', NULL, '2016-05-05 15:54:34', 'no'),
(77, 98, 'yes', 'dtest-er-98.docx', NULL, '2016-05-05 22:55:28', 'no'),
(78, 99, 'yes', 'kevin-de-la-horra-99.txt', NULL, '2016-05-06 01:02:08', 'no'),
(79, 100, 'yes', 'sean-brogan-100.jpg', NULL, '2016-05-06 18:22:12', 'no'),
(80, 102, 'yes', 'u-alan-102.pdf', NULL, '2016-05-07 22:39:29', 'no'),
(81, 103, 'yes', 'markettom-103.docx', NULL, '2016-05-08 11:15:53', 'no'),
(82, 105, 'yes', 'teste-105.doc', NULL, '2016-05-10 03:10:00', 'no'),
(83, 106, 'yes', 'alex-muurphy-106.doc', NULL, '2016-05-11 11:34:48', 'no'),
(84, 107, 'yes', 'gandhi-107.pdf', NULL, '2016-05-12 07:34:23', 'no'),
(85, 108, 'yes', 'dddddddddddddddd-108.doc', NULL, '2016-05-12 23:30:55', 'no'),
(86, 109, 'yes', 'jean-val-109.docx', NULL, '2016-05-13 20:24:42', 'no'),
(87, 110, 'yes', 'raakesh-kumar-110.pdf', NULL, '2016-05-13 21:13:28', 'no'),
(88, 111, 'yes', 'shaik-jilani-111.doc', NULL, '2016-05-15 01:20:46', 'no'),
(89, 113, 'yes', 'kevin-de-la-horra-113.docx', NULL, '2016-05-15 16:32:39', 'no'),
(90, 114, 'yes', 'asmaa-114.jpg', NULL, '2016-05-16 17:04:46', 'no'),
(91, 115, 'yes', 'test-115.jpg', NULL, '2016-05-16 17:17:43', 'no'),
(92, 116, 'yes', 'biniyam-116.doc', NULL, '2016-05-16 17:23:56', 'no'),
(93, 117, 'yes', 'abraiz-khan-117.docx', NULL, '2016-05-16 22:51:31', 'no'),
(94, 118, 'yes', 'razor-118.jpg', NULL, '2016-05-17 03:29:40', 'no'),
(95, 119, 'yes', 'anibal-centurion-119.jpg', NULL, '2016-05-17 17:30:52', 'no'),
(96, 121, 'yes', 'patryk-kloz-121.docx', NULL, '2016-05-17 18:31:32', 'no'),
(97, 121, 'yes', 'patryk-kloz-JOBPORTAL-1211463491984.docx', NULL, '2016-05-17 18:33:04', 'no'),
(98, 122, 'yes', 'job-seeker-122.txt', NULL, '2016-05-19 00:31:47', 'no'),
(99, 123, 'yes', 'admin-123.pdf', NULL, '2016-05-22 12:39:40', 'no'),
(100, 124, 'yes', 'parkkichul-124.jpg', NULL, '2016-05-23 15:42:06', 'no'),
(101, 125, 'yes', 'ina-125.pdf', NULL, '2016-05-24 17:36:03', 'no'),
(102, 126, 'yes', 'pepito-piguave-126.doc', NULL, '2016-05-25 00:32:51', 'no'),
(103, 127, 'yes', 'shiva-127.docx', NULL, '2016-05-25 17:07:07', 'no'),
(105, 129, 'yes', 'altan-kastalmis-129.jpg', NULL, '2016-05-27 19:04:49', 'no'),
(106, 130, 'yes', 'gray-jumba-130.docx', NULL, '2016-05-28 22:59:08', 'no'),
(107, 132, 'yes', 'neyber-becerra-zapata-132.pdf', NULL, '2016-06-01 03:39:36', 'no'),
(108, 133, 'yes', 'full-name-133.doc', NULL, '2016-06-02 12:50:25', 'no'),
(109, 134, 'yes', 'lvcmuz-134.docx', NULL, '2016-06-08 15:05:33', 'no'),
(110, 135, 'yes', 'zgh-135.docx', NULL, '2016-06-08 23:40:44', 'no'),
(111, 136, 'yes', 'larry-barry-136.docx', NULL, '2016-06-09 18:59:07', 'no'),
(112, 137, 'yes', 'casper-ved-137.jpg', NULL, '2016-06-09 23:55:17', 'no'),
(113, 138, 'yes', 'praveen-dokania-138.doc', NULL, '2016-06-10 23:41:39', 'no'),
(114, 139, 'yes', 'fdsa-139.jpg', NULL, '2016-06-11 22:01:01', 'no'),
(115, 142, 'yes', 'qsaf-142.pdf', NULL, '2016-06-15 14:06:39', 'no'),
(116, 143, 'yes', 'ekow-baahnyarkoh-143.pdf', NULL, '2018-11-27 18:52:31', 'no');

-- --------------------------------------------------------

--
-- Table structure for table `pp_seeker_skills`
--

CREATE TABLE `pp_seeker_skills` (
  `ID` int(11) NOT NULL,
  `seeker_ID` int(11) DEFAULT NULL,
  `skill_name` varchar(155) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_seeker_skills`
--

INSERT INTO `pp_seeker_skills` (`ID`, `seeker_ID`, `skill_name`) VALUES
(1, 8, 'php'),
(2, 8, 'java'),
(3, 8, 'javascript'),
(4, 9, 'html'),
(5, 9, 'css'),
(6, 9, 'photoshop'),
(7, 9, 'illustrator'),
(8, 9, 'js'),
(9, 9, 'jquery'),
(10, 10, 'html'),
(11, 10, 'css'),
(12, 10, 'js'),
(13, 11, 'css'),
(14, 11, 'photoshop'),
(15, 11, 'designer'),
(16, 12, 'prawojazdy c'),
(17, 12, 'dobry zawodowo'),
(18, 12, 'xdddd d ddd'),
(19, 14, 'nothing'),
(20, 14, 'more'),
(21, 14, 'nix'),
(22, 15, 'computação'),
(23, 15, 'formatação'),
(24, 15, 'administração'),
(25, 16, '54'),
(26, 16, 'hiioyui'),
(27, 16, 'etyt'),
(28, 17, 'illustrator'),
(29, 18, 'demo'),
(30, 18, 'dedede'),
(31, 18, 'dedededede'),
(32, 15, 'illustrator'),
(33, 15, 'indesign'),
(34, 15, 'marketting'),
(35, 15, 'ms office'),
(36, 19, 'php'),
(37, 19, 'ms office'),
(38, 19, 'jquery'),
(40, 21, 'wordpress, html, css, php'),
(41, 21, 'wordpress'),
(42, 21, 'html'),
(43, 21, 'css'),
(44, 21, 'photoshop'),
(45, 22, 'asasasas'),
(46, 22, 'wewewew'),
(47, 22, 'wewewewe'),
(48, 23, 'medicl assistant'),
(49, 23, 'front office'),
(50, 23, 'back office'),
(51, 24, 'cvcddsr'),
(52, 24, 'gddss'),
(53, 25, 'web'),
(54, 25, 'food'),
(55, 25, 'ass'),
(56, 25, 'boobs'),
(57, 26, ', desenvolvedor, administrador, obras'),
(58, 28, 'php'),
(59, 28, 'illustrator'),
(60, 28, 'java'),
(61, 29, 'test, test, test'),
(62, 29, 'test'),
(63, 29, 'testtest'),
(64, 29, 'ok'),
(65, 30, 'wordpress'),
(66, 30, 'html'),
(67, 30, 'php'),
(68, 32, 'php'),
(69, 32, 'photoshop'),
(70, 32, 'java'),
(71, 33, 'php'),
(72, 33, 'html'),
(73, 33, 'css'),
(74, 35, 'test'),
(75, 35, 'testttt'),
(76, 36, 'web design'),
(77, 36, 'web development'),
(78, 36, 'trainer'),
(79, 37, 'html'),
(80, 37, 'css'),
(81, 37, 'sx'),
(82, 37, 'cmmi'),
(83, 38, 'php'),
(84, 41, 'develpper'),
(85, 41, 'djjdjdj'),
(86, 41, 'dskdkdk'),
(87, 42, 'excel'),
(88, 42, 'illustrator'),
(89, 42, 'informática'),
(90, 47, 'drgdqg'),
(91, 47, 'rqdghqesh'),
(92, 47, 'gshtsrrfghrts'),
(93, 48, 'photoshop'),
(94, 48, 'dd'),
(95, 48, 'illustrator'),
(96, 49, 'illustrator'),
(97, 49, 'java'),
(98, 49, 'html'),
(99, 51, '.net'),
(100, 52, 'web developer'),
(101, 53, 'php, html, css'),
(102, 53, 'php'),
(103, 53, 'css'),
(104, 54, 'indesign'),
(105, 54, 'marketting'),
(106, 55, 'php delvoper'),
(107, 55, 'ss'),
(108, 55, 'dd'),
(109, 57, 'php'),
(110, 57, 'jquery'),
(111, 57, 'informática'),
(112, 59, 'php'),
(113, 59, '.net'),
(114, 59, 'php developer'),
(115, 58, 'fghfgh'),
(116, 58, 'dghd'),
(117, 58, 'dghdgh'),
(118, 58, 'dghdfgh'),
(119, 60, 'design'),
(120, 60, 'skill'),
(121, 60, 'skill2'),
(122, 60, 'skill3'),
(123, 61, 'php'),
(124, 61, 'mysql'),
(125, 61, 'photoshop'),
(126, 65, 'illustrator'),
(127, 65, 'indesign'),
(128, 65, 'cms'),
(129, 65, 'online marketing'),
(130, 65, 'crestone'),
(131, 65, 'extron'),
(132, 66, 'dsd'),
(133, 66, 'ads'),
(134, 66, 'asd'),
(135, 67, 'desarrolo de software'),
(136, 67, 'diseño grafico'),
(137, 67, 'web'),
(138, 68, 'web design'),
(139, 69, 'photoshop'),
(140, 69, 'dreamweaver'),
(141, 69, 'html5'),
(142, 69, 'css3'),
(143, 70, 'programmer, designer, writer'),
(144, 70, 'programmer'),
(145, 70, 'designer'),
(146, 70, 'writer'),
(147, 74, 'php'),
(148, 74, 'css'),
(149, 74, 'html'),
(150, 75, 'embedded testing'),
(151, 75, 'printer domain'),
(152, 75, 'testing'),
(157, 76, 'html'),
(155, 76, 'js'),
(158, 76, 'css'),
(159, 78, 'php developer'),
(160, 78, 'php'),
(161, 78, 'mysql'),
(162, 79, 'html'),
(163, 79, 'css'),
(164, 80, 'marketting'),
(165, 80, 'php'),
(166, 80, 'html'),
(167, 81, 'java'),
(168, 81, 'jquery'),
(169, 81, 'informática'),
(170, 84, 'atley-t'),
(171, 85, 'web design, seo, development'),
(172, 85, 'seo'),
(173, 85, 'web design'),
(174, 86, 'php'),
(175, 86, 'word'),
(176, 86, 'ffgh'),
(177, 87, 'php'),
(178, 87, 'photoshop'),
(179, 87, 'java'),
(180, 88, 'accountant, cost accountant, acca'),
(181, 88, 'fw'),
(182, 88, 'qwefw'),
(183, 89, 'html'),
(184, 89, 'css'),
(185, 89, 'jquery'),
(186, 90, 'php;mysql'),
(187, 90, 'qqq'),
(188, 90, 'ert'),
(189, 91, 'informaticien'),
(190, 91, 'administrateur de réseau'),
(191, 91, 'developpeur'),
(192, 92, 'test'),
(193, 92, 'cctv'),
(194, 92, 'software'),
(195, 92, 'hello'),
(196, 92, 'hr'),
(197, 93, 'marketting'),
(198, 93, 'informática'),
(199, 93, 'jquery'),
(200, 93, 'mysql'),
(201, 94, 'designer'),
(202, 94, 'website developer'),
(203, 94, 'photoshop'),
(204, 95, 'yes'),
(205, 95, 'no'),
(206, 95, 'marketting'),
(207, 97, 'aaa'),
(208, 97, 'dd'),
(209, 99, 'adasd'),
(210, 99, 'asdfasdf'),
(211, 99, 'sdfgdsfg'),
(212, 100, 'sfsff'),
(213, 100, 'sdfdf'),
(214, 100, 'dfsff'),
(215, 102, 'web'),
(216, 102, 'php coder, desing'),
(217, 102, 'desin'),
(218, 103, 'php developer, php coder, php programmer, website developer, word press, java script, js, ajax etc'),
(219, 105, 'indesign'),
(220, 105, 'html'),
(221, 105, 'photoshop'),
(222, 106, 'php'),
(223, 107, 'vendedor'),
(224, 107, 'cabesero'),
(225, 107, 'tematico'),
(226, 108, 'mmmm'),
(227, 108, 'bjhbjmh'),
(228, 108, 'nkjknkjn'),
(229, 109, 'seo'),
(230, 109, 'sem'),
(231, 109, 'kick boxing'),
(232, 110, 'php,python,java'),
(233, 110, 'php'),
(234, 110, 'python'),
(235, 110, 'java'),
(236, 111, 'php'),
(237, 111, 'java'),
(238, 111, '.net'),
(239, 111, 'oracle'),
(240, 113, 'programmer'),
(241, 113, 'desings'),
(242, 113, 'informatic'),
(243, 114, 'word press'),
(244, 115, 'test'),
(245, 116, 'php developer'),
(246, 116, 'php programmer'),
(247, 116, 'website developer'),
(248, 116, 'chartered accountant'),
(249, 117, 'php,'),
(250, 117, 'wordpress'),
(251, 117, 'html'),
(252, 121, 'html'),
(255, 121, 'testing2'),
(254, 121, 'testing'),
(256, 121, 'java'),
(257, 122, 'php'),
(258, 122, '.net'),
(259, 122, 'java'),
(260, 123, 'indesign'),
(305, 123, 'photoshop'),
(262, 124, 'sdfdsf'),
(263, 124, 'dsfdsf'),
(264, 124, 'dsfdsfff'),
(265, 124, 'ssdfdsfddddddd'),
(266, 125, 'no'),
(267, 125, 'dsg'),
(268, 126, 'html5'),
(269, 126, 'css3'),
(270, 126, 'php'),
(271, 127, 'java'),
(272, 128, 'php'),
(273, 128, 'java'),
(274, 128, 'indesign'),
(275, 129, 'cv'),
(276, 129, 'computer'),
(277, 129, 'php'),
(278, 130, 'banker'),
(279, 130, 'accountant'),
(280, 130, 'analyst'),
(281, 132, 'marketting'),
(282, 132, 'indesign'),
(283, 132, 'photoshop'),
(284, 132, 'php'),
(285, 133, 'jkjkjkjkj'),
(286, 133, 'hjhjhj'),
(287, 133, 'kkkk'),
(289, 135, 'illustrator'),
(290, 136, 'indesing'),
(291, 136, 'photoshop'),
(292, 136, 'graphic designer'),
(293, 137, 'html'),
(294, 137, 'css'),
(295, 137, 'java'),
(296, 138, 'html'),
(297, 138, 'php'),
(298, 138, 'css'),
(299, 139, 'html'),
(300, 139, 'css'),
(301, 139, 'java'),
(302, 142, 'xml'),
(303, 142, 'java'),
(304, 142, 'php'),
(306, 123, 'css'),
(307, 114, 'java'),
(308, 114, 'php'),
(309, 143, 'ms office'),
(310, 143, 'developer'),
(311, 143, 'photoshop');

-- --------------------------------------------------------

--
-- Table structure for table `pp_sessions`
--

CREATE TABLE `pp_sessions` (
  `session_id` varchar(40) NOT NULL DEFAULT '0',
  `ip_address` varchar(45) NOT NULL DEFAULT '0',
  `user_agent` varchar(120) NOT NULL,
  `last_activity` int(10) UNSIGNED NOT NULL DEFAULT '0',
  `user_data` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_sessions`
--

INSERT INTO `pp_sessions` (`session_id`, `ip_address`, `user_agent`, `last_activity`, `user_data`) VALUES
('952ac5662604ae0a5e98ac90b3730850', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:64.0) Gecko/20100101 Firefox/64.0', 1547553052, 'a:6:{s:7:\"cptcode\";s:4:\"N2W5\";s:8:\"admin_id\";s:1:\"1\";s:4:\"name\";s:4:\"demo\";s:14:\"is_admin_login\";b:1;s:10:\"user_email\";s:18:\"baahekow@ymail.com\";s:10:\"first_name\";s:16:\"Ekow BaahNyarkoh\";}');

-- --------------------------------------------------------

--
-- Table structure for table `pp_settings`
--

CREATE TABLE `pp_settings` (
  `ID` int(11) NOT NULL,
  `emails_per_hour` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_settings`
--

INSERT INTO `pp_settings` (`ID`, `emails_per_hour`) VALUES
(1, 300);

-- --------------------------------------------------------

--
-- Table structure for table `pp_skills`
--

CREATE TABLE `pp_skills` (
  `ID` int(11) NOT NULL,
  `skill_name` varchar(40) DEFAULT NULL,
  `industry_ID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `pp_skills`
--

INSERT INTO `pp_skills` (`ID`, `skill_name`, `industry_ID`) VALUES
(1, 'html', NULL),
(2, 'php', NULL),
(3, 'js', NULL),
(4, '.net', NULL),
(5, 'css', NULL),
(6, 'jquery', NULL),
(7, 'java', NULL),
(8, 'photoshop', NULL),
(9, 'illustrator', NULL),
(10, 'Indesign', NULL),
(11, 'mysql', NULL),
(12, 'Ms Office', NULL),
(13, 'Marketting', NULL),
(14, 'informática', NULL),
(15, 'web', NULL),
(16, 'indesing', NULL),
(17, 'developer', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pp_stories`
--

CREATE TABLE `pp_stories` (
  `ID` int(11) NOT NULL,
  `seeker_ID` int(11) NOT NULL,
  `is_featured` enum('yes','no') DEFAULT 'no',
  `sts` enum('active','inactive') DEFAULT 'inactive',
  `title` varchar(250) DEFAULT NULL,
  `story` text,
  `dated` datetime DEFAULT NULL,
  `ip_address` varchar(40) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_gallery`
--

CREATE TABLE `tbl_gallery` (
  `ID` int(11) NOT NULL,
  `image_caption` varchar(150) DEFAULT NULL,
  `image_name` varchar(155) DEFAULT NULL,
  `dated` datetime DEFAULT NULL,
  `sts` enum('inactive','active') DEFAULT 'active'
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Dumping data for table `tbl_gallery`
--

INSERT INTO `tbl_gallery` (`ID`, `image_caption`, `image_name`, `dated`, `sts`) VALUES
(1, 'Test', 'portfolio-2.jpg', '2015-09-05 18:16:41', 'active'),
(2, '', 'portfolio-1.jpg', '2015-09-05 21:17:59', 'active'),
(3, '', 'portfolio-3.jpg', '2015-09-05 21:22:19', 'active'),
(4, '', 'portfolio-6.jpg', '2015-09-05 21:22:29', 'active'),
(5, '', 'portfolio-7.jpg', '2015-09-05 21:22:38', 'active'),
(6, '', 'portfolio-8.jpg', '2015-09-05 21:22:53', 'active'),
(7, '', 'portfolio-9.jpg', '2015-09-05 21:23:05', 'active'),
(8, 'Walk with the Queen... But be careful!', 'portfolio-10.jpg', '2015-09-05 21:23:16', 'inactive'),
(9, 'Bla bla bla Bla bla bla Bla bla bla Bla bla bla Bla bla bla Bla bla bla Bla bla bla Bla bla bla Bla.', 'portfolio-11.jpg', '2015-09-05 21:23:24', 'active'),
(10, 'Beatuiful Bubble', 'portfolio-12.jpg', '2015-09-05 21:23:32', 'active');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `pp_admin`
--
ALTER TABLE `pp_admin`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pp_ad_codes`
--
ALTER TABLE `pp_ad_codes`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_cities`
--
ALTER TABLE `pp_cities`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_cms`
--
ALTER TABLE `pp_cms`
  ADD PRIMARY KEY (`pageID`);

--
-- Indexes for table `pp_cms_previous`
--
ALTER TABLE `pp_cms_previous`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_companies`
--
ALTER TABLE `pp_companies`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_countries`
--
ALTER TABLE `pp_countries`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_email_content`
--
ALTER TABLE `pp_email_content`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_employers`
--
ALTER TABLE `pp_employers`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_favourite_candidates`
--
ALTER TABLE `pp_favourite_candidates`
  ADD PRIMARY KEY (`employer_id`);

--
-- Indexes for table `pp_favourite_companies`
--
ALTER TABLE `pp_favourite_companies`
  ADD PRIMARY KEY (`seekerid`);

--
-- Indexes for table `pp_institute`
--
ALTER TABLE `pp_institute`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_job_alert`
--
ALTER TABLE `pp_job_alert`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_job_alert_queue`
--
ALTER TABLE `pp_job_alert_queue`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_job_functional_areas`
--
ALTER TABLE `pp_job_functional_areas`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_job_industries`
--
ALTER TABLE `pp_job_industries`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_job_seekers`
--
ALTER TABLE `pp_job_seekers`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_job_titles`
--
ALTER TABLE `pp_job_titles`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_newsletter`
--
ALTER TABLE `pp_newsletter`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_post_jobs`
--
ALTER TABLE `pp_post_jobs`
  ADD PRIMARY KEY (`ID`);
ALTER TABLE `pp_post_jobs` ADD FULLTEXT KEY `job_search` (`job_title`,`job_description`);

--
-- Indexes for table `pp_prohibited_keywords`
--
ALTER TABLE `pp_prohibited_keywords`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_qualifications`
--
ALTER TABLE `pp_qualifications`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_salaries`
--
ALTER TABLE `pp_salaries`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_scam`
--
ALTER TABLE `pp_scam`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_seeker_academic`
--
ALTER TABLE `pp_seeker_academic`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_seeker_additional_info`
--
ALTER TABLE `pp_seeker_additional_info`
  ADD PRIMARY KEY (`ID`);
ALTER TABLE `pp_seeker_additional_info` ADD FULLTEXT KEY `resume_search` (`summary`,`keywords`);

--
-- Indexes for table `pp_seeker_applied_for_job`
--
ALTER TABLE `pp_seeker_applied_for_job`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_seeker_experience`
--
ALTER TABLE `pp_seeker_experience`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_seeker_resumes`
--
ALTER TABLE `pp_seeker_resumes`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_seeker_skills`
--
ALTER TABLE `pp_seeker_skills`
  ADD PRIMARY KEY (`ID`);
ALTER TABLE `pp_seeker_skills` ADD FULLTEXT KEY `js_skill_search` (`skill_name`);

--
-- Indexes for table `pp_sessions`
--
ALTER TABLE `pp_sessions`
  ADD PRIMARY KEY (`session_id`),
  ADD KEY `last_activity_idx` (`last_activity`);

--
-- Indexes for table `pp_settings`
--
ALTER TABLE `pp_settings`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_skills`
--
ALTER TABLE `pp_skills`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `pp_stories`
--
ALTER TABLE `pp_stories`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `tbl_gallery`
--
ALTER TABLE `tbl_gallery`
  ADD PRIMARY KEY (`ID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `pp_admin`
--
ALTER TABLE `pp_admin`
  MODIFY `id` int(8) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;
--
-- AUTO_INCREMENT for table `pp_ad_codes`
--
ALTER TABLE `pp_ad_codes`
  MODIFY `ID` int(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `pp_cities`
--
ALTER TABLE `pp_cities`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=30;
--
-- AUTO_INCREMENT for table `pp_cms`
--
ALTER TABLE `pp_cms`
  MODIFY `pageID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;
--
-- AUTO_INCREMENT for table `pp_cms_previous`
--
ALTER TABLE `pp_cms_previous`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;
--
-- AUTO_INCREMENT for table `pp_companies`
--
ALTER TABLE `pp_companies`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=82;
--
-- AUTO_INCREMENT for table `pp_countries`
--
ALTER TABLE `pp_countries`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;
--
-- AUTO_INCREMENT for table `pp_email_content`
--
ALTER TABLE `pp_email_content`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `pp_employers`
--
ALTER TABLE `pp_employers`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=82;
--
-- AUTO_INCREMENT for table `pp_favourite_candidates`
--
ALTER TABLE `pp_favourite_candidates`
  MODIFY `employer_id` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `pp_favourite_companies`
--
ALTER TABLE `pp_favourite_companies`
  MODIFY `seekerid` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `pp_institute`
--
ALTER TABLE `pp_institute`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `pp_job_alert`
--
ALTER TABLE `pp_job_alert`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `pp_job_alert_queue`
--
ALTER TABLE `pp_job_alert_queue`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `pp_job_functional_areas`
--
ALTER TABLE `pp_job_functional_areas`
  MODIFY `ID` int(7) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `pp_job_industries`
--
ALTER TABLE `pp_job_industries`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=41;
--
-- AUTO_INCREMENT for table `pp_job_seekers`
--
ALTER TABLE `pp_job_seekers`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=144;
--
-- AUTO_INCREMENT for table `pp_job_titles`
--
ALTER TABLE `pp_job_titles`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;
--
-- AUTO_INCREMENT for table `pp_newsletter`
--
ALTER TABLE `pp_newsletter`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `pp_post_jobs`
--
ALTER TABLE `pp_post_jobs`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=52;
--
-- AUTO_INCREMENT for table `pp_prohibited_keywords`
--
ALTER TABLE `pp_prohibited_keywords`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;
--
-- AUTO_INCREMENT for table `pp_qualifications`
--
ALTER TABLE `pp_qualifications`
  MODIFY `ID` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;
--
-- AUTO_INCREMENT for table `pp_salaries`
--
ALTER TABLE `pp_salaries`
  MODIFY `ID` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;
--
-- AUTO_INCREMENT for table `pp_scam`
--
ALTER TABLE `pp_scam`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `pp_seeker_academic`
--
ALTER TABLE `pp_seeker_academic`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
--
-- AUTO_INCREMENT for table `pp_seeker_additional_info`
--
ALTER TABLE `pp_seeker_additional_info`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=115;
--
-- AUTO_INCREMENT for table `pp_seeker_applied_for_job`
--
ALTER TABLE `pp_seeker_applied_for_job`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=84;
--
-- AUTO_INCREMENT for table `pp_seeker_experience`
--
ALTER TABLE `pp_seeker_experience`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;
--
-- AUTO_INCREMENT for table `pp_seeker_resumes`
--
ALTER TABLE `pp_seeker_resumes`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=117;
--
-- AUTO_INCREMENT for table `pp_seeker_skills`
--
ALTER TABLE `pp_seeker_skills`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=312;
--
-- AUTO_INCREMENT for table `pp_settings`
--
ALTER TABLE `pp_settings`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
--
-- AUTO_INCREMENT for table `pp_skills`
--
ALTER TABLE `pp_skills`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;
--
-- AUTO_INCREMENT for table `pp_stories`
--
ALTER TABLE `pp_stories`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT;
--
-- AUTO_INCREMENT for table `tbl_gallery`
--
ALTER TABLE `tbl_gallery`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
