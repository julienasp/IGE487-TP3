/*
-- =========================================================================== A
Activité : IGE487
Trimestre : Automne 2015
Composant : ige487_tra.sql
Encodage : UTF-8
Plateforme : Oracle
Responsable : Luc.Lavoie@USherbrooke.ca
Version : 2.0
Statut : en vigueur
-- =========================================================================== A
*/

/*
-- =========================================================================== B
Création du schéma de la base de données transactionnelle.
Inclus les TRIGGERS
-- =========================================================================== B
*/

-- Dossier d'un patient
CREATE TABLE DOSSIER_PATIENT (
	NO_DOSSIER NUMBER, 
	NOM VARCHAR2(30) NOT NULL, 
	PRENOM VARCHAR2(30 ) NOT NULL, 
	NOM_MERE VARCHAR2(30), 
	PRENOM_MERE VARCHAR2(30), 
	NAM VARCHAR2(9) NOT NULL, 
	DATE_DE_NAISSANCE DATE,
	CONSTRAINT pk_DOSSIERS PRIMARY KEY(NO_DOSSIER)
 );
 
 -- Medicament
CREATE TABLE MEDICAMENT (	
    DIN VARCHAR2(8), 
	NOM_MEDICAMENT VARCHAR2(30) NOT NULL , 
	FORME_GALENIQUE VARCHAR2(20),
	POSOLOGIE VARCHAR2(30), 
	CONSTRAINT pk_MEDICAMENTS PRIMARY KEY(DIN)
 );
 
 -- Voie d'administration  
  CREATE TABLE VOIE_ADMINISTRATION (	
  	NO_VOIE_ADMINISTRATION NUMBER , 
	NOM_VOIE VARCHAR2(30), 
	CONSTRAINT pk_VOIE_ADMINISTRATION PRIMARY KEY(NO_VOIE_ADMINISTRATION)
);

-- Unité de soin
CREATE TABLE UNITE_DE_SOIN (
	NO_UNITE NUMBER ,
	NOM_UNITE VARCHAR2 (30) NOT NULL,
	ETAGE NUMBER NOT NULL,
	CONSTRAINT pk_UNITE_DE_SOIN PRIMARY KEY(NO_UNITE)
);

-- Plage horaire
CREATE TABLE PLAGE_HORAIRE ( 
	DATE_JOUR DATE, 
	QUART_DE_TRAVAIL VARCHAR2(10),
	CONSTRAINT pk_PLAGE_HORAIRE PRIMARY KEY(DATE_JOUR,QUART_DE_TRAVAIL)
);

-- Rôle
CREATE TABLE ROLE (
	NO_ROLE NUMBER, 
	NOM_ROLE VARCHAR2(50) NOT NULL,
	CONSTRAINT pk_ROLES PRIMARY KEY(NO_ROLE)
);

-- Employé
CREATE TABLE EMPLOYE (	
	NO_EMPLOYE NUMBER, 
	NAS VARCHAR2(9) NOT NULL , 
	NOM VARCHAR2(30) NOT NULL , 
	PRENOM VARCHAR2(30) NOT NULL,
	CONSTRAINT pk_EMPLOYES PRIMARY KEY(NO_EMPLOYE)
);

-- Chambre
CREATE TABLE CHAMBRE (
	NO_CHAMBRE NUMBER, 
	NO_UNITE NUMBER, 
	CONSTRAINT pk_CHAMBRES PRIMARY KEY(NO_CHAMBRE),
	CONSTRAINT FK_CHAMBRES_UNITE FOREIGN KEY (NO_UNITE) REFERENCES UNITE_DE_SOIN (NO_UNITE)
);

-- Lit
CREATE TABLE LIT (
	NO_LIT NUMBER, 
	NO_CHAMBRE NUMBER, 
	CONSTRAINT pk_LITS PRIMARY KEY(NO_LIT),
	CONSTRAINT FK_LITS_CHAMBRE FOREIGN KEY (NO_CHAMBRE) REFERENCES CHAMBRE(NO_CHAMBRE)
);

-- Sejour
CREATE TABLE SEJOUR (	
	NO_SEJOUR NUMBER, 
	NO_DOSSIER NUMBER,  
	NO_UNITE NUMBER,
	DATE_ARRIVEE DATE, 
	DATE_DEPART DATE,  
	CONSTRAINT pk_SEJOUR PRIMARY KEY(NO_SEJOUR),
	CONSTRAINT FK_SEJOUR_DOSSIER FOREIGN KEY (NO_DOSSIER) REFERENCES DOSSIER_PATIENT (NO_DOSSIER),  
	CONSTRAINT FK_SEJOUR_UNITE_DE_SOIN FOREIGN KEY (NO_UNITE) REFERENCES UNITE_DE_SOIN (NO_UNITE) 
);

