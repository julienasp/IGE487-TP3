/*
-- =========================================================================== A
Activité : IGE487
Trimestre : Automne 2015
Composant : ige487_dim.sql
Encodage : UTF-8
Plateforme : Oracle
Responsable : Luc.Lavoie@USherbrooke.ca
Version : 2.5
Statut : en vigueur
-- =========================================================================== A
*/

/*
-- =========================================================================== B
Création du schéma d’entrepôt de données dimensionnel.
-- =========================================================================== B
*/

-- Dimension Dossier_patient
CREATE TABLE DOSSIER_PATIENT (
	NO_DOSSIER_AK NUMBER,
	NO_DOSSIER NUMBER NOT NULL,
	NAM VARCHAR2(9) NOT NULL, 
	NOM VARCHAR2(30) NOT NULL, 
	PRENOM VARCHAR2(30 ) NOT NULL, 
	DATE_DE_NAISSANCE DATE NOT NULL,
	NOM_MERE VARCHAR2(30) NOT NULL, 
	PRENOM_MERE VARCHAR2(30) NOT NULL, 

	CONSTRAINT pk_DOSSIERS PRIMARY KEY(NO_DOSSIER_AK)
 );

 -- Dimension Sejour
CREATE TABLE SEJOUR (	
	NO_SEJOUR_AK NUMBER, 	
	NO_SEJOUR NUMBER NOT NULL, 
	NO_DOSSIER NUMBER NOT NULL,  
	NO_UNITE NUMBER  NOT NULL,
	DATE_ARRIVEE DATE NOT NULL, 
	DATE_DEPART DATE  NOT NULL, 

	CONSTRAINT pk_SEJOUR PRIMARY KEY(NO_SEJOUR_AK) 
);

-- Dimension PLAGE_HORAIRE
CREATE TABLE PLAGE_HORAIRE (	
	NO_PLAGE_HORAIRE_AK NUMBER,
	DATE_JOUR DATE, 
	QUART_DE_TRAVAIL VARCHAR2(10),

	CONSTRAINT PK_PLAGE_HORAIRE PRIMARY KEY (NO_PLAGE_HORAIRE_AK)
);

-- Dimension LIEU
CREATE TABLE LIEUX (	
	NO_LIEUX_AK NUMBER,
	NO_UNITE NUMBER NOT NULL,
	NO_LIT NUMBER NOT NULL,
    NO_CHAMBRE NUMBER NOT NULL,
    TITRE VARCHAR2(20),
    NO_ETAGE NUMBER NOT NULL,

	CONSTRAINT PK_LIEUX PRIMARY KEY (NO_LIEUX_AK)
);

-- Dimension Habilitation
CREATE TABLE Habilitation (
	no_habilitation_ak NUMBER, 
	no_role NUMBER NOT NULL, 
	no_voie_administration NUMBER NOT NULL, 
	nom_methode VARCHAR2(30) NOT NULL, 

	CONSTRAINT pk_Habilitation PRIMARY KEY(no_habilitation_ak)
 );

-- Dimension Médicament
CREATE TABLE Medicament (
	no_medicament_ak NUMBER, 
	no_habilitation_ak NUMBER,
	din VARCHAR2(8) NOT NULL,  
	nom_medicament VARCHAR2(30) NOT NULL,

	CONSTRAINT pk_Medicament PRIMARY KEY(no_medicament_ak),
	CONSTRAINT fk_Medicament_Habilitation FOREIGN KEY (no_habilitation_ak) REFERENCES Habilitation (no_habilitation_ak)
 );

-- Dimension Prescription
CREATE TABLE Prescription (
	no_prescription_ak NUMBER, 
	no_medicament_ak NUMBER,
	no_prescription NUMBER NOT NULL,  
	no_ordonnance NUMBER NOT NULL,
	no_dossier NUMBER NOT NULL,
	no_employe NUMBER NOT NULL,
	din VARCHAR2(8), 
	date_ordonnance DATE NOT NULL,
	frequence VARCHAR2(10)  NOT NULL,
	dosage VARCHAR2(10)  NOT NULL,
	date_debut DATE NOT NULL,
	date_fin DATE NOT NULL,

	CONSTRAINT pk_Prescription PRIMARY KEY(no_prescription_ak),
	CONSTRAINT fk_Prescription_Medicament FOREIGN KEY (no_medicament_ak) REFERENCES Medicament (no_medicament_ak)
 );

