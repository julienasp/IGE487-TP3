/*
-- =========================================================================== A
Activité : IGE487
Trimestre : Automne 2015
Composant : ige487_alim.sql
Encodage : UTF-8
Plateforme : Oracle
Responsable : Luc.Lavoie@USherbrooke.ca
Version : 3.3
Statut : en vigueur
-- =========================================================================== A
*/

/*
-- =========================================================================== B
Alimentation initiale de l’entrepôt de données à partir de la base de données
transactionnelle.

Note:
A n'appliquer que si le schéma a déjà été crée
-- =========================================================================== B
*/

SET SERVEROUTPUT ON; 

/* Nous allons d'abord créer un lien vers la base de données transactionnelle (BDT) pour pouvoir 
 * l'interroger et ainsi remplir notre entrepôt
*/
CREATE PUBLIC DATABASE LINK entrepot_bd
CONNECT TO system IDENTIFIED BY Wd44op88$29
USING '(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=10.44.88.229)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=orcl)))';


/* Procédure permettant d'insérer dans la dimension Habilitation, les données correspondantes 
 * dans la base de données transactionnelle
 */
CREATE OR REPLACE PROCEDURE Insert_Habilitation AS
	vnom VARCHAR2(30);
BEGIN
	-- On recupère toutes les habilitations présentes dans la BDT
	FOR c1 IN (SELECT * FROM Habilitation@entrepot_bd) LOOP
		-- Pour chacune, on recupère le nom de la voie d'administration correspondante
	    SELECT nom_voie INTO vnom FROM Voie_administration@entrepot_bd
	    WHERE no_voie_administration = c1.no_voie_administration;

	    -- On insère les données correspondantes
	    INSERT INTO Habilitation VALUES (seq_habilitation.nextval, c1.no_role, c1.no_voie_administration, vnom);
	    dbms_output.put_line('1 ligne insérée.');
 	END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Cette clé artificielle existe déjà dans la dimension Habilitation');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute Insert_Habilitation;


/* Procédure permettant d'insérer dans la dimension Lieu, les données correspondantes 
 * dans la base de données transactionnelle
 */
create or replace PROCEDURE INSERT_LIEUX AS
  titrl VARCHAR2(20);
BEGIN
  FOR c1 IN (SELECT * FROM UNITE_DE_SOIN@entrepot_bd) LOOP         
  	SELECT NOM_UNITE INTO titrl FROM UNITE_DE_SOIN@entrepot_bd
    where NO_UNITE = c1.NO_UNITE;   
  
    FOR c2 IN (SELECT NO_CHAMBRE FROM CHAMBRE@entrepot_bd WHERE NO_UNITE = c1.NO_UNITE) LOOP
      FOR c3 IN (SELECT NO_LIT FROM LIT@entrepot_bd WHERE NO_CHAMBRE = c2.NO_CHAMBRE) LOOP
        INSERT INTO LIEUX VALUES (SEQ_LIEUX.nextval,c1.NO_UNITE, c3.NO_LIT, c2.NO_CHAMBRE, titrl, c1.ETAGE);
        dbms_output.put_line('1 ligne insérée.');
      END LOOP;
    END LOOP;
 END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Cette clé artificielle existe déjà dans la dimension Lieu');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute INSERT_LIEUX;


/* Procédure permettant d'insérer dans la dimension PLAGE_HORAIRE, les données correspondantes 
 * dans la base de données transactionnelle
 */
create or replace PROCEDURE INSERT_PLAGE_HORAIRE AS
BEGIN
  FOR i IN (SELECT * FROM PLAGE_HORAIRE@ENTREPOT_BD)LOOP
    INSERT INTO PLAGE_HORAIRE VALUES(SEQ_PLAGE_HORAIRE.NEXTVAL,i.DATE_JOUR,i.QUART_DE_TRAVAIL);
    dbms_output.put_line('1 ligne insérée.');
  END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Cette clé artificielle existe déjà dans la dimension PLAGE_HORAIRE');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute INSERT_PLAGE_HORAIRE;


/* Procédure permettant d'insérer dans la dimension DOSSIER_PATIENT, les données correspondantes 
 * dans la base de données transactionnelle
 */