-- Ordonnance
CREATE TABLE ORDONNANCE (
	NO_ORDONNANCE NUMBER,
	NO_DOSSIER NUMBER,
	NO_EMPLOYE NUMBER,
	DATE_EMISSION DATE,
	CONSTRAINT pk_ORDONNANCES PRIMARY KEY(NO_ORDONNANCE),
	CONSTRAINT FK_ORDONANCES_DOSSIER_PATIENT FOREIGN KEY(NO_DOSSIER) REFERENCES DOSSIER_PATIENT(NO_DOSSIER),
	CONSTRAINT FK_ORDONANCES_MEDECIN FOREIGN KEY(NO_EMPLOYE) REFERENCES EMPLOYE(NO_EMPLOYE)
);

-- Prescription
CREATE TABLE PRESCRIPTION (
	NO_PRESCRIPTION NUMBER,
	NO_ORDONNANCE NUMBER,
	DIN VARCHAR2(8), 
	DATE_DEBUT DATE, 
	DATE_FIN DATE,
	DOSAGE VARCHAR2(10), 
	FREQUENCE VARCHAR2(10),
	CONSTRAINT pk_PRESCRIPTIONS PRIMARY KEY(NO_PRESCRIPTION),
	CONSTRAINT FK_PRESCRIPTIONS_ORDONNANCE FOREIGN KEY(NO_ORDONNANCE) REFERENCES ORDONNANCE(NO_ORDONNANCE),
	CONSTRAINT FK_PRESCRIPTIONS_MEDICAMENT FOREIGN KEY(DIN) REFERENCES MEDICAMENT(DIN)
);                                              

-- Voie d'administration des médicaments
CREATE TABLE VOIE_ADM_MEDICAMENT (	
	DIN VARCHAR2(8),
	NO_VOIE_ADMINISTRATION NUMBER,
	CONSTRAINT pk_VOIE_ADM_MEDIC PRIMARY KEY(DIN, NO_VOIE_ADMINISTRATION),
	CONSTRAINT FK_VAM_MEDICAMENT FOREIGN KEY(DIN) REFERENCES MEDICAMENT(DIN),
	CONSTRAINT FK_VAM_VADM FOREIGN KEY(NO_VOIE_ADMINISTRATION) REFERENCES VOIE_ADMINISTRATION(NO_VOIE_ADMINISTRATION)
);

-- Affectation
CREATE TABLE AFFECTATION (	
	NO_UNITE NUMBER,
	NO_EMPLOYE NUMBER,
	DATE_JOUR DATE, 
	QUART_DE_TRAVAIL VARCHAR2(10),	
	STATUS INT,
	CONSTRAINT pk_AFFECTATION PRIMARY KEY(NO_UNITE,NO_EMPLOYE,DATE_JOUR,QUART_DE_TRAVAIL),
	CONSTRAINT FK_AFFECTATION_UNITE_DE_SOIN FOREIGN KEY(NO_UNITE) REFERENCES UNITE_DE_SOIN(NO_UNITE),
	CONSTRAINT FK_AFFECTATION_EMPLOYE FOREIGN KEY(NO_EMPLOYE) REFERENCES EMPLOYE(NO_EMPLOYE),
	CONSTRAINT FK_AFFECTATION_PLAGE_HORAIRE FOREIGN KEY(DATE_JOUR,QUART_DE_TRAVAIL) REFERENCES PLAGE_HORAIRE(DATE_JOUR,QUART_DE_TRAVAIL)
);

-- Occupation des lits
CREATE TABLE OCCUPATION_DES_LITS (	
	NO_SEJOUR NUMBER,
	NO_LIT NUMBER,
	CONSTRAINT pk_OCCUPATION_DES_LITS PRIMARY KEY(NO_SEJOUR, NO_LIT),
	CONSTRAINT FK_OCCUP_LITS_SEJOUR FOREIGN KEY(NO_SEJOUR) REFERENCES SEJOUR(NO_SEJOUR),
	CONSTRAINT FK_OCCUPATION_DES_LITS FOREIGN KEY(NO_LIT) REFERENCES LIT(NO_LIT)
);