-- Dimension Employe
CREATE TABLE Employe (
	no_employe_ak NUMBER, 
	no_habilitation_ak NUMBER,
	no_employe NUMBER NOT NULL,
	no_role NUMBER NOT NULL,
	nom_role VARCHAR2(50) NOT NULL,  
	nas VARCHAR2(9) NOT NULL, 
	nom VARCHAR2(30) NOT NULL, 
	prenom VARCHAR2(30) NOT NULL, 

	CONSTRAINT pk_Employe PRIMARY KEY(no_employe_ak),
	CONSTRAINT fk_Employe_Habilitation FOREIGN KEY (no_habilitation_ak) REFERENCES Habilitation (no_habilitation_ak)
 );

-- Table de fait représentant l'ajout d'une prescription
CREATE TABLE Nouvelle_prescription_fact (
	no_employe_ak NUMBER, 
	no_prescription_ak NUMBER,

	CONSTRAINT pk_Prescription_fact PRIMARY KEY(no_employe_ak,no_prescription_ak),
	CONSTRAINT fk_Prescription_fact FOREIGN KEY (no_prescription_ak) REFERENCES Prescription (no_prescription_ak),
	CONSTRAINT fk_Prescription_fact_employe FOREIGN KEY (no_employe_ak) REFERENCES Employe (no_employe_ak)
 );

-- Table de fait représentant l'affectation d'un employé à une prescription
CREATE TABLE Planification_presc_fact (
	no_employe_ak NUMBER,
	no_plage_horaire_ak NUMBER,
	no_prescription_ak NUMBER,

	CONSTRAINT pk_Planification_presc_fact PRIMARY KEY(no_employe_ak,no_prescription_ak,no_plage_horaire_ak),
	CONSTRAINT fk_Planification_presc_fact FOREIGN KEY (no_prescription_ak) REFERENCES Prescription (no_prescription_ak),
	CONSTRAINT fk_Planification_presc_employe FOREIGN KEY (no_employe_ak) REFERENCES Employe (no_employe_ak),
	CONSTRAINT fk_Planification_presc_horaire FOREIGN KEY (no_plage_horaire_ak) REFERENCES Plage_horaire (no_plage_horaire_ak)
 );

-- Table de fait représentant le fait qu'un employé ait bien administré une prescription
CREATE TABLE Prescription_admin_fact (
	no_employe_ak NUMBER,
	no_plage_horaire_ak NUMBER,
	no_prescription_ak NUMBER,

	CONSTRAINT pk_Prescription_admin_fact PRIMARY KEY(no_employe_ak,no_prescription_ak,no_plage_horaire_ak),
	CONSTRAINT fk_administree_presc_fact FOREIGN KEY (no_prescription_ak) REFERENCES Prescription (no_prescription_ak),
	CONSTRAINT fk_admin_presc_employe FOREIGN KEY (no_employe_ak) REFERENCES Employe (no_employe_ak),
	CONSTRAINT fk_admin_presc_horaire FOREIGN KEY (no_plage_horaire_ak) REFERENCES Plage_horaire (no_plage_horaire_ak)
 );

