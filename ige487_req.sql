/*
-- =========================================================================== A
Activité : IGE487
Trimestre : Automne 2015
Composant : ige487_req.sql
Encodage : UTF-8
Plateforme : Oracle
Responsable : Luc.Lavoie@USherbrooke.ca
Version : 1.1
Statut : en vigueur
-- =========================================================================== A
*/

/*
-- =========================================================================== B
Requêtes temporelles mettant en évidence la couverture et la qualité 
des schémas
-- =========================================================================== B
*/

/*CHERCHE LES COUPLES MEDECIN_TRAITANT(EMPLOYE)-SEJOUR POUR LESQUELS LE MEDECIN_TRAITANT 
 * A COMMENCÉ ET DEJA FINI D'OFFICIER
 */
DATA :	

MEDECIN_TRAIT_DEBUT_FACT
		NO_SEJOUR_AK	NO_EMPLOYE_AK	DATE_DEBUT
1			1				4			21-SEP-15
2			2				9			29-SEP-15	
3			3				10			10-SEP-15
4			10				6			30-SEP-15

MEDECIN_TRAIT_FIN_FACT
		NO_SEJOUR_AK	NO_EMPLOYE_AK	DATE_FIN
1			1				4			28-OCT-15
2			2				9			05-OCT-15	
3			3				10			30-OCT-15

SELECT sejour.no_sejour_ak, medecin_trait_debut_fact.no_employe_ak
FROM (sejour INNER JOIN medecin_trait_debut_fact
ON sejour.no_sejour_ak = medecin_trait_debut_fact.no_sejour_ak) INNER JOIN  
(sejour INNER JOIN medecin_trait_fin_fact 
ON sejour.no_sejour_ak = medecin_trait_fin_fact.no_sejour_ak) 
ON (medecin_trait_debut_fact.no_sejour_ak = medecin_trait_fin_fact.no_sejour_ak 
AND medecin_trait_debut_fact.no_employe_ak = medecin_trait_fin_fact.no_employe_ak);

RESULTS :
		NO_sejour_AK	NO_employe_AK
1			1				4
2			2				9
3			3				10


/* Requête permettant de trouver le medecin ayant le plus prescris de médicaments 
*/
SELECT e.nas, e.prenom, e.nom
FROM Employe e, Prescription p, Nouvelle_prescription_fact n
WHERE e.no_employe_ak = n.no_employe_ak and p.no_prescription_ak = n.no_prescription_ak 
GROUP BY e.nas, e.prenom, e.nom
HAVING COUNT(n.no_employe_ak) = (SELECT MAX(COUNT(n.no_employe_ak)) 
                                  FROM Employe e, Prescription p, Nouvelle_prescription_fact n
                                  WHERE e.no_employe_ak = n.no_employe_ak and p.no_prescription_ak = n.no_prescription_ak 
                                  GROUP BY e.nas);

RESULTS :
101200376	CLAUDE	POULIN

/* Requête permettant de trouver le medecin ayant le moins prescris de médicaments 
*/
SELECT e.nas, e.prenom, e.nom
FROM Employe e, Prescription p, Nouvelle_prescription_fact n
WHERE e.no_employe_ak = n.no_employe_ak and p.no_prescription_ak = n.no_prescription_ak 
GROUP BY e.nas, e.prenom, e.nom
HAVING COUNT(n.no_employe_ak) = (SELECT MIN(COUNT(n.no_employe_ak)) 
                                  FROM Employe e, Prescription p, Nouvelle_prescription_fact n
                                  WHERE e.no_employe_ak = n.no_employe_ak and p.no_prescription_ak = n.no_prescription_ak 
                                  GROUP BY e.nas);

RESULTS :
332660987 SERGE BOULIN

/*
-- =========================================================================== Z
Contributeurs :
(MBB) Mamadou.Bobo.Bah@USherbrooke.ca    (matricule 15 130 742)
(SK)  Soumia.Kherbache@USherbrooke.ca    (matricule 14 181 440)
(JA)  Julien.Aspirot@USherbrooke.ca      (matricule 15 146 398)
(PMA) Pierre-Marie.Airiau@USherbrooke.ca (matricule 15 138 398)

-- -----------------------------------------------------------------------------
-- fin de ige487_req.sql
-- =========================================================================== Z
*/