-- Medecin traitant
CREATE TABLE MEDECIN_TRAITANT (	
	NO_SEJOUR NUMBER,
	NO_EMPLOYE NUMBER,
	D_DEBUT DATE, 
	D_FIN DATE,
	CONSTRAINT pk_MEDECIN_TRAITANT PRIMARY KEY(NO_SEJOUR, NO_EMPLOYE),
	CONSTRAINT FK_MEDECIN_TRAITANT_SEJOUR FOREIGN KEY(NO_SEJOUR) REFERENCES SEJOUR(NO_SEJOUR),
	CONSTRAINT FK_MEDECIN_TRAITANT_EMPLOYE FOREIGN KEY(NO_EMPLOYE) REFERENCES EMPLOYE(NO_EMPLOYE)
);

-- Spécialité (Rôle que joue un employé)
CREATE TABLE SPECIALITE (	
	NO_ROLE NUMBER,
	NO_EMPLOYE NUMBER,
	CONSTRAINT pk_SPECIALITE PRIMARY KEY(NO_ROLE, NO_EMPLOYE),
	CONSTRAINT FK_SPECIALITE_ROLE FOREIGN KEY(NO_ROLE) REFERENCES ROLE(NO_ROLE),
	CONSTRAINT FK_SPECIALITE_EMPLOYE FOREIGN KEY(NO_EMPLOYE) REFERENCES EMPLOYE(NO_EMPLOYE)
);

-- Habilitation (rôle requis pour administrer un médicament)
CREATE TABLE HABILITATION (	
	NO_ROLE NUMBER,
	NO_VOIE_ADMINISTRATION NUMBER,
	CONSTRAINT pk_HABILITATION PRIMARY KEY(NO_ROLE, NO_VOIE_ADMINISTRATION),
	CONSTRAINT FK_HABILITATION_ROLE FOREIGN KEY(NO_ROLE) REFERENCES ROLE(NO_ROLE),
	CONSTRAINT FK_HABILITATION_VOIE_ADM FOREIGN KEY(NO_VOIE_ADMINISTRATION) REFERENCES VOIE_ADMINISTRATION(NO_VOIE_ADMINISTRATION)
);

-- Affectation_prescription 
CREATE TABLE AFFECTATION_PRESCRIPTION (	
	NO_PRESCRIPTION NUMBER,
	NO_EMPLOYE NUMBER,
	DATE_JOUR DATE,
	QUART_DE_TRAVAIL VARCHAR2(10),
	STATUSAP INT,
	CONSTRAINT pk_AFFECTATION_PRESC PRIMARY KEY(NO_PRESCRIPTION, NO_EMPLOYE, DATE_JOUR, QUART_DE_TRAVAIL),
	CONSTRAINT FK_AFFECTATION_PRESCRIPTION FOREIGN KEY(NO_PRESCRIPTION) REFERENCES PRESCRIPTION(NO_PRESCRIPTION),
	CONSTRAINT FK_AFFECTATION_PRESC_EMPLOYE FOREIGN KEY(NO_EMPLOYE) REFERENCES EMPLOYE(NO_EMPLOYE),
	CONSTRAINT FK_AFFECTATION_PRESC_HORAIRE FOREIGN KEY(DATE_JOUR,QUART_DE_TRAVAIL) REFERENCES PLAGE_HORAIRE(DATE_JOUR,QUART_DE_TRAVAIL)
);


-- Création des auto-incrément pour l'insertion automatique des clés primaires
CREATE SEQUENCE seq_DOSSIER_PATIENT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_VOIE_ADMINISTRATION START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_UNITE_DE_SOIN START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ROLE START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_EMPLOYE START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_CHAMBRE START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_LIT START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_SEJOUR START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ORDONNANCE START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_PRESCRIPTION START WITH 1 INCREMENT BY 1;


/* 
 * CREATION DES TRIGGERS
*/

/* Trigger permettant d'empecher l'insertion de plus de quatre lits pour une chambre */
CREATE OR REPLACE TRIGGER t_b_i_lit BEFORE INSERT ON lit
FOR EACH ROW 
DECLARE
	nb NUMBER;
BEGIN
	-- On compte le nombre de lits que possede deja la chambre
	SELECT COUNT(*) INTO nb FROM lit WHERE no_chambre = :NEW.no_chambre;
	-- Si elle en a 4, on leve une exception pour refuser l'insetion
	if (nb >= 4) then 
		RAISE_APPLICATION_ERROR(-20001, 'La chambre numero ' || :NEW.no_chambre || ' a atteind son maximum de 4 lits');
	end if;
END;
/ 

/* Trigger permettant de s'assurer que l'employe charge d'administrer un medicament a un patient a bien la qualification requise */
CREATE OR REPLACE TRIGGER t_b_i_Affectation_prescription BEFORE INSERT ON affectation_prescription
FOR EACH ROW 
DECLARE
	qualif  role.no_role%type; -- La qualification requise pour administrer le medicament
	vrole   role.no_role%type; -- La qualification de l''employé
