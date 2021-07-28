CREATE DATABASE db_pacientes_covid19;

USE db_pacientes_covid19;

CREATE TABLE paciente (
	cpf VARCHAR (11) NOT NULL,
	nome VARCHAR(30) NOT NULL,
	nascimento DATE,
	sexo ENUM("M", "F" ),
	telefone VARCHAR(13),
	estado VARCHAR(2),
	cidade VARCHAR(50),
    sintomatico CHAR(1),-- flag para sintomas X ou ""
    obito CHAR (1), -- flag para morte
	PRIMARY KEY (cpf)
)DEFAULT CHARSET = utf8;


CREATE TABLE sintoma (
    codigo VARCHAR(10), -- padronizado por abreviação dos sistemas afetados como codigo seguido de um numero que indica qual o sintoma "exemplo CARDIO01=arritimia cardiaca"
    descricao VARCHAR(100), -- descrição do codigo de sintoma 
    PRIMARY KEY (codigo)
)DEFAULT CHARSET =utf8;


CREATE TABLE estado_saude (
    paciente VARCHAR(11),
    sintoma  VARCHAR(10),
    PRIMARY KEY (paciente, sintoma),
    FOREIGN KEY (paciente) REFERENCES paciente(cpf),
    FOREIGN KEY (sintoma) REFERENCES sintoma(codigo)
)DEFAULT CHARSET =utf8;


CREATE TABLE comorbidade (
	codigo VARCHAR(10),
	descrição VARCHAR(100),
	PRIMARY KEY (codigo)
)DEFAULT CHARSET =utf8;


CREATE TABLE paciente_comorbidade (
	comorbidade VARCHAR(10),
    paciente VARCHAR(11),
    PRIMARY KEY (paciente, comorbidade),
    FOREIGN KEY (comorbidade) REFERENCES comorbidade(codigo),
	FOREIGN KEY (paciente) REFERENCES paciente(cpf)
) DEFAULT CHARSET =utf8;
 
 
INSERT INTO paciente (cpf, nome, nascimento, sexo, telefone, estado, cidade, sintomatico, obito)
VALUES
('47230869862', 'Denys Gaspar','1940-11-23','M','13988391802','SP','Santos','X',''),
('47230869863', 'Rogerio Gaspar','1999-11-24','M','13988391802','SP','Santos','X',''),
('47230864874', 'Renata Mendes','1987-11-24','F','62995625878','GO','Goiânia','X','x'),
('52654879584', 'Maria Mari','1982-11-24','F','62998548795','GO','Goiânia','X',''),
('47230885498', 'Camilo Levis','1992-11-24','M','62915487878','GO','Goiânia','X','');
    
    
INSERT INTO sintoma (codigo, descricao)
VALUES
('CARDI01', 'Arritmia Cardiaca'),
('RESP01', 'Bronquite'),
('RESP02', 'Pneumonia'),
('DIGES01', 'Vômito'),
('TEMP01', 'febre moderada'),
('TEMP02', 'febre alta'),
('RESP03', 'Baixa dilatação de Oxigenio'),
('DIGES02', 'Vômito com sangue');
    
    
INSERT INTO comorbidade (codigo, descrição)
VALUES
('PESO01', 'Obesidade grau 1'),
('PESO02', 'Obesidade grau 2'),
('PESO03', 'Obesidade morbida'),
('CARDI02', 'hiper tenso'),
('METAB01', 'Diabets'),
('PULM01', 'asma');

INSERT INTO estado_saude (paciente, sintoma)
VALUES
('47230869862', 'DIGES01'),
('47230869862', 'RESP01'),
('47230869863', 'CARDI01'),
('47230869863', 'RESP02'),
('47230864874', 'CARDI01'),
('47230869862', 'RESP02'),
('47230885498', 'RESP01'),
('52654879584', 'RESP02');
    
INSERT INTO paciente_comorbidade (comorbidade, paciente)
VALUES
('PULM01', '47230869862'),
('CARDI02', '47230864874'),
('CARDI02', '52654879584'),
('PESO01', '47230869862'),
('PESO03', '47230864874'),
('PULM01', '52654879584'),
('PESO02', '47230885498'),
('PESO01', '52654879584');
    
    
CREATE VIEW view_paciente_sintoma AS -- busca de relação entre paciente e sintoma desejado " SELECT * FROM paciente_sintoma; "
SELECT paciente.cpf,
    paciente.nome,
    sintoma.codigo AS sintoma_codigo,
    sintoma.descricao AS sintoma_descricao
FROM
	paciente
    INNER JOIN estado_saude AS estado
		ON	paciente.cpf = estado.paciente
	INNER JOIN sintoma
		ON estado.sintoma = sintoma.codigo;
        
CREATE VIEW view_paciente_comorbidade AS
SELECT
	paciente.cpf,
	paciente.nome,
	comorbidade.codigo AS comorbidade_codigo,
	comorbidade.descrição AS comorbidade_descrição
FROM
	paciente
	INNER JOIN paciente_comorbidade AS pac_comorbidade
		ON paciente.cpf = pac_comorbidade.paciente
	INNER JOIN comorbidade
		ON pac_comorbidade.comorbidade = comorbidade.codigo;
        
CREATE VIEW view_paciente_sintoma_comorbidade AS -- busca de relação entre paciente e sintoma desejado "select * FROM paciente_sintoma_comorbidade; "
SELECT 
	paciente.cpf,
	paciente.nome,
	sintoma.codigo AS sintoma_codigo,
	sintoma.descricao AS sintoma_descricao,
	comorbidade.codigo AS comorbidade_codigo,
	comorbidade.descrição AS comorbidade_descrição
FROM
	paciente
    INNER JOIN estado_saude AS estado
		ON	paciente.cpf = estado.paciente
	INNER JOIN sintoma
		ON estado.sintoma = sintoma.codigo
	INNER JOIN paciente_comorbidade AS pac_comorbidade
		ON paciente.cpf = pac_comorbidade.paciente
	INNER JOIN comorbidade
		ON pac_comorbidade.comorbidade = comorbidade.codigo;

CREATE VIEW view_grupo_risco AS 
SELECT
	paciente.cpf, 
    paciente.nome
FROM
	paciente
    INNER JOIN paciente_comorbidade
		ON paciente.cpf = paciente_comorbidade.paciente
    INNER JOIN comorbidade
		ON paciente_comorbidade.comorbidade = comorbidade.codigo
WHERE 
	YEAR (FROM_DAYS(TO_DAYS(now()) - TO_DAYS(nascimento))) > 60 OR
    comorbidade.codigo IN ('PESO03', 'CADRI02', 'PULM01')
GROUP BY 
	paciente.cpf,
    paciente.nome;   
    
    select * from view_paciente_comorbidade;
    select * from view_grupo_risco;
    select * from view_paciente_sintoma;
    select*from view_paciente_comorbidade;