create or replace PROCEDURE INSERT_DOSSIER AS 
BEGIN
  FOR c1 IN (SELECT * FROM Dossier_patient@entrepot_bd) LOOP
    INSERT INTO Dossier_patient VALUES (seq_dossier.nextval, c1.no_dossier, c1.nam, c1.nom, c1.prenom, c1.date_de_naissance, c1.nom_mere, c1.prenom_mere);
    dbms_output.put_line('1 ligne insérée.');
 	END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Cette clé artificielle existe déjà dans la dimension DOSSIER_PATIENT');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute INSERT_DOSSIER;


/* Procédure permettant d'insérer dans la dimension SEJOUR, les données correspondantes 
 * dans la base de données transactionnelle
 */
create or replace PROCEDURE INSERT_SEJOUR AS 
BEGIN
  FOR c1 IN (SELECT * FROM SEJOUR@entrepot_bd) LOOP 
    INSERT INTO SEJOUR VALUES (seq_sejour.nextval, c1.no_sejour, c1.no_dossier, c1.no_unite, c1.date_arrivee, c1.date_depart);
    dbms_output.put_line('1 ligne insérée.');
 	END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Cette clé artificielle existe déjà dans la dimension SEJOUR');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute INSERT_SEJOUR;


/* Procédure permettant d'insérer dans la dimension EMPLOYE, les données correspondantes 
 * dans la base de données transactionnelle
 */
create or replace PROCEDURE INSERT_EMPLOYE AS
  nomR VARCHAR2(50);
BEGIN
  FOR c1 IN (SELECT * FROM Employe@entrepot_bd) LOOP
    FOR c2 IN (SELECT no_role FROM Specialite@entrepot_bd WHERE no_employe = c1.no_employe) LOOP 
      SELECT NOM_role INTO nomR FROM Role@entrepot_bd
      where no_role = c2.no_role;
  
      FOR c3 IN (SELECT no_habilitation_ak FROM Habilitation WHERE no_role = c2.no_role) LOOP
        INSERT INTO Employe VALUES (seq_employe.nextval, c3.no_habilitation_ak, c1.no_employe, c2.no_role, nomR, c1.nas, c1.nom, c1.prenom);
        dbms_output.put_line('1 ligne insérée.');
      END LOOP;
    END LOOP;
 	END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Cette clé artificielle existe déjà dans la dimension EMPLOYE');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute INSERT_EMPLOYE;


/* Procédure permettant d'insérer dans la dimension Medicament, les données correspondantes 
 * dans la base de données transactionnelle
 */
CREATE OR REPLACE PROCEDURE Insert_Medicament AS
	vcle NUMBER;
	vnum_voie NUMBER;
BEGIN
	-- On recupère tous les médicaments présents dans la BDT
	FOR c1 IN (SELECT din,nom_medicament FROM Medicament@entrepot_bd) LOOP
	    -- Pour chacun, on recupère la voie d'administration correspondante
	    SELECT no_voie_administration INTO vnum_voie FROM Voie_adm_medicament@entrepot_bd
	    WHERE din = c1.din;

	    -- On récupère la clé artificielle liée à la voie d'administration
	    SELECT no_habilitation_ak INTO vcle FROM Habilitation
	    WHERE no_voie_administration = vnum_voie;

	    -- On insère les données correspondantes
	    INSERT INTO Medicament VALUES (seq_medicament.nextval, vcle, c1.din, c1.nom_medicament);
	    dbms_output.put_line('1 ligne insérée.');
	END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Cette clé artificielle existe déjà dans la dimension Medicament');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute Insert_Medicament;


/* Procédure permettant d'insérer dans la dimension Prescription, les données correspondantes 
 * dans la base de données transactionnelle
 */
CREATE OR REPLACE PROCEDURE Insert_Prescription AS
	vordo Ordonnance@entrepot_bd%ROWTYPE;
	vcle NUMBER;
BEGIN
	-- On recupère toutes les prescriptions présentes dans la BDT
	FOR c1 IN (SELECT * FROM Prescription@entrepot_bd) LOOP
		-- Pour chacune, on recupère l'ordonnance correspondante
	    SELECT * INTO vordo FROM Ordonnance@entrepot_bd
	    WHERE no_ordonnance = c1.no_ordonnance;

	    -- On récupère la clé artificielle liée au médicament prescrit
	    SELECT no_medicament_ak INTO vcle FROM Medicament
	    WHERE din = c1.din;

	    -- On insère les données correspondantes
	    INSERT INTO Prescription VALUES (seq_prescription.nextval, vcle, c1.no_prescription, vordo.no_ordonnance, vordo.no_dossier, vordo.no_employe, 
	    								 c1.din, vordo.date_emission, c1.frequence, c1.dosage, c1.date_debut, c1.date_fin);
	    dbms_output.put_line('1 ligne insérée.');
	END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Cette clé artificielle existe déjà dans la dimension Prescription');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute Insert_Prescription;


