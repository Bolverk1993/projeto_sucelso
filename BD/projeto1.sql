create database projeto1;
use projeto1;
 
 -- Tabela para gerenciamento dos coordenadores
 create table coordenadores(coordenador_id int auto_increment primary key,
nome_coordenador varchar(70) not null,
telefone_coordenador varchar(15) not null,
celular_coordenador varchar(15),
email_coordenador varchar(255) not null,
codigo int
 );
 -- dado para ser executado junto com a criação da table
 insert into coordenadores (nome_coordenador, telefone_coordenador, celular_coordenador, email_coordenador, codigo)
values ('ADM_TI', '----------', '----------', 'ADM_TI@senaisucelso.com', 91118);



-- Tabela para gerenciamento dos docentes
create table docentes(docente_id int auto_increment primary key,
nome_docente varchar(70) not null,
telefone_docente varchar(15) not null,
celular_docente varchar(15),
email_docente varchar(255) not null,
area varchar(30)
 );

 -- Tabela para gerenciamento das turmas
 create table turmas(turma_id int auto_increment primary key,
  nome_turma varchar(70),
 curso varchar(30),
 periodo varchar(15)
 );
 
 -- Tabela para gerenciamento horarios de aula 
 create table horarios_docentes(hora_doc_id int auto_increment primary key,
 docente_id_fk int,
 turma_id_fk int,
 dia_semana enum ('Domingo','Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado') not null,
 hora_inicio time,
 hora_fim time,
 foreign key (docente_id_fk) references docentes(docente_id),
 foreign key ( turma_id_fk) references turmas( turma_id)
 );
 
-- Tabela para gerenciamento de login e senha com nível de acesso
create table usuarios (usuarios_id int auto_increment primary key,
usuario varchar(50) unique not null,
senha varchar(255) not null,
nivel_acesso enum ('coordenador','professor','TI') not null,
docente_id_fk int,
coordenador_id_fk int,
foreign key (docente_id_fk) references docentes(docente_id),
foreign key (coordenador_id_fk) references coordenadores(coordenador_id)
);
 -- dado para ser executado junto com a criação da table
 insert into usuarios (usuario, senha, nivel_acesso, docente_id_fk, coordenador_id_fk)
values ('ADM_TI', sha2('senha456', 256), 'TI', null, 1);
 
 -- TRIGGER
 
 -- impedir de apagar logins da TI
 DELIMITER //

CREATE TRIGGER prevent_ti_user_delete
BEFORE DELETE ON usuarios
FOR EACH ROW
BEGIN
    IF OLD.nivel_acesso = 'TI' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Não é permitido excluir usuários com nível de acesso TI';
    END IF;
END//

DELIMITER ;

 -- impedir de apagar registro da TI
DELIMITER //

CREATE TRIGGER prevent_adm_ti_coordenador_delete
BEFORE DELETE ON coordenadores
FOR EACH ROW
BEGIN
    IF OLD.codigo = 91118 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Não é permitido excluir membro da TI ';
    END IF;
END//

DELIMITER ;

 -- INSERÇOES
 
 
 
 -- inserir coordenador
insert into coordenadores (nome_coordenador, telefone_coordenador, celular_coordenador, email_coordenador, codigo)
values ('Maria Clara','(71) 3333-4444','(71) 98888-7777','maria.clara@senai.com', 00000);

-- inserir docente
insert into docentes (nome_docente,telefone_docente, celular_docente, email_docente, area)
values ('Álvaro', '(71) 5555-4444', '(71) 96969-7777','alvarinhoo@senai.com','português');

-- inserir turma
insert into turmas (nome_turma, curso, periodo)
values ('turma b', 'ensino fundamental', 'tarde');

-- inserir horário
insert into horarios_docentes (docente_id_fk, turma_id_fk, dia_semana, hora_inicio, hora_fim)
values (1, 1, 'terça', '13:00:00', '14:50:00');