BEGIN
	-- On recupere la qualification requise pour administrer le medicament prescris 
	SELECT no_role INTO qualif FROM habilitation h, voie_adm_medicament vam, prescription p
	WHERE h.no_voie_administration = vam.no_voie_administration AND vam.din = p.din
		  AND p.no_prescription = :new.no_prescription;
	-- On recupere la qualification de l'employe charge d'administrer cette prescription
	SELECT no_role INTO vrole FROM specialite s, employe e 
	WHERE s.no_employe = e.no_employe AND e.no_employe = :NEW.no_employe;
	-- Si le niveau de l'employe est inferieur a la qualification requise, on leve une exception pour refuser l'insertion
	if (vrole < qualif) then 
		RAISE_APPLICATION_ERROR(-20002, 'Cet employe a le niveau ' || vrole || ' alors que le medicament requiert le niveau ' || qualif || ', il ne peut donc l''administrer');
	end if;
END;
/ 

/* Trigger permettant de s'assurer que seul un medecin peut prescrire un medicament */
CREATE OR REPLACE TRIGGER t_b_i_ordonnance BEFORE INSERT ON ordonnance
FOR EACH ROW 
DECLARE
	vrole role.no_role%type;
BEGIN
	-- On recupere la qualification de l'employe qui prescrit l'ordonnance
	SELECT no_role INTO vrole FROM specialite s, employe e 
	WHERE s.no_employe = e.no_employe AND e.no_employe = :NEW.no_employe;
	-- Si la qualification de l'employe est differente de 5 (niveau medecin), on leve une exception pour refuser l'insertion
	if (vrole != 5) then 
		RAISE_APPLICATION_ERROR(-20003, 'Seul un medecin peut prescrire une ordonnance');
	end if;
END;
/ 

/* Trigger permettant de s'assurer que seul un medecin peut être désigné medecin traitant pour un séjour */
CREATE OR REPLACE TRIGGER t_b_i_medecin_traitant BEFORE INSERT ON medecin_traitant
FOR EACH ROW 
DECLARE
	vrole role.no_role%type;
BEGIN
	-- On recupere la qualification de l'employe
	SELECT no_role INTO vrole FROM specialite s, employe e 
	WHERE s.no_employe = e.no_employe AND e.no_employe = :NEW.no_employe;
	-- Si la qualification de l'employe est differente de 5 (niveau medecin), on leve une exception pour refuser l'insertion
	if (vrole != 5) then 
		RAISE_APPLICATION_ERROR(-20004, 'Seul un medecin peut être désigné comme medecin traitant');
	end if;
END;
/ 

/* Trigger permettant de vérifier que la couverture globale sur 7 jours est assurée 
	après l'ajout d'une prescription, sinon affiche un message d'avertissement */
CREATE OR REPLACE TRIGGER t_a_i_o_u_prescription AFTER INSERT OR UPDATE ON prescription
FOR EACH ROW 
DECLARE
	ajd DATE;	-- La date d'aujourd'hui
	sem DATE;	-- La date dans une semaine
	nb  NUMBER;
BEGIN
	-- On recupere la date d'aujourd'hui et de celle dans 7 jours
	SELECT SYSDATE INTO ajd from DUAL;
	SELECT SYSDATE +7 INTO sem from DUAL;

	SELECT COUNT(*) INTO nb FROM affectation 
	WHERE date_jour BETWEEN ajd AND sem;

	-- Nous devons avoir 3 équipes par jour et ce pour les 7 jours suivants
	if (nb < (3*7)) then 
		dbms_output.put_line('********************************************************************************************************');
		dbms_output.put_line('ATTENTION, LA COUVERTURE DE L''AFFECTATION DU PERSONNEL N''EST PAS ASSUREE SUR L''HORIZON DES SEPT JOURS');
		dbms_output.put_line('********************************************************************************************************');
	end if;
END;
/

-- Soumettre la création du schéma
commit;

/*
-- =========================================================================== Z
Contributeurs :
(MBB) Mamadou.Bobo.Bah@USherbrooke.ca    (matricule 15 130 742)
(SK)  Soumia.Kherbache@USherbrooke.ca    (matricule 14 181 440)
(JA)  Julien.Aspirot@USherbrooke.ca      (matricule 15 146 398)
(PMA) Pierre-Marie.Airiau@USherbrooke.ca (matricule 15 138 398)

-- -----------------------------------------------------------------------------
-- fin de ige487_tra.sql
-- =========================================================================== Z
*/