-- Table de fait représentant le fait qu'un employé ne fera pas finalement la prescription qui lui avait affecté
CREATE TABLE Annuler_planing_presc_fact (
	no_employe_ak NUMBER,
	no_plage_horaire_ak NUMBER,
	no_prescription_ak NUMBER,

	CONSTRAINT pk_Annuler_planing_presc_fact PRIMARY KEY(no_employe_ak,no_prescription_ak,no_plage_horaire_ak),
	CONSTRAINT fk_annuler_planning_presc_fact FOREIGN KEY (no_prescription_ak) REFERENCES Prescription (no_prescription_ak),
	CONSTRAINT fk_annuler_plan_presc_employe FOREIGN KEY (no_employe_ak) REFERENCES Employe (no_employe_ak),
	CONSTRAINT fk_annuler_plan_presc_horaire FOREIGN KEY (no_plage_horaire_ak) REFERENCES Plage_horaire (no_plage_horaire_ak)
 );

 -- Table de fait HOSPITALISATION_SEJOUR_ADMISSION_FACT
 CREATE TABLE HOSPI_SEJOUR_ADMISSION_FACT(	
	NO_DOSSIER_AK NUMBER,  
	NO_SEJOUR_AK NUMBER,
	NO_LIEUX_AK NUMBER,
	DATE_DEPART DATE NOT NULL,

	CONSTRAINT pk_HOSPI_SEJOUR_ADMISSION_FACT PRIMARY KEY(NO_DOSSIER_AK, NO_SEJOUR_AK, NO_LIEUX_AK),
	CONSTRAINT SEJOUR_ADMISSION_DOSSIER FOREIGN KEY (NO_DOSSIER_AK) REFERENCES DOSSIER_PATIENT (NO_DOSSIER_AK),
	CONSTRAINT SEJOUR_ADMISSION_SEJOUR FOREIGN KEY (NO_SEJOUR_AK) REFERENCES SEJOUR (NO_SEJOUR_AK),
	CONSTRAINT SEJOUR_ADMISSION_LIEUX FOREIGN KEY (NO_LIEUX_AK) REFERENCES LIEUX (NO_LIEUX_AK)
);


-- Table de fait HOSPITALISATION_SEJOUR_CONGE_FACT
 CREATE TABLE HOSPI_SEJOUR_CONGE_FACT (	
	NO_DOSSIER_AK NUMBER,  
	NO_SEJOUR_AK NUMBER,
	DATE_DEBUT DATE NOT NULL,

	CONSTRAINT pk_HOSPI_SEJOUR_CONGE_FACT PRIMARY KEY(NO_DOSSIER_AK, NO_SEJOUR_AK),
	CONSTRAINT SEJOUR_FIN_DOSSIER FOREIGN KEY (NO_DOSSIER_AK) REFERENCES DOSSIER_PATIENT (NO_DOSSIER_AK),
	CONSTRAINT SEJOUR_FIN_SEJOUR FOREIGN KEY (NO_SEJOUR_AK) REFERENCES SEJOUR (NO_SEJOUR_AK)
);

-- Table de fait MEDECIN_TRAITANT_DEBUT_FACT
 CREATE TABLE MEDECIN_TRAIT_DEBUT_FACT (	
	NO_SEJOUR_AK NUMBER,
	NO_EMPLOYE_AK NUMBER,
	DATE_DEBUT DATE NOT NULL,

	CONSTRAINT pk_MEDECIN_TRAIT_DEBUT_FACT PRIMARY KEY(NO_SEJOUR_AK, NO_EMPLOYE_AK),
	CONSTRAINT MEDECIN_TRAIT_SEJOUR FOREIGN KEY (NO_SEJOUR_AK) REFERENCES SEJOUR (NO_SEJOUR_AK),
	CONSTRAINT MEDECIN_TRAIT_EMPLOYE FOREIGN KEY (NO_EMPLOYE_AK) REFERENCES EMPLOYE (NO_EMPLOYE_AK)
);

-- Table de fait MEDECIN_TRAITANT_FIN_FACT
CREATE TABLE MEDECIN_TRAIT_FIN_FACT (	
	NO_SEJOUR_AK NUMBER,
	NO_EMPLOYE_AK NUMBER,
	DATE_FIN DATE NOT NULL,

	CONSTRAINT pk_MEDECIN_TRAIT_FIN_FACT PRIMARY KEY(NO_SEJOUR_AK, NO_EMPLOYE_AK),
	CONSTRAINT MEDECIN_TRAIT_F_SEJOUR FOREIGN KEY (NO_SEJOUR_AK) REFERENCES SEJOUR (NO_SEJOUR_AK),
	CONSTRAINT MEDECIN_TRAIT_F_EMPLOYE FOREIGN KEY (NO_EMPLOYE_AK) REFERENCES EMPLOYE (NO_EMPLOYE_AK)
); 

