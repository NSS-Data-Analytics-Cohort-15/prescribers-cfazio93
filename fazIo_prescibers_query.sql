--1.a. Which prescriber had the highest total number of claims (totaled over all drugs)? Report the npi and the total number of claims.

SELECT npi, total_claim_count
FROM prescription
ORDER BY total_claim_count DESC;

--answer: npi 1912011792 had 4538 claims

--1.b. Repeat the above, but this time report the nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, and the total number of claims.

SELECT prescription.npi, prescription.total_claim_count, prescriber.nppes_provider_first_name, prescriber.nppes_provider_last_org_name, prescriber.specialty_description
FROM prescription
LEFT JOIN prescriber
ON prescription.npi = prescriber.npi
ORDER BY prescription.total_claim_count DESC;

--2.a. Which specialty had the most total number of claims (totaled over all drugs)?

SELECT prescriber.specialty_description, SUM(prescription.total_claim_count) as total_claims 
FROM prescription 
LEFT JOIN prescriber ON prescription.npi = prescriber.npi  
GROUP BY prescriber.specialty_description
ORDER BY total_claims DESC;
--answer: Family Practice

--2.b. Which specialty had the most total number of claims for opioids?
SELECT prescriber.specialty_description, SUM(prescription.total_claim_count) as total_claims, drug.opioid_drug_flag
FROM prescription 
LEFT JOIN prescriber ON prescription.npi = prescriber.npi  
LEFT JOIN drug ON prescription.drug_name = drug.drug_name
WHERE drug.opioid_drug_flag = 'Y'
GROUP BY prescriber.specialty_description, drug.opioid_drug_flag
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
SELECT drug.generic_name, ROUND(prescription.total_drug_cost/30, 2)
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
ORDER BY prescription.total_drug_cost DESC;
--answer: PIRFENIDONE

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
		ELSE 'neither' END AS drug_type, SUM(prescription.total_drug_cost) AS MONEY
FROM drug
INNER JOIN prescription
ON drug.drug_name = prescription.drug_name
GROUP BY drug_type;
--more spent on opioids

--5.a. How many CBSAs are in Tennessee? Warning: The cbsa table contains information for all states, not just Tennessee.

--5.b. Which cbsa has the largest combined population? Which has the smallest? Report the CBSA name and total population.

--5.c. What is the largest (in terms of population) county which is not included in a CBSA? Report the county name and population.

--6.a. Find all rows in the prescription table where total_claims is at least 3000. Report the drug_name and the total_claim_count.

--6.b. For each instance that you found in part a, add a column that indicates whether the drug is an opioid.

--6.c. Add another column to you answer from the previous part which gives the prescriber first and last name associated with each row.

--7.The goal of this exercise is to generate a full list of all pain management specialists in Nashville and the number of claims they had for each opioid. Hint: The results from all 3 parts will have 637 rows.

--7.a. First, create a list of all npi/drug_name combinations for pain management specialists (specialty_description = 'Pain Management) in the city of Nashville (nppes_provider_city = 'NASHVILLE'), where the drug is an opioid (opiod_drug_flag = 'Y'). Warning: Double-check your query before running it. You will only need to use the prescriber and drug tables since you don't need the claims numbers yet.

--7.b. Next, report the number of claims per drug per prescriber. Be sure to include all combinations, whether or not the prescriber had any claims. You should report the npi, the drug name, and the number of claims (total_claim_count).

--7.c. Finally, if you have not done so already, fill in any missing values for total_claim_count with 0. Hint - Google the COALESCE function.