/* Procédure permettant d'insérer les données dans la table de fait Nouvelle_prescription 
 */
CREATE OR REPLACE PROCEDURE Insert_Nvle_prescription_fact AS
	vemp NUMBER;
	vcle NUMBER;
	vpresc NUMBER;
BEGIN
	-- On recupère toutes les prescriptions présentes dans la BDT
	FOR c1 IN (SELECT * FROM Prescription@entrepot_bd) LOOP
		-- Pour chacune, on recupère l'employé ayant prescrit l'ordonnance
	    SELECT no_employe INTO vemp FROM Ordonnance@entrepot_bd
	    WHERE no_ordonnance = c1.no_ordonnance;

	    -- On récupère la clé artificielle liée à la prescription
	    SELECT no_prescription_ak INTO vpresc FROM Prescription
	    WHERE no_prescription = c1.no_prescription;

	    -- On récupère la clé artificielle liée à l'employé
	    FOR c2 IN (SELECT no_employe_ak FROM Employe WHERE no_employe = vemp) LOOP
	    	vcle := c2.no_employe_ak;
	    END LOOP;

	    -- On insère les données correspondantes
	    INSERT INTO Nouvelle_prescription_fact VALUES (vcle, vpresc);
	    dbms_output.put_line('1 ligne insérée.');
	END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Ce couple de clés artificielles existe déjà dans la table de fait Nouvelle_prescription');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute Insert_Nvle_prescription_fact;


/* Procédure permettant d'insérer les données dans la table de fait Planification_prescription 
 */
CREATE OR REPLACE PROCEDURE Insert_Planif_presc_fact AS
	vemp NUMBER;
	vheure NUMBER;
	vpresc NUMBER;
BEGIN
	/* On recupère toutes les affectations à une prescriptions présentes dans la BDT
	   ayant comme status 0 (non encore effectué) */
	FOR c1 IN (SELECT * FROM Affectation_prescription@entrepot_bd WHERE statusAP = 0) LOOP
	    -- On récupère la clé artificielle liée à l'employé affecté à la prescription
	    FOR c2 IN (SELECT no_employe_ak FROM Employe WHERE no_employe = c1.no_employe) LOOP
	    	vemp := c2.no_employe_ak;
	    END LOOP;

	    -- On récupère la clé artificielle liée à la prescription 
	    SELECT no_prescription_ak INTO vpresc FROM Prescription
	    WHERE no_prescription = c1.no_prescription;

	    -- On récupère la clé artificielle liée à la plage horaire
	    SELECT no_plage_horaire_ak INTO vheure FROM Plage_horaire
	    WHERE date_jour = c1.date_jour AND quart_de_travail like c1.quart_de_travail;

	    -- On insère les données correspondantes
	    INSERT INTO Planification_presc_fact VALUES (vemp, vheure, vpresc);
	    dbms_output.put_line('1 ligne insérée.');
	END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Ce couple de clés artificielles existe déjà dans la table de fait Planification_prescription');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute Insert_Planif_presc_fact;


/* Procédure permettant d'insérer les données dans la table de fait Prescription_administree
 */
CREATE OR REPLACE PROCEDURE Insert_Prescription_admin_fact AS
	vemp NUMBER;
	vheure NUMBER;
	vpresc NUMBER;
BEGIN
	/* On recupère toutes les affectations à une prescriptions présentes dans la BDT
	   ayant comme status 1 (déjà effectué) */
	FOR c1 IN (SELECT * FROM Affectation_prescription@entrepot_bd WHERE statusAP = 1) LOOP
		-- On récupère la clé artificielle liée à l'employé affecté à la prescription
	    FOR c2 IN (SELECT no_employe_ak FROM Employe WHERE no_employe = c1.no_employe) LOOP
	    	vemp := c2.no_employe_ak;
	    END LOOP;

	    -- On récupère la clé artificielle liée à la prescription 
	    SELECT no_prescription_ak INTO vpresc FROM Prescription
	    WHERE no_prescription = c1.no_prescription;

	    -- On récupère la clé artificielle liée à la plage horaire
	    SELECT no_plage_horaire_ak INTO vheure FROM Plage_horaire
	    WHERE date_jour = c1.date_jour AND quart_de_travail like c1.quart_de_travail;

	    -- On insère les données correspondantes
	    INSERT INTO Prescription_admin_fact VALUES (vemp, vheure, vpresc);
	    dbms_output.put_line('1 ligne insérée.');
	END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Ce couple de clés artificielles existe déjà dans la table de fait Prescription_administree');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute Insert_Prescription_admin_fact;