-- Table de fait HORAIRE_EFFECTIVE_FACT 
CREATE TABLE HORAIRE_EFFECTIF_FACT (	
	NO_EMPLOYE_AK NUMBER,
	NO_LIEUX_AK NOT NULL, 
	NO_PLAGE_HORAIRE_AK NUMBER NOT NULL,

	CONSTRAINT PK_HORAIRE_EFFECTIF_FQCT PRIMARY KEY(NO_EMPLOYE_AK,NO_LIEUX_AK,NO_PLAGE_HORAIRE_AK),
	CONSTRAINT FK_HORAIRE_EFFECTIF_FQCT_EMP FOREIGN KEY(NO_EMPLOYE_AK) REFERENCES EMPLOYE(NO_EMPLOYE_AK),
	CONSTRAINT FK_HORAIRE_EFFECTIF_FQCT_LIEU FOREIGN KEY(NO_LIEUX_AK) REFERENCES LIEUX(NO_LIEUX_AK),
	CONSTRAINT FK_HORAIRE_EFFECTIF_FQCT_PH FOREIGN KEY(NO_PLAGE_HORAIRE_AK) REFERENCES PLAGE_HORAIRE(NO_PLAGE_HORAIRE_AK)
);

-- Table de fait PLANIFICATION_HORAIRE_FACT 
CREATE TABLE PLAN_HOR_EFF_FACT (	
	NO_EMPLOYE_AK NUMBER NOT NULL ,
	NO_LIEUX_AK NUMBER NOT NULL,
	NO_PLAGE_HORAIRE_AK NUMBER NOT NULL,

	CONSTRAINT PK_PLAN_HOR_EFF_FACT PRIMARY KEY(NO_EMPLOYE_AK,NO_LIEUX_AK,NO_PLAGE_HORAIRE_AK),
	CONSTRAINT FK_PLAN_HOR_EFF_FACT_EMP FOREIGN KEY(NO_EMPLOYE_AK) REFERENCES EMPLOYE(NO_EMPLOYE_AK),
	CONSTRAINT FK_PLAN_HOR_EFF_FACT_LIEU FOREIGN KEY(NO_LIEUX_AK) REFERENCES LIEUX(NO_LIEUX_AK),
	CONSTRAINT FK_PLAN_HOR_EFF_FACT_PH FOREIGN KEY(NO_PLAGE_HORAIRE_AK) REFERENCES PLAGE_HORAIRE(NO_PLAGE_HORAIRE_AK)
);

-- Table de fait ANNULATION_PLANIFICATION_HORAIRE_FACT 
CREATE TABLE ANNUL_PLAN_HOR_EFF_FACT (	
	NO_EMPLOYE_AK NUMBER NOT NULL ,
	NO_LIEUX_AK NUMBER NOT NULL,
	NO_PLAGE_HORAIRE_AK NUMBER NOT NULL,

	CONSTRAINT PK_ANNUL_PLAN_HOR_EFF PRIMARY KEY(NO_EMPLOYE_AK,NO_LIEUX_AK,NO_PLAGE_HORAIRE_AK),
	CONSTRAINT FK_ANNUL_PLAN_HOR_EFF_EMP FOREIGN KEY(NO_EMPLOYE_AK) REFERENCES EMPLOYE(NO_EMPLOYE_AK),
	CONSTRAINT FK_ANNUL_PLAN_HOR_EFF_LIEU FOREIGN KEY(NO_LIEUX_AK) REFERENCES LIEUX(NO_LIEUX_AK),
	CONSTRAINT FK_ANNUL_PLAN_HOR_EFF_PH FOREIGN KEY(NO_PLAGE_HORAIRE_AK) REFERENCES PLAGE_HORAIRE(NO_PLAGE_HORAIRE_AK)
);


/* 
 *	Création des auto-incrément pour l'insertion automatique des clés artificielles
*/
CREATE SEQUENCE seq_dossier START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_LIEUX START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE SEQ_PLAGE_HORAIRE START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_sejour START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_employe START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_habilitation START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_medicament START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_prescription START WITH 1 INCREMENT BY 1;

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
-- fin de ige487_dim.sql
-- =========================================================================== Z
*/