-- inserir usuário
insert into usuarios (usuario, senha, nivel_acesso, docente_id_fk, coordenador_id_fk)
values ('coord.maria', sha2('senha456', 256), 'coordenador', null, 2),
('prof.alvaro', sha2('senha852', 256), 'professor', 1, null);




-- ATUALIZAÇÃO DE REGISTROS


-- atualizar docente
update docentes
set area = 'literatura'
where docente_id = 1;

-- atualizar horário
update horarios_docentes
set hora_inicio = '13:30:00', hora_fim = '15:30:00'
where hora_doc_id = 1;

-- atualizar usuário
update usuarios
set senha = sha2('novaSenha789', 256)
where usuarios_id = 2;



-- APAGANDO



-- remover horário
delete from horarios_docentes
where hora_doc_id = 1;


 -- CONSULTAS
 
 
 -- horários de um dia
select * from horarios_docentes
where dia_semana = 'terça';

-- horários da semana
select * from horarios_docentes
where dia_semana in ('segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado')
order by field(dia_semana, 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado'), hora_inicio;

-- todas as turmas
select * from turmas
order by nome_turma;

-- turmas por curso
select * from turmas
where curso = 'ensino fundamental';

-- turmas por período
select * from turmas
where periodo = 'tarde';

-- docente com filtro de dia
select h.*, t.nome_turma 
from horarios_docentes h
join turmas t on h.turma_id_fk = t.turma_id
where h.docente_id_fk = 2 and h.dia_semana = 'terça'
order by h.hora_inicio;

-- turma com filtro de semana
select h.*, d.area as disciplina, d.nome_docente as professor
from horarios_docentes h
join docentes d on h.docente_id_fk = d.docente_id
where h.turma_id_fk = 2 and h.dia_semana in ('segunda', 'terça', 'quarta')
order by field(h.dia_semana, 'segunda', 'terça', 'quarta'), h.hora_inicio;

-- horário diário
select h.dia_semana, h.hora_inicio, h.hora_fim, d.area as disciplina, d.nome_docente as professor
from horarios_docentes h
join docentes d on h.docente_id_fk = d.docente_id
where h.turma_id_fk = 2 and h.dia_semana = 'sexta'
order by h.hora_inicio;

-- grade semanal
select h.dia_semana, h.hora_inicio, h.hora_fim, d.area as disciplina, d.nome_docente as professor
from horarios_docentes h
join docentes d on h.docente_id_fk = d.docente_id
where h.turma_id_fk = 2
order by field(h.dia_semana, 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado'), h.hora_inicio;

-- Relatório mensal para um docente específico
SELECT 
    CONCAT('Semana ', 
           WEEK(h.dia_semana, 1) - WEEK(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), 1) + 1) AS semana_mes,
    h.dia_semana,
    h.hora_inicio,
    h.hora_fim,
    t.nome_turma AS turma,
    t.curso,
    COUNT(*) OVER (PARTITION BY h.dia_semana) AS total_aulas_dia
FROM 
    horarios_docentes h
JOIN 
    turmas t ON h.turma_id_fk = t.turma_id
WHERE 
    h.docente_id_fk = 2
ORDER BY 
    semana_mes,
    FIELD(h.dia_semana, 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado'),
    h.hora_inicio;


-- RELATORIOS

-- docentes e horários
select d.nome_docente, d.area, h.dia_semana, h.hora_inicio, h.hora_fim, t.nome_turma as turma
from docentes d
left join horarios_docentes h on d.docente_id = h.docente_id_fk
left join turmas t on h.turma_id_fk = t.turma_id
order by d.nome_docente, h.dia_semana, h.hora_inicio;

-- turmas e professores
select t.nome_turma as turma, t.curso, t.periodo, 
       group_concat(distinct d.nome_docente separator ', ') as professores
from turmas t
join horarios_docentes h on t.turma_id = h.turma_id_fk
join docentes d on h.docente_id_fk = d.docente_id
group by t.turma_id;


 