/* Procédure permettant d'insérer les données dans la table de fait Planification_horaire
 */
create or replace PROCEDURE INSERT_PLAN_HORAIRE_FACT AS 
  vemp NUMBER;
  vheure NUMBER;
  vlieu NUMBER;

BEGIN
  /* On recupère toutes les affectations présentes dans la BDT
	   ayant comme status 0 (non encore effectué) */
  FOR c1 IN (SELECT * FROM affectation@entrepot_bd  WHERE status = 0) LOOP
    -- On récupère la clé artificielle liée à l'employé affecté 
    FOR c2 IN (SELECT no_employe_ak FROM Employe WHERE no_employe = c1.no_employe) LOOP
	    	vemp := c2.no_employe_ak;
    END LOOP;
      
	  -- On récupère la clé artificielle liée à la plage horaire
    SELECT no_plage_horaire_ak INTO vheure FROM Plage_horaire
    WHERE date_jour = c1.date_jour AND quart_de_travail like c1.quart_de_travail;
   
    -- On récupère la clé artificielle liée au lieu
    FOR c2 IN (SELECT no_lieux_ak FROM Lieux WHERE no_unite = c1.no_unite) LOOP
	    	vlieu := c2.no_lieux_ak;
    END LOOP;
  
    -- On insère les données correspondantes
    INSERT INTO PLAN_HOR_EFF_FACT VALUES (vemp,vlieu,vheure);
    dbms_output.put_line('1 ligne insérée.');
 	END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Ce couple de clés artificielles existe déjà dans la table de fait Planification_horaire');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute INSERT_PLAN_HORAIRE_FACT;


/* Procédure permettant d'insérer les données dans la table de fait Horaire_effective
 */
 create or replace PROCEDURE INSERT_HORAIRE_EFFECTIVE_FACT AS 
  vemp NUMBER;
  vheure NUMBER;
  vlieu NUMBER;

BEGIN
  /* On recupère toutes les affectations présentes dans la BDT
	   ayant comme status 0 (non encore effectué) */
  FOR c1 IN (SELECT * FROM affectation@entrepot_bd  WHERE status = 1) LOOP
    -- On récupère la clé artificielle liée à l'employé affecté 
    FOR c2 IN (SELECT no_employe_ak FROM Employe WHERE no_employe = c1.no_employe) LOOP
	    	vemp := c2.no_employe_ak;
    END LOOP;
      
	  -- On récupère la clé artificielle liée à la plage horaire
    SELECT no_plage_horaire_ak INTO vheure FROM Plage_horaire
    WHERE date_jour = c1.date_jour AND quart_de_travail like c1.quart_de_travail;
   
    -- On récupère la clé artificielle liée au lieu
    FOR c2 IN (SELECT no_lieux_ak FROM Lieux WHERE no_unite = c1.no_unite) LOOP
	    	vlieu := c2.no_lieux_ak;
    END LOOP;
  
    -- On insère les données correspondantes
    INSERT INTO HORAIRE_EFFECTIF_FACT VALUES (vemp,vlieu,vheure);
    dbms_output.put_line('1 ligne insérée.');
 	END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Ce couple de clés artificielles existe déjà dans la table de fait Horaire_effective');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute INSERT_HORAIRE_EFFECTIVE_FACT;


/* Procédure permettant d'insérer les données dans la table de fait hospitalisation_sejour_admission_fact
 */
create or replace PROCEDURE INSERT_FACT_ADMIN_HOSPI AS
  sejour_ak NUMBER;
  dossier_ak NUMBER;
  lieux_ak NUMBER;
