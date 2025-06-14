--1.a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi, SUM(total_claim_count)
FROM prescription
GROUP BY npi
ORDER BY SUM(total_claim_count) DESC;
--answer: npi 1881634483 had 99707 claims

--1.b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

SELECT 
	prescriber.nppes_provider_last_org_name AS last_name,
	prescriber.nppes_provider_first_name AS first_name,
	prescriber.specialty_description,
	SUM(prescription.total_claim_count) AS highest_claim_total
FROM prescriber
INNER JOIN prescription
ON prescriber.npi = prescription.npi
GROUP BY prescriber.nppes_provider_last_org_name, prescriber.nppes_provider_first_name, prescriber.specialty_description
ORDER BY highest_claim_total DESC
LIMIT 1;
--updated from Jennifer

--2.a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT prescriber.specialty_description, SUM(prescription.total_claim_count) as total_claims 
FROM prescription 
LEFT JOIN prescriber ON prescription.npi = prescriber.npi  
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC;
--answer: Family Practice

--2.b. Which specialty had the most total number of claims for opioids?
SELECT 
	prescriber.specialty_description, 
	SUM(prescription.total_claim_count) as total_claims 
FROM prescription 
LEFT JOIN prescriber ON prescription.npi = prescriber.npi  
LEFT JOIN drug ON prescription.drug_name = drug.drug_name
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC;
--answer: Nurse Practitioner

--2.c. Challenge Question: Are there any specialties that appear in the prescriber table that have no associated prescriptions in the prescription table?

--2.d. Difficult Bonus: Do not attempt until you have solved all other problems! For each specialty, report the percentage of total claims by that specialty which are for opioids. Which specialties have a high percentage of opioids?

--3.a. Which drug (generic_name) had the highest total drug cost?
SELECT drug.generic_name, prescription.total_drug_cost
FROM drug
INNER JOIN prescription 
ON drug.drug_name = prescription.drug_name
ORDER BY prescription.total_drug_cost DESC
LIMIT 1;
--answer: PIRFENIDONE

--3.b. Which drug (generic_name) has the hightest total cost per day? Bonus: Round your cost per day column to 2 decimal places. Google ROUND to see how this works.
--WRONG (1st attempt) SELECT drug.generic_name, ROUND(prescription.total_drug_cost/30, 2)
--FROM drug
--INNER JOIN prescription
--ON drug.drug_name = prescription.drug_name
--ORDER BY prescription.total_drug_cost DESC;
--answer: PIRFENIDONE

SELECT
	generic_name, 
	ROUND(SUM(total_drug_cost) / SUM(total_day_supply), 2) AS total_cost_per_day
FROM prescription
INNER JOIN drug
USING (drug_name)
GROUP BY generic_name
ORDER BY total_cost_per_day DESC;
--answer: C1 ESTERASE INHIBITOR

--4.a. For each drug in the drug table, return the drug name and then a column named 'drug_type' which says 'opioid' for drugs which have opioid_drug_flag = 'Y', says 'antibiotic' for those drugs which have antibiotic_drug_flag = 'Y', and says 'neither' for all other drugs. Hint: You may want to use a CASE expression for this. See https://www.postgresqltutorial.com/postgresql-tutorial/postgresql-case/
SELECT drug_name, 
CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
ELSE
	'neither'
END AS drug_type
FROM drug;

--4.b. Building off of the query you wrote for part a, determine whether more was spent (total_drug_cost) on opioids or on antibiotics. Hint: Format the total costs as MONEY for easier comparision.
SELECT  
	CASE
		WHEN opioid_drug_flag = 'Y' THEN 'opioid'
		WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
		ELSE 'neither' END AS drug_type, SUM(prescription.total_drug_cost)::MONEY AS total_cost 
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY drug_type;
--more spent on opioids

--another option from KRITHIKA:
--SELECT 
		/*CASE 
			WHEN (SUM(CASE  WHEN opioid_drug_flag='Y' THEN prescription.total_drug_cost  END) > SUM(CASE  WHEN antibiotic_drug_flag='Y' THEN prescription.total_drug_cost  END)) THEN 'Most money spent on opioid' ELSE 'Most money spent on antibiotic'  END,*/
	 --CAST (SUM(CASE  WHEN opioid_drug_flag='Y' THEN prescription.total_drug_cost  END) AS money)AS opioid_cost,
	 --CAST (SUM(CASE  WHEN antibiotic_drug_flag='Y' THEN prescription.total_drug_cost  END)AS money) AS antibiotic_cost
	
--FROM drug
 --JOIN prescription
	--USING (drug_name)

--5.a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.
SELECT DISTINCT (cbsa)
FROM cbsa
WHERE cbsaname LIKE '%TN%';
--answer: 10

SELECT COUNT(cbsa)
FROM cbsa
INNER JOIN fips_county
USING (fipscounty)
WHERE state = 'TN';

--5.b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.
select cbsa.cbsaname, SUM(population.population) 
from cbsa
INNER JOIN population
ON cbsa.fipscounty = population.fipscounty
GROUP BY cbsa.cbsaname
ORDER BY SUM(population.population) DESC;
--answer: largest - Nashville-Davidson-Murfreesboro-Franklin, TN (1830410), smallest - Morristown (116352)

--5.c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.
SELECT 
	population, 
	fips_county.county
FROM population
LEFT JOIN cbsa
ON population.fipscounty = cbsa.fipscounty
LEFT JOIN fips_county
ON population.fipscounty = fips_county.fipscounty
WHERE cbsa.cbsaname IS NULL
ORDER BY population DESC; 

--answer: Sevier (95523)

--6.a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.
SELECT drug_name, total_claim_count
FROM prescription
WHERE total_claim_count >= 3000;

--6.b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.
SELECT prescription.drug_name, prescription.total_claim_count, drug.opioid_drug_flag
FROM prescription
LEFT JOIN drug
ON prescription.drug_name = drug.drug_name
WHERE total_claim_count >= 3000;

--6.c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.
SELECT prescription.drug_name, prescription.total_claim_count, drug.opioid_drug_flag, prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name
FROM prescription
LEFT JOIN drug
ON prescription.drug_name = drug.drug_name
LEFT JOIN prescriber
ON prescription.npi = prescriber.npi
WHERE prescription.total_claim_count >= 3000;

--7.The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.

--7.a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

SELECT prescriber.specialty_description, drug.drug_name, drug.opioid_drug_flag
FROM prescriber
JOIN prescription
USING (npi)
JOIN drug
USING (drug_name)
WHERE prescriber.specialty_description = 'Pain Management'
AND prescriber.nppes_provider_city ILIKE 'NASHVILLE';


--7.b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

SELECT  
	prescriber.npi,
	prescription.drug_name,
	prescription.total_claim_count
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING  (drug_name, npi)
WHERE prescriber.specialty_description = 'Pain Management'
AND prescriber.nppes_provider_city ILIKE 'NASHVILLE'
AND drug.opioid_drug_flag = 'Y';

--7.c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.

SELECT  
	prescriber.npi,
	prescription.drug_name,
	COALESCE(prescription.total_claim_count, 0) AS total_claims
FROM prescriber
CROSS JOIN drug
LEFT JOIN prescription
USING  (drug_name, npi)
WHERE prescriber.specialty_description = 'Pain Management'
AND prescriber.nppes_provider_city ILIKE 'NASHVILLE'
AND drug.opioid_drug_flag = 'Y';