BEGIN
  FOR c1 IN (SELECT * FROM Sejour@entrepot_bd) LOOP
  
    SELECT MAX(no_sejour_ak) INTO sejour_ak FROM (SELECT * FROM Sejour
    WHERE No_sejour = c1.no_sejour);
    
    SELECT MAX(no_dossier_ak) INTO dossier_ak FROM (SELECT * FROM Dossier_patient
    WHERE No_dossier = c1.no_dossier);
    
    SELECT MAX(no_lieux_ak) INTO lieux_ak FROM (SELECT no_lieux_ak FROM Lieux, occupation_des_lits@entrepot_bd
    WHERE ((Lieux.no_lit = occupation_des_lits.no_lit@entrepot_bd AND Lieux.No_unite = c1.no_unite) 
    AND c1.no_sejour = occupation_des_lits.no_sejour@entrepot_bd));
  
    INSERT INTO hospi_sejour_admission_fact VALUES (sejour_ak, dossier_ak, lieux_ak, c1.date_arrivee);
    dbms_output.put_line('1 ligne insérée.');
  END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Ce couple de clés artificielles existe déjà dans la table de fait hospitalisation_sejour_admission');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute INSERT_FACT_ADMIN_HOSPI;


/* Procédure permettant d'insérer les données dans la table de fait hospitalisation_sejour_conge_fact
*/
create or replace PROCEDURE INSERT_FACT_END_HOSPI AS 
  sejour_ak NUMBER;
  dossier_ak NUMBER;
BEGIN
  FOR c1 IN (SELECT * FROM Sejour@entrepot_bd) LOOP
  
    SELECT MAX(no_sejour_ak) INTO sejour_ak FROM (SELECT * FROM Sejour
    WHERE No_sejour = c1.no_sejour);
    
    SELECT MAX(no_dossier_ak) INTO dossier_ak FROM (SELECT * FROM Dossier_patient
    WHERE No_dossier = c1.no_dossier);
  
    INSERT INTO hospi_sejour_conge_fact VALUES (sejour_ak, dossier_ak, c1.date_depart);
    dbms_output.put_line('1 ligne insérée.');
  END LOOP;
 EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Ce couple de clés artificielles existe déjà dans la table de fait hospitalisation_sejour_conge');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute INSERT_FACT_END_HOSPI;


/* Procédure permettant d'insérer les données dans la table de fait MEDECIN_TRAITANT_DEBUT_FACT
*/
create or replace PROCEDURE INSERT_DOCTOR_START_FACT AS 
BEGIN
  FOR c1 IN (SELECT * FROM Medecin_Traitant@entrepot_bd) LOOP
  
    INSERT INTO MEDECIN_TRAIT_DEBUT_FACT VALUES (c1.no_sejour, c1.no_employe, c1.d_debut);
    dbms_output.put_line('1 ligne insérée.');
  END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Ce couple de clés artificielles existe déjà dans la table de fait MEDECIN_TRAITANT_DEBUT');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute INSERT_DOCTOR_START_FACT;


/* Procédure permettant d'insérer les données dans la table de fait MEDECIN_TRAITANT_FIN_FACT
*/
create or replace PROCEDURE INSERT_DOCTOR_STOP_FACT AS 
BEGIN
  FOR c1 IN (SELECT * FROM Medecin_Traitant@entrepot_bd) LOOP
  
    INSERT INTO MEDECIN_TRAIT_FIN_FACT VALUES (c1.no_sejour, c1.no_employe, c1.d_fin);
    dbms_output.put_line('1 ligne insérée.');
 END LOOP;
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		dbms_output.put_line('Ce couple de clés artificielles existe déjà dans la table de fait MEDECIN_TRAITANT_FIN_FACT');
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('La requete a renvoye une ligne vide');
	WHEN OTHERS THEN
		dbms_output.put_line(TO_CHAR(SQLCODE) || '->' || SQLERRM);
END;
/

/* On exécute la procédure pour insérer les données
 */
execute INSERT_DOCTOR_STOP_FACT;

-- Soumettre l'alimentation initiale
commit;

/*
-- =========================================================================== Z
Contributeurs :
(MBB) Mamadou.Bobo.Bah@USherbrooke.ca    (matricule 15 130 742)
(SK)  Soumia.Kherbache@USherbrooke.ca    (matricule 14 181 440)
(JA)  Julien.Aspirot@USherbrooke.ca 	 (matricule 15 146 398)
(PMA) Pierre-Marie.Airiau@USherbrooke.ca (matricule 15 138 398)

-- -----------------------------------------------------------------------------
-- fin de ige487_alim.sql
-- =========================================================